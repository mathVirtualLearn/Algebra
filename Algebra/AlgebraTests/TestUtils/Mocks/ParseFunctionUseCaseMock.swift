@testable import Algebra

final class ParseFunctionUseCaseMock: ParseFunctionUseCase, @unchecked Sendable {
    var result: FunctionExpr?
    private(set) var executeCallCount = 0
    private(set) var lastText: String?

    func execute(_ text: String) -> FunctionExpr? {
        executeCallCount += 1
        lastText = text
        return result
    }
}
