import SwiftUI

struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColor.border, lineWidth: 1)
            )
    }
}

#Preview {
    ZStack {
        AppColor.background.ignoresSafeArea()
        Card {
            Text("Contenido de ejemplo")
                .foregroundStyle(AppColor.textPrimary)
        }
        .padding()
    }
}
