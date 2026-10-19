package com.yonaharel.cadencedemo.ui.settings

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.yonaharel.cadencedemo.TunerViewModel
import com.yonaharel.cadencedemo.data.Settings
import com.yonaharel.cadencedemo.ui.theme.Tuner
import kotlin.math.roundToInt

/** Instrument, tuning, reference pitch and sensitivity, in a sheet the tuner keeps listening behind. */
@Composable
fun SettingsSheet(settings: Settings, level: Float, model: TunerViewModel, modifier: Modifier = Modifier) {
    Column(modifier.verticalScroll(rememberScrollState()).padding(bottom = 24.dp)) {
        Section("Instrument") { InstrumentPicker(settings.tuning, model::setTuning) }
        Section("Tuning") { TuningCards(settings.tuning, model::setTuning) }
        Section("Reference pitch", padded = true) { A4Ruler(settings.a4, model::setA4) }
        Section(
            "Sensitivity",
            footer = "Pluck a string: the bar should pass the line. Turn it down if the room keeps setting it off.",
            padded = true,
        ) {
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                LevelMeter(level, TunerViewModel.listeningLevel(settings))
                SensitivitySlider(settings.sensitivity, model::setSensitivity)
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("Loud room", style = MaterialTheme.typography.bodySmall, color = Tuner.secondary)
                    Text("Quiet strings", style = MaterialTheme.typography.bodySmall, color = Tuner.secondary)
                }
            }
        }
    }
}

@Composable
private fun SensitivitySlider(sensitivity: Double, onChange: (Double) -> Unit) {
    val haptics = LocalHapticFeedback.current
    var tick by remember { mutableIntStateOf((sensitivity * 10).roundToInt()) }
    Slider(
        value = sensitivity.toFloat(),
        onValueChange = {
            onChange(it.toDouble())
            // A light tick every 10% of travel, not on every pixel of the drag.
            val t = (it * 10).roundToInt()
            if (t != tick) {
                tick = t
                haptics.performHapticFeedback(HapticFeedbackType.SegmentFrequentTick)
            }
        },
        modifier = Modifier.semantics { contentDescription = "Sensitivity" },
    )
}

@Composable
private fun Section(title: String, footer: String? = null, padded: Boolean = false, content: @Composable () -> Unit) {
    Text(
        title,
        Modifier.padding(start = 32.dp, end = 32.dp, top = 16.dp, bottom = 6.dp),
        style = MaterialTheme.typography.labelLarge,
        color = Tuner.secondary,
    )
    Surface(
        Modifier.padding(horizontal = 16.dp).fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        color = MaterialTheme.colorScheme.surfaceContainerHighest,
    ) {
        Box(if (padded) Modifier.padding(16.dp) else Modifier) { content() }
    }
    if (footer != null) {
        Text(
            footer,
            Modifier.padding(start = 32.dp, end = 32.dp, top = 6.dp),
            style = MaterialTheme.typography.bodySmall,
            color = Tuner.secondary,
        )
    }
}
