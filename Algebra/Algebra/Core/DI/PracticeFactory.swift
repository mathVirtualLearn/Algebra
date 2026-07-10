@MainActor
enum PracticeFactory {
    static func make() -> PracticeView {
        let random = SystemRandomSource()
        let viewModel = PracticeViewModel(
            generateEquation: GenerateEquationExerciseUseCaseImpl(random: random),
            generateSystem: GenerateSystemExerciseUseCaseImpl(random: random),
            checkEquation: CheckEquationAnswerUseCaseImpl(),
            checkSystem: CheckSystemAnswerUseCaseImpl(),
            solveEquation: SolveEquationUseCaseImpl(),
            solveSystem: SolveSystemUseCaseImpl(),
            equationMapper: EquationUIMapperImpl(),
            systemMapper: SystemUIMapperImpl()
        )
        return PracticeView(viewModel: viewModel)
    }
}
