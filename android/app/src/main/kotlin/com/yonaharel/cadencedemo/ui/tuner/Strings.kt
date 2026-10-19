package com.yonaharel.cadencedemo.ui.tuner

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.key
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.onClick
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.min
import androidx.compose.ui.unit.sp
import com.yonaharel.cadencedemo.core.Note
import com.yonaharel.cadencedemo.core.Tuning
import com.yonaharel.cadencedemo.ui.components.pressable
import com.yonaharel.cadencedemo.ui.components.selectionHighlight
import com.yonaharel.cadencedemo.ui.components.staggeredAppear
import com.yonaharel.cadencedemo.ui.theme.Tuner

/**
 * The tuning's strings; the one being tuned is highlighted. Tap one to hear its note.
 * A 12-string shows one button per pair, with the pair's octave string underneath.
 */
@Composable
fun Strings(tuning: Tuning, active: Int?, play: (Int) -> Unit, modifier: Modifier = Modifier) {
    val count = tuning.strings.size
    val gap = if (count > 6) 8.dp else 12.dp
    // A new instrument rebuilds the row, so its buttons spring in one after another.
    key(tuning.instrument) {
        BoxWithConstraints(modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
            // Seven strings need smaller buttons to fit across a phone.
            val size = min(if (count > 6) 40.dp else 46.dp, (maxWidth - gap * (count - 1)) / count)
            Row(horizontalArrangement = Arrangement.spacedBy(gap)) {
                tuning.strings.forEachIndexed { index, midi ->
                    StringButton(
                        note = Note(midi),
                        octave = tuning.octaveString(midi)?.let { Note(it) },
                        active = midi == active,
                        size = size,
                        index = index,
                        play = { play(midi) },
                    )
                }
            }
        }
    }
}

@Composable
private fun StringButton(note: Note, octave: Note?, active: Boolean, size: Dp, index: Int, play: () -> Unit) {
    val strings = octave?.let { "${note.name} ${note.octave} and ${it.name} ${it.octave} strings" } ?: "${note.name} ${note.octave} string"
    Column(
        Modifier
            .staggeredAppear(index)
            .pressable(onClick = play)
            .size(size)
            .background(Tuner.secondary.copy(alpha = 0.15f), CircleShape)
            .selectionHighlight(active, CircleShape)
            .clearAndSetSemantics {
                contentDescription = if (active) "$strings, tuning" else strings
                selected = active
                role = Role.Button
                onClick(label = "Play the note") {
                    play()
                    true
                }
            },
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        val color = if (active) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface
        Text(
            buildAnnotatedString {
                append(note.name)
                withStyle(SpanStyle(fontSize = 11.sp)) { append("${note.octave}") }
            },
            color = color,
            fontSize = 17.sp,
            fontWeight = FontWeight.SemiBold,
        )
        if (octave != null) Text("${octave.name}${octave.octave}", fontSize = 11.sp, lineHeight = 11.sp, color = Tuner.secondary)
    }
}

