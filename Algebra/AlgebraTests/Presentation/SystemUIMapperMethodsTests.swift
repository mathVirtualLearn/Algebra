import Testing
@testable import Algebra

struct SystemUIMapperMethodsTests {
    private let sut = SystemUIMapperImpl()
    private let solver = SolveSystemUseCaseImpl()

    private func map(_ input: SystemInput, method: SystemMethod) -> SystemResultState {
        sut.map(input: input, result: solver.execute(input), method: method)
    }

    @Test(arguments: SystemMethod.allCases)
    func test_given2x2Unique_whenMapWithMethod_thenStepsNotEmptyAndSolutionPresent(
        method: SystemMethod
    ) async throws {

        let input = SystemInputBuilder()
            .with(size: .two)
            .with(coefficients: [[1, 1], [1, -1]])
            .with(constants: [3, 1])
            .build()

        let state = map(input, method: method)

        #expect(!state.steps.isEmpty)
        #expect(state.solutionLatex.contains("x ="))
        #expect(state.solutionLatex.contains("y ="))
    }

    @Test
    func test_given2x2Unique_whenMapWithEachMethod_thenSolutionLatexIsIdentical() async throws {
        let input = SystemInputBuilder()
            .with(size: .two)
            .with(coefficients: [[1, 1], [1, -1]])
            .with(constants: [3, 1])
            .build()
        let substitution = map(input, method: .substitution).solutionLatex
        let equalization = map(input, method: .equalization).solutionLatex
        let reduction = map(input, method: .reduction).solutionLatex
        #expect(substitution == equalization)
        #expect(equalization == reduction)
    }

    @Test
    func test_given3x3Unique_whenMapWithReduction_thenStepsNotEmptyAndSolutionPresent() async throws {
        let input = SystemInputBuilder()
            .with(size: .three)
            .with(coefficients: [[1, 1, 1], [1, 2, 3], [1, 4, 9]])
            .with(constants: [6, 14, 36])
            .build()
        let state = map(input, method: .reduction)
        #expect(!state.steps.isEmpty)
        #expect(state.solutionLatex.contains("x ="))
        #expect(state.solutionLatex.contains("y ="))
        #expect(state.solutionLatex.contains("z ="))
    }
}
