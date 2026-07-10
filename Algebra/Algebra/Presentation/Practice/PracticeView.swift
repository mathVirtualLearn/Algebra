import SwiftUI

struct PracticeView: View {
    @State private var viewModel: PracticeViewModel

    init(viewModel: PracticeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                typeSelector(viewModel: viewModel)
                statementCard(viewModel: viewModel)
                answerCard(viewModel: viewModel)
                actions(viewModel: viewModel)
                if let result = viewModel.result {
                    feedback(result)
                }
                if viewModel.showSolution {
                    solutionCard(viewModel: viewModel)
                }
            }
            .padding(Spacing.m)
        }
        .scrollContentBackground(.hidden)
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("Práctica")
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
        }
    }

    @ViewBuilder
    private func typeSelector(viewModel: PracticeViewModel) -> some View {
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

    @ViewBuilder
    private func statementCard(viewModel: PracticeViewModel) -> some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Enunciado")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
                if viewModel.isSystem {
                    ForEach(Array(viewModel.systemEquationsLatex.enumerated()), id: \.offset) { _, eq in
                        MathView(
                            latex: eq,
                            fontSize: 20,
                            color: UIColor(AppColor.textPrimary)
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    MathView(
                        latex: viewModel.exerciseLatex,
                        fontSize: 24,
                        color: UIColor(AppColor.textPrimary)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    @ViewBuilder
    private func answerCard(viewModel: PracticeViewModel) -> some View {
        @Bindable var viewModel = viewModel
        Card {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Tu respuesta")
                    .font(.headline)
                    .foregroundStyle(AppColor.textPrimary)
                if viewModel.isSystem {
                    ForEach(Array(viewModel.variableLabels.enumerated()), id: \.offset) { index, label in
                        CoefficientField(label: "\(label) =", text: $viewModel.systemAnswers[index])
                    }
                } else {
                    TextField("Soluciones separadas por comas (p. ej. 2, -1, 3)", text: $viewModel.answer)
                        .keyboardType(.numbersAndPunctuation)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .foregroundStyle(AppColor.textPrimary)
                        .padding(.horizontal, Spacing.s)
                        .padding(.vertical, Spacing.xs)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColor.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .accessibilityLabel(Text("Respuesta"))
                    Text("El orden no importa")
                        .font(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
        }
    }

    @ViewBuilder
    private func actions(viewModel: PracticeViewModel) -> some View {
        VStack(spacing: Spacing.s) {
            PrimaryButton(title: "Comprobar") {
                hideKeyboard()
                viewModel.check()
            }
            HStack(spacing: Spacing.l) {
                Button {
                    hideKeyboard()
                    viewModel.next()
                } label: {
                    Text("Otro ejercicio")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .buttonStyle(.plain)
                Button {
                    hideKeyboard()
                    viewModel.revealSolution()
                } label: {
                    Text("Ver solución")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColor.accent)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func feedback(_ result: Bool) -> some View {
        if result {
            Text("¡Correcto! 🎉")
                .font(.headline)
                .foregroundStyle(AppColor.mint)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityLabel(Text("Correcto"))
        } else {
            Text("No es correcto. Inténtalo de nuevo o mira la solución.")
                .font(.subheadline)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private func solutionCard(viewModel: PracticeViewModel) -> some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.s) {
                if !viewModel.steps.isEmpty {
                    Text("Procedimiento")
                        .font(.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    StepListView(steps: viewModel.steps)
                }
                if let solutionLatex = viewModel.solutionLatex {
                    Divider().overlay(AppColor.border)
                    MathView(
                        latex: solutionLatex,
                        fontSize: 24,
                        color: UIColor(AppColor.mint)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
