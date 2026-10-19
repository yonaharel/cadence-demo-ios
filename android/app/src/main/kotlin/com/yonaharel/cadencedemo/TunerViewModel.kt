package com.yonaharel.cadencedemo

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.yonaharel.cadencedemo.audio.PitchListener
import com.yonaharel.cadencedemo.audio.ReferenceTone
import com.yonaharel.cadencedemo.core.Tuning
import com.yonaharel.cadencedemo.core.minimumLevel
import com.yonaharel.cadencedemo.data.Settings
import com.yonaharel.cadencedemo.data.SettingsStore
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/** What the tuner screen and its settings show and do: the saved setup, the live reading, and playing a string. */
class TunerViewModel(application: Application, demoFrequency: Double = 0.0) : AndroidViewModel(application) {
    private val store = SettingsStore(application)
    private val listener = PitchListener(demoFrequency)
    private val tone = ReferenceTone()

    private val _settings = MutableStateFlow<Settings?>(null)

    /** The saved setup; null for the moment it takes to load. Changes show at once and are saved behind. */
    val settings: StateFlow<Settings?> = _settings.asStateFlow()

    // The live reading, passed through from the listener.
    val state: StateFlow<PitchListener.State> = listener.state
    val reading: StateFlow<PitchListener.Reading> = listener.reading
    val level: StateFlow<Float> = listener.level

    init {
        viewModelScope.launch {
            val saved = store.load()
            if (_settings.value == null) {
                _settings.value = saved
                apply(saved)
            }
        }
    }

    fun start() = listener.start(getApplication<Application>())

    fun stop() = listener.stop()

    fun play(string: Int) = tone.play(string)

    fun setTuning(tuning: Tuning) = update { it.copy(tuning = tuning) }

    fun setA4(a4: Int) = update { it.copy(a4 = a4.coerceIn(A4_RANGE)) }

    fun setSensitivity(sensitivity: Double) = update { it.copy(sensitivity = sensitivity.coerceIn(0.0, 1.0)) }

    override fun onCleared() {
        listener.stop()
        tone.release()
    }

    private fun update(change: (Settings) -> Settings) {
        val old = _settings.value ?: return
        val new = change(old)
        if (new == old) return
        _settings.value = new
        apply(new)
        viewModelScope.launch { store.save(new) }
    }

    /** Clamped so a corrupt saved value can't reach Note. */
    private fun apply(settings: Settings) {
        val a4 = settings.a4.coerceIn(A4_RANGE).toDouble()
        listener.a4 = a4
        tone.a4 = a4
        // Low enough for the tuning's lowest string at the current A4.
        listener.detectionFloor = settings.tuning.detectionFloor(a4)
        listener.sensitivity = settings.sensitivity.coerceIn(0.0, 1.0).toFloat()
    }

    companion object {
        val A4_RANGE = 415..466

        /** The mic level the tuner starts listening at, for the sensitivity meter. */
        fun listeningLevel(settings: Settings) = minimumLevel(settings.sensitivity.toFloat())
    }
}
