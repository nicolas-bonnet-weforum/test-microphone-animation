//
//  MeshWaveView.swift
//  test microphone animation
//
//  Created by Nicolas Bonnet on 11.10.2025.
//

import SwiftUI

struct MeshWaveView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    
    var body: some View {
        ZStack {
            ForEach(0...15, id: \.self) { lineIndex in
                WaveLineShape(
                    amplitude: audioRecorder.audioLevel,
                    phase: audioRecorder.phase,
                    lineIndex: lineIndex,
                    totalLines: 15
                )
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.7, green: 0.9, blue: 0.2).opacity(0.8),
                            Color(red: 0.2, green: 0.8, blue: 0.2).opacity(0.8),
                            Color(red: 0.2, green: 0.8, blue: 0.6).opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1.5
                )
            }
        }
    }
}

// MARK: - Wave Line Shape
struct WaveLineShape: Shape {
    var amplitude: CGFloat
    var phase: Double
    var lineIndex: Int
    var totalLines: Int
    
    var animatableData: AnimatablePair<CGFloat, Double> {
        get { AnimatablePair(amplitude, phase) }
        set {
            amplitude = newValue.first
            phase = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        let t = CGFloat(lineIndex) / CGFloat(totalLines)
        
        // Create smooth interpolated points
        var points: [CGPoint] = []
        
        let steps = 100
        for i in 0...steps {
            let relativeX = CGFloat(i) / CGFloat(steps)
            let x = relativeX * width
            
            // Create organic wave variations using multiple sine waves at different frequencies
            let wave1 = sin((relativeX * 2.0 * 2 * .pi) + phase)
            let wave2 = sin((relativeX * 3.5 * 2 * .pi) + phase * 1.3)
            let wave3 = sin((relativeX * 1.2 * 2 * .pi) + phase * 0.7)
            
            // Combine waves for organic effect
            let combinedWave = (wave1 * 0.5 + wave2 * 0.3 + wave3 * 0.2)
            
            // Top base wave
            let topY = midHeight - height * 0.08 + (combinedWave * amplitude * 100)
            
            // Bottom base wave with different phase
            let bottomWave1 = sin((relativeX * 2.2 * 2 * .pi) + phase + 0.5)
            let bottomWave2 = sin((relativeX * 3.0 * 2 * .pi) + phase * 1.5)
            let bottomWave3 = sin((relativeX * 1.5 * 2 * .pi) + phase * 0.9)
            let combinedBottomWave = (bottomWave1 * 0.5 + bottomWave2 * 0.3 + bottomWave3 * 0.2)
            
            let bottomY = midHeight + height * 0.08 + (combinedBottomWave * amplitude * 100)
            
            // Interpolate between top and bottom
            let y = topY + (bottomY - topY) * t
            
            points.append(CGPoint(x: x, y: y))
        }
        
        // Use smooth curve through points
        guard points.count > 2 else { return path }
        
        path.move(to: points[0])
        
        for i in 1..<points.count {
            let currentPoint = points[i]
            let previousPoint = points[i - 1]
            
            // Create smooth curves using quadratic bezier
            let midPoint = CGPoint(
                x: (currentPoint.x + previousPoint.x) / 2,
                y: (currentPoint.y + previousPoint.y) / 2
            )
            
            if i == 1 {
                path.addLine(to: midPoint)
            } else {
                path.addQuadCurve(to: midPoint, control: previousPoint)
            }
            
            if i == points.count - 1 {
                path.addQuadCurve(to: currentPoint, control: midPoint)
            }
        }
        
        return path
    }
}
