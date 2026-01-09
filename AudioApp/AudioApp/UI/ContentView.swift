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
                .padding(.top, 20)
            audioInfo()
            waveForm()
                .frame(height: 180)
                .background(Color.black.opacity(0.1))
            ZStack {
                currentTimeIndicator()
                playAndStopButtons()
                volumeSlider()
            }
            .padding(.top, -5)
            Spacer()
            Text(viewModel.metrics?.fileName ?? "")
                .font(.system(size: 14, weight: .semibold))
                .padding(.bottom, 10)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

private extension ContentView {
    
    func openFile() -> some View {
        HStack(alignment: .center, spacing: 30) {
            Button("Open Audio File") {
                Task {
                    await viewModel.openFile()
                }
            }
            .frame(height: 20)
            ZStack {
                ProgressView()
                    .opacity(viewModel.isLoading ? 1 : 0)
            }
            .frame(width: 20, height: 20)
        }
        .frame(minHeight: 30, alignment: .top)
        .padding(.vertical, 5)
    }
    
    func audioInfo() -> some View {
        HStack(alignment: .top, spacing: 150) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Duration: \(String(format: "%.2f", viewModel.metrics?.duration ?? "0")) s")
                Text("Sample Rate: \(String(format: "%.1f", viewModel.metrics?.sampleRate ?? "0")) kHz")
                Text("Channels: \(Int(viewModel.metrics?.channels ?? 0))")
                Text("RMS: \(String(format: "%.2f", viewModel.metrics?.rms ?? "0.0")) (norm)")
                Text("Peak: \(String(format: "%.2f", viewModel.metrics?.peak ?? "0.0")) (FS)")
            }
            VStack(alignment: .leading, spacing: 5) {
                Text("Silence Ratio: \(String(format: "%.2f", viewModel.metrics?.silenceRatio ?? "0")) %")
                Text("Zero crossing rate: \(String(format: "%.2f", viewModel.metrics?.zeroCrossingRate ?? 0)) %")
                Text("DC offset: \(String(format: "%.2f", viewModel.metrics?.dcOffset ?? 0)) %")
                Text("Dynamic range: \(String(format: "%.2f", viewModel.metrics?.dynamicRange ?? "0")) (approx)")
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
    
    func currentTimeIndicator() -> some View {
        HStack {
            Text("\(viewModel.formatTime(viewModel.currentTime)) / \(viewModel.formatTime(viewModel.metrics?.duration ?? 0))")
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
            .frame(maxWidth: 180, alignment: .trailing)
        }
    }
}
