import SwiftUI

struct TypeChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? .white : AppColor.textSecondary)
                .padding(.horizontal, Spacing.s)
                .padding(.vertical, Spacing.xs)
                .background(isSelected ? AppColor.accent : AppColor.surfaceElevated)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    ZStack {
        AppColor.background.ignoresSafeArea()
        HStack(spacing: Spacing.xs) {
            TypeChip(title: "1.º grado", isSelected: true, action: {})
            TypeChip(title: "2.º grado", isSelected: false, action: {})
        }
        .padding()
    }
}
