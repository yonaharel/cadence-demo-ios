package com.yonaharel.cadencedemo.core

import kotlin.math.pow
import kotlin.math.sqrt

/** The RMS of [samples]: how loud the mic is. */
fun rms(samples: FloatArray): Float {
    var sum = 0f
    for (x in samples) sum += x * x
    return sqrt(sum / maxOf(samples.size, 1))
}

/** The quietest level treated as a string, for a sensitivity from 0 (loud room) to 1 (quiet strings). */
fun minimumLevel(sensitivity: Float): Float = 0.03f * 0.1f.pow(sensitivity.coerceIn(0f, 1f))

/**
 * The fundamental frequency of [samples], by YIN (de Cheveigné & Kawahara, 2002), or null when there is no clear pitch.
 * [sensitivity] (0..1) trades rejecting room noise for hearing quiet, less clear strings.
 */
fun detectPitch(
    samples: FloatArray,
    sampleRate: Double,
    range: ClosedFloatingPointRange<Double> = 60.0..1200.0,
    sensitivity: Float = 0.7f,
): Double? {
    val minLag = (sampleRate / range.endInclusive).toInt()
    val maxLag = (sampleRate / range.start).toInt()
    val window = samples.size - maxLag
    if (minLag <= 1 || window <= 0) return null
    if (rms(samples) <= minimumLevel(sensitivity)) return null // too quiet to be a string

    val diff = FloatArray(maxLag + 1)
    for (lag in 1..maxLag) {
        var sum = 0f
        for (j in 0 until window) {
            val d = samples[j] - samples[j + lag]
            sum += d * d
        }
        diff[lag] = sum
    }
    // Cumulative mean normalised difference: the first dip under the threshold is the period.
    val cmnd = FloatArray(maxLag + 1) { 1f }
    var running = 0f
    for (lag in 1..maxLag) {
        running += diff[lag]
        cmnd[lag] = if (running > 0) diff[lag] * lag / running else 1f
    }
    var lag = minLag
    while (lag < maxLag && cmnd[lag] >= 0.15f) lag++
    if (lag >= maxLag) return null
    while (lag + 1 < maxLag && cmnd[lag + 1] < cmnd[lag]) lag++
    if (cmnd[lag] >= 0.08f + 0.07f * sensitivity.coerceIn(0f, 1f)) return null // not periodic enough to trust

    // Parabolic interpolation between neighbouring lags for sub-sample precision.
    val a = cmnd[lag - 1]
    val b = cmnd[lag]
    val c = cmnd[lag + 1]
    val curve = a - 2 * b + c
    val shift = if (curve == 0f) 0f else 0.5f * (a - c) / curve
    return sampleRate / (lag + shift.toDouble())
}
