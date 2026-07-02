import SwiftUI

struct SystemsView: View {
    @State private var viewModel: SystemsViewModel
    @Environment(\.showDetailedSteps) private var showDetailedSteps

    init(viewModel: SystemsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                sizeSelector(viewModel: viewModel)
                methodSelector(viewModel: viewModel)
                systemCard(viewModel: viewModel)
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
        .navigationTitle("Sistemas")
    }

    @ViewBuilder
    private func sizeSelector(viewModel: SystemsViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Tamaño del sistema")
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
            HStack(spacing: Spacing.xs) {
                ForEach(Array(viewModel.sizeTitles.enumerated()), id: \.offset) { index, title in
                    TypeChip(title: title, isSelected: viewModel.sizeIndex == index) {
                        viewModel.sizeIndex = index
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func methodSelector(viewModel: SystemsViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Método")
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(Array(viewModel.methodTitles.enumerated()), id: \.offset) { index, title in
                        TypeChip(title: title, isSelected: viewModel.methodIndex == index) {
                            viewModel.methodIndex = index
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func systemCard(viewModel: SystemsViewModel) -> some View {
        @Bindable var viewModel = viewModel
        let n = viewModel.equationCount
        Card {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Ecuaciones")
                    .font(.headline)
                    .foregroundStyle(AppColor.textPrimary)
                ForEach(0..<n, id: \.self) { i in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.xs) {
                            ForEach(0..<n, id: \.self) { j in
                                if j > 0 {
                                    Text("+")
                                        .foregroundStyle(AppColor.textSecondary)
                                }
                                inlineField($viewModel.coefficients[i][j])
                                Text(viewModel.variableSymbols[j])
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                            Text("=")
                                .foregroundStyle(AppColor.textSecondary)
                            inlineField($viewModel.constants[i])
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func inlineField(_ text: Binding<String>) -> some View {
        TextField("0", text: text)
            .keyboardType(.numbersAndPunctuation)
            .multilineTextAlignment(.center)
            .frame(width: 44)
            .padding(.vertical, Spacing.xxs)
            .background(AppColor.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(AppColor.textPrimary)
            .accessibilityLabel(Text("Coeficiente"))
    }

    @ViewBuilder
    private func errorCard(_ message: String) -> some View {
        Card {
            Label(message, systemImage: "exclamationmark.triangle")
                .foregroundStyle(.red)
        }
    }

    @ViewBuilder
    private func resultCard(_ result: SystemResultState) -> some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.s) {
                ForEach(Array(result.equationsLatex.enumerated()), id: \.offset) { _, eq in
                    MathView(
                        latex: eq,
                        fontSize: 20,
                        color: UIColor(AppColor.textPrimary)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                    fontSize: 24,
                    color: UIColor(AppColor.mint),
                    accessibilityLabelText: result.summary
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
