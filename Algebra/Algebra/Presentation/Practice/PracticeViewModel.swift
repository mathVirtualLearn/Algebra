import Foundation
import Observation

@MainActor
@Observable
final class PracticeViewModel {

    var selectedIndex: Int = 0 {
        didSet {
            guard selectedIndex != oldValue else { return }
            generate()
        }
    }

    let typeTitles: [String] = [
        String(localized: "Grado 1"),
        String(localized: "Grado 2"),
        String(localized: "Grado 3"),
        String(localized: "Grado 4"),
        String(localized: "Bicuadrada"),
        String(localized: "Sistema 2×2"),
        String(localized: "Sistema 3×3")
    ]

    var answer: String = ""
    var systemAnswers: [String] = []

    private(set) var exerciseLatex: String = ""
    private(set) var systemEquationsLatex: [String] = []
    private(set) var variableLabels: [String] = []
    private(set) var result: Bool?
    private(set) var steps: [ExplanationStep] = []
    private(set) var solutionLatex: String?
    private(set) var showSolution: Bool = false

    var isSystem: Bool {
        selectedType == .system2 || selectedType == .system3
    }

    private let generateEquation: GenerateEquationExerciseUseCase
    private let generateSystem: GenerateSystemExerciseUseCase
    private let checkEquation: CheckEquationAnswerUseCase
    private let checkSystem: CheckSystemAnswerUseCase
    private let solveEquation: SolveEquationUseCase
    private let solveSystem: SolveSystemUseCase
    private let equationMapper: EquationUIMapper
    private let systemMapper: SystemUIMapper

    private var currentEquation: EquationExercise?
    private var currentSystem: SystemExercise?

    init(
        generateEquation: GenerateEquationExerciseUseCase,
        generateSystem: GenerateSystemExerciseUseCase,
        checkEquation: CheckEquationAnswerUseCase,
        checkSystem: CheckSystemAnswerUseCase,
        solveEquation: SolveEquationUseCase,
        solveSystem: SolveSystemUseCase,
        equationMapper: EquationUIMapper,
        systemMapper: SystemUIMapper
    ) {
        self.generateEquation = generateEquation
        self.generateSystem = generateSystem
        self.checkEquation = checkEquation
        self.checkSystem = checkSystem
        self.solveEquation = solveEquation
        self.solveSystem = solveSystem
        self.equationMapper = equationMapper
        self.systemMapper = systemMapper
        generate()
    }

    func generate() {
        result = nil
        steps = []
        solutionLatex = nil
        showSolution = false
        answer = ""
        switch selectedType {
        case .system2, .system3:
            let size: SystemSize = selectedType == .system2 ? .two : .three
            let exercise = generateSystem.execute(size: size)
            currentSystem = exercise
            currentEquation = nil
            variableLabels = size == .two ? ["x", "y"] : ["x", "y", "z"]
            systemAnswers = Array(repeating: "", count: variableLabels.count)
            let state = systemMapper.map(input: exercise.input,
                                         result: solveSystem.execute(exercise.input),
                                         method: .cramer)
            systemEquationsLatex = state.equationsLatex
            exerciseLatex = ""
        default:
            let exercise = generateEquation.execute(type: equationType(for: selectedType))
            currentEquation = exercise
            currentSystem = nil
            variableLabels = []
            systemAnswers = []
            systemEquationsLatex = []
            let state = equationMapper.map(input: exercise.input,
                                           result: solveEquation.execute(exercise.input))
            exerciseLatex = state.equationLatex
        }
    }

    func check() {
        switch selectedType {
        case .system2, .system3:
            guard let exercise = currentSystem else { return }
            result = checkSystem.execute(answers: systemAnswers, solution: exercise.solution)
        default:
            guard let exercise = currentEquation else { return }
            result = checkEquation.execute(answer: answer, roots: exercise.roots)
        }
    }

    func revealSolution() {
        switch selectedType {
        case .system2, .system3:
            guard let exercise = currentSystem else { return }
            let state = systemMapper.map(input: exercise.input,
                                         result: solveSystem.execute(exercise.input),
                                         method: .cramer)
            steps = state.steps
            solutionLatex = state.solutionLatex
        default:
            guard let exercise = currentEquation else { return }
            let state = equationMapper.map(input: exercise.input,
                                           result: solveEquation.execute(exercise.input))
            steps = state.steps
            solutionLatex = state.solutionLatex
        }
        showSolution = true
    }

    func next() {
        generate()
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
