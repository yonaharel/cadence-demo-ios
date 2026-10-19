package com.yonaharel.cadencedemo.core

/** What you're tuning. Each tuning belongs to one instrument; the key is never saved (the tuning is). */
enum class Instrument(
    val key: String,
    val label: String,
    /** How many buttons its tunings have: one per string, or per pair of strings on a 12-string or mandolin. */
    val stringCount: Int,
) {
    GUITAR("guitar", "Guitar", 6),
    SEVEN_STRING("sevenString", "7-string", 7),
    TWELVE_STRING("twelveString", "12-string", 6),
    UKULELE("ukulele", "Ukulele", 4),
    MANDOLIN("mandolin", "Mandolin", 4),
    BANJO("banjo", "Banjo", 5);

    /** Its tunings, standard first. */
    val tunings: List<Tuning> get() = Tuning.entries.filter { it.instrument == this }
}
