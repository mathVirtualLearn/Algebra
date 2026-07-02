@MainActor
enum TheoryFactory {
    static func makeList() -> TheoryListView {
        let viewModel = TheoryListViewModel(
            getArticles: GetTheoryArticlesUseCaseImpl(
                repository: InMemoryTheoryArticleRepository()
            ),
            mapper: TheoryUIMapperImpl()
        )
        return TheoryListView(viewModel: viewModel)
    }

    static func makeArticle(id: String) -> TheoryArticleView {
        let viewModel = TheoryArticleViewModel(
            id: id,
            getArticle: GetTheoryArticleUseCaseImpl(
                repository: InMemoryTheoryArticleRepository()
            ),
            mapper: TheoryUIMapperImpl()
        )
        return TheoryArticleView(viewModel: viewModel)
    }
}
