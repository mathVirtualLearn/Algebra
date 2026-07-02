@testable import Algebra

struct IdentityInputBuilder {
    private var identity: NotableIdentity = .squareSum
    private var a = Monomial(coefficient: 1, variables: ["x": 1])
    private var b = Monomial(coefficient: 1)

    func with(identity: NotableIdentity) -> Self { var copy = self; copy.identity = identity; return copy }
    func with(a: Monomial) -> Self { var copy = self; copy.a = a; return copy }
    func with(b: Monomial) -> Self { var copy = self; copy.b = b; return copy }

    func build() -> IdentityInput {
        IdentityInput(identity: identity, a: a, b: b)
    }
}
