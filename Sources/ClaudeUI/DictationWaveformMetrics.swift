import Foundation

/// UI-only waveform contract. Heights/timing for audible input are provisional until
/// measured from the mobile app; the 2.6pt silent dots follow the captured silent state.
public enum DictationWaveformMetrics {
    public static let dotDiameter = 2.6
    public static let sampleSpacing = 6.0
    public static let maximumBarHeight = 24.0
    public static let maximumSamples = 256
    public static func normalized(_ levels: [Double]) -> [Double] {
        levels.suffix(maximumSamples).map { $0.isFinite ? min(1, max(0, $0)) : 0 }
    }
    /// Resamples a host-supplied level window to the available visual columns.
    /// Nonfinite values are silence; all results stay inside the fixed visual bounds.
    public static func barHeights(for levels: [Double], count: Int) -> [Double] {
        let count = min(maximumSamples, max(0, count))
        guard count > 0 else { return [] }
        let samples = normalized(levels)
        guard !samples.isEmpty else { return Array(repeating: dotDiameter, count: count) }
        return (0..<count).map { column in
            let index = count == 1 ? samples.count - 1 : Int(Double(column) * Double(samples.count - 1) / Double(count - 1))
            return max(dotDiameter, samples[index] * maximumBarHeight)
        }
    }
}
