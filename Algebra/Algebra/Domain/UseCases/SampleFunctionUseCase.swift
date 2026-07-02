import Foundation

protocol SampleFunctionUseCase: Sendable {
    func execute(expression: FunctionExpr, domain: ClosedRange<Double>, count: Int) -> [FunctionSample]
}

struct SampleFunctionUseCaseImpl: SampleFunctionUseCase {
    // Muestrea la función en 'count' puntos equiespaciados del dominio, descartando valores no finitos.
    func execute(expression: FunctionExpr, domain: ClosedRange<Double>, count: Int) -> [FunctionSample] {
        let pointCount = max(count, 2)
        let lower = domain.lowerBound
        let upper = domain.upperBound
        let step = (upper - lower) / Double(pointCount - 1)

        var samples: [FunctionSample] = []
        samples.reserveCapacity(pointCount)
        for i in 0..<pointCount {
            let x = lower + step * Double(i)
            let y = expression.evaluate(x)

            if y.isFinite {
                samples.append(FunctionSample(x: x, y: y))
            }
        }
        return samples
    }
}
