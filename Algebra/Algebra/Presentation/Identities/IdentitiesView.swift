import SwiftUI

struct IdentitiesView: View {
    @State private var viewModel: IdentitiesViewModel

    init(viewModel: IdentitiesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                typeSelector(viewModel: viewModel)
                valuesCard(viewModel: viewModel)
                PrimaryButton(title: "Desarrollar") {
                    hideKeyboard()
                    viewModel.expandTapped()
                }
                if let message = viewModel.inputError {
                    errorCard(message)
                }
                if let result = viewModel.result {
                    resultCard(result)
                }
            }
            .padding(Spacing.m)
        }
        .scrollContentBackground(.hidden)
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("Identidades")
    }

    @ViewBuilder
    private func typeSelector(viewModel: IdentitiesViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Tipo de identidad")
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(Array(viewModel.identityTitles.enumerated()), id: \.offset) { index, title in
                        TypeChip(title: title, isSelected: viewModel.identityIndex == index) {
                            viewModel.identityIndex = index
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func valuesCard(viewModel: IdentitiesViewModel) -> some View {
        @Bindable var viewModel = viewModel
        Card {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Valores")
                    .font(.headline)
                    .foregroundStyle(AppColor.textPrimary)
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: Spacing.s),
                        GridItem(.flexible(), spacing: Spacing.s)
                    ],
                    spacing: Spacing.s
                ) {
                    CoefficientField(label: "a", text: $viewModel.a)
                    CoefficientField(label: "b", text: $viewModel.b)
                }
            }
        }
    }

    @ViewBuilder
    private func errorCard(_ message: String) -> some View {
        Card {
            Label(message, systemImage: "exclamationmark.triangle")
                .foregroundStyle(.red)
        }
    }

    @ViewBuilder
    private func resultCard(_ result: IdentityExpansionState) -> some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.s) {
                MathView(
                    latex: result.identityLatex,
                    fontSize: 22,
                    color: UIColor(AppColor.textPrimary),
                    accessibilityLabelText: result.summary
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider().overlay(AppColor.border)

                MathView(
                    latex: result.developmentLatex,
                    fontSize: 24,
                    color: UIColor(AppColor.mint),
                    accessibilityLabelText: result.summary
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
