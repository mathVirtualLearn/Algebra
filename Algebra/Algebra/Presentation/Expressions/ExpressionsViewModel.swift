import Foundation
import Observation

@MainActor
@Observable
final class ExpressionsViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded([ExpressionRowState])
        case empty
        case error(String)
    }

    private(set) var state: State = .idle

    private let topicId: String?
    private let getExpressions: GetExpressionsUseCase
    private let mapper: ExpressionUIMapper

    init(topicId: String?, getExpressions: GetExpressionsUseCase, mapper: ExpressionUIMapper) {
        self.topicId = topicId
        self.getExpressions = getExpressions
        self.mapper = mapper
    }

    func load() async {
        state = .loading
        do {
            let expressions = try await getExpressions.execute(topicId: topicId)
            let rows = expressions.map(mapper.map)
            state = rows.isEmpty ? .empty : .loaded(rows)
        } catch {
            state = .error(String(localized: "No se pudieron cargar las fórmulas."))
        }
    }
}
