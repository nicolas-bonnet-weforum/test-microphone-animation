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
    @Published var audioLevel: CGFloat = 0.12
    @Published var phase: Double = 0
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var animationTimer: Timer?
    private var idleWavePhase: Double = 0
    private var recordingStartTime: Date?
    
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
            
            // Apply idle level when audio is below threshold (regardless of recording state)
            // This ensures smooth continuity when switching between idle and recording
            if self.audioLevel < 0.18 {
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
            recordingStartTime = Date()
            
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
        
        // Ignore audio spikes during the first 1.0 seconds of recording (microphone warmup)
        if let startTime = recordingStartTime {
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < 1.0 {
                return
            }
        }
        
        // Get average power for channel 0 (ranges from -160 to 0)
        let averagePower = recorder.averagePower(forChannel: 0)
        
        // Map to a reasonable range: silence (-160 to -40 dB) -> 0.12, loud sound (-40 to 0 dB) -> 1.0
        let newLevel: CGFloat
        if averagePower < -40 {
            // Silence or very quiet - keep at idle level
            newLevel = 0.12
        } else {
            // Real sound detected - map -40dB to 0dB -> 0.12 to 1.0
            let soundRange = (averagePower + 40) / 40
            newLevel = CGFloat(0.12 + (soundRange * 0.88))
        }
        
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
