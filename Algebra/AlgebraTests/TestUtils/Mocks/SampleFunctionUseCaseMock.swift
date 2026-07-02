@testable import Algebra
import Foundation

final class SampleFunctionUseCaseMock: SampleFunctionUseCase, @unchecked Sendable {
    var result: [FunctionSample] = []
    private(set) var executeCallCount = 0
    private(set) var lastExpression: FunctionExpr?
    private(set) var lastDomain: ClosedRange<Double>?
    private(set) var lastCount: Int?

    func execute(expression: FunctionExpr, domain: ClosedRange<Double>, count: Int) -> [FunctionSample] {
        executeCallCount += 1
        lastExpression = expression
        lastDomain = domain
        lastCount = count
        return result
    }
}
