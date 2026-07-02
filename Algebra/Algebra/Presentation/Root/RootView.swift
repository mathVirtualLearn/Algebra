import SwiftUI

struct RootView: View {
    @State private var preferences = PreferencesStore(repository: UserDefaultsPreferencesRepository())

    var body: some View {
        TabView {
            Tab("Aprende", systemImage: "graduationcap") {
                HomeFactory.make()
            }
            Tab("Teoría", systemImage: "text.book.closed") {
                TheoryFactory.makeList()
            }
            Tab("Ajustes", systemImage: "gearshape") {
                SettingsFactory.make(preferences: preferences)
            }
        }
        .environment(\.formulaScale, CGFloat(preferences.formulaSize.scale))
        .environment(\.showDetailedSteps, preferences.showDetailedSteps)
    }
}
