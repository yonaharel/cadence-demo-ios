package com.yonaharel.cadencedemo.ui.settings

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animate
import androidx.compose.animation.core.spring
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.gestures.draggable
import androidx.compose.foundation.gestures.rememberDraggableState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.CustomAccessibilityAction
import androidx.compose.ui.semantics.ProgressBarRangeInfo
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.customActions
import androidx.compose.ui.semantics.progressBarRangeInfo
import androidx.compose.ui.semantics.setProgress
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.dp
import com.yonaharel.cadencedemo.R
import com.yonaharel.cadencedemo.TunerViewModel
import com.yonaharel.cadencedemo.ui.theme.Tuner
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.launch
import kotlin.math.abs
import kotlin.math.roundToInt

/** A ruler you drag to set A4, snapping to each hertz; 432 and 442 are dotted. Double-tap the value for 440. */
@Composable
fun A4Ruler(a4: Int, onChange: (Int) -> Unit, modifier: Modifier = Modifier) {
    val range = TunerViewModel.A4_RANGE
    val haptics = LocalHapticFeedback.current
    val current by rememberUpdatedState(a4)
    val change by rememberUpdatedState(onChange)
    val stepPx = with(LocalDensity.current) { 12.dp.toPx() }
    // The hertz under the centre line, fractional while dragging or settling.
    var position by remember { mutableFloatStateOf(a4.toFloat()) }
    val scope = rememberCoroutineScope()
    var settling by remember { mutableStateOf<Job?>(null) }
    fun settle(target: Int, velocity: Float = 0f) {
        settling?.cancel()
        settling = scope.launch {
            animate(position, target.toFloat(), velocity, spring(dampingRatio = 1f, stiffness = Spring.StiffnessLow)) { v, _ -> position = v }
        }
    }

    // The ruler sets A4 as it passes each hertz...
    LaunchedEffect(Unit) {
        snapshotFlow { position.roundToInt().coerceIn(range) }.collect { if (it != current) change(it) }
    }
    // ...and follows A4 when it changes some other way (reset, accessibility).
    LaunchedEffect(a4) { if (position.roundToInt() != a4) settle(a4) }
    LaunchedEffect(Unit) { snapshotFlow { current }.drop(1).collect { haptics.performHapticFeedback(HapticFeedbackType.SegmentFrequentTick) } }

    val drag = rememberDraggableState { delta ->
        settling?.cancel()
        position = (position - delta / stepPx).coerceIn(range.first.toFloat(), range.last.toFloat())
    }
    val measurer = rememberTextMeasurer()
    val labelStyle = MaterialTheme.typography.labelSmall
    val tick = Tuner.secondary
    val accent = MaterialTheme.colorScheme.primary

    Column(
        modifier
            .fillMaxWidth()
            .clearAndSetSemantics {
                contentDescription = "Reference pitch"
                stateDescription = "A4 $a4 hertz"
                progressBarRangeInfo = ProgressBarRangeInfo(a4.toFloat(), range.first.toFloat()..range.last.toFloat(), range.last - range.first - 1)
                setProgress { value ->
                    change(value.roundToInt().coerceIn(range))
                    true
                }
                customActions = listOf(CustomAccessibilityAction("Reset to 440") { change(440); true })
            },
        verticalArrangement = Arrangement.spacedBy(6.dp),
    ) {
        Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
            Text(
                "$a4 Hz",
                Modifier.pointerInput(Unit) { detectTapGestures(onDoubleTap = { change(440) }) },
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.SemiBold,
            )
            // Beside the value, so the number stays centred over the ruler.
            ResetButton(a4 != 440, { change(440) }, Modifier.align(Alignment.CenterEnd))
        }
        Canvas(
            Modifier
                .fillMaxWidth()
                .height(46.dp)
                .draggable(
                    drag,
                    Orientation.Horizontal,
                    onDragStopped = { velocity ->
                        // Glide a little with the fling, then snap to the nearest hertz.
                        val target = (position - velocity / stepPx * 0.2f).roundToInt().coerceIn(range)
                        settle(target, -velocity / stepPx)
                    },
                ),
        ) {
            val centre = size.width / 2
            for (hz in range) {
                val x = centre + (hz - position) * stepPx
                if (x < -stepPx * 2 || x > size.width + stepPx * 2) continue
                val fade = (1 - abs(x - centre) / centre).coerceIn(0f, 1f) // the ends fade out
                val major = hz % 10 == 0
                drawLine(
                    tick.copy(alpha = (if (major) 0.8f else 0.4f) * fade),
                    Offset(x, 0f),
                    Offset(x, (if (major) 20 else 12).dp.toPx()),
                    1.5.dp.toPx(),
                    StrokeCap.Round,
                )
                if (hz == 432 || hz == 442) drawCircle(tick.copy(alpha = fade), 2.dp.toPx(), Offset(x, 25.dp.toPx()))
                if (major) {
                    val label = measurer.measure("$hz", labelStyle)
                    drawText(label, tick, Offset(x - label.size.width / 2f, 30.dp.toPx()), alpha = fade)
                }
            }
            drawLine(accent, Offset(centre, 0f), Offset(centre, 23.dp.toPx()), 3.dp.toPx(), StrokeCap.Round)
        }
    }
}

@Composable
private fun ResetButton(visible: Boolean, reset: () -> Unit, modifier: Modifier = Modifier) {
    AnimatedVisibility(visible, modifier, enter = scaleIn() + fadeIn(), exit = scaleOut() + fadeOut()) {
        FilledTonalButton(onClick = reset, contentPadding = PaddingValues(horizontal = 12.dp)) {
            Icon(painterResource(R.drawable.ic_reset), contentDescription = null, Modifier.size(16.dp))
            Spacer(Modifier.width(4.dp))
            Text("440", style = MaterialTheme.typography.labelLarge)
        }
    }
}
