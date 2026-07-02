import Testing
import Foundation
@testable import Algebra

struct UserDefaultsPreferencesRepositoryTests {
    private func makeDefaults() -> (UserDefaults, String) {
        let suite = "test.preferences.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return (defaults, suite)
    }

    @Test
    func test_givenNothingStored_whenLoad_thenReturnsDefaults() {
        let (defaults, suite) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suite) }
        let sut = UserDefaultsPreferencesRepository(defaults: defaults)

        let preferences = sut.load()

        #expect(preferences.formulaSize == .medium)
        #expect(preferences.showDetailedSteps == true)
    }

    @Test(arguments: FormulaSize.allCases)
    func test_givenFormulaSize_whenSaveThenLoad_thenRoundTrips(size: FormulaSize) {
        let (defaults, suite) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suite) }
        let sut = UserDefaultsPreferencesRepository(defaults: defaults)

        sut.save(Preferences(formulaSize: size, showDetailedSteps: true))

        #expect(sut.load().formulaSize == size)
    }

    @Test(arguments: [true, false])
    func test_givenShowDetailedSteps_whenSaveThenLoad_thenRoundTrips(flag: Bool) {
        let (defaults, suite) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suite) }
        let sut = UserDefaultsPreferencesRepository(defaults: defaults)

        sut.save(Preferences(formulaSize: .large, showDetailedSteps: flag))

        let loaded = sut.load()
        #expect(loaded.showDetailedSteps == flag)
        #expect(loaded.formulaSize == .large)
    }
}
