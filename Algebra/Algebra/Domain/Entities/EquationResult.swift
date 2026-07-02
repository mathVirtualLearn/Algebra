enum SolveMethod: Equatable, Sendable {
    case linearFormula
    case quadraticFormula
    case ruffini
    case biquadratic
}

enum SolveOutcome: Equatable, Sendable {
    case solved
    case noRealSolutions
    case noSolution
    case infiniteSolutions
    case partial
}

struct RuffiniStep: Equatable, Sendable {
    let root: Double
    let quotient: [Double]
}

struct QuadraticInfo: Equatable, Sendable {
    let a: Double
    let b: Double
    let c: Double
    let discriminant: Double
    let roots: [Double]
}

struct EquationResult: Equatable, Sendable {
    let roots: [Double]
    let outcome: SolveOutcome
    let method: SolveMethod
    let discriminant: Double?
    let ruffiniSteps: [RuffiniStep]
    let finalQuadratic: QuadraticInfo?
}
