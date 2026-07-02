import SwiftUI

struct CoefficientField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(label)
                .font(.caption)
                .foregroundStyle(AppColor.textSecondary)
            TextField("0", text: $text)
                .keyboardType(.numbersAndPunctuation)
                .foregroundStyle(AppColor.textPrimary)
                .padding(.horizontal, Spacing.s)
                .padding(.vertical, Spacing.xs)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColor.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Coeficiente \(label)"))
    }
}

#Preview {
    ZStack {
        AppColor.background.ignoresSafeArea()
        CoefficientField(label: "a", text: .constant("2"))
            .padding()
    }
}
