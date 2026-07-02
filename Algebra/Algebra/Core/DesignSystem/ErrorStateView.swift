import SwiftUI

struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Algo ha ido mal", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Reintentar", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ErrorStateView(message: "No se pudieron cargar las fórmulas.", onRetry: {})
}
