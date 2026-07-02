enum SystemSize: Equatable, Sendable {
    case two
    case three

    var equationCount: Int { self == .two ? 2 : 3 }
}

struct SystemInput: Equatable, Sendable {
    let size: SystemSize

    let coefficients: [[Double]]

    let constants: [Double]
}
