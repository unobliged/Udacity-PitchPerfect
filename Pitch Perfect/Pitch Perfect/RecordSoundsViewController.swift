//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Brian Ortega on 3/4/15.
//  Copyright (c) 2015 AZC. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    var pauseButtonState = true // This will be used to toggle the pause button
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        recordButton.enabled = true
    }

    @IBAction func recordAudio(sender: UIButton) {
        // Handles display/hiding of buttons
        recordingLabel.hidden = false
        stopButton.hidden = false
        recordButton.enabled = false
        pauseButton.hidden = false
        
        // Sets up naming and pathing for audioRecorder
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var currentDateTime = NSDate()
        var formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        var recordingName = formatter.stringFromDate(currentDateTime) + ".wav"
        var pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        // Sets up audioRecorder to record audio
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        // Delegate function for AVAudioRecorder
        // If recording is successful, perform segue to scene for audio playback
        if flag {
            recordedAudio = RecordedAudio()
            recordedAudio.filePathURL = recorder.url
            recordedAudio.title = recorder.url.lastPathComponent
            
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Sets audio file for PlaySoundsViewController
        if segue.identifier == "stopRecording" {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            let data = sender as RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        // Resets buttons and labels
        recordingLabel.hidden = true
        pauseButton.hidden = true
        recordButton.enabled = true
        pauseButtonState = true
        
        // Stops all recording
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        // This conditional covers both pausing and resuming with the same button
        if pauseButtonState {
            pauseButton.setImage(UIImage(named: "resumeButton"), forState: UIControlState.Normal)
            audioRecorder.pause()
            recordingLabel.hidden = true
        } else {
            pauseButton.setImage(UIImage(named: "pauseButton"), forState: UIControlState.Normal)
            audioRecorder.record()
            recordingLabel.hidden = false
        }
        pauseButtonState  = !pauseButtonState
    }
}

