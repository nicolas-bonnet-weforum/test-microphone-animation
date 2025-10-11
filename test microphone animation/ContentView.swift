//
//  ContentView.swift
//  test microphone animation
//
//  Created by Nicolas Bonnet on 11.10.2025.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var selectedStyle: AnimationStyle = .meshWave
    @State private var showStylePicker = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Style picker button
                HStack {
                    Spacer()
                    Button(action: {
                        showStylePicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: "waveform.circle.fill")
                            Text(selectedStyle.rawValue)
                        }
                        .foregroundColor(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(20)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Animated waves
                Group {
                    switch selectedStyle {
                    case .meshWave:
                        MeshWaveView(audioRecorder: audioRecorder)
                    case .circularPulse:
                        CircularPulseView(audioRecorder: audioRecorder)
                    case .bars:
                        FrequencyBarsView(audioRecorder: audioRecorder)
                    }
                }
                .frame(height: 400)
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Recording button
                Button(action: {
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                    } else {
                        audioRecorder.startRecording()
                    }
                }) {
                    ZStack {
                        Circle()
                            .stroke(Color.green, lineWidth: 3)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(audioRecorder.isRecording ? Color.red : Color.green)
                            .frame(width: audioRecorder.isRecording ? 30 : 60, height: audioRecorder.isRecording ? 30 : 60)
                            .animation(.spring(), value: audioRecorder.isRecording)
                    }
                }
                .padding(.bottom, 40)
                
                Text(audioRecorder.isRecording ? "Recording..." : "Tap to Record")
                    .foregroundColor(.green)
                    .font(.headline)
            }
        }
        .sheet(isPresented: $showStylePicker) {
            StylePickerView(selectedStyle: $selectedStyle)
        }
    }
}

#Preview {
    ContentView()
}
                
#Preview {
    ContentView()
}
