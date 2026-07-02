import SwiftUI

struct EquationsView: View {
    @State private var viewModel: EquationsViewModel
    @Environment(\.showDetailedSteps) private var showDetailedSteps

    init(viewModel: EquationsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                typeSelector(viewModel: viewModel)
                coefficientsCard(viewModel: viewModel)
                PrimaryButton(title: "Resolver") {
                    hideKeyboard()
                    viewModel.solveTapped()
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
        .navigationTitle("Ecuaciones")
    }

    @ViewBuilder
    private func typeSelector(viewModel: EquationsViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Tipo de ecuación")
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(Array(viewModel.typeTitles.enumerated()), id: \.offset) { index, title in
                        TypeChip(title: title, isSelected: viewModel.typeIndex == index) {
                            viewModel.typeIndex = index
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func coefficientsCard(viewModel: EquationsViewModel) -> some View {
        @Bindable var viewModel = viewModel
        Card {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Coeficientes")
                    .font(.headline)
                    .foregroundStyle(AppColor.textPrimary)
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: Spacing.s),
                        GridItem(.flexible(), spacing: Spacing.s)
                    ],
                    spacing: Spacing.s
                ) {
                    ForEach(Array(viewModel.coefficientLabels.enumerated()), id: \.offset) { index, label in
                        CoefficientField(label: label, text: $viewModel.coefficients[index])
                    }
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
    private func resultCard(_ result: EquationResultState) -> some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.s) {
                MathView(
                    latex: result.equationLatex,
                    fontSize: 22,
                    color: UIColor(AppColor.textPrimary)
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                if let tableau = result.ruffiniTableau {
                    Text("División por Ruffini")
                        .font(.subheadline)
                        .foregroundStyle(AppColor.textSecondary)
                    RuffiniTableView(tableau: tableau)
                        .fitToWidth()
                }

                if showDetailedSteps, !result.steps.isEmpty {
                    Text("Procedimiento")
                        .font(.subheadline)
                        .foregroundStyle(AppColor.textSecondary)
                    StepListView(steps: result.steps)
                }

                Divider().overlay(AppColor.border)

                MathView(
                    latex: result.solutionLatex,
                    fontSize: 26,
                    color: UIColor(AppColor.mint),
                    accessibilityLabelText: result.summary
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
