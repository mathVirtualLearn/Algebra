import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded([TopicCardState])
        case empty
        case error(String)
    }

    private(set) var state: State = .idle

    private let getTopics: GetTopicsUseCase
    private let mapper: TopicUIMapper

    init(getTopics: GetTopicsUseCase, mapper: TopicUIMapper) {
        self.getTopics = getTopics
        self.mapper = mapper
    }

    func load() async {
        state = .loading
        do {
            let topics = try await getTopics.execute()
            let cards = topics.map(mapper.map)
            state = cards.isEmpty ? .empty : .loaded(cards)
        } catch {
            state = .error(String(localized: "No se pudieron cargar los temas."))
        }
    }
}
