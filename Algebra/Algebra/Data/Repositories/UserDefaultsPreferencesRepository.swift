import Foundation

final class UserDefaultsPreferencesRepository: PreferencesRepository, @unchecked Sendable {
    private let defaults: UserDefaults

    private enum Key {
        static let formulaSize = "pref.formulaSize"
        static let showDetailedSteps = "pref.showDetailedSteps"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> Preferences {
        let size = defaults.string(forKey: Key.formulaSize)
            .flatMap(FormulaSize.init(rawValue:)) ?? Preferences.default.formulaSize
        let show = defaults.object(forKey: Key.showDetailedSteps) as? Bool
            ?? Preferences.default.showDetailedSteps
        return Preferences(formulaSize: size, showDetailedSteps: show)
    }

    func save(_ preferences: Preferences) {
        defaults.set(preferences.formulaSize.rawValue, forKey: Key.formulaSize)
        defaults.set(preferences.showDetailedSteps, forKey: Key.showDetailedSteps)
    }
}
