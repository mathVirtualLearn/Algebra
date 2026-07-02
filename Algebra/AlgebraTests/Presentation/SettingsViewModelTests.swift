import Testing
@testable import Algebra

@MainActor
struct SettingsViewModelTests {
    private func makeSUT(repository: PreferencesRepositoryMock) -> SettingsViewModel {
        let store = PreferencesStore(repository: repository)
        return SettingsViewModel(appName: "Algebra", version: "1.0", preferences: store)
    }

    @Test
    func test_givenStoredPreferences_whenRead_thenGettersReflectThem() {
        let repository = PreferencesRepositoryMock(stored: Preferences(formulaSize: .large, showDetailedSteps: false))
        let sut = makeSUT(repository: repository)

        #expect(sut.formulaSize == .large)
        #expect(sut.showDetailedSteps == false)
    }

    @Test
    func test_givenNewFormulaSize_whenSet_thenPersistedAndGetterUpdated() {
        let repository = PreferencesRepositoryMock()
        let sut = makeSUT(repository: repository)

        sut.formulaSize = .small

        #expect(sut.formulaSize == .small)
        #expect(repository.lastSaved?.formulaSize == .small)
        #expect(repository.saveCallCount == 1)
    }

    @Test
    func test_givenShowDetailedSteps_whenSet_thenPersistedAndGetterUpdated() {
        let repository = PreferencesRepositoryMock()
        let sut = makeSUT(repository: repository)

        sut.showDetailedSteps = false

        #expect(sut.showDetailedSteps == false)
        #expect(repository.lastSaved?.showDetailedSteps == false)
        #expect(repository.saveCallCount == 1)
    }
}
