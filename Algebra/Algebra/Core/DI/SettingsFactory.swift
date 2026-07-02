import Foundation

@MainActor
enum SettingsFactory {
    static func make(preferences: PreferencesStore) -> SettingsView {
        let bundle = Bundle.main
        let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Algebra"
        let shortVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        let viewModel = SettingsViewModel(
            appName: name,
            version: "\(shortVersion) (\(build))",
            preferences: preferences
        )
        return SettingsView(viewModel: viewModel)
    }
}
