//
//  ContentView.swift
//  AudioApp
//
//  Created by Roman on 06/01/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AudioViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            openFile()
            
            if let metrics = viewModel.metrics {
                audioInfo(metrics)
                
                if !viewModel.waveform.isEmpty {
                    waveForm()
                        .frame(height: 150)
                        .background(Color.black.opacity(0.1))
                }
                
                ZStack {
                    currentTimeIndicator(metrics)
                    playAndStopButtons()
                    volumeSlider()
                }
                .padding(.top, -10)
                .padding(.horizontal)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

private extension ContentView {
    
    func openFile() -> some View {
        VStack(alignment: .center, spacing: 5) {
            Button("Open Audio File") {
                Task {
                    await viewModel.openFile()
                }
            }
            .padding(.top, 5)
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.top, 20)
                Slider(
                    value: Binding(
                        get: {viewModel.volume},
                        set: {viewModel.setVolume($0)}
                    ),
                    in: 0...1
                )
            }
        }
    }
    
    func audioInfo(_ metrics: AudioMetrics) -> some View {
        HStack(spacing: 100) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Duration: \(String(format: "%.2f", metrics.duration))s")
                Text("Sample Rate: \(Int(metrics.sampleRate)) Hz")
                Text("Channels: \(metrics.channels)")
                Text("RMS: \(String(format: "%.2f", metrics.rms))")
                Text("Peak: \(String(format: "%.2f", metrics.peak))")
            }
            VStack(alignment: .leading, spacing: 5) {
                Text("Silence Ratio: \(metrics.silenceRatio)")
                Text("Zero crossing rate: \(metrics.zeroCrossingRate)")
                Text("DC offset: \(metrics.dcOffset)")
                Text("Dynamic range: \(String(format: "%.2f", metrics.dynamicRange))")
            }
        }
        .font(.system(.body, design: .monospaced))
    }
    
    func waveForm() -> WaveformView {
        WaveformView(
            waveform: viewModel.waveform,
            currentTime: viewModel.currentTime,
            duration: viewModel.metrics?.duration ?? 1,
            onSeek: { time in
                viewModel.seek(to: time)
            }
        )
    }
    
    func currentTimeIndicator(_ metrics: AudioMetrics) -> some View {
        HStack {
            Text("\(viewModel.formatTime(viewModel.currentTime)) / \(viewModel.formatTime(metrics.duration))")
                .font(.system(size: 13, design: .monospaced))
                .frame(width: 90, alignment: .leading)
            Spacer()
        }
    }
    
    func playAndStopButtons() -> some View {
        HStack(spacing: 5) {
            Button {
                viewModel.stop()
            } label: {
                Image(systemName: "stop.circle.fill")
                    .font(Font(.init(.system, size: 40)))
            }
            .buttonStyle(.plain)
            
            Button {
                viewModel.isPlaying ? viewModel.pause() : viewModel.play()
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 40))
            }
            .buttonStyle(.plain)
        }
    }
    
    func volumeSlider() -> some View {
        HStack {
            Spacer()
            HStack {
                Image(systemName: "speaker.fill")
                Slider(
                    value: Binding(
                        get: {viewModel.volume},
                        set: {viewModel.setVolume($0)}
                    ),
                    in: 0...1
                )
                Image(systemName: "speaker.wave.3.fill")
            }
            .frame(maxWidth: 180)
        }
    }
}
