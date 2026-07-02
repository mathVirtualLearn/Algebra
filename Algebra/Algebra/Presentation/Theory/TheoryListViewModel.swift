import Foundation
import Observation

@MainActor
@Observable
final class TheoryListViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded([TheoryListItemState])
        case empty
        case error(String)
    }

    private(set) var state: State = .idle

    private let getArticles: GetTheoryArticlesUseCase
    private let mapper: TheoryUIMapper

    init(getArticles: GetTheoryArticlesUseCase, mapper: TheoryUIMapper) {
        self.getArticles = getArticles
        self.mapper = mapper
    }

    func load() async {
        state = .loading
        do {
            let articles = try await getArticles.execute()
            let items = mapper.mapList(articles)
            state = items.isEmpty ? .empty : .loaded(items)
        } catch {
            state = .error(String(localized: "No se pudo cargar la teoría."))
        }
    }
}
