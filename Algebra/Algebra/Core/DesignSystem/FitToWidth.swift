import SwiftUI

private struct FitWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

extension View {

    func fitToWidth() -> some View { modifier(FitToWidthModifier()) }
}

private struct FitToWidthModifier: ViewModifier {
    @State private var naturalWidth: CGFloat = 0
    @State private var naturalHeight: CGFloat = 0
    func body(content: Content) -> some View {
        GeometryReader { geo in
            let scale = (naturalWidth > 0 && naturalWidth > geo.size.width) ? geo.size.width / naturalWidth : 1
            content
                .fixedSize()
                .background(GeometryReader { g in
                    Color.clear
                        .onAppear { naturalWidth = g.size.width; naturalHeight = g.size.height }
                        .onChange(of: g.size) { _, new in naturalWidth = new.width; naturalHeight = new.height }
                })
                .scaleEffect(scale, anchor: .topLeading)
                .frame(width: geo.size.width, height: naturalHeight * scale, alignment: .leading)
        }
        .frame(height: naturalHeight == 0 ? nil : naturalHeight * fitScaleFallback)
    }

    private var fitScaleFallback: CGFloat { 1 }
}
