@MainActor
enum FunctionsFactory {
    static func make() -> FunctionsView {
        let viewModel = FunctionsViewModel(
            parse: ParseFunctionUseCaseImpl(),
            sample: SampleFunctionUseCaseImpl(),
            mapper: FunctionUIMapperImpl()
        )
        return FunctionsView(viewModel: viewModel)
    }
}
