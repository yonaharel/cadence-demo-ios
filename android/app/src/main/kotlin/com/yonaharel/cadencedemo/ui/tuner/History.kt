package com.yonaharel.cadencedemo.ui.tuner

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import com.yonaharel.cadencedemo.audio.PitchListener
import com.yonaharel.cadencedemo.ui.theme.Tuner

/** The last few seconds of cents, newest at the right; gaps where nothing confident was heard. */
@Composable
fun History(cents: List<Double?>, modifier: Modifier = Modifier) {
    val band = Tuner.inTune.copy(alpha = 0.25f)
    val axis = Tuner.secondary.copy(alpha = 0.4f)
    val color = MaterialTheme.colorScheme.primary
    Canvas(modifier.fillMaxWidth().height(56.dp)) {
        val y = { c: Double -> (size.height / 2 - c.coerceIn(-50.0, 50.0) / 50 * (size.height / 2)).toFloat() }
        drawRect(band, Offset(0f, y(5.0)), Size(size.width, y(-5.0) - y(5.0)))
        drawLine(axis, Offset(0f, y(0.0)), Offset(size.width, y(0.0)), 1.dp.toPx())
        val length = PitchListener.HISTORY_LENGTH
        val line = Path()
        var gap = true
        cents.forEachIndexed { i, c ->
            if (c == null) {
                gap = true
                return@forEachIndexed
            }
            val px = size.width * (i + 1 + length - cents.size) / length
            if (gap) line.moveTo(px, y(c)) // a lone point draws as a dot
            line.lineTo(px, y(c))
            gap = false
        }
        drawPath(line, color, style = Stroke(2.dp.toPx(), cap = StrokeCap.Round, join = StrokeJoin.Round))
    }
}
