package com.yonaharel.cadencedemo.core

import com.yonaharel.cadencedemo.core.Instrument.BANJO
import com.yonaharel.cadencedemo.core.Instrument.GUITAR
import com.yonaharel.cadencedemo.core.Instrument.MANDOLIN
import com.yonaharel.cadencedemo.core.Instrument.SEVEN_STRING
import com.yonaharel.cadencedemo.core.Instrument.TWELVE_STRING
import com.yonaharel.cadencedemo.core.Instrument.UKULELE

/**
 * Tunings for every instrument. The key is what's saved (the same keys as the iOS app), so don't change them.
 *
 * [strings] are MIDI note numbers in the order they're shown: low to high, except that a ukulele's high G and a banjo's
 * short drone string keep their place on the neck. A 12-string or mandolin lists one note per pair.
 */
enum class Tuning(val key: String, val instrument: Instrument, val label: String, val strings: List<Int>) {
    // Guitar
    STANDARD("standard", GUITAR, "Standard", listOf(40, 45, 50, 55, 59, 64)), // E A D G B E
    HALF_STEP_DOWN("halfStepDown", GUITAR, "Half step down", listOf(39, 44, 49, 54, 58, 63)), // E♭ A♭ D♭ G♭ B♭ E♭
    WHOLE_STEP_DOWN("wholeStepDown", GUITAR, "Whole step down", listOf(38, 43, 48, 53, 57, 62)), // D G C F A D
    C_STANDARD("cStandard", GUITAR, "C Standard", listOf(36, 41, 46, 51, 55, 60)), // C F B♭ E♭ G C
    DROP_D("dropD", GUITAR, "Drop D", listOf(38, 45, 50, 55, 59, 64)), // D A D G B E
    DROP_C_SHARP("dropCSharp", GUITAR, "Drop C♯", listOf(37, 44, 49, 54, 58, 63)), // C♯ G♯ C♯ F♯ A♯ D♯
    DROP_C("dropC", GUITAR, "Drop C", listOf(36, 43, 48, 53, 57, 62)), // C G C F A D
    DOUBLE_DROP_D("doubleDropD", GUITAR, "Double Drop D", listOf(38, 45, 50, 55, 59, 62)), // D A D G B D
    OPEN_D("openD", GUITAR, "Open D", listOf(38, 45, 50, 54, 57, 62)), // D A D F♯ A D
    OPEN_E("openE", GUITAR, "Open E", listOf(40, 47, 52, 56, 59, 64)), // E B E G♯ B E
    OPEN_G("openG", GUITAR, "Open G", listOf(38, 43, 50, 55, 59, 62)), // D G D G B D
    OPEN_A("openA", GUITAR, "Open A", listOf(40, 45, 52, 57, 61, 64)), // E A E A C♯ E
    OPEN_C("openC", GUITAR, "Open C", listOf(36, 43, 48, 55, 60, 64)), // C G C G C E
    DADGAD("dadgad", GUITAR, "DADGAD", listOf(38, 45, 50, 55, 57, 62)), // D A D G A D

    // 7-string guitar
    SEVEN_STANDARD("sevenStandard", SEVEN_STRING, "Standard", listOf(35, 40, 45, 50, 55, 59, 64)), // B E A D G B E
    SEVEN_DROP_A("sevenDropA", SEVEN_STRING, "Drop A", listOf(33, 40, 45, 50, 55, 59, 64)), // A E A D G B E
    SEVEN_HALF_STEP_DOWN("sevenHalfStepDown", SEVEN_STRING, "Half step down", listOf(34, 39, 44, 49, 54, 58, 63)),

    // 12-string guitar
    TWELVE_STANDARD("twelveStandard", TWELVE_STRING, "Standard", listOf(40, 45, 50, 55, 59, 64)), // E A D G B E
    TWELVE_DROP_D("twelveDropD", TWELVE_STRING, "Drop D", listOf(38, 45, 50, 55, 59, 64)), // D A D G B E
    TWELVE_HALF_STEP_DOWN("twelveHalfStepDown", TWELVE_STRING, "Half step down", listOf(39, 44, 49, 54, 58, 63)),

    // Ukulele
    UKULELE_STANDARD("ukuleleStandard", UKULELE, "Standard", listOf(67, 60, 64, 69)), // G C E A, high G
    UKULELE_LOW_G("ukuleleLowG", UKULELE, "Low G", listOf(55, 60, 64, 69)), // G C E A, low G
    UKULELE_BARITONE("ukuleleBaritone", UKULELE, "Baritone", listOf(50, 55, 59, 64)), // D G B E
    UKULELE_D("ukuleleD", UKULELE, "D tuning", listOf(69, 62, 66, 71)), // A D F♯ B

    // Mandolin
    MANDOLIN_STANDARD("mandolinStandard", MANDOLIN, "Standard", listOf(55, 62, 69, 76)), // G D A E

    // 5-string banjo
    BANJO_OPEN_G("banjoOpenG", BANJO, "Open G", listOf(67, 50, 55, 59, 62)), // G D G B D
    BANJO_DOUBLE_C("banjoDoubleC", BANJO, "Double C", listOf(67, 48, 55, 60, 62)), // G C G C D
    BANJO_OPEN_D("banjoOpenD", BANJO, "Open D", listOf(66, 50, 54, 57, 62)), // F♯ D F♯ A D
    BANJO_C("banjoC", BANJO, "C tuning", listOf(67, 48, 55, 59, 62)); // G C G B D

    /** "Drop D", or "Ukulele Standard" for anything but a guitar. */
    val description: String get() = if (instrument == GUITAR) label else "${instrument.label} $label"

    /** The octave string paired with [string] on a 12-string: the four lowest pairs have one; the top two are in unison. */
    fun octaveString(string: Int): Int? {
        if (instrument != TWELVE_STRING) return null
        val index = strings.indexOf(string)
        return if (index in 0..3) string + 12 else null
    }

    /**
     * The lowest pitch worth listening for: just below the lowest string, so a slack string still registers,
     * but never above 60 Hz, so guitars keep ignoring 50 Hz mains hum.
     */
    fun detectionFloor(a4: Double): Double = minOf(60.0, Note(strings.min(), a4).frequency * 0.85)

    companion object {
        fun fromKey(key: String?): Tuning? = entries.firstOrNull { it.key == key }
    }
}
