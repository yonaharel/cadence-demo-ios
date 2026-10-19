package com.yonaharel.cadencedemo.ui

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings as SystemSettings
import androidx.activity.compose.LocalActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.compose.LifecycleStartEffect
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.yonaharel.cadencedemo.BuildConfig
import com.yonaharel.cadencedemo.R
import com.yonaharel.cadencedemo.TunerViewModel
import com.yonaharel.cadencedemo.audio.PitchListener
import com.yonaharel.cadencedemo.ui.settings.SettingsSheet
import com.yonaharel.cadencedemo.ui.theme.Tuner
import com.yonaharel.cadencedemo.ui.tuner.Reading
import com.yonaharel.cadencedemo.ui.tuner.Strings
import com.yonaharel.cadencedemo.ui.tuner.Unavailable

/** The tuner: your setup at the top, the strings, and the reading. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TunerScreen(model: TunerViewModel) {
    val settings = model.settings.collectAsStateWithLifecycle().value
    val state by model.state.collectAsStateWithLifecycle()
    val reading by model.reading.collectAsStateWithLifecycle()
    var settingsOpen by rememberSaveable { mutableStateOf(false) }
    val context = LocalContext.current
    val activity = LocalActivity.current

    // start() reports Denied by itself when the answer was no.
    val askForMic = rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission()) { model.start() }
    // Listen only while the app is on screen.
    LifecycleStartEffect(Unit) {
        val granted = ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED
        if (granted || model.state.value == PitchListener.State.Denied) model.start() else askForMic.launch(Manifest.permission.RECORD_AUDIO)
        onStopOrDispose { model.stop() }
    }

    Surface(Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
        if (settings == null) return@Surface // loading, for a moment
        Column(
            Modifier.fillMaxSize().safeDrawingPadding().padding(horizontal = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            FilledTonalButton(
                onClick = { settingsOpen = true },
                modifier = Modifier
                    .padding(top = 8.dp)
                    .semantics { contentDescription = "Settings: ${settings.tuning.description}, A4 ${settings.a4} hertz" },
            ) {
                Icon(painterResource(R.drawable.ic_tune), contentDescription = null, Modifier.size(18.dp))
                Spacer(Modifier.width(8.dp))
                Text("${settings.tuning.description} · A4 ${settings.a4}")
            }
            Strings(
                settings.tuning,
                // The string being tuned, while one is ringing.
                active = if (reading.hearing) reading.note?.nearestString(settings.tuning) else null,
                play = model::play,
                modifier = Modifier.padding(top = 12.dp),
            )
            Spacer(Modifier.weight(1f))
            when (val s = state) {
                PitchListener.State.Denied -> {
                    // Android asks twice; after that only system settings can grant the mic.
                    val canAsk = activity?.let { ActivityCompat.shouldShowRequestPermissionRationale(it, Manifest.permission.RECORD_AUDIO) } == true
                    Unavailable(
                        "Twang needs the microphone to hear your instrument.",
                        action = if (canAsk) "Allow microphone" else "Open Settings",
                        perform = {
                            if (canAsk) {
                                askForMic.launch(Manifest.permission.RECORD_AUDIO)
                            } else {
                                context.startActivity(
                                    Intent(SystemSettings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", context.packageName, null)),
                                )
                            }
                        },
                    )
                }
                is PitchListener.State.Failed -> Unavailable("The microphone couldn't start: ${s.reason}", action = null, perform = {})
                else -> Reading(reading)
            }
            Spacer(Modifier.weight(1f))
            Text(
                "Version ${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})",
                Modifier.padding(bottom = 8.dp),
                style = MaterialTheme.typography.bodySmall,
                color = Tuner.secondary,
            )
        }
        if (settingsOpen) {
            val level by model.level.collectAsStateWithLifecycle()
            ModalBottomSheet(onDismissRequest = { settingsOpen = false }) { SettingsSheet(settings, level, model) }
        }
    }
}
