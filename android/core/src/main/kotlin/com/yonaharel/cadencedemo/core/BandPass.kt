package com.yonaharel.cadencedemo.core

import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/**
 * Cuts mic rumble below [low] and hiss above [high] (outside guitar range), which would otherwise confuse YIN.
 * Keeps state between calls: one per audio stream.
 */
class BandPass(sampleRate: Double, low: Double = 55.0, high: Double = 1300.0) { // 55 Hz stays below C2 at A4=415 (61.7 Hz)
    private class Biquad(sampleRate: Double, cutoff: Double, highPass: Boolean) {
        private val b0: Double
        private val b1: Double
        private val b2: Double
        private val a1: Double
        private val a2: Double
        private var x1 = 0.0
        private var x2 = 0.0
        private var y1 = 0.0
        private var y2 = 0.0

        // RBJ audio-EQ cookbook, Q = 1/√2 (Butterworth).
        init {
            val w = 2 * PI * cutoff / sampleRate
            val alpha = sin(w) / (2 * 0.7071)
            val c = cos(w)
            val a0 = 1 + alpha
            b0 = (if (highPass) 1 + c else 1 - c) / 2 / a0
            b1 = (if (highPass) -(1 + c) else 1 - c) / a0
            b2 = b0
            a1 = -2 * c / a0
            a2 = (1 - alpha) / a0
        }

        fun process(x: Double): Double {
            val y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
            x2 = x1
            x1 = x
            y2 = y1
            y1 = y
            return y
        }
    }

    private val highPass = Biquad(sampleRate, low, highPass = true)
    private val lowPass = Biquad(sampleRate, high, highPass = false)

    fun process(samples: FloatArray) {
        for (i in samples.indices) samples[i] = lowPass.process(highPass.process(samples[i].toDouble())).toFloat()
    }
}
