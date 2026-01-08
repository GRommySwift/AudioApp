//
//  Waveform.swift
//  AudioApp
//
//  Created by Roman on 06/01/2026.
//

import SwiftUI

struct WaveformView: View {
    let waveform: [Float]
    let currentTime: TimeInterval
    let duration: TimeInterval
    let onSeek: (TimeInterval) -> Void
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            ZStack(alignment: .leading) {
                Path { path in
                    let step = max(1, waveform.count / Int(width))
                    for i in stride(from: 0, to: waveform.count, by: step) {
                        let x = CGFloat(i) / CGFloat(waveform.count) * width
                        let y = height * (1 - CGFloat(waveform[i]))
                        path.move(to: CGPoint(x: x, y: height))
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color.blue, lineWidth: 1)
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 2, height: height)
                    .offset(x: CGFloat(currentTime / duration) * width)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let percent = min(max(value.location.x / width, 0), 1)
                        let time = duration * percent
                        onSeek(time)
                    }
            )
        }
    }
}
