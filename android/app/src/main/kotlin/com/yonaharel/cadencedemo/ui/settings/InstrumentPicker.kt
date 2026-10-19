package com.yonaharel.cadencedemo.ui.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.yonaharel.cadencedemo.core.Instrument
import com.yonaharel.cadencedemo.core.Tuning
import com.yonaharel.cadencedemo.ui.components.pressable
import com.yonaharel.cadencedemo.ui.components.selectionHighlight
import com.yonaharel.cadencedemo.ui.theme.Tuner

/** Instrument chips above the tuning cards. Picking another instrument switches to its standard tuning. */
@Composable
fun InstrumentPicker(tuning: Tuning, onChange: (Tuning) -> Unit, modifier: Modifier = Modifier) {
    val haptics = LocalHapticFeedback.current
    val state = rememberLazyListState(initialFirstVisibleItemIndex = maxOf(0, Instrument.entries.indexOf(tuning.instrument) - 1))
    LazyRow(modifier, state, contentPadding = PaddingValues(12.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        items(Instrument.entries) { instrument ->
            val selected = instrument == tuning.instrument
            val shape = RoundedCornerShape(50)
            Text(
                instrument.label,
                Modifier
                    .pressable {
                        if (!selected) {
                            onChange(instrument.tunings.first())
                            haptics.performHapticFeedback(HapticFeedbackType.SegmentTick)
                        }
                    }
                    .background(Tuner.secondary.copy(alpha = 0.1f), shape)
                    .selectionHighlight(selected, shape)
                    .padding(horizontal = 14.dp, vertical = 10.dp)
                    .semantics { this.selected = selected },
                style = MaterialTheme.typography.titleSmall,
                fontWeight = FontWeight.SemiBold,
                color = if (selected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface,
            )
        }
    }
}
