import SwiftUI

@main
struct TunerApp: App {
    // Made here, not in TunerScreen: SwiftUI re-runs a view's @State initialiser every time it rebuilds the view,
    // and each throwaway model would start its own audio engines.
    @State private var model = TunerViewModel()

    var body: some Scene {
        WindowGroup { TunerScreen(model: model) }
    }
}
