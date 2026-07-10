enum PracticeType: CaseIterable, Equatable, Sendable {
    case linear, quadratic, cubic, quartic, biquadratic, system2, system3
}

struct EquationExercise: Equatable, Sendable {
    let input: EquationInput
    let roots: [Fraction]
}

struct SystemExercise: Equatable, Sendable {
    let input: SystemInput
    let solution: [Fraction]
}
