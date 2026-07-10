import Foundation
import Observation

@MainActor
@Observable
final class WorksheetViewModel {

    let typeTitles: [String] = [
        String(localized: "Grado 1"),
        String(localized: "Grado 2"),
        String(localized: "Grado 3"),
        String(localized: "Grado 4"),
        String(localized: "Bicuadrada"),
        String(localized: "Sistema 2×2"),
        String(localized: "Sistema 3×3")
    ]

    var selectedIndex: Int = 0

    private let generateEquation: GenerateEquationExerciseUseCase
    private let generateSystem: GenerateSystemExerciseUseCase
    private let solveEquation: SolveEquationUseCase
    private let solveSystem: SolveSystemUseCase
    private let equationMapper: EquationUIMapper
    private let systemMapper: SystemUIMapper
    private let pdfRenderer: WorksheetPDFRenderer

    init(
        generateEquation: GenerateEquationExerciseUseCase,
        generateSystem: GenerateSystemExerciseUseCase,
        solveEquation: SolveEquationUseCase,
        solveSystem: SolveSystemUseCase,
        equationMapper: EquationUIMapper,
        systemMapper: SystemUIMapper,
        pdfRenderer: WorksheetPDFRenderer
    ) {
        self.generateEquation = generateEquation
        self.generateSystem = generateSystem
        self.solveEquation = solveEquation
        self.solveSystem = solveSystem
        self.equationMapper = equationMapper
        self.systemMapper = systemMapper
        self.pdfRenderer = pdfRenderer
    }

    var worksheetTitle: String {
        "\(String(localized: "Hoja de ejercicios")) · \(typeTitles[selectedIndex])"
    }

    func makeWorksheetPDF() -> URL? {
        var items: [WorksheetItem] = []
        for _ in 0..<10 {
            switch selectedType {
            case .system2, .system3:
                let size: SystemSize = selectedType == .system2 ? .two : .three
                let exercise = generateSystem.execute(size: size)
                let state = systemMapper.map(input: exercise.input,
                                             result: solveSystem.execute(exercise.input),
                                             method: .cramer)
                items.append(WorksheetItem(statementLatexLines: state.equationsLatex,
                                           solutionLatex: state.solutionLatex))
            default:
                let exercise = generateEquation.execute(type: equationType(for: selectedType))
                let state = equationMapper.map(input: exercise.input,
                                               result: solveEquation.execute(exercise.input))
                items.append(WorksheetItem(statementLatexLines: [state.equationLatex],
                                           solutionLatex: state.solutionLatex))
            }
        }
        let data = pdfRenderer.render(title: worksheetTitle, items: items, includeSolutions: true)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("hoja-ejercicios.pdf")
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    private var selectedType: PracticeType {
        let all = PracticeType.allCases
        return selectedIndex >= 0 && selectedIndex < all.count ? all[selectedIndex] : .linear
    }

    private func equationType(for type: PracticeType) -> EquationType {
        switch type {
        case .quadratic: return .quadratic
        case .cubic: return .cubic
        case .quartic: return .quartic
        case .biquadratic: return .biquadratic
        default: return .linear
        }
    }
}
