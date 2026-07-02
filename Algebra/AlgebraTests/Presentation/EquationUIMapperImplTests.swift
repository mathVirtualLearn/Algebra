import Testing
@testable import Algebra

struct EquationUIMapperImplTests {
    private let sut = EquationUIMapperImpl()
    private let solver = SolveEquationUseCaseImpl()

    private func map(_ input: EquationInput) -> EquationResultState {
        sut.map(input: input, result: solver.execute(input))
    }

    @Test
    func test_givenQuadratic_whenMap_thenBuildEquationLatexHidingUnitCoefficient() {
        let input = EquationInputBuilder().with(type: .quadratic).with(coefficients: [1, -3, 2]).build()
        let state = map(input)
        #expect(state.equationLatex == "x^2 - 3x + 2 = 0")
    }

    @Test
    func test_givenCubic_whenMap_thenBuildEquationLatexWithCubicTerm() {
        let input = EquationInputBuilder().with(type: .cubic).with(coefficients: [1, -6, 11, -6]).build()
        let state = map(input)
        #expect(state.equationLatex == "x^3 - 6x^2 + 11x - 6 = 0")
        #expect(state.equationLatex.contains("x^3"))
    }

    @Test
    func test_givenQuadraticTwoRoots_whenMap_thenBuildSolutionAndDiscriminantStep() {
        let input = EquationInputBuilder().with(type: .quadratic).with(coefficients: [1, -3, 2]).build()
        let state = map(input)
        #expect(state.solutionLatex == "x_1 = 1 \\quad x_2 = 2")
        #expect(!state.steps.isEmpty)
        #expect(state.steps.contains { $0.text.isEmpty == false })
        #expect(state.steps.contains { ($0.latex ?? "").contains("\\Delta") })
    }

    @Test
    func test_givenLinear_whenMap_thenHasExplanationStepAndUniqueSolution() {
        let input = EquationInputBuilder().with(type: .linear).with(coefficients: [2, -4]).build()
        let state = map(input)
        #expect(!state.steps.isEmpty)
        #expect(state.steps.contains { $0.text.isEmpty == false })
        #expect(state.solutionLatex == "x = 2")
    }

    @Test
    func test_givenNoRealRoots_whenMap_thenBuildTextSolution() {
        let input = EquationInputBuilder().with(type: .quadratic).with(coefficients: [1, 0, 1]).build()
        let state = map(input)
        #expect(state.solutionLatex == "\\text{Sin soluciones reales}")
    }

    @Test
    func test_givenCubicRuffini_whenMap_thenStepsNotEmptyAndSolutionContainsRoots() {
        let input = EquationInputBuilder().with(type: .cubic).with(coefficients: [1, -6, 11, -6]).build()
        let state = map(input)
        #expect(!state.steps.isEmpty)
        #expect(state.steps.contains { $0.text.isEmpty == false })
        #expect(state.solutionLatex.contains("x_1 = 1"))
        #expect(state.solutionLatex.contains("x_2 = 2"))
        #expect(state.solutionLatex.contains("x_3 = 3"))
    }

    @Test
    func test_givenBiquadratic_whenMap_thenStepsExplainChangeOfVariable() {
        let input = EquationInputBuilder().with(type: .biquadratic).with(coefficients: [1, -5, 4]).build()
        let state = map(input)
        #expect(!state.steps.isEmpty)
        #expect(state.steps.contains { ($0.latex ?? "").contains("t = x^2") })
        #expect(state.solutionLatex.contains("-2"))
        #expect(state.solutionLatex.contains("2"))
    }
}
