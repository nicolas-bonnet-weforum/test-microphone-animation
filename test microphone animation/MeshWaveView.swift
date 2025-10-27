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
                            Color(red: 0.18, green: 0.41, blue: 1.00).opacity(0.8),
                            Color(red: 0.93, green: 0.42, blue: 1.00).opacity(0.8)
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
            let wave4 = sin((relativeX * 5.7 * 2 * .pi) + phase * 1.8) // Additional high-frequency noise
            let wave5 = sin((relativeX * 7.3 * 2 * .pi) + phase * 2.1) // More high-frequency detail
            
            // Combine waves with more balanced weights and reduced base noise
            let baseNoise = 0.08 // Reduced always present noise
            let combinedWave = (wave1 * 0.4 + wave2 * 0.3 + wave3 * 0.2 + wave4 * 0.08 + wave5 * 0.05) + baseNoise
            
            // Top base wave with increased amplitude impact
            let topY = midHeight - height * 0.04 + (combinedWave * (amplitude * 200 + 10))
            
            // Bottom base wave with different phase
            let bottomWave1 = sin((relativeX * 2.2 * 2 * .pi) + phase + 0.5)
            let bottomWave2 = sin((relativeX * 3.0 * 2 * .pi) + phase * 1.5)
            let bottomWave3 = sin((relativeX * 1.5 * 2 * .pi) + phase * 0.9)
            let bottomWave4 = sin((relativeX * 6.1 * 2 * .pi) + phase * 2.3) // Additional noise
            let bottomWave5 = sin((relativeX * 8.2 * 2 * .pi) + phase * 1.7) // More detail
            let combinedBottomWave = (bottomWave1 * 0.4 + bottomWave2 * 0.3 + bottomWave3 * 0.2 + bottomWave4 * 0.08 + bottomWave5 * 0.05) + baseNoise
            
            let bottomY = midHeight + height * 0.04 + (combinedBottomWave * (amplitude * 200 + 10))
            
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
