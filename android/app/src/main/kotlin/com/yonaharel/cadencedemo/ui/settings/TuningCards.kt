package com.yonaharel.cadencedemo.ui.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.key
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.onClick
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.yonaharel.cadencedemo.core.Note
import com.yonaharel.cadencedemo.core.Tuning
import com.yonaharel.cadencedemo.ui.components.pressable
import com.yonaharel.cadencedemo.ui.components.selectionHighlight
import com.yonaharel.cadencedemo.ui.components.staggeredAppear
import com.yonaharel.cadencedemo.ui.theme.Tuner

/** The current instrument's tunings as cards to swipe through; each shows its strings so you can see what you're picking. */
@Composable
fun TuningCards(tuning: Tuning, onChange: (Tuning) -> Unit, modifier: Modifier = Modifier) {
    val haptics = LocalHapticFeedback.current
    val pick = { t: Tuning ->
        if (t != tuning) {
            onChange(t)
            haptics.performHapticFeedback(HapticFeedbackType.SegmentTick)
        }
    }
    // A new instrument rebuilds the row from its start, and the cards spring in one after another.
    key(tuning.instrument) {
        val tunings = tuning.instrument.tunings
        val state = rememberLazyListState(initialFirstVisibleItemIndex = maxOf(0, tunings.indexOf(tuning) - 1))
        LazyRow(modifier, state, contentPadding = PaddingValues(12.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            itemsIndexed(tunings, key = { _, t -> t.key }) { index, t ->
                val selected = t == tuning
                val notes = t.strings.joinToString(" ") { Note(it).name }
                val shape = RoundedCornerShape(14.dp)
                Column(
                    Modifier
                        .staggeredAppear(index)
                        .pressable { pick(t) }
                        .background(Tuner.secondary.copy(alpha = 0.1f), shape)
                        .selectionHighlight(selected, shape)
                        .padding(horizontal = 12.dp, vertical = 8.dp)
                        .clearAndSetSemantics {
                            contentDescription = "${t.label}, $notes"
                            this.selected = selected
                            role = Role.Button
                            onClick {
                                pick(t)
                                true
                            }
                        },
                    verticalArrangement = Arrangement.spacedBy(2.dp),
                ) {
                    Text(
                        t.label,
                        style = MaterialTheme.typography.titleSmall,
                        fontWeight = FontWeight.SemiBold,
                        color = if (selected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface,
                    )
                    Text(notes, style = MaterialTheme.typography.bodySmall, fontFamily = FontFamily.Monospace, color = Tuner.secondary)
                }
            }
        }
    }
}
