//
//  testViewController.swift
//  BS TASK
//
//  Created by Hardik on 10/28/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit
import Speech


class testViewController: UIViewController, AVAudioRecorderDelegate, SFSpeechRecognizerDelegate {

    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var lblSpeak: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewVoice: UIView!
    
    var arrSpeech = [SpeakResponse]()
    let itemcell = "VoiceTableViewCell"
    let itemrecieve = "RecievedChatTableViewCell"
    let itemSend = "SendChatTableViewCell"
    var strVoice = ""
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    let speechRecognitionTimeout: Double = 1.5
    private var timer: Timer?
    let maximumAllowedTimeDuration = 10
    private var totalTime: Int = 0
        
    var speechRecognizerUtility: SpeechRecognitionUtility!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblSpeak.text = "Say hi"
        let nib = UINib(nibName: itemrecieve, bundle: nil)
        tblView.register(nib, forCellReuseIdentifier: itemrecieve)
        
        let nib1 = UINib(nibName: itemSend, bundle: nil)
        tblView.register(nib1, forCellReuseIdentifier: itemSend)
        
        tblView.delegate = self
        tblView.dataSource = self
        
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
    
    private func startTimeCounterAndUpdateUI() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
            guard let weakSelf = self else { return }

            guard weakSelf.totalTime < self!.maximumAllowedTimeDuration else {
                weakSelf.toggleSpeechRecognitionState()
                weakSelf.speechRecognitionDone()
                return
            }

//            weakSelf.totalTime = weakSelf.totalTime + 1

//            if weakSelf.totalTime >= 2 * (maximumAllowedTimeDuration / 3) {
//                weakSelf.timeLimiterIndicatorLabel.backgroundColor = .red
//            }
//            weakSelf.timeLimiterIndicatorLabel.text = "\(weakSelf.totalTime)"
        })
    }
    
    @IBAction func onClickVocie(_ sender: Any) {
        
        if speechRecognizerUtility == nil {
            speechRecognizerUtility = SpeechRecognitionUtility(speechRecognitionAuthorizedBlock: { [weak self] in
                self?.toggleSpeechRecognitionState()
            }, stateUpdateBlock: { [weak self] (currentSpeechRecognitionState, finalOutput) in
                self?.stateChangedWithNew(state: currentSpeechRecognitionState)
                if finalOutput {
                    //self?.stopTimeCounter()
                    self?.toggleSpeechRecognitionState()
                    self?.speechRecognitionDone()
                }
            }, timeoutPeriod: speechRecognitionTimeout)
            
        } else {
            self.toggleSpeechRecognitionState()
        }
        
    }
    
    func speechRecognitionDone() {
        
        if let query = self.strVoice as? String, query.count > 0 {
            
            // Disable the toggle speech button while we're getting translations from server.
//            toggleSpeechButtonAccessState(enabled: false)
            NetworkRequest.sendRequestWith(query: query, completion: { (translation) in
                OperationQueue.main.addOperation {
                    // Explicitly execute the code on main thread since the request we get back need not be on the main thread.
                    print(translation)
//                    self.translatedTextLabel.text = translation
                    self.resetState()
                }
            })
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
        if enabled {
            self.btnStart.alpha = 1.0
        } else {
            self.btnStart.alpha = 1.0
        }
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
//                toggleSpeechButtonAccessState(enabled: true)
                startTimeCounterAndUpdateUI()
                print("State: Audio Engine Started")
            case .audioEngineStop:
                print("State: Audio Engine Stopped")
            case .recognitionTaskCancelled:
                print("State: Recognition Task Cancelled")
            case .speechRecognized(let recognizedString):
                self.strVoice = recognizedString
                
                print("State: Recognized String \(strVoice)")
            case .speechNotRecognized:
                print("State: Speech Not Recognized")
            case .availabilityChanged(let availability):
//                toggleSpeechButtonAccessState(enabled: availability)
                print("State: Availability changed. New availability \(availability)")
            case .speechRecognitionStopped(let finalRecognizedString):
                self.strVoice = finalRecognizedString
                print("finalRecognizedString------->",finalRecognizedString)
                self.arrSpeech.append(SpeakResponse(name: finalRecognizedString, type: "0"))
                self.arrSpeech.append(SpeakResponse(name: finalRecognizedString, type: "1"))
                self.tblView.reloadData()
                print("State: Speech Recognition Stopped with final string \(finalRecognizedString)")
        }
    }
}

extension testViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSpeech.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrSpeech[indexPath.row].type == "1"{
            let cell = self.tblView.dequeueReusableCell(withIdentifier: self.itemrecieve, for: indexPath) as! RecievedChatTableViewCell
                cell.lblSpeech.text = self.arrSpeech[indexPath.row].name
            cell.viewMain.layer.cornerRadius = 10
            cell.viewMain.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.viewMain.layer.borderWidth = 1
            return cell
        }else if arrSpeech[indexPath.row].type == "0"{
            let cellSend = tblView.dequeueReusableCell(withIdentifier: itemSend, for: indexPath) as! SendChatTableViewCell
            cellSend.lblSpeech.text = arrSpeech[indexPath.row].name
//            cellSend.imgBubbel.image = UIImage(named: "send")
            cellSend.imgBubbel.image = UIImage(named: "send")?
                .resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),
                                resizingMode: .stretch)
//            showOutgoingMessage(width: cellSend.frame.width, height: cellSend.frame.height)
            cellSend.viewMain.layer.cornerRadius = 10
            cellSend.viewMain.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cellSend.viewMain.layer.borderWidth = 1
            return cellSend
        }else {
           return UITableViewCell()
       }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func showOutgoingMessage(width: CGFloat, height: CGFloat) {
        let bubbleImageSize = CGSize(width: width, height: height)

        let outgoingMessageView = UIImageView(frame:
            CGRect(x: view.frame.width - bubbleImageSize.width - 20,
                   y: view.frame.height - bubbleImageSize.height - 86,
                   width: bubbleImageSize.width,
                   height: bubbleImageSize.height))

        let bubbleImage = UIImage(named: "send")?
            .resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),
                            resizingMode: .stretch)

        outgoingMessageView.image = bubbleImage

        view.addSubview(outgoingMessageView)
    }
    
    
    
}

