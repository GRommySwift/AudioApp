//
//  WaveformExtractor.swift
//  AudioApp
//
//  Created by Roman on 06/01/2026.
//

import AVFoundation
import Accelerate

final class WaveformExtractor {
    
    func extract(buffer: AVAudioPCMBuffer, points: Int = 1000, scale: Float = 1) async -> [Float] {
        await Task.detached(priority: .userInitiated) {
            guard let channelData = buffer.floatChannelData else { return [] }
            
            let samples = channelData[0]
            let frameLength = Int(buffer.frameLength)
            let samplesPerPoint = max(frameLength / points, 1)
            
            var waveform: [Float] = []
            
            for i in stride(from: 0, to: frameLength, by: samplesPerPoint) {
                let chunkEnd = min(i + samplesPerPoint, frameLength)
                var sum: Float = 0
                
                for j in i..<chunkEnd {
                    let s = samples[j]
                    sum += s * s
                }
                
                let count = Float(chunkEnd - i)
                let rms = sqrt(sum / max(count, 1))
                
                waveform.append(rms)
            }
            
            guard let maxValue = waveform.max(), maxValue > 0 else {
                return waveform
            }
            
            return waveform.map {
                pow($0 / maxValue, 0.6) * scale
            }
        }.value
    }
}
