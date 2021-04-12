//
//  VoiceViewController.swift
//  BS TASK
//
//  Created by Hardik on 10/28/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit
import Speech
struct SpeakResponse : Codable{
    let name : String!
    let type : String!
}

let speechRecognitionTimeout: Double = 1.5
let maximumAllowedTimeDuration = 10


class VoiceViewController: UIViewController, SFSpeechRecognizerDelegate {
    @IBOutlet weak var wave: RoundRectImageView!
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var lblSpeak: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewVoice: UIView!
    
    
    
    private let lowerLimit: Float = -100.0
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer:AVAudioPlayer!
    private var settings = [String : Int]()
    private var bufferTimer:Timer!
    private let timeLimiterIndicatorLabel = UILabel()

    // A utility to easily use the speech recognition facility.
    var speechRecognizerUtility: SpeechRecognitionUtility?
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    private var timer: Timer?
    private var totalTime: Int = 0
    
    private var ToStart = "End"
    
    var arrSpeech = [SpeakResponse]()
    let itemcell = "VoiceTableViewCell"
    var strVoice = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: itemcell, bundle: nil)
        tblView.register(nib, forCellReuseIdentifier: itemcell)
        tblView.delegate = self
        tblView.dataSource = self
        lblSpeak.text = "Say something, I'm listening!"
        
        viewVoice.layer.cornerRadius = viewVoice.frame.width / 2
    }
    override func viewWillAppear(_ animated: Bool) {
        setupSpeech()
    }
    
    func setupSpeech() {
        
        //        self.btnStart.isEnabled = false
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                print("authorized")
                
            case .denied:
                
                print("User denied access to speech recognition")
                
            case .restricted:
                
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                //                self.btnStart.isEnabled = isButtonEnabled
            }
        }
    }
    
    func speechRecognitionDone() {
        // Trigger the request to get translations as soon as user has done providing full speech input. Don't trigger until query length is at least one.
        if let query = strVoice as? String, query.count > 0{
            // Disable the toggle speech button while we're getting translations from server.
            toggleSpeechButtonAccessState(enabled: false)
//            NetworkRequest.sendRequestWith(query: query, completion: { (translation) in
//                OperationQueue.main.addOperation {
//                    // Explicitly execute the code on main thread since the request we get back need not be on the main thread.
//                    self.translatedTextLabel.text = translation
//                    self.resetState()
//                }
//            })
        } else {
            resetState()
        }
    }

    func resetState() {
        // Re-enable the toggle speech button once translations are ready.
        self.toggleSpeechButtonAccessState(enabled: true)
    }

    // A method to toggle the userInteractionState of toggle speech state button
    func toggleSpeechButtonAccessState(enabled: Bool) {
        self.btnStart.isUserInteractionEnabled = enabled
    }

    // A method to toggle the speech recognition state between on/off
    private func toggleSpeechRecognitionState() {
        do {
            try self.speechRecognizerUtility?.toggleSpeechRecognitionActivity()
        } catch SpeechRecognitionOperationError.denied {
            print("Speech Recognition access denied")
        } catch SpeechRecognitionOperationError.notDetermined {
            print("Unrecognized Error occurred")
        } catch SpeechRecognitionOperationError.restricted {
            print("Speech recognition access restricted")
        } catch SpeechRecognitionOperationError.audioSessionUnavailable {
            print("Audio session unavailable")
        } catch SpeechRecognitionOperationError.invalidRecognitionRequest {
            print("Recognition request is null. Expected non-null value")
        } catch SpeechRecognitionOperationError.audioEngineUnavailable {
            print("Audio engine is unavailable. Cannot perform speech recognition")
        } catch {
            print("Unknown error occurred")
        }
    }

    private func stateChangedWithNew(state: SpeechRecognitionOperationState) {
        switch state {
            case .authorized:
                print("State: Speech recognition authorized")
            case .audioEngineStart:
                toggleSpeechButtonAccessState(enabled: false)
                self.startTimeCounterAndUpdateUI()
                print("State: Audio Engine Started")
            case .audioEngineStop:
                print("State: Audio Engine Stopped")
            case .recognitionTaskCancelled:
                print("State: Recognition Task Cancelled")
            case .speechRecognized(let recognizedString):
                print("State: Recognized String \(recognizedString)")
//                self.speechTextLabel.text = recognizedString
            case .speechNotRecognized:
                print("State: Speech Not Recognized")
            case .availabilityChanged(let availability):
                toggleSpeechButtonAccessState(enabled: availability)
                print("State: Availability changed. New availability \(availability)")
            case .speechRecognitionStopped(let finalRecognizedString):
                self.stopTimeCounter()
                self.finishRecording(success: false)
                if finalRecognizedString != "" {
                    self.arrSpeech.append(SpeakResponse(name: finalRecognizedString, type: "0"))
//                    self.arrSpeech.append(SpeakResponse(name: finalRecognizedString, type: "1"))
                }
                
                self.tblView.reloadData()
//                self.InsertElementinArray(Element: finalRecognizedString)
                print("State: Speech Recognition Stopped with final string \(finalRecognizedString)")
        }
    }

    private func startTimeCounterAndUpdateUI() {
        
        print("Start")
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { [weak self] (timer) in
            guard let weakSelf = self else { return }

            guard weakSelf.totalTime < maximumAllowedTimeDuration else {
                weakSelf.toggleSpeechRecognitionState()
                weakSelf.speechRecognitionDone()
                return
            }

            weakSelf.totalTime = weakSelf.totalTime + 1

            if weakSelf.totalTime >= 2 * (maximumAllowedTimeDuration / 3) {
                weakSelf.timeLimiterIndicatorLabel.backgroundColor = .red
            } else if weakSelf.totalTime >= maximumAllowedTimeDuration / 3 {
                weakSelf.timeLimiterIndicatorLabel.backgroundColor = .orange
            } else {
                weakSelf.timeLimiterIndicatorLabel.backgroundColor = .green
        }
            weakSelf.timeLimiterIndicatorLabel.text = "\(weakSelf.totalTime)"
        })
    }

    private func stopTimeCounter() {
        print("Stopped")
        self.timer?.invalidate()
        self.timer = nil
        self.totalTime = 0
        self.timeLimiterIndicatorLabel.backgroundColor = .green
        self.timeLimiterIndicatorLabel.text = "0"
        
        speechRecognizerUtility = SpeechRecognitionUtility(speechRecognitionAuthorizedBlock: { [weak self] in
            self?.toggleSpeechRecognitionState()
        }, stateUpdateBlock: { [weak self] (currentSpeechRecognitionState, finalOutput) in
            // A block to update the status of speech recognition. This block will get called every time Speech framework recognizes the speech input
            self?.stateChangedWithNew(state: .recognitionTaskCancelled)
        })
    }
            
    func speakText(voiceOutdata: String ) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }

        let utterance = AVSpeechUtterance(string: voiceOutdata)
//        utterance.voice = AVSpeechSynthesisVoice(language: LANGUAGE)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")

        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)

        defer {
            disableAVSession()
        }
    }

    private func disableAVSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't disable.")
        }
    }
    
    override func viewWillLayoutSubviews() {
        print(strVoice)
    }
    
    @IBAction func onClickVoice(_ sender: Any) {
                
        if audioRecorder != nil {
            return
        }
        print("Main Start")
//        ToStart = "Main Start"

        speechRecognizerUtility = nil

//        self.view.layoutIfNeeded() // call it also here to finish pending layout operations
        
        
        self.startRecording()
        
        if speechRecognizerUtility == nil {
            // Initialize the speech recognition utility here
            speechRecognizerUtility = SpeechRecognitionUtility(speechRecognitionAuthorizedBlock: { [weak self] in
                self?.toggleSpeechRecognitionState()
            }, stateUpdateBlock: { [weak self] (currentSpeechRecognitionState, finalOutput) in
                // A block to update the status of speech recognition. This block will get called every time Speech framework recognizes the speech input
                self?.stateChangedWithNew(state: currentSpeechRecognitionState)
                // We won't perform translation until final input is ready. We will usually wait for users to finish speaking their input until translation request is sent
                if finalOutput {
                    //self?.stopTimeCounter()
                    self?.toggleSpeechRecognitionState()
                    self?.speechRecognitionDone()
                }
            }, timeoutPeriod: speechRecognitionTimeout) // We will set the Speech recognition Timeout to make sure we get the full string output once user has stopped talking. For example, if we specify timeout as 2 seconds. User initiates speech recognition, speaks continuously (Hopegully way less than full one minute), and if pauses for more than 2 seconds, value of finalOutput in above block will be true. Before that you will keep getting output, but that won't be the final one.
        } else {
            // We will call this method to toggle the state on/off of speech recognition operation.
            self.toggleSpeechRecognitionState()
        }
        
    }
    
   

}

extension VoiceViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSpeech.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: itemcell, for: indexPath) as! VoiceTableViewCell
        cell.lblspeech.text = arrSpeech[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}

extension VoiceViewController : AVAudioRecorderDelegate{
    func PrepareForRecording(){
        recordingSession = AVAudioSession.sharedInstance()

            do {
                try recordingSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat, options: AVAudioSession.CategoryOptions.mixWithOthers)
                try recordingSession.setActive(true)
                recordingSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                        } else {
                        }
                    }
                }
            } catch {
                // failed to record!
        }
    }
        
    func startRecording() {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
       // Audio Settings
            settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: self.directoryURL(), settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            audioRecorder.isMeteringEnabled = true
        } catch {
            
            finishRecording(success: false)
        }
      
        do {
            try audioSession.setActive(true)
            audioRecorder.record()
            bufferTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.createWaveform), userInfo: nil, repeats: true)
        } catch {
       
        }
    }
    
    func directoryURL() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("sound.m4a")
//        print(soundURL!)
        return soundURL!
    }
    
    func finishRecording(success: Bool) {
        
        UIView.animate(withDuration: 0.1, animations: {
            self.wave.transform = .identity
        })

        audioRecorder.stop()
        audioRecorder = nil
        bufferTimer.invalidate()
        
        if success {
            print("Tap to Re-record")
        } else {
            print("Somthing Wrong.")
        }
    }
    
    // Create Waveform
    
    @objc func createWaveform(timer:Timer) {
        
        audioRecorder.updateMeters()
        
        let power = audioRecorder.averagePower(forChannel: 0)
//        print(power)
        if power > lowerLimit {
       
            let scale: Float = 1.75
            let proportion = scale + scale * (power - lowerLimit) / lowerLimit
//            print(scale - proportion)
            
            UIView.animate(withDuration: 0.1, animations: {
//                print(proportion)
                self.wave.transform =  CGAffineTransform(scaleX: CGFloat(scale - proportion), y: CGFloat(scale - proportion))
            })
            
        }
    }
}

