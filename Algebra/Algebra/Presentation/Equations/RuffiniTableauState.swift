struct RuffiniTableauState: Equatable {

    let header: [String]

    let divisions: [Division]

    struct Division: Equatable {

        let root: String

        let products: [String]

        let results: [String]
    }
}
