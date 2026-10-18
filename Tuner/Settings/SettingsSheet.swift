import SwiftUI

/// Tuning, reference pitch and sensitivity, in a sheet the tuner keeps listening behind (glass on iOS 26).
struct SettingsSheet: View {
    @Binding var tuning: Tuning
    @Binding var a4: Int
    @Binding var sensitivity: Double
    let tuner: Tuner

    var body: some View {
        Form {
            Section("Tuning") {
                TuningCards(tuning: $tuning).listRowInsets(EdgeInsets())
            }
            Section("Reference pitch") {
                A4Ruler(a4: $a4)
            }
            Section {
                VStack(spacing: 6) {
                    LevelMeter(level: tuner.level, threshold: minimumLevel(sensitivity: Float(sensitivity)))
                    Slider(value: $sensitivity, in: 0...1).accessibilityLabel("Sensitivity")
                    HStack { Text("Loud room"); Spacer(); Text("Quiet strings") }.font(.caption).foregroundStyle(.secondary)
                }
            } header: {
                Text("Sensitivity")
            } footer: {
                Text("Pluck a string: the bar should pass the line. Turn it down if the room keeps setting it off.")
            }
        }
        .scrollContentBackground(.hidden) // let the sheet's glass show through
    }
}
