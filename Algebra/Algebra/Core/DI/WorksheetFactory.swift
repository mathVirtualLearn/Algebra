@MainActor
enum WorksheetFactory {
    static func make() -> WorksheetView {
        let random = SystemRandomSource()
        let viewModel = WorksheetViewModel(
            generateEquation: GenerateEquationExerciseUseCaseImpl(random: random),
            generateSystem: GenerateSystemExerciseUseCaseImpl(random: random),
            solveEquation: SolveEquationUseCaseImpl(),
            solveSystem: SolveSystemUseCaseImpl(),
            equationMapper: EquationUIMapperImpl(),
            systemMapper: SystemUIMapperImpl(),
            pdfRenderer: SwiftMathWorksheetPDFRenderer()
        )
        return WorksheetView(viewModel: viewModel)
    }
}
