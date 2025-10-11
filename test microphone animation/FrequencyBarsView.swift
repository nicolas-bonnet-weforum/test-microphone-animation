//
//  FrequencyBarsView.swift
//  test microphone animation
//
//  Created by Nicolas Bonnet on 11.10.2025.
//

import SwiftUI

struct FrequencyBarsView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            ForEach(0..<30) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.7, green: 0.9, blue: 0.2),
                                Color(red: 0.2, green: 0.8, blue: 0.2),
                                Color(red: 0.2, green: 0.8, blue: 0.6)
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(
                        width: 8,
                        height: calculateBarHeight(index: index)
                    )
            }
        }
    }
    
    private func calculateBarHeight(index: Int) -> CGFloat {
        let baseHeight: CGFloat = 40
        let maxHeight: CGFloat = 320
        
        // Create varying heights based on position and audio level
        let wave1 = sin(Double(index) * 0.5 + audioRecorder.phase * 0.4)
        let wave2 = sin(Double(index) * 0.3 + audioRecorder.phase * 0.6)
        
        // Combine waves for organic variation
        let combinedWave = (wave1 * 0.6 + wave2 * 0.4 + 1) / 2
        
        let amplitude = audioRecorder.audioLevel
        
        return baseHeight + (maxHeight - baseHeight) * amplitude * CGFloat(combinedWave)
    }
}
