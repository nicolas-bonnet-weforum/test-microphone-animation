//
//  AudioRecorder.swift
//  test microphone animation
//
//  Created by Nicolas Bonnet on 11.10.2025.
//

import Foundation
import AVFoundation
import SwiftUI

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var audioLevel: CGFloat = 0.1
    @Published var phase: Double = 0
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var animationTimer: Timer?
    private var idleWavePhase: Double = 0
    
    override init() {
        super.init()
        setupAudioSession()
        // Start animation immediately
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
    
    private func startAnimation() {
        // Start phase animation for wave movement
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.phase += 0.1
            self.idleWavePhase += 0.05
            
            // Calculate idle animation level
            let wave1 = sin(self.idleWavePhase * 0.5) * 0.02
            let wave2 = sin(self.idleWavePhase * 0.3) * 0.015
            let idleLevel = 0.12 + wave1 + wave2
            
            // Apply idle level when not recording or when recording with low audio
            if !self.isRecording || self.audioLevel < 0.18 {
                self.audioLevel = idleLevel
            }
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            
            // Start monitoring audio levels
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                self?.updateAudioLevel()
            }
            
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        timer?.invalidate()
        // Don't stop animation timer - keep it running
        // Audio level will naturally return to idle state from the animation timer
    }
    
    private func updateAudioLevel() {
        guard let recorder = audioRecorder else { return }
        recorder.updateMeters()
        
        // Get average power for channel 0 (ranges from -160 to 0)
        let averagePower = recorder.averagePower(forChannel: 0)
        
        // Normalize to 0.0 - 1.0 range
        let normalized = max(0, (averagePower + 160) / 160)
        
        // Apply stronger exponential scaling for more dramatic response
        let scaledLevel = pow(normalized, 0.3)
        
        // Calculate the new level
        let newLevel = min(1.0, max(0.05, CGFloat(scaledLevel)))
        
        // Threshold for detecting actual speech (not just background noise)
        let speechThreshold: CGFloat = 0.18
        
        if newLevel > speechThreshold {
            // Speech detected! Update audio level
            withAnimation(.easeOut(duration: 0.08)) {
                audioLevel = newLevel
            }
        }
        // If below threshold, the idle animation from startAnimation() continues
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
