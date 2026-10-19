package com.yonaharel.cadencedemo.core

import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

// The iOS app's scripts/check-pitch/main.swift, case for case, on synthetic guitar-like tones.
class PitchDetectionTest {
    private val rate = 48_000.0

    /** A fundamental with weaker harmonics, like a plucked string. */
    private fun tone(f: Double, count: Int = 4096, offset: Int = 0) = FloatArray(count) { i ->
        val t = (offset + i) / rate
        (0.5 * sin(2 * PI * f * t) + 0.3 * sin(4 * PI * f * t) + 0.15 * sin(6 * PI * f * t)).toFloat()
    }

    private var seed = 0x9E37_79B9_7F4A_7C15uL

    private fun noise(count: Int, amplitude: Float) = FloatArray(count) {
        seed = seed * 6_364_136_223_846_793_005uL + 1_442_695_040_888_963_407uL
        amplitude * ((seed shr 40).toFloat() / (1 shl 24).toFloat() * 2 - 1)
    }

    /** Several buffers through one filter, like the live stream; analyse the last. */
    private fun filtered(f: Double, buffers: Int = 3, noiseAmp: Float = 0f): FloatArray {
        val filter = BandPass(rate)
        var last = FloatArray(0)
        for (b in 0 until buffers) {
            val x = tone(f, offset = b * 4096)
            if (noiseAmp > 0) noise(4096, noiseAmp).forEachIndexed { i, n -> x[i] += n }
            filter.process(x)
            last = x
        }
        return last
    }

    private fun detect(samples: FloatArray, range: ClosedFloatingPointRange<Double> = 60.0..1200.0) =
        detectPitch(samples, rate, range)

    @Test
    fun everyStringOfEveryTuningReadsWithinOneCent() {
        for (t in Tuning.entries) {
            for (midi in t.strings) {
                val heard = assertNotNull(detect(tone(Note(midi).frequency), t.detectionFloor(440.0)..1200.0), "$t $midi")
                val note = Note(heard)
                assertTrue(note.midi == midi && abs(note.cents) < 1, "$t string $midi: heard $heard Hz")
            }
        }
    }

    @Test
    fun flatAIsFlat() {
        val flat = Note(detect(tone(108.9))!!)
        assertTrue(flat.name == "A" && flat.octave == 2 && flat.cents in -19.0..-15.0, "flat A2: $flat")
    }

    @Test
    fun silenceHasNoPitch() = assertNull(detect(FloatArray(4096)))

    @Test
    fun nearestString() {
        assertEquals(64, Note(330.0).nearestString(Tuning.STANDARD))
        assertEquals(40, Note(82.0).nearestString(Tuning.STANDARD))
        assertEquals(38, Note(73.4).nearestString(Tuning.DROP_D), "low D in Drop D")
        // A 12-string's octave strings belong to their pair.
        assertEquals(40, Note(52).nearestString(Tuning.TWELVE_STANDARD), "high E3 of the low E pair")
        assertEquals(64, Note(64).nearestString(Tuning.TWELVE_STANDARD), "top E is in unison")
        assertEquals(50, Note(52).nearestString(Tuning.STANDARD), "a 6-string has no octave pairs")
    }

    @Test
    fun tuningsAreWellFormed() {
        for (t in Tuning.entries) {
            val lowToHigh = t.instrument in listOf(Instrument.GUITAR, Instrument.SEVEN_STRING, Instrument.TWELVE_STRING)
            assertTrue(t.strings.size == t.instrument.stringCount && t.strings.toSet().size == t.strings.size, "$t strings")
            assertTrue(!lowToHigh || t.strings == t.strings.sorted(), "$t strings run low to high")
            assertEquals(t, Tuning.fromKey(t.key))
        }
        for (i in Instrument.entries) assertTrue(i.tunings.isNotEmpty(), "$i has tunings")
        assertEquals(29, Tuning.entries.size)
        assertEquals(Tuning.STANDARD, Instrument.GUITAR.tunings.first())
    }

    @Test
    fun detectionFloor() {
        // Guitars keep the 60 Hz floor (50 Hz mains hum stays out); a 7-string in Drop A listens lower.
        assertEquals(60.0, Tuning.STANDARD.detectionFloor(440.0))
        assertTrue(Tuning.DROP_C.detectionFloor(440.0) < 60)
        assertNull(detect(tone(50.0), Tuning.STANDARD.detectionFloor(440.0)..1200.0), "50 Hz hum ignored on guitar")
    }

    @Test
    fun otherReferencePitches() {
        for (a4 in listOf(432.0, 442.0)) {
            for (midi in Tuning.STANDARD.strings) {
                val note = Note(detect(tone(Note(midi, a4).frequency))!!, a4)
                assertTrue(note.midi == midi && abs(note.cents) < 1, "A4=$a4 string $midi: $note")
            }
        }
        assertTrue(abs(Note(110.0, 432.0).cents - 31.8) < 0.2, "440-tuned A2 is sharp at 432")
    }

    @Test
    fun filteredStringsStillReadWithinOneCent() {
        for (t in Tuning.entries) {
            for (midi in t.strings) {
                val note = Note(detect(filtered(Note(midi).frequency, buffers = 2), t.detectionFloor(440.0)..1200.0)!!)
                assertTrue(note.midi == midi && abs(note.cents) < 1, "$t filtered string $midi: $note")
            }
        }
        val lowA = Note(33, 415.0)
        val heardLowA = detect(filtered(lowA.frequency), Tuning.SEVEN_DROP_A.detectionFloor(415.0)..1200.0)
        assertEquals(33, heardLowA?.let { Note(it, 415.0).midi }, "7-string Drop A at A4=415 survives the high-pass")
        val lowC = Note(36, 415.0)
        assertEquals(36, Note(detect(filtered(lowC.frequency))!!, 415.0).midi, "C2 at A4=415 survives the high-pass")
        val high = filtered(3000.0, buffers = 2)
        assertTrue(sqrt(high.map { it * it }.sum() / 4096) < 0.1, "3 kHz is attenuated")
    }

    @Test
    fun noise() {
        val noisyA = Note(detect(filtered(110.0, noiseAmp = 0.3f))!!)
        assertTrue(noisyA.midi == 45 && abs(noisyA.cents) < 3, "A2 in noise: $noisyA")
        val hiss = noise(4096 * 3, 0.3f)
        BandPass(rate).process(hiss)
        assertNull(detect(hiss.copyOfRange(4096 * 2, 4096 * 3)), "filtered noise has no pitch")
        assertNull(detect(noise(4096, 0.3f)), "raw noise has no pitch")
    }

    @Test
    fun smoother() {
        val s = Smoother()
        repeat(5) { s.add(110.0) }
        assertNull(s.add(220.0), "a single octave jump is held")
        assertTrue(abs(s.add(110.0)!! - 110) < 0.01, "steady note continues after a blip")

        val slide = Smoother()
        for (i in 0 until 20) assertNotNull(slide.add(105 + i * 0.5), "slow retune is never held")

        val change = Smoother()
        repeat(5) { change.add(110.0) }
        assertTrue(change.add(146.8) == null && change.add(146.8) == null, "first two of a new string held")
        assertTrue(abs(change.add(146.8)!! - 146.8) < 0.01, "new string accepted on the 3rd buffer")

        val flicker = Smoother()
        repeat(5) { flicker.add(110.0) }
        for (f in listOf(300.0, 500.0, 300.0, 500.0, 300.0, 500.0)) assertNull(flicker.add(f), "alternating outliers never accepted")

        assertNotNull(Smoother().add(82.4), "first reading after reset is shown")
    }

    @Test
    fun sensitivity() {
        // 0 is strict for a loud room, 1 hears quiet strings.
        val quietA = tone(110.0).map { it * 0.02f }.toFloatArray() // RMS ≈ 0.009, a softly picked string
        assertEquals(45, Note(detect(quietA)!!).midi, "quiet string heard at the default sensitivity")
        assertNull(detectPitch(quietA, rate, sensitivity = 0f), "quiet string ignored in loud-room mode")
        assertNull(detectPitch(noise(4096, 0.3f), rate, sensitivity = 1f), "noise still rejected at full sensitivity")
        assertTrue(minimumLevel(0f) > minimumLevel(1f), "more sensitive listens to quieter sound")
    }

    @Test
    fun noteNames() {
        assertEquals("E", Note(40).name)
        assertEquals(2, Note(40).octave)
        assertEquals("C♯", Note(61).name)
        assertEquals(4, Note(61).octave)
    }
}
