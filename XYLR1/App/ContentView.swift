import SwiftUI

/// Root content view — manages navigation between all app views.
struct ContentView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        Group {
            switch appState.currentView {
            case .layer:
                LayerMainView()
            case .synth:
                SynthView()
            case .animation:
                AnimationView()
            case .delay:
                DelayView()
            case .environment:
                EnvironmentView()
            case .treatment:
                TreatmentView()
            case .revise:
                ReviseView()
            }
        }
        .environmentObject(appState)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
    }
}

#Preview {
    ContentView()
}
