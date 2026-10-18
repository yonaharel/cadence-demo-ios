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
print("pitch detection ok")
