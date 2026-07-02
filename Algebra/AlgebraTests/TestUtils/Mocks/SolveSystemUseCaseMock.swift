@testable import Algebra

final class SolveSystemUseCaseMock: SolveSystemUseCase, @unchecked Sendable {
    var result = SystemResult(
        outcome: .unique([2, 1]),
        determinant: -2,
        variableDeterminants: [-4, -2],
        solution: [2, 1]
    )
    private(set) var executeCallCount = 0
    private(set) var lastInput: SystemInput?

    func execute(_ input: SystemInput) -> SystemResult {
        executeCallCount += 1
        lastInput = input
        return result
    }
}
