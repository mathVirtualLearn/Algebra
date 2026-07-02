import Foundation

@MainActor
@Observable
final class PreferencesStore {
    private let repository: PreferencesRepository

    var formulaSize: FormulaSize {
        didSet { persist() }
    }
    var showDetailedSteps: Bool {
        didSet { persist() }
    }

    init(repository: PreferencesRepository) {
        self.repository = repository
        let loaded = repository.load()
        self.formulaSize = loaded.formulaSize
        self.showDetailedSteps = loaded.showDetailedSteps
    }

    private func persist() {
        repository.save(Preferences(formulaSize: formulaSize, showDetailedSteps: showDetailedSteps))
    }
}
