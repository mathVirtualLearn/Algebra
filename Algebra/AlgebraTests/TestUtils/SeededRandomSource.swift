@testable import Algebra

final class SeededRandomSource: RandomSource {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed &+ 0x9E3779B97F4A7C15
    }

    func int(in range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        let bits = state >> 33
        let span = UInt64(range.upperBound - range.lowerBound + 1)
        return range.lowerBound + Int(bits % span)
    }
}
