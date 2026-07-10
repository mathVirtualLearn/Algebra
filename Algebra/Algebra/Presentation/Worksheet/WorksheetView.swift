import SwiftUI

private struct WorksheetDocument: Identifiable {
    let id = UUID()
    let url: URL
}

struct WorksheetView: View {
    @State private var viewModel: WorksheetViewModel
    @State private var worksheet: WorksheetDocument?
    @State private var isExporting = false

    init(viewModel: WorksheetViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text("Elige el tipo y genera 10 ejercicios en PDF, con hoja de soluciones al final.")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
                typeSelector(viewModel: viewModel)
                if isExporting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    PrimaryButton(title: "Generar PDF") {
                        exportWorksheet()
                    }
                }
            }
            .padding(Spacing.m)
        }
        .scrollContentBackground(.hidden)
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("Generar ejercicios")
        .sheet(item: $worksheet) { document in
            NavigationStack {
                PDFKitView(url: document.url)
                    .ignoresSafeArea(edges: .bottom)
                    .navigationTitle("Vista previa")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cerrar") { worksheet = nil }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            ShareLink(item: document.url) {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
            }
        }
    }

    private func exportWorksheet() {
        isExporting = true
        Task { @MainActor in
            defer { isExporting = false }
            if let url = viewModel.makeWorksheetPDF() {
                worksheet = WorksheetDocument(url: url)
            }
        }
    }

    @ViewBuilder
    private func typeSelector(viewModel: WorksheetViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Tipo de ejercicio")
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(Array(viewModel.typeTitles.enumerated()), id: \.offset) { index, title in
                        TypeChip(title: title, isSelected: viewModel.selectedIndex == index) {
                            viewModel.selectedIndex = index
                        }
                    }
                }
            }
        }
    }
}
