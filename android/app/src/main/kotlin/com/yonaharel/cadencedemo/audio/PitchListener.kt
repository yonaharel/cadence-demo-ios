package com.yonaharel.cadencedemo.audio

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper
import androidx.core.content.ContextCompat
import com.yonaharel.cadencedemo.core.BandPass
import com.yonaharel.cadencedemo.core.Note
import com.yonaharel.cadencedemo.core.Smoother
import com.yonaharel.cadencedemo.core.detectPitch
import com.yonaharel.cadencedemo.core.rms
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.concurrent.thread

/**
 * Listens to the microphone and reports the note being played. Audio is analysed on the device and never stored.
 * Call everything on the main thread; the microphone is read on a background thread of its own.
 *
 * @param demoFrequency above 0, a fixed reading without the microphone, for screenshots.
 */
class PitchListener(private val demoFrequency: Double = 0.0) {
    sealed interface State {
        data object Idle : State
        data object Listening : State
        data object Denied : State
        data class Failed(val reason: String) : State
    }

    data class Reading(
        val note: Note? = null,
        /** False once the string has rung out; the last note stays on screen, dimmed. */
        val hearing: Boolean = false,
        /** Cents per buffer, oldest first; null where nothing confident was heard. */
        val history: List<Double?> = emptyList(),
    )

    private val _state = MutableStateFlow<State>(State.Idle)
    val state: StateFlow<State> = _state.asStateFlow()
    private val _reading = MutableStateFlow(Reading())
    val reading: StateFlow<Reading> = _reading.asStateFlow()
    private val _level = MutableStateFlow(0f)

    /** How loud the mic is (RMS after filtering), for the sensitivity meter. */
    val level: StateFlow<Float> = _level.asStateFlow()

    var a4 = 440.0
        set(value) {
            if (field == value) return
            field = value
            if (demo) return // demo keeps its fixed flat line
            // The note and trace were measured against the old A4.
            _reading.update { r -> r.copy(note = r.note?.let { Note(it.frequency, value) }, history = emptyList()) }
        }

    /** 0 (loud room) to 1 (quiet strings). Read by the audio thread. */
    @Volatile
    var sensitivity = 0.7f

    /** The lowest pitch listened for, in Hz; it follows the tuning (see `Tuning.detectionFloor`). Read by the audio thread. */
    @Volatile
    var detectionFloor = 60.0

    private class Recording(val record: AudioRecord, val running: AtomicBoolean, val thread: Thread)

    private val demo = demoFrequency > 0
    private val main = Handler(Looper.getMainLooper())
    private val smoother = Smoother()
    private var recording: Recording? = null
    private var quietFrames = 0

    /** Bumped on every start and stop, so readings still in flight from an old recording are dropped. */
    private var session = 0

    init {
        if (demo) {
            val note = Note(demoFrequency)
            _reading.value = Reading(note, hearing = true, history = List(HISTORY_LENGTH) { note.cents })
            _state.value = State.Listening
        }
    }

    /** Starts listening, if the microphone permission has been granted; otherwise reports [State.Denied]. */
    fun start(context: Context) {
        if (demo || recording != null) return
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            _state.value = State.Denied
            return
        }
        // The raw mic, without the automatic gain and noise suppression that colour a voice call (iOS uses .measurement).
        val audio = context.getSystemService(AudioManager::class.java)
        val unprocessed = audio?.getProperty(AudioManager.PROPERTY_SUPPORT_AUDIO_SOURCE_UNPROCESSED) == "true"
        val source = if (unprocessed) MediaRecorder.AudioSource.UNPROCESSED else MediaRecorder.AudioSource.VOICE_RECOGNITION
        val record = try {
            open(source)
        } catch (e: Exception) {
            _state.value = State.Failed(e.message ?: e.javaClass.simpleName)
            return
        }
        val running = AtomicBoolean(true)
        val id = ++session
        val reader = thread(name = "PitchListener") { analyse(record, running, id) }
        recording = Recording(record, running, reader)
        _state.value = State.Listening
    }

    @SuppressLint("MissingPermission") // start() checks it
    private fun open(source: Int): AudioRecord {
        val minimum = AudioRecord.getMinBufferSize(SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_FLOAT)
        check(minimum > 0) { "this device can't record 48 kHz audio" }
        val record = AudioRecord(source, SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_FLOAT, maxOf(minimum, BUFFER * 4 * 2))
        try {
            check(record.state == AudioRecord.STATE_INITIALIZED) { "the microphone is in use" }
            record.startRecording()
        } catch (e: Exception) {
            record.release()
            throw e
        }
        return record
    }

    fun stop() {
        if (demo) return
        val r = recording ?: return
        recording = null
        session++
        r.running.set(false)
        try {
            r.record.stop() // unblocks the reader
        } catch (_: IllegalStateException) {
        }
        r.thread.join(500)
        _state.value = State.Idle
        // Resume with a gap, not joined to the old trace.
        smoother.reset()
        quietFrames = 0
        _reading.update { it.copy(hearing = false, history = emptyList()) }
        _level.value = 0f
    }

    /** Mic to the main thread: 4096-sample buffers (~85 ms), filtered, then YIN. Runs on the reader thread. */
    private fun analyse(record: AudioRecord, running: AtomicBoolean, id: Int) {
        val filter = BandPass(SAMPLE_RATE.toDouble()) // one per recording; keeps its state across buffers
        val samples = FloatArray(BUFFER)
        try {
            while (running.get()) {
                var filled = 0
                while (filled < BUFFER && running.get()) {
                    val n = record.read(samples, filled, BUFFER - filled, AudioRecord.READ_BLOCKING)
                    if (n < 0) {
                        if (running.get()) main.post { if (id == session) _state.value = State.Failed("the microphone stopped ($n)") }
                        return
                    }
                    filled += n
                }
                if (filled < BUFFER) return
                filter.process(samples)
                val pitch = detectPitch(samples, SAMPLE_RATE.toDouble(), detectionFloor..1200.0, sensitivity)
                val level = rms(samples)
                main.post { if (id == session) heard(pitch, level) }
            }
        } finally {
            record.release()
        }
    }

    private fun heard(pitch: Double?, level: Float) {
        _level.value = level
        if (pitch == null) {
            record(null)
            quietFrames++
            if (quietFrames > 10) {
                _reading.update { it.copy(hearing = false) }
                smoother.reset()
            }
            return
        }
        quietFrames = 0
        _reading.update { it.copy(hearing = true) }
        val f = smoother.add(pitch)
        if (f == null) {
            record(null)
            return
        }
        val new = Note(f, a4)
        if (new.midi != _reading.value.note?.midi) _reading.update { it.copy(history = emptyList()) }
        record(new.cents)
        _reading.update { it.copy(note = new) }
    }

    // One entry per buffer, so the strip steps ~12×/s, as on iOS.
    private fun record(cents: Double?) {
        val history = _reading.value.history
        if (cents == null && history.none { it != null }) return // already blank; don't redraw
        _reading.update { it.copy(history = (history + cents).takeLast(HISTORY_LENGTH)) }
    }

    companion object {
        const val SAMPLE_RATE = 48_000
        private const val BUFFER = 4096
        const val HISTORY_LENGTH = 60 // ~5 s at 4096 samples / 48 kHz
    }
}
