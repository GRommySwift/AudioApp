//
//  AudioPlayer.swift
//  AudioApp
//
//  Created by Roman on 06/01/2026.
//

import AVFoundation

final class AudioPlayer {
    
    private let engine = AVAudioEngine()
    private var player = AVAudioPlayerNode()
    
    private var file: AVAudioFile?
    private var isItPlaying = false
    private var pauseFrame: AVAudioFramePosition = 0
    
    init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        try? engine.start()
    }
    
    func play(file: AVAudioFile) {
        self.file = file
        schedule(startFrame: pauseFrame)
        player.play()
        isItPlaying = true
    }
    
    func pause() {
        guard isItPlaying else { return }
        player.pause()
        isItPlaying = false
    }
    
    func stop() {
        player.stop()
        isItPlaying = false
    }
    
    func setVolume(_ value: Float) {
        engine.mainMixerNode.outputVolume = value
    }
    
    func volume() -> Float {
        engine.mainMixerNode.outputVolume
    }
    
    func seek(to time: TimeInterval) {
        guard let file = file else { return }
        let frame = AVAudioFramePosition(time * file.processingFormat.sampleRate)
        pauseFrame = frame
        if isItPlaying {
            schedule(startFrame: pauseFrame)
            player.play()
        }
    }
    
    func currentTime() -> TimeInterval {
        guard let file = file,
              let nodeTime = player.lastRenderTime,
              let playerTime = player.playerTime(forNodeTime: nodeTime)
        else { return Double(pauseFrame) / (file?.processingFormat.sampleRate ?? 1) }
        
        return Double(pauseFrame + playerTime.sampleTime) / file.processingFormat.sampleRate
    }
    
    private func schedule(startFrame: AVAudioFramePosition) {
        guard let file = file else { return }
        player.stop()
        let framesToPlay = AVAudioFrameCount(file.length - startFrame)
        player.scheduleSegment(file, startingFrame: startFrame, frameCount: framesToPlay, at: nil)
    }
    
    func resetPauseFrame() {
        self.pauseFrame = 0
    }
}
