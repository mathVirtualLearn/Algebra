@testable import Algebra

final class PreferencesRepositoryMock: PreferencesRepository, @unchecked Sendable {
    var stored: Preferences
    private(set) var loadCallCount = 0
    private(set) var saveCallCount = 0
    private(set) var lastSaved: Preferences?

    init(stored: Preferences = .default) {
        self.stored = stored
    }

    func load() -> Preferences {
        loadCallCount += 1
        return stored
    }

    func save(_ preferences: Preferences) {
        saveCallCount += 1
        lastSaved = preferences
        stored = preferences
    }
}
