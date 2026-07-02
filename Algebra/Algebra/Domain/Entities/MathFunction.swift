enum FunctionType: Equatable, Sendable, CaseIterable {
    case linear
    case quadratic
    case cubic
    case exponential
    case logarithmic
    case sine
    case cosine

    var coefficientCount: Int {
        switch self {
        case .linear: return 2
        case .quadratic: return 3
        case .cubic: return 4
        case .exponential: return 2
        case .logarithmic: return 2
        case .sine: return 2
        case .cosine: return 2
        }
    }
}

struct MathFunction: Equatable, Sendable {
    let type: FunctionType

    let coefficients: [Double]
}
