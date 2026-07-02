@MainActor
enum SystemsFactory {
    static func make() -> SystemsView {
        SystemsView(
            viewModel: SystemsViewModel(
                solve: SolveSystemUseCaseImpl(),
                mapper: SystemUIMapperImpl()
            )
        )
    }
}
