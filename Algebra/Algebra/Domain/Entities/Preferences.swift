enum FormulaSize: String, CaseIterable, Sendable {
    case small
    case medium
    case large

    var scale: Double {
        switch self {
        case .small: return 0.85
        case .medium: return 1.0
        case .large: return 1.25
        }
    }
}

struct Preferences: Sendable, Equatable {
    var formulaSize: FormulaSize
    var showDetailedSteps: Bool

    static let `default` = Preferences(formulaSize: .medium, showDetailedSteps: true)
}
