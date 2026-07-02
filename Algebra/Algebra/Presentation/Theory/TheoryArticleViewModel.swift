import Foundation
import Observation

@MainActor
@Observable
final class TheoryArticleViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(TheoryArticleState)
        case notFound
        case error(String)
    }

    private(set) var state: State = .idle

    private let id: String
    private let getArticle: GetTheoryArticleUseCase
    private let mapper: TheoryUIMapper

    init(id: String, getArticle: GetTheoryArticleUseCase, mapper: TheoryUIMapper) {
        self.id = id
        self.getArticle = getArticle
        self.mapper = mapper
    }

    func load() async {
        state = .loading
        do {
            guard let article = try await getArticle.execute(id: id) else {
                state = .notFound
                return
            }
            state = .loaded(mapper.mapArticle(article))
        } catch {
            state = .error(String(localized: "No se pudo cargar el artículo."))
        }
    }
}
