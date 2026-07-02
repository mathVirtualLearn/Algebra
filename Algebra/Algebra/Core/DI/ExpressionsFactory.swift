@MainActor
enum ExpressionsFactory {

    static func make(topicId: String?, title: String) -> ExpressionsListView {
        let repository = InMemoryExpressionRepository()
        let useCase = GetExpressionsUseCaseImpl(repository: repository)
        let mapper = ExpressionUIMapperImpl()
        let viewModel = ExpressionsViewModel(topicId: topicId, getExpressions: useCase, mapper: mapper)
        return ExpressionsListView(viewModel: viewModel, title: title)
    }
}
