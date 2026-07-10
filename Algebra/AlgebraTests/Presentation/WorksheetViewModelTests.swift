import Foundation
import Testing
@testable import Algebra

@MainActor
struct WorksheetViewModelTests {
    private func makeSUT(seed: UInt64) -> WorksheetViewModel {
        let random = SeededRandomSource(seed: seed)
        return WorksheetViewModel(
            generateEquation: GenerateEquationExerciseUseCaseImpl(random: random),
            generateSystem: GenerateSystemExerciseUseCaseImpl(random: random),
            solveEquation: SolveEquationUseCaseImpl(),
            solveSystem: SolveSystemUseCaseImpl(),
            equationMapper: EquationUIMapperImpl(),
            systemMapper: SystemUIMapperImpl(),
            pdfRenderer: SwiftMathWorksheetPDFRenderer())
    }

    @Test
    func test_makeWorksheetPDF_writesNonEmptyPDFFile() throws {
        let sut = makeSUT(seed: 7)
        let url = try #require(sut.makeWorksheetPDF())
        #expect(FileManager.default.fileExists(atPath: url.path))
        let data = try Data(contentsOf: url)
        #expect(data.count > 1000)
        #expect(data.prefix(4) == Data("%PDF".utf8))
    }
}
