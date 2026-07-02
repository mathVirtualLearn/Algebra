import SwiftUI

struct StepListView: View {
    let steps: [ExplanationStep]

    private enum ViewTraits {
        static let bulletSize: CGFloat = 24
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: Spacing.s) {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(width: ViewTraits.bulletSize, height: ViewTraits.bulletSize)
                        .background(AppColor.surfaceElevated)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(step.text)
                            .font(.subheadline)
                            .foregroundStyle(AppColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        if let latex = step.latex {
                            MathView(
                                latex: latex,
                                fontSize: 18,
                                color: UIColor(AppColor.textPrimary)
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

#Preview {
    ZStack {
        AppColor.background.ignoresSafeArea()
        StepListView(steps: [
            ExplanationStep(text: "Igualamos la ecuación a cero.", latex: "x^2 - 5x + 6 = 0"),
            ExplanationStep(text: "Aplicamos la fórmula general.", latex: nil),
            ExplanationStep(text: "Calculamos el discriminante.", latex: "\\Delta = b^2 - 4ac = 1")
        ])
        .padding()
    }
}
