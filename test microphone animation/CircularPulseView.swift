//
//  CircularPulseView.swift
//  test microphone animation
//
//  Created by Nicolas Bonnet on 11.10.2025.
//

import SwiftUI

struct CircularPulseView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    
    var body: some View {
        ZStack {
            ForEach(0..<15) { index in
                OrganicCircleShape(
                    phase: audioRecorder.phase * 0.4 + Double(index) * 0.3,
                    index: index,
                    audioLevel: audioRecorder.audioLevel
                )
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.7, green: 0.9, blue: 0.2).opacity(0.8),
                            Color(red: 0.2, green: 0.8, blue: 0.2).opacity(0.8),
                            Color(red: 0.2, green: 0.8, blue: 0.6).opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(
                    width: 120 + CGFloat(index) * 4 + audioRecorder.audioLevel * 100,
                    height: 120 + CGFloat(index) * 4 + audioRecorder.audioLevel * 100
                )
                .animation(.linear(duration: 0.016), value: audioRecorder.audioLevel)
            }
        }
    }
}

// MARK: - Organic Circle Shape
struct OrganicCircleShape: Shape {
    var phase: Double
    var index: Int
    var audioLevel: CGFloat
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2
        
        let points = 120
        for i in 0...points {
            let angle = (Double(i) / Double(points)) * 2 * .pi
            
            // Create flowing wave patterns similar to the image
            let wave1 = sin(angle * 2 + phase) * 0.12
            let wave2 = sin(angle * 4 + phase * 1.5) * 0.08
            let wave3 = sin(angle * 6 - phase * 0.8) * 0.05
            let wave4 = cos(angle * 3 + phase * 1.2) * 0.06
            
            // Add audio reactivity
            let audioVariation = audioLevel * 0.15
            
            let variation = 1 + wave1 + wave2 + wave3 + wave4 + audioVariation
            let radius = baseRadius * variation
            
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}
