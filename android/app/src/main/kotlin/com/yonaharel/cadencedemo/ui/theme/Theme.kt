package com.yonaharel.cadencedemo.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

/** Material You colours where the phone has them (Android 12+); the iOS app's blue before that. */
@Composable
fun TwangTheme(content: @Composable () -> Unit) {
    val dark = isSystemInDarkTheme()
    val context = LocalContext.current
    val colors = when {
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> if (dark) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        dark -> darkColorScheme(primary = Color(0xFF0A84FF), onPrimary = Color.White)
        else -> lightColorScheme(primary = Color(0xFF007AFF), onPrimary = Color.White)
    }
    MaterialTheme(colorScheme = colors, content = content)
}

/** The tuner's own colours, the same in every theme: green is in tune, orange is off. */
object Tuner {
    val inTune: Color
        @Composable
        get() = if (isSystemInDarkTheme()) Color(0xFF30D158) else Color(0xFF34C759)

    val off: Color
        @Composable
        get() = if (isSystemInDarkTheme()) Color(0xFFFF9F0A) else Color(0xFFFF9500)

    /** Like iOS's secondary label colour: text and marks that support the main reading. */
    val secondary: Color
        @Composable
        get() = MaterialTheme.colorScheme.onSurfaceVariant
}
