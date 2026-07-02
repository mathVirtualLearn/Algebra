@MainActor
enum HomeFactory {
    static func make() -> HomeView {
        let repository = InMemoryTopicRepository()
        let useCase = GetTopicsUseCaseImpl(repository: repository)
        let mapper = TopicUIMapperImpl()
        let viewModel = HomeViewModel(getTopics: useCase, mapper: mapper)
        return HomeView(viewModel: viewModel)
    }
}
