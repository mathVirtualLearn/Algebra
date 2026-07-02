@MainActor
enum EquationsFactory {
    static func make() -> EquationsView {
        let viewModel = EquationsViewModel(
            solve: SolveEquationUseCaseImpl(),
            mapper: EquationUIMapperImpl()
        )
        return EquationsView(viewModel: viewModel)
    }
}
