// Self-check for the tuner's pitch detection on synthetic guitar-like tones.
//   swiftc -O Tuner/Pitch.swift scripts/check-pitch/main.swift -o /tmp/check-pitch && /tmp/check-pitch
import Foundation

let rate = 48_000.0
func tone(_ f: Double, count: Int = 4096) -> [Float] {
    // A fundamental with weaker harmonics, like a plucked string.
    (0..<count).map { i in
        let t = Double(i) / rate
        return Float(0.5 * sin(2 * .pi * f * t) + 0.3 * sin(4 * .pi * f * t) + 0.15 * sin(6 * .pi * f * t))
    }
}

for midi in Set(Tuning.allCases.flatMap(\.strings)).sorted() {
    let f = Note(midi: midi).frequency
    let heard = detectPitch(tone(f), sampleRate: rate)!
    let note = Note(frequency: heard)
    precondition(note.midi == midi && abs(note.cents) < 1, "string \(midi): heard \(heard) Hz")
}
let flat = Note(frequency: detectPitch(tone(108.9), sampleRate: rate)!)
precondition(flat.name == "A" && flat.octave == 2 && (-19 ... -15).contains(flat.cents), "flat A2: \(flat)")
precondition(detectPitch([Float](repeating: 0, count: 4096), sampleRate: rate) == nil, "silence has no pitch")
precondition(Note(frequency: 330).nearestString(in: .standard) == 64 && Note(frequency: 82).nearestString(in: .standard) == 40)
precondition(Note(frequency: 73.4).nearestString(in: .dropD) == 38, "low D in Drop D")
for t in Tuning.allCases {
    precondition(t.strings.count == 6 && t.strings == t.strings.sorted() && Set(t.strings).count == 6, "\(t.name) strings")
}
for a4 in [432.0, 442.0] {
    for midi in Tuning.standard.strings {
        let f = Note(midi: midi, a4: a4).frequency
        let note = Note(frequency: detectPitch(tone(f), sampleRate: rate)!, a4: a4)
        precondition(note.midi == midi && abs(note.cents) < 1, "A4=\(a4) string \(midi): \(note)")
    }
}
precondition(abs(Note(frequency: 110, a4: 432).cents - 31.8) < 0.2, "440-tuned A2 is sharp at 432")
var seed: UInt64 = 0x9E3779B97F4A7C15
func noise(_ count: Int, amplitude: Float) -> [Float] {
    (0..<count).map { _ in
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        return amplitude * (Float(seed >> 40) / Float(1 << 24) * 2 - 1)
    }
}
func filtered(_ f: Double, buffers: Int = 3, noiseAmp: Float = 0) -> [Float] {
    // Several buffers through one filter, like the live tap; analyse the last.
    var filter = BandPass(sampleRate: rate)
    var last: [Float] = []
    for b in 0..<buffers {
        var x = (0..<4096).map { i in
            let t = Double(b * 4096 + i) / rate
            return Float(0.5 * sin(2 * .pi * f * t) + 0.3 * sin(4 * .pi * f * t) + 0.15 * sin(6 * .pi * f * t))
        }
        if noiseAmp > 0 { x = zip(x, noise(4096, amplitude: noiseAmp)).map(+) }
        filter.process(&x)
        last = x
    }
    return last
}
for midi in Set(Tuning.allCases.flatMap(\.strings)).sorted() {
    let f = Note(midi: midi).frequency
    let note = Note(frequency: detectPitch(filtered(f, buffers: 2), sampleRate: rate)!)
    precondition(note.midi == midi && abs(note.cents) < 1, "filtered string \(midi): \(note)")
}
let lowC = Note(midi: 36, a4: 415)
precondition(Note(frequency: detectPitch(filtered(lowC.frequency), sampleRate: rate)!, a4: 415).midi == 36, "C2 at A4=415 survives the high-pass")
let noisyA = Note(frequency: detectPitch(filtered(110, noiseAmp: 0.3), sampleRate: rate)!)
precondition(noisyA.midi == 45 && abs(noisyA.cents) < 3, "A2 in noise: \(noisyA)")
var hiss = noise(4096 * 3, amplitude: 0.3), hissFilter = BandPass(sampleRate: rate)
hissFilter.process(&hiss)
precondition(detectPitch(Array(hiss.suffix(4096)), sampleRate: rate) == nil, "filtered noise has no pitch")
precondition(detectPitch(noise(4096, amplitude: 0.3), sampleRate: rate) == nil, "raw noise has no pitch")
let high = filtered(3000, buffers: 2)
precondition(sqrt(high.map { $0 * $0 }.reduce(0, +) / 4096) < 0.1, "3 kHz is attenuated")
print("pitch detection ok")
