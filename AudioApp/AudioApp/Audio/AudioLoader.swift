//
//  AudioLoader.swift
//  AudioApp
//
//  Created by Roman on 06/01/2026.
//

import AVFoundation

final class AudioLoader {

    func load(url: URL) async throws -> AVAudioFile {
        try AVAudioFile(forReading: url)
    }

    func readPCMBuffer(from file: AVAudioFile) async throws -> AVAudioPCMBuffer {
        let format = file.processingFormat
        let frameCount = AVAudioFrameCount(file.length)

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: frameCount
        ) else {
            throw NSError(domain: "BufferError", code: -1)
        }

        try file.read(into: buffer)
        return buffer
    }
}
