enum SystemOutcome: Equatable, Sendable {
    case unique([Double])
    case noSolution
    case infiniteSolutions
}

struct SystemResult: Equatable, Sendable {
    let outcome: SystemOutcome
    let determinant: Double
    let variableDeterminants: [Double]
    let solution: [Double]
}
