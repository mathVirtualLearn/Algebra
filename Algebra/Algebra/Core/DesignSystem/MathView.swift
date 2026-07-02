import SwiftMath
import SwiftUI

struct MathView: UIViewRepresentable {
    let latex: String
    var fontSize: CGFloat = 24
    var color: UIColor = .label
    var accessibilityLabelText: String?

    @Environment(\.formulaScale) private var formulaScale

    func makeUIView(context: Context) -> MTMathUILabel {
        let label = MTMathUILabel()
        label.labelMode = .display
        label.textAlignment = .left
        label.displayErrorInline = true
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ label: MTMathUILabel, context: Context) {
        label.latex = Self.sanitized(latex)
        label.fontSize = fontSize * formulaScale
        label.textColor = color
        if let accessibilityLabelText {
            label.isAccessibilityElement = true
            label.accessibilityLabel = accessibilityLabelText
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: MTMathUILabel, context: Context) -> CGSize? {
        uiView.latex = Self.sanitized(latex)
        uiView.fontSize = fontSize * formulaScale
        let natural = uiView.intrinsicContentSize

        if let proposedWidth = proposal.width,
           proposedWidth.isFinite,
           proposedWidth > 0,
           natural.width > proposedWidth {
            let fitted = max(10, fontSize * formulaScale * (proposedWidth / natural.width))
            uiView.fontSize = fitted
            return uiView.intrinsicContentSize
        }
        return natural
    }

    private static func sanitized(_ latex: String) -> String {
        let commaBeforeSign =
            ",(?=(?:\\s|\\\\[,;:! ]|\\\\quad|\\\\qquad)*(?:\\\\pm|\\\\mp|\\\\cdot|\\\\times|\\\\div|[-+]))"
        return latex.replacingOccurrences(
            of: commaBeforeSign, with: " ", options: .regularExpression)
    }
}

#Preview {
    MathView(latex: "x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}", fontSize: 28)
        .padding()
}
