import Testing
@testable import Algebra

struct SystemUIMapperImplTests {
    private let sut = SystemUIMapperImpl()
    private let solver = SolveSystemUseCaseImpl()

    private func map(_ input: SystemInput, method: SystemMethod = .reduction) -> SystemResultState {
        sut.map(input: input, result: solver.execute(input), method: method)
    }

    @Test
    func test_given2x2Unique_whenMap_thenEquationsStepsAndSolution() {
        let input = SystemInputBuilder()
            .with(size: .two)
            .with(coefficients: [[1, 1], [1, -1]])
            .with(constants: [3, 1])
            .build()
        let state = map(input)
        #expect(state.equationsLatex.count == 2)
        #expect(!state.steps.isEmpty)
        #expect(state.steps.contains { $0.text.isEmpty == false })
        #expect(state.solutionLatex.contains("x ="))
        #expect(state.solutionLatex.contains("y ="))
    }

    @Test
    func test_given3x3Unique_whenMap_thenThreeEquationsAndSolutionHasVariables() {
        let input = SystemInputBuilder()
            .with(size: .three)
            .with(coefficients: [[1, 1, 1], [1, 2, 3], [1, 4, 9]])
            .with(constants: [6, 14, 36])
            .build()
        let state = map(input)
        #expect(state.equationsLatex.count == 3)
        #expect(!state.steps.isEmpty)
        #expect(state.solutionLatex.contains("x ="))
        #expect(state.solutionLatex.contains("y ="))
        #expect(state.solutionLatex.contains("z ="))
    }

    @Test
    func test_given2x2Inconsistent_whenMap_thenSolutionIsText() {
        let input = SystemInputBuilder()
            .with(size: .two)
            .with(coefficients: [[1, 1], [1, 1]])
            .with(constants: [1, 2])
            .build()
        let state = map(input)
        #expect(state.equationsLatex.count == 2)
        #expect(!state.steps.isEmpty)
        #expect(state.solutionLatex.contains("\\text"))
    }

    @Test
    func test_given2x2FractionalByEqualization_whenMap_thenSolutionLatexHasFractionsAndFourSteps() {
        let input = SystemInputBuilder()
            .with(size: .two)
            .with(coefficients: [[1, 9], [8, 8]])
            .with(constants: [8, 5])
            .build()
        let state = map(input, method: .equalization)

        #expect(state.solutionLatex.contains("\\frac{19}{64}"))
        #expect(state.solutionLatex.contains("\\frac{59}{64}"))

        #expect(state.solutionLatex.contains("\\displaystyle\\frac"))

        #expect(state.steps.count >= 4)
    }
}
