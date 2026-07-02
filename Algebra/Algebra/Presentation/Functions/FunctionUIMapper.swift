import Foundation

protocol FunctionUIMapper: Sendable {
    func map(expression: FunctionExpr, samples: [FunctionSample], domain: ClosedRange<Double>) -> FunctionPlotState
}

struct FunctionUIMapperImpl: FunctionUIMapper {
    private let yClampLimit = 50.0
    private let marginRatio = 0.1

    func map(expression: FunctionExpr, samples: [FunctionSample], domain: ClosedRange<Double>) -> FunctionPlotState {
        let points = samples.enumerated().map {
            FunctionPointState(id: $0.offset, x: $0.element.x, y: $0.element.y)
        }
        let yWindow = yWindow(for: samples)
        return FunctionPlotState(
            functionLatex: "y = " + expression.latex(),
            points: points,
            xMin: domain.lowerBound,
            xMax: domain.upperBound,
            yMin: yWindow.min,
            yMax: yWindow.max
        )
    }

    private func yWindow(for samples: [FunctionSample]) -> (min: Double, max: Double) {
        let ys = samples.map(\.y)
        let rawMin = ys.min() ?? -1
        let rawMax = ys.max() ?? 1
        var lower = clamp(rawMin)
        var upper = clamp(rawMax)

        if lower == upper {
            lower -= 1
            upper += 1
        }
        let margin = (upper - lower) * marginRatio
        return (lower - margin, upper + margin)
    }

    private func clamp(_ value: Double) -> Double {
        min(max(value, -yClampLimit), yClampLimit)
    }
}
