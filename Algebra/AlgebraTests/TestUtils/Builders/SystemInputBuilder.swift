@testable import Algebra

struct SystemInputBuilder {
    private var size: SystemSize = .two
    private var coefficients: [[Double]] = [[1, 1], [1, -1]]
    private var constants: [Double] = [3, 1]

    func with(size: SystemSize) -> Self { var x = self; x.size = size; return x }
    func with(coefficients: [[Double]]) -> Self { var x = self; x.coefficients = coefficients; return x }
    func with(constants: [Double]) -> Self { var x = self; x.constants = constants; return x }

    func build() -> SystemInput {
        SystemInput(size: size, coefficients: coefficients, constants: constants)
    }
}
