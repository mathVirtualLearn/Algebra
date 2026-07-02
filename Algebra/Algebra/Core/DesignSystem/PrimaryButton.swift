import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.s)
                .background(
                    LinearGradient(
                        colors: [AppColor.accent, AppColor.accent2],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        AppColor.background.ignoresSafeArea()
        PrimaryButton(title: "Resolver", action: {})
            .padding()
    }
}
