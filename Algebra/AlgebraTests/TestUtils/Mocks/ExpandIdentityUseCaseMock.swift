@testable import Algebra

final class ExpandIdentityUseCaseMock: ExpandIdentityUseCase, @unchecked Sendable {
    var result = IdentityResult(terms: [])
    private(set) var executeCallCount = 0
    private(set) var lastInput: IdentityInput?

    func execute(_ input: IdentityInput) -> IdentityResult {
        executeCallCount += 1
        lastInput = input
        return result
    }
}
