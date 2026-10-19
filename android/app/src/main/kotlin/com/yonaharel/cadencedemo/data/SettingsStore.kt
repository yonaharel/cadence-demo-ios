package com.yonaharel.cadencedemo.data

import android.content.Context
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.doublePreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.yonaharel.cadencedemo.core.Tuning
import kotlinx.coroutines.flow.first

/** The saved setup. */
data class Settings(
    val tuning: Tuning = Tuning.STANDARD,
    /** The reference pitch, 415..466 Hz. */
    val a4: Int = 440,
    /** 0 (loud room) to 1 (quiet strings). */
    val sensitivity: Double = 0.7,
)

private val Context.dataStore by preferencesDataStore("settings")

/** Saves [Settings] under the same keys as the iOS app: `tuning`, `a4` and `sensitivity`. */
class SettingsStore(context: Context) {
    private val store = context.applicationContext.dataStore

    suspend fun load(): Settings = store.data.first().let { p ->
        Settings(
            tuning = Tuning.fromKey(p[TUNING]) ?: Tuning.STANDARD,
            a4 = p[A4] ?: 440,
            sensitivity = p[SENSITIVITY] ?: 0.7,
        )
    }

    suspend fun save(settings: Settings) {
        store.edit {
            it[TUNING] = settings.tuning.key
            it[A4] = settings.a4
            it[SENSITIVITY] = settings.sensitivity
        }
    }

    private companion object {
        val TUNING: Preferences.Key<String> = stringPreferencesKey("tuning")
        val A4: Preferences.Key<Int> = intPreferencesKey("a4")
        val SENSITIVITY: Preferences.Key<Double> = doublePreferencesKey("sensitivity")
    }
}
