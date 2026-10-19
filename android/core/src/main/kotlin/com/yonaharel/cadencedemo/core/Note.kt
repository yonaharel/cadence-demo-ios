package com.yonaharel.cadencedemo.core

import kotlin.math.abs
import kotlin.math.log2
import kotlin.math.pow
import kotlin.math.roundToInt

/** The nearest equal-tempered note to a frequency, relative to `a4` (440 Hz unless set), and how far off it is in cents. */
@ConsistentCopyVisibility
data class Note private constructor(val midi: Int, val cents: Double, val frequency: Double) {
    val name: String get() = NAMES[midi.mod(12)]
    val octave: Int get() = Math.floorDiv(midi, 12) - 1

    /** The string (or pair of strings) of [tuning] this note is closest to; a 12-string's octave strings count for their pair. */
    fun nearestString(tuning: Tuning): Int {
        fun distance(string: Int): Int {
            val octave = tuning.octaveString(string)?.let { abs(it - midi) } ?: Int.MAX_VALUE
            return minOf(abs(string - midi), octave)
        }
        return tuning.strings.minBy(::distance)
    }

    companion object {
        val NAMES = listOf("C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B")

        operator fun invoke(frequency: Double, a4: Double = 440.0): Note {
            val exact = 69 + 12 * log2(frequency / a4)
            val midi = exact.roundToInt()
            return Note(midi, (exact - midi) * 100, frequency)
        }

        operator fun invoke(midi: Int, a4: Double = 440.0): Note = invoke(a4 * 2.0.pow((midi - 69) / 12.0), a4)
    }
}
