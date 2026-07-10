import Testing
@testable import Algebra

@MainActor
struct PracticeViewModelTests {
    private func makeSUT(seed: UInt64) -> PracticeViewModel {
        let random = SeededRandomSource(seed: seed)
        return PracticeViewModel(
            generateEquation: GenerateEquationExerciseUseCaseImpl(random: random),
            generateSystem: GenerateSystemExerciseUseCaseImpl(random: random),
            checkEquation: CheckEquationAnswerUseCaseImpl(),
            checkSystem: CheckSystemAnswerUseCaseImpl(),
            solveEquation: SolveEquationUseCaseImpl(),
            solveSystem: SolveSystemUseCaseImpl(),
            equationMapper: EquationUIMapperImpl(),
            systemMapper: SystemUIMapperImpl())
    }

    private func answerToken(_ fraction: Fraction) -> String {
        fraction.denominator == 1 ? "\(fraction.numerator)" : "\(fraction.numerator)/\(fraction.denominator)"
    }

    @Test
    func test_givenInit_whenLinearSelected_thenStatementIsGenerated() {
        let sut = makeSUT(seed: 42)
        #expect(!sut.exerciseLatex.isEmpty)
        #expect(sut.result == nil)
        #expect(!sut.showSolution)
    }

    @Test
    func test_givenCorrectEquationAnswer_whenCheck_thenResultIsTrue() {
        let expectedRoots = GenerateEquationExerciseUseCaseImpl(random: SeededRandomSource(seed: 42))
            .execute(type: .linear).roots
        let sut = makeSUT(seed: 42)
        sut.answer = expectedRoots.map(answerToken).joined(separator: ", ")
        sut.check()
        #expect(sut.result == true)
    }

    @Test
    func test_givenIncorrectEquationAnswer_whenCheck_thenResultIsFalse() {
        let sut = makeSUT(seed: 42)
        sut.answer = "99999"
        sut.check()
        #expect(sut.result == false)
    }

    @Test
    func test_givenEquation_whenRevealSolution_thenStepsFilledAndShowSolutionTrue() {
        let sut = makeSUT(seed: 42)
        sut.revealSolution()
        #expect(!sut.steps.isEmpty)
        #expect(sut.showSolution)
        #expect(sut.solutionLatex != nil)
    }

    @Test
    func test_givenSystemSelected_whenGenerated_thenSystemStatementAndLabelsSet() {
        let sut = makeSUT(seed: 42)
        sut.selectedIndex = 5
        #expect(sut.isSystem)
        #expect(!sut.systemEquationsLatex.isEmpty)
        #expect(sut.variableLabels == ["x", "y"])
    }
}
