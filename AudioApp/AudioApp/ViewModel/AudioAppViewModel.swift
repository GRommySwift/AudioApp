//
//  AudioAppViewModel.swift
//  AudioApp
//
//  Created by Roman on 06/01/2026.
//

import SwiftUI
import AVFoundation
import Combine

@MainActor
final class AudioViewModel: ObservableObject {
    
    @Published var metrics: AudioMetrics?
    @Published var waveform: [Float] = []
    @Published var isLoading = false
    @Published var currentTime: TimeInterval = 0
    @Published var isPlaying: Bool = false
    @Published var samples: [Float] = []
    @Published var volume: Float = 0.2
    
    private var timer: Timer?
    private var audioFile: AVAudioFile?
    
    private let player = AudioPlayer()
    private let loader = AudioLoader()
    private let analyzer = AudioAnalyzer()
    private let waveformExtractor = WaveformExtractor()
    
    let spacing: CGFloat = 2
    let width: CGFloat = 2
    
    private func load(url: URL) async {
        isLoading = true
        Task {
            do {
                let file = try await self.loader.load(url: url)
                let buffer = try await self.loader.readPCMBuffer(from: file)
                let metrics = await self.analyzer.analyze(file: file,buffer: buffer)
                let waveform = await self.waveformExtractor.extract(buffer: buffer)
                
                await MainActor.run {
                    self.audioFile = file
                    self.metrics = metrics
                    self.waveform = waveform
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    func openFile() async {
        if audioFile != nil {
            loadNewFile()
        }
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.audio]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url {
            await load(url: url)
        }
    }
    
    func play() {
        guard let file = audioFile else { return }
            player.play(file: file)
            isPlaying = true
            startTimer()
    }
    
    func pause() {
        isPlaying = false
        player.pause()
        seek(to: currentTime)
        stopTimer()
    }
    
    func stop() {
        player.stop()
        player.resetPauseFrame()
        isPlaying = false
        stopTimer()
        currentTime = 0
    }
    
    func setVolume(_ value: Float) {
        volume = value
        player.setVolume(value)
    }

    func seek(to time: TimeInterval) {
        player.seek(to: time)
        currentTime = time
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                guard self.audioFile != nil else { return }
                self.currentTime = self.player.currentTime()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite else { return "0:00" }

        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func loadNewFile() {
        stopTimer()
        player.stop()
        player.resetPauseFrame()
        self.audioFile = nil
        self.metrics = nil
        self.waveform = []
        self.currentTime = 0
        self.metrics?.duration = 0
        self.isPlaying = false
    }
}
