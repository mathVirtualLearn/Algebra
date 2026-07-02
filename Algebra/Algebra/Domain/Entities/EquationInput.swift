enum EquationType: Equatable, Sendable, CaseIterable {
    case linear
    case quadratic
    case cubic
    case quartic
    case biquadratic

    var coefficientCount: Int {
        switch self {
        case .linear: return 2
        case .quadratic: return 3
        case .cubic: return 4
        case .quartic: return 5
        case .biquadratic: return 3
        }
    }
}

struct EquationInput: Equatable, Sendable {
    let type: EquationType

    let coefficients: [Double]
}
