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
            ForEach(0..<8) { index in
                OrganicCircleShape(
                    phase: audioRecorder.phase + Double(index) * 0.5,
                    index: index
                )
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.7, green: 0.9, blue: 0.2).opacity(0.7 - Double(index) * 0.08),
                            Color(red: 0.2, green: 0.8, blue: 0.2).opacity(0.7 - Double(index) * 0.08),
                            Color(red: 0.2, green: 0.8, blue: 0.6).opacity(0.7 - Double(index) * 0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(
                    width: 40 + CGFloat(index) * 50 + audioRecorder.audioLevel * 180,
                    height: 40 + CGFloat(index) * 50 + audioRecorder.audioLevel * 180
                )
            }
        }
    }
}

// MARK: - Organic Circle Shape
struct OrganicCircleShape: Shape {
    var phase: Double
    var index: Int
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2
        
        let points = 60
        for i in 0...points {
            let angle = (Double(i) / Double(points)) * 2 * .pi
            
            // Add organic variation to radius
            let wave1 = sin(angle * 3 + phase) * 0.05
            let wave2 = sin(angle * 5 + phase * 1.3) * 0.03
            let wave3 = sin(angle * 7 + phase * 0.7) * 0.02
            
            let variation = 1 + wave1 + wave2 + wave3
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
