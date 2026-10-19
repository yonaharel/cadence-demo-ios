package com.yonaharel.cadencedemo

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.viewmodel.compose.viewModel
import com.yonaharel.cadencedemo.ui.TunerScreen
import com.yonaharel.cadencedemo.ui.theme.TwangTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        // Screenshots: `adb shell am start -n com.yonaharel.cadencedemo/.MainActivity --ef demoFrequency 108.9`
        // shows a fixed reading without the microphone.
        val demoFrequency = intent.getFloatExtra("demoFrequency", 0f).toDouble()
        setContent {
            TwangTheme {
                TunerScreen(viewModel { TunerViewModel(application, demoFrequency) })
            }
        }
    }
}
