package com.yonaharel.cadencedemo.ui.tuner

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.yonaharel.cadencedemo.R
import com.yonaharel.cadencedemo.ui.theme.Tuner

@Composable
fun Unavailable(message: String, action: String?, perform: () -> Unit, modifier: Modifier = Modifier) {
    Column(modifier, horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Icon(painterResource(R.drawable.ic_mic_off), contentDescription = null, Modifier.size(48.dp), tint = Tuner.secondary)
        Text(message, textAlign = TextAlign.Center)
        if (action != null) Button(onClick = perform) { Text(action) }
    }
}
