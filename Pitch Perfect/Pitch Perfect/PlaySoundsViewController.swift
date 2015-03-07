//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Brian Ortega on 3/4/15.
//  Copyright (c) 2015 AZC. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    var audioPlayer:AVAudioPlayer!
    var audioEngine:AVAudioEngine!
    var audioFile: AVAudioFile!
    var receivedAudio:RecordedAudio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up audio players (audio engine required for complex effects)
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathURL, error: nil)
        audioPlayer.enableRate = true
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathURL, error: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        playAudioWithVariableRate(0.5)
    }
    
    @IBAction func playFastAudio(sender: UIButton) {
        playAudioWithVariableRate(2.0)
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        stopAllAudio()
    }

    @IBAction func playDryReverbAudio(sender: UIButton) {
        playAudioWithVariableReverb(25)
    }
    
    @IBAction func playWetReverbAudio(sender: UIButton) {
        playAudioWithVariableReverb(75)
    }
    
    func playAudioWithVariableRate(rate: Float) {
        // Rate can range from 0.5 to 2.0
        stopAllAudio()
        
        audioPlayer.rate = rate
        audioPlayer.play()
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        // Pitch can range from -2400 to 2400
        stopAllAudio()
        
        let playerNode = AVAudioPlayerNode()
        let avPitch = AVAudioUnitTimePitch()
        avPitch.pitch = pitch
        
        audioEngine.attachNode(playerNode)
        audioEngine.attachNode(avPitch)
        
        audioEngine.connect(playerNode, to: avPitch, format: nil)
        audioEngine.connect(avPitch, to: audioEngine.outputNode, format: nil)
        
        playerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        playerNode.play()
    }
    
    func playAudioWithVariableReverb(reverb: Float) {
        // Reverb (wetDryMix) can range from 0 to 100
        stopAllAudio()
        
        let playerNode = AVAudioPlayerNode()
        let avReverb = AVAudioUnitReverb()
        avReverb.wetDryMix = reverb
        
        audioEngine.attachNode(playerNode)
        audioEngine.attachNode(avReverb)
        
        audioEngine.connect(playerNode, to: avReverb, format: nil)
        audioEngine.connect(avReverb, to: audioEngine.outputNode, format: nil)
        
        playerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        playerNode.play()
    }
    
    func stopAllAudio() {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        audioEngine.stop()
        audioEngine.reset()
    }
}
