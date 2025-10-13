//
//  AudioRecorder.swift
//  test microphone animation
//
//  Created by Nicolas Bonnet on 11.10.2025.
//

import Foundation
import AVFoundation
import SwiftUI

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var audioLevel: CGFloat = 0.12
    @Published var phase: Double = 0
    
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var animationTimer: Timer?
    private var idleWavePhase: Double = 0
    private var targetAudioLevel: CGFloat = 0.12
    
    override init() {
        super.init()
        setupAudioSession()
        setupAudioEngine()
        startAnimation()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        inputNode = audioEngine.inputNode
        guard let inputNode = inputNode else { return }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
            guard let self = self, self.isRecording else { return }
            
            // Get raw audio samples
            guard let channelData = buffer.floatChannelData else { return }
            let channelDataValue = channelData.pointee
            let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map { channelDataValue[$0] }
            
            // Calculate RMS (root mean square) for audio level
            let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
            
            // Convert RMS to a usable level (0.0 to 1.0 range)
            let level = CGFloat(rms * 10) // Scale up for visibility
            
            DispatchQueue.main.async {
                // Clamp between idle (0.12) and max (1.0)
                let clampedLevel = min(max(level + 0.12, 0.12), 1.0)
                
                // Store target level for smooth interpolation
                self.targetAudioLevel = clampedLevel
            }
        }
    }
    
    private func startAnimation() {
        // Start phase animation for wave movement
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.phase += 0.1
            self.idleWavePhase += 0.05
            
            // Apply idle animation when not recording
            if !self.isRecording {
                // Calculate idle animation level with gentle waves
                let wave1 = sin(self.idleWavePhase * 0.5) * 0.02
                let wave2 = sin(self.idleWavePhase * 0.3) * 0.015
                let idleLevel = 0.12 + wave1 + wave2
                self.audioLevel = idleLevel
            } else {
                // Smooth interpolation to target level (ease-out effect)
                let diff = self.targetAudioLevel - self.audioLevel
                // Interpolate: move 40% of the distance each frame at 60fps (~0.08s to reach 95%)
                self.audioLevel += diff * 0.4
            }
        }
    }
    
    func startRecording() {
        guard let audioEngine = audioEngine else { return }
        
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            print("Could not start audio engine: \(error)")
        }
    }
    
    func stopRecording() {
        audioEngine?.stop()
        isRecording = false
        // Audio level will return to idle animation automatically from the timer
    }
}
