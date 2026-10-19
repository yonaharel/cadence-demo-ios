package com.yonaharel.cadencedemo.ui.tuner

import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.unit.dp
import com.yonaharel.cadencedemo.ui.theme.Tuner

/** A scale from −50 to +50 cents with a needle; the centre band is in tune. */
@Composable
fun Needle(cents: Double?, inTune: Boolean, modifier: Modifier = Modifier) {
    val position by animateFloatAsState(
        (cents ?: 0.0).coerceIn(-50.0, 50.0).toFloat(),
        spring(dampingRatio = 0.8f, stiffness = Spring.StiffnessMediumLow),
        label = "needle",
    )
    val band = Tuner.inTune.copy(alpha = 0.25f)
    val tick = Tuner.secondary
    val needle = if (inTune) Tuner.inTune else Tuner.off
    Canvas(modifier.fillMaxWidth().height(72.dp)) {
        val inset = 6.dp.toPx()
        val x = { c: Float -> size.width / 2 + c / 50 * (size.width / 2 - inset) }
        val tall = 56.dp.toPx()
        val top = (size.height - tall) / 2
        drawRoundRect(band, Offset(x(-5f), top), Size(x(5f) - x(-5f), tall), CornerRadius(3.dp.toPx()))
        for (i in -5..5) {
            val h = (if (i == 0) 56 else if (i % 5 == 0) 36 else 22).dp.toPx()
            drawRect(
                tick.copy(alpha = if (i == 0) 0.9f else 0.4f),
                Offset(x(i * 10f) - 1.dp.toPx(), (size.height - h) / 2),
                Size(2.dp.toPx(), h),
            )
        }
        if (cents != null) {
            val w = 6.dp.toPx()
            drawRoundRect(needle, Offset(x(position) - w / 2, 0f), Size(w, size.height), CornerRadius(w / 2))
        }
    }
}
