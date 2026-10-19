package com.yonaharel.cadencedemo.ui.components

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.hypot

/** A button that shrinks a little while pressed, so a tap feels physical. No ripple, like iOS. */
@Composable
fun Modifier.pressable(onClickLabel: String? = null, onClick: () -> Unit): Modifier {
    val source = remember { MutableInteractionSource() }
    val pressed by source.collectIsPressedAsState()
    val scale by animateFloatAsState(
        if (pressed) 0.94f else 1f,
        spring(dampingRatio = 0.6f, stiffness = Spring.StiffnessMedium),
        label = "press",
    )
    return graphicsLayer {
        scaleX = scale
        scaleY = scale
    }.clickable(source, indication = null, onClickLabel = onClickLabel, role = Role.Button, onClick = onClick)
}

/**
 * Selection that grows in: a tinted circle expands from the centre to fill [shape], and the border fades in as it lands.
 * Clips what follows to [shape].
 */
@Composable
fun Modifier.selectionHighlight(selected: Boolean, shape: Shape): Modifier {
    val color = MaterialTheme.colorScheme.primary
    val fill by animateFloatAsState(
        if (selected) 1f else 0f,
        if (selected) spring(dampingRatio = 0.8f, stiffness = Spring.StiffnessMediumLow) else tween(200),
        label = "fill",
    )
    val border by animateFloatAsState(
        if (selected) 1f else 0f,
        tween(if (selected) 150 else 200, delayMillis = if (selected) 200 else 0), // as the fill lands
        label = "border",
    )
    return clip(shape)
        .drawBehind { drawCircle(color.copy(alpha = 0.15f), radius = hypot(size.width, size.height) / 2 * fill) } // just covers the corners
        .border(2.dp, color.copy(alpha = border), shape)
}

/**
 * Springs a view in when it appears, a beat after the item before it, so a row fills in one item after another.
 * Wrap the row in `key(...)` to replay it, as the string buttons and tuning cards do on an instrument change.
 */
@Composable
fun Modifier.staggeredAppear(index: Int): Modifier {
    val scale = remember { Animatable(0.6f) }
    val opacity = remember { Animatable(0f) }
    LaunchedEffect(Unit) {
        delay(index * 50L)
        launch { opacity.animateTo(1f, spring(dampingRatio = 0.65f, stiffness = Spring.StiffnessMediumLow)) }
        scale.animateTo(1f, spring(dampingRatio = 0.65f, stiffness = Spring.StiffnessMediumLow))
    }
    return graphicsLayer {
        scaleX = scale.value
        scaleY = scale.value
        alpha = opacity.value.coerceIn(0f, 1f)
    }
}
