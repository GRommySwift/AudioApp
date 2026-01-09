//
//  AudioAnalizer.swift
//  AudioApp
//
//  Created by Roman on 06/01/2026.
//

import AVFoundation

final class AudioAnalyzer {
    
    func analyze(file: AVAudioFile, buffer: AVAudioPCMBuffer) async -> AudioMetrics {

        return await Task.detached(priority: .userInitiated) {
            let format = file.processingFormat
            let sampleRate = format.sampleRate
            let channels = format.channelCount
            let frameLength = Int(buffer.frameLength)
            let fileName = file.url.lastPathComponent
            let duration = Double(file.length) / sampleRate
            
            guard let channelData = buffer.floatChannelData else {
                fatalError("No float data")
            }
            let samples = channelData[0]
            
            var sum: Float = 0
            var peak: Float = 0
            var silenceCount = 0
            var crossingsCount = 0
            var dcSum: Float = 0
            
            for i in 0..<frameLength {
                let s = samples[i]
                sum += s * s
                peak = max(peak, abs(s))
                if abs(s) < 0.01 { silenceCount += 1 }
                dcSum += s
                if i > 0 && samples[i-1] * s < 0 { crossingsCount += 1 }
            }
            
            let rms = sqrt(sum / Float(frameLength))
            let silenceRatio = Float(silenceCount) / Float(frameLength)
            let crossingRate = Float(crossingsCount) / Float(frameLength - 1)
            let dcOffset = dcSum / Float(frameLength)
            let dynamicRange = peak - rms
            
            return AudioMetrics(
                fileName: fileName,
                duration: duration,
                sampleRate: sampleRate / 1000,
                channels: channels,
                rms: rms,
                peak: peak,
                silenceRatio: silenceRatio * 100,
                zeroCrossingRate: crossingRate * 100,
                dcOffset: dcOffset * 100,
                dynamicRange: dynamicRange
            )
        }.value
    }
}
