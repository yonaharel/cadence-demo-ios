package com.yonaharel.cadencedemo.core

import kotlin.math.abs
import kotlin.math.log2

/**
 * Steadies the needle: the median of the last few readings doesn't lag a retune, and a reading over a semitone away
 * is held back until three agree, so a stray octave jump never reaches the needle.
 */
class Smoother {
    private var history = listOf<Double>()
    private var pending = listOf<Double>()

    /** The frequency to show, or null while [frequency] is held back as a possible outlier. */
    fun add(frequency: Double): Double? {
        if (history.isEmpty() || cents(frequency, median(history)) <= 100) {
            pending = emptyList()
            history = (history + frequency).takeLast(5)
            return median(history)
        }
        val first = pending.firstOrNull()
        pending = if (first != null && cents(frequency, first) <= 100) pending + frequency else listOf(frequency)
        if (pending.size < 3) return null
        history = pending
        pending = emptyList()
        return median(history)
    }

    fun reset() {
        history = emptyList()
        pending = emptyList()
    }

    private companion object {
        fun cents(a: Double, b: Double) = abs(1200 * log2(a / b))

        fun median(x: List<Double>) = x.sorted()[x.size / 2]
    }
}
