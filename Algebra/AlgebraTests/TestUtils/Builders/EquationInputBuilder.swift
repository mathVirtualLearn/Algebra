@testable import Algebra

struct EquationInputBuilder {
    private var type: EquationType = .quadratic
    private var coefficients: [Double] = [1, -3, 2]

    func with(type: EquationType) -> Self { var x = self; x.type = type; return x }
    func with(coefficients: [Double]) -> Self { var x = self; x.coefficients = coefficients; return x }
    func with(coeffs: [Double]) -> Self { var x = self; x.coefficients = coeffs; return x }

    func build() -> EquationInput {
        EquationInput(type: type, coefficients: coefficients)
    }
}
