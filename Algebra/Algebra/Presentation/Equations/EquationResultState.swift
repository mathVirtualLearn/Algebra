struct EquationResultState: Equatable {
    let equationLatex: String
    let steps: [ExplanationStep]
    let solutionLatex: String
    let summary: String
    let ruffiniTableau: RuffiniTableauState?
}
