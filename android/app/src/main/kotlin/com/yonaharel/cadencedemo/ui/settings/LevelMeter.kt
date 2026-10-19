package com.yonaharel.cadencedemo.ui.settings

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.unit.dp
import com.yonaharel.cadencedemo.ui.theme.Tuner
import kotlin.math.log10

/** The mic level on a log scale, with a line where the tuner starts listening. */
@Composable
fun LevelMeter(level: Float, threshold: Float, modifier: Modifier = Modifier) {
    val shown by animateFloatAsState(level, tween(80, easing = LinearEasing), label = "level")
    val hearing = level > threshold
    val track = Tuner.secondary.copy(alpha = 0.2f)
    val fill = if (hearing) Tuner.inTune else Tuner.secondary
    val line = MaterialTheme.colorScheme.onSurface
    Canvas(
        modifier
            .fillMaxWidth()
            .height(16.dp)
            .clearAndSetSemantics { contentDescription = if (hearing) "Mic level: hearing you" else "Mic level: too quiet to hear" },
    ) {
        val x = { v: Float -> size.width * ((log10(maxOf(v, 1e-4f)) + 3) / 2.5f).coerceIn(0f, 1f) } // 0.001 to ~0.3
        val bar = 8.dp.toPx()
        val top = (size.height - bar) / 2
        drawRoundRect(track, Offset(0f, top), Size(size.width, bar), CornerRadius(bar / 2))
        drawRoundRect(fill, Offset(0f, top), Size(x(shown), bar), CornerRadius(bar / 2))
        drawRect(line, Offset(x(threshold) - 1.dp.toPx(), 0f), Size(2.dp.toPx(), size.height))
    }
}
