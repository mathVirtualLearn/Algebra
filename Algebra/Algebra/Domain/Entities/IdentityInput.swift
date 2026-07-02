enum NotableIdentity: Equatable, Sendable {
    case squareSum
    case squareDifference
    case sumByDifference
}

struct IdentityInput: Equatable, Sendable {
    let identity: NotableIdentity
    let a: Monomial
    let b: Monomial
}
