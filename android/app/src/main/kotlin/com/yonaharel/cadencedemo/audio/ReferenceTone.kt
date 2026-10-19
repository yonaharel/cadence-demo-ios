package com.yonaharel.cadencedemo.audio

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import com.yonaharel.cadencedemo.core.Note
import kotlin.concurrent.thread
import kotlin.math.PI
import kotlin.math.exp
import kotlin.math.min
import kotlin.math.sin

/**
 * Plays a string's note so you can tune by ear.
 * A plucked tone with overtones, not a pure sine: phone speakers barely reproduce a low string's fundamental,
 * but the ear hears the pitch from its harmonics.
 *
 * The speaker only runs while a note rings: a render thread starts on a tap and ends once the pluck has died away.
 */
class ReferenceTone {
    @Volatile
    var a4 = 440.0

    private val lock = Any()

    // Guarded by lock: the frequency to play, a count that restarts the pluck on every tap, and the render thread.
    private var frequency = 0.0
    private var count = 0
    private var renderer: Thread? = null
    private var closed = false

    fun play(midi: Int) {
        val f = Note(midi, a4).frequency
        synchronized(lock) {
            if (closed) return
            frequency = f
            count++
            if (renderer == null) renderer = thread(name = "ReferenceTone") { render() }
        }
    }

    fun release() {
        synchronized(lock) { closed = true }
    }

    private fun render() {
        val minimum = AudioTrack.getMinBufferSize(RATE, AudioFormat.CHANNEL_OUT_MONO, AudioFormat.ENCODING_PCM_FLOAT)
        val track = try {
            AudioTrack.Builder()
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build(),
                )
                .setAudioFormat(
                    AudioFormat.Builder()
                        .setSampleRate(RATE)
                        .setEncoding(AudioFormat.ENCODING_PCM_FLOAT)
                        .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                        .build(),
                )
                .setTransferMode(AudioTrack.MODE_STREAM)
                .setBufferSizeInBytes(maxOf(minimum, CHUNK * 4 * 2))
                .build()
                .also { it.play() }
        } catch (_: Exception) {
            synchronized(lock) { renderer = null }
            return
        }
        val chunk = FloatArray(CHUNK)
        var playing = -1
        var phase = 0.0
        var time = 0.0
        try {
            while (true) {
                val (f, c) = synchronized(lock) {
                    // Rung out, closed, or nothing new to play: hand back the speaker.
                    if (closed || (playing == count && time > RING)) {
                        renderer = null
                        return
                    }
                    frequency to count
                }
                if (c != playing) {
                    playing = c
                    phase = 0.0
                    time = 0.0
                }
                for (i in chunk.indices) {
                    val envelope = min(time / 0.005, 1.0) * exp(-time / 0.8) // 5 ms attack, rings ~2 s
                    var x = 0.0
                    for (h in 1..6) x += sin(phase * h) / h
                    chunk[i] = (0.45 * envelope * x).toFloat() // peaks below 0.9
                    phase = (phase + 2 * PI * f / RATE) % (2 * PI)
                    time += 1.0 / RATE
                }
                track.write(chunk, 0, chunk.size, AudioTrack.WRITE_BLOCKING)
            }
        } finally {
            track.stop()
            track.release()
        }
    }

    private companion object {
        const val RATE = 48_000
        const val CHUNK = 512

        /** Seconds until the pluck is inaudible (e^-6 ≈ 0.25%). */
        const val RING = 0.8 * 6
    }
}
