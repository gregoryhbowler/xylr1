import Foundation
import Accelerate

/// Spectral time-stretching effect using magnitude-preserving FFT with
/// randomized phase resynthesis (PaulXStretch approach).
///
/// The input is analyzed via FFT to extract magnitude spectrum. Output frames
/// are synthesized with the same magnitudes but randomized phases, then
/// overlap-added with a Hann window. The stretch factor controls how slowly
/// new input frames are consumed.
///
/// Reference: PaulXStretch (essej/paulxstretch)
public final class TimeStretch: ObservableObject {
    @Published public var dryWet: Float = 0
    @Published public var stretchFactor: Float = 1.0   // 1.0 = normal, 2.0 = 2x slower
    @Published public var fftSizeLog2: Int = 11          // 2^11 = 2048

    // Internal DSP state
    private var fftSize: Int = 2048
    private var halfFFT: Int = 1024
    private var inputHistory: [Float] = []
    private var prevInputFrame: [Float] = []
    private var outputAccumulator: [Float] = []
    private var window: [Float] = []
    private var magnitudes: [Float] = []
    private var remainedSamples: Double = 0

    // vDSP FFT
    private var fftSetup: vDSP_DFT_Setup?
    private var realPart: [Float] = []
    private var imagPart: [Float] = []

    private var isInitialized = false

    public init() {
        setupFFT(sizeLog2: 11)
    }

    private func setupFFT(sizeLog2: Int) {
        fftSize = 1 << sizeLog2
        halfFFT = fftSize / 2

        inputHistory = Array(repeating: 0, count: fftSize)
        prevInputFrame = Array(repeating: 0, count: halfFFT)
        outputAccumulator = Array(repeating: 0, count: fftSize)
        magnitudes = Array(repeating: 0, count: halfFFT)
        window = Array(repeating: 0, count: fftSize)
        realPart = Array(repeating: 0, count: halfFFT)
        imagPart = Array(repeating: 0, count: halfFFT)

        // Hann window
        vDSP_hann_window(&window, vDSP_Length(fftSize), Int32(vDSP_HANN_NORM))

        fftSetup = vDSP_DFT_zrop_CreateSetup(nil, vDSP_Length(fftSize), .FORWARD)

        remainedSamples = 0
        isInitialized = true
    }

    public func process(buffer: UnsafeMutablePointer<Float>, sampleCount: Int) {
        guard dryWet > 0, isInitialized, stretchFactor > 0 else { return }

        let readRate = 1.0 / Double(stretchFactor)
        var outputIndex = 0

        while outputIndex < sampleCount {
            // Check if we need to synthesize a new output frame
            if outputIndex == 0 || remainedSamples <= 0 {
                // Feed input into history buffer
                let feedCount = min(sampleCount - outputIndex, halfFFT)
                for i in 0..<feedCount {
                    // Shift history left by feedCount, append new samples
                    if outputIndex + i < sampleCount {
                        inputHistory.append(buffer[outputIndex + i])
                        if inputHistory.count > fftSize {
                            inputHistory.removeFirst()
                        }
                    }
                }

                // Pad if needed
                while inputHistory.count < fftSize {
                    inputHistory.append(0)
                }

                // Analysis: window and FFT
                var windowed = [Float](repeating: 0, count: fftSize)
                vDSP_vmul(inputHistory, 1, window, 1, &windowed, 1, vDSP_Length(fftSize))

                // Forward FFT — extract magnitudes only
                analyzeFrame(windowed)

                // Synthesis: random phases + inverse FFT
                synthesizeFrame()

                remainedSamples = Double(halfFFT)
            }

            // Read from output accumulator
            let readCount = min(sampleCount - outputIndex, Int(remainedSamples))
            let accOffset = halfFFT - Int(remainedSamples)
            for i in 0..<readCount {
                let accIdx = accOffset + i
                guard accIdx >= 0, accIdx < outputAccumulator.count else { continue }
                let dry = buffer[outputIndex]
                let wet = outputAccumulator[accIdx]
                buffer[outputIndex] = dry * (1 - dryWet) + wet * dryWet
                outputIndex += 1
            }
            remainedSamples -= Double(readCount) * readRate
        }
    }

    private func analyzeFrame(_ windowed: [Float]) {
        // Simple DFT magnitude extraction via Accelerate
        guard windowed.count == fftSize else { return }

        // Split into even/odd for real FFT
        var splitReal = [Float](repeating: 0, count: halfFFT)
        var splitImag = [Float](repeating: 0, count: halfFFT)

        for i in 0..<halfFFT {
            splitReal[i] = windowed[i * 2]
            splitImag[i] = windowed[i * 2 + 1]
        }

        if let setup = fftSetup {
            vDSP_DFT_Execute(setup, splitReal, splitImag, &realPart, &imagPart)
        }

        // Extract magnitudes
        for i in 0..<halfFFT {
            magnitudes[i] = sqrtf(realPart[i] * realPart[i] + imagPart[i] * imagPart[i])
        }
    }

    private func synthesizeFrame() {
        // Reconstruct with randomized phases (the PaulXStretch trick)
        var synthReal = [Float](repeating: 0, count: halfFFT)
        var synthImag = [Float](repeating: 0, count: halfFFT)

        for i in 0..<halfFFT {
            let phase = Float.random(in: 0..<(2.0 * .pi))
            synthReal[i] = magnitudes[i] * cosf(phase)
            synthImag[i] = magnitudes[i] * sinf(phase)
        }
        // DC and Nyquist are real
        synthImag[0] = 0

        // Inverse FFT
        if let invSetup = vDSP_DFT_zrop_CreateSetup(nil, vDSP_Length(fftSize), .INVERSE) {
            var outReal = [Float](repeating: 0, count: halfFFT)
            var outImag = [Float](repeating: 0, count: halfFFT)
            vDSP_DFT_Execute(invSetup, synthReal, synthImag, &outReal, &outImag)
            vDSP_DFT_DestroySetup(invSetup)

            // Interleave back to time domain
            let scale = 1.0 / Float(fftSize)
            for i in 0..<halfFFT {
                let idx = i * 2
                if idx < fftSize {
                    outputAccumulator[idx] = outReal[i] * scale
                }
                if idx + 1 < fftSize {
                    outputAccumulator[idx + 1] = outImag[i] * scale
                }
            }

            // Apply synthesis window
            vDSP_vmul(outputAccumulator, 1, window, 1, &outputAccumulator, 1, vDSP_Length(fftSize))
        }
    }

    public func randomize() {
        stretchFactor = Float.random(in: 0.5...4.0)
        dryWet = Float.random(in: 0.3...1.0)
    }
}
