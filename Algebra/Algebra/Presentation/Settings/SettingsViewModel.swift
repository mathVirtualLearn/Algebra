import Observation

@MainActor
@Observable
final class SettingsViewModel {
    let appName: String
    let version: String
    private let preferences: PreferencesStore

    init(appName: String, version: String, preferences: PreferencesStore) {
        self.appName = appName
        self.version = version
        self.preferences = preferences
    }

    var formulaSize: FormulaSize {
        get { preferences.formulaSize }
        set { preferences.formulaSize = newValue }
    }
    var showDetailedSteps: Bool {
        get { preferences.showDetailedSteps }
        set { preferences.showDetailedSteps = newValue }
    }
}
