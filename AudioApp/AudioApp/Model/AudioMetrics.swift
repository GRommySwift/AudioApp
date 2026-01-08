//
//  AudioMetrics.swift
//  AudioApp
//
//  Created by Roman on 06/01/2026.
//

import Foundation

struct AudioMetrics {
    var duration: TimeInterval
    let sampleRate: Double
    let channels: UInt32

    let rms: Float
    let peak: Float
    let silenceRatio: Float
    let zeroCrossingRate: Float
    let dcOffset: Float
    let dynamicRange: Float
}
