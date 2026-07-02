import Foundation
import Observation

@MainActor
@Observable
final class IdentitiesViewModel {

    var identityIndex: Int = 0
    var a: String = ""
    var b: String = ""

    let identityTitles = [
        String(localized: "Cuadrado de la suma"),
        String(localized: "Cuadrado de la diferencia"),
        String(localized: "Suma por diferencia"),
    ]

    private(set) var result: IdentityExpansionState?
    private(set) var inputError: String?

    private let expand: ExpandIdentityUseCase
    private let mapper: IdentityUIMapper

    init(expand: ExpandIdentityUseCase, mapper: IdentityUIMapper) {
        self.expand = expand
        self.mapper = mapper
    }

    func expandTapped() {
        inputError = nil
        guard let monomialA = Monomial.parse(a), let monomialB = Monomial.parse(b) else {
            inputError = String(localized: "Introduce un número o un monomio (p. ej. 5x).")
            result = nil
            return
        }
        let input = IdentityInput(identity: identity(for: identityIndex), a: monomialA, b: monomialB)
        result = mapper.map(input: input, result: expand.execute(input))
    }

    private func identity(for index: Int) -> NotableIdentity {
        switch index {
        case 1: return .squareDifference
        case 2: return .sumByDifference
        default: return .squareSum
        }
    }
}
