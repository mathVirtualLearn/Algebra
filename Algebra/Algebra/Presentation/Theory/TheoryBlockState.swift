enum TheoryBlockState: Equatable, Identifiable {
    case heading(id: Int, String)
    case paragraph(id: Int, String)
    case formula(id: Int, String)
    case bullet(id: Int, [String])
    case ruffini(id: Int, RuffiniTableauState)

    var id: Int {
        switch self {
        case let .heading(id, _),
             let .paragraph(id, _),
             let .formula(id, _),
             let .bullet(id, _),
             let .ruffini(id, _):
            return id
        }
    }
}
