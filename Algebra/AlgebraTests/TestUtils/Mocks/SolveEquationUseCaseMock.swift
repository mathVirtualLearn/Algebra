@testable import Algebra

final class SolveEquationUseCaseMock: SolveEquationUseCase, @unchecked Sendable {
    var result = EquationResult(
        roots: [],
        outcome: .noSolution,
        method: .linearFormula,
        discriminant: nil,
        ruffiniSteps: [],
        finalQuadratic: nil
    )
    private(set) var executeCallCount = 0
    private(set) var lastInput: EquationInput?

    func execute(_ input: EquationInput) -> EquationResult {
        executeCallCount += 1
        lastInput = input
        return result
    }
}
