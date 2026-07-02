protocol PreferencesRepository: Sendable {
    func load() -> Preferences
    func save(_ preferences: Preferences)
}
