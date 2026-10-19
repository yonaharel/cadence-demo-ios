package com.yonaharel.cadencedemo.ui.tuner

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yonaharel.cadencedemo.audio.PitchListener
import com.yonaharel.cadencedemo.ui.theme.Tuner
import java.util.Locale
import kotlin.math.abs

/** The note, a cents needle, the history strip, and what to do about it. */
@Composable
fun Reading(reading: PitchListener.Reading, modifier: Modifier = Modifier) {
    val note = reading.note
    val hearing = reading.hearing
    val inTune = abs(note?.cents ?: 99.0) <= 5
    val advice = when {
        note == null || !hearing -> "Play a string"
        inTune -> "In tune"
        note.cents < 0 -> "Flat · tune up"
        else -> "Sharp · tune down"
    }
    val alpha by animateFloatAsState(if (hearing) 1f else 0.45f, tween(200), label = "hearing")
    Column(
        modifier.alpha(alpha).semantics(mergeDescendants = true) {},
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(28.dp),
    ) {
        Row {
            Text(note?.name ?: "–", Modifier.alignByBaseline(), fontSize = 120.sp, lineHeight = 120.sp, fontWeight = FontWeight.Bold)
            if (note != null) {
                Text(
                    "${note.octave}",
                    Modifier.alignByBaseline(),
                    fontSize = 36.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = Tuner.secondary,
                )
            }
        }
        Needle(if (hearing) note?.cents else null, inTune)
        History(reading.history)
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                advice,
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.SemiBold,
                color = if (hearing && inTune) Tuner.inTune else MaterialTheme.colorScheme.onSurface,
                textAlign = TextAlign.Center,
            )
            Spacer(Modifier.height(6.dp))
            Text(
                note?.let { String.format(Locale.getDefault(), "%.1f Hz · %+.0f ¢", it.frequency, it.cents) } ?: " ",
                style = MaterialTheme.typography.bodyLarge,
                color = Tuner.secondary,
            )
        }
    }
}
