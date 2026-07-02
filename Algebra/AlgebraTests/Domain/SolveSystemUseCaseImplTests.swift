import Testing
@testable import Algebra

struct SolveSystemUseCaseImplTests {
    private let sut = SolveSystemUseCaseImpl()

    @Test
    func test_given2x2Compatible_whenSolve_thenReturnUniqueSolution() {

        let input = SystemInputBuilder()
            .with(size: .two)
            .with(coefficients: [[1, 1], [1, -1]])
            .with(constants: [3, 1])
            .build()
        let result = sut.execute(input)
        guard case .unique(let solution) = result.outcome else {
            Issue.record("esperaba .unique"); return
        }
        #expect(solution == [2, 1])
        #expect(result.solution == [2, 1])
    }

    @Test
    func test_given2x2Inconsistent_whenSolve_thenNoSolution() {

        let input = SystemInputBuilder()
            .with(size: .two)
            .with(coefficients: [[1, 1], [1, 1]])
            .with(constants: [1, 2])
            .build()
        let result = sut.execute(input)
        #expect(result.outcome == .noSolution)
        #expect(result.solution.isEmpty)
    }

    @Test
    func test_given2x2Dependent_whenSolve_thenInfiniteSolutions() {

        let input = SystemInputBuilder()
            .with(size: .two)
            .with(coefficients: [[1, 1], [2, 2]])
            .with(constants: [1, 2])
            .build()
        let result = sut.execute(input)
        #expect(result.outcome == .infiniteSolutions)
        #expect(result.solution.isEmpty)
    }

    @Test
    func test_given3x3Compatible_whenSolve_thenReturnUniqueSolution() {

        let input = SystemInputBuilder()
            .with(size: .three)
            .with(coefficients: [[1, 1, 1], [1, 2, 3], [1, 4, 9]])
            .with(constants: [6, 14, 36])
            .build()
        let result = sut.execute(input)
        guard case .unique(let solution) = result.outcome else {
            Issue.record("esperaba .unique"); return
        }
        #expect(solution == [1, 2, 3])
        #expect(result.solution == [1, 2, 3])
    }
}
