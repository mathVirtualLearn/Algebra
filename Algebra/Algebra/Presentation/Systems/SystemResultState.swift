struct SystemResultState: Equatable {
    let equationsLatex: [String]
    let steps: [ExplanationStep]
    let solutionLatex: String
    let summary: String
}
