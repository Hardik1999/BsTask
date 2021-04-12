//
//  SinglelineVoiceViewController.swift
//  BS TASK
//
//  Created by Hardik on 11/2/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit
import Speech
//import Pulsator

class SinglelineVoiceViewController: UIViewController, SFSpeechRecognizerDelegate {
    @IBOutlet weak var viewAnimation: UIView!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var btnSpeech: UIButton!
    @IBOutlet weak var viewMic: UIView!
    
    
//    let pulsator = Pulsator()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    let speechRecognitionTimeout: Double = 1.5
    private var timer: Timer?
    let maximumAllowedTimeDuration = 10
    private var totalTime: Int = 0
    var speechRecognizerUtility: SpeechRecognitionUtility!
    let rippleLayer = RippleLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       
        
        viewMic.layer.cornerRadius = viewMic.frame.height / 2
        viewAnimation.layer.cornerRadius = viewAnimation.frame.height / 2
        
        
        
        rippleLayer.position = CGPoint(x: self.viewMic.layer.bounds.midX, y: self.viewMic.layer.bounds.midY)
        
        rippleLayer.rippleRadius = viewAnimation.frame.width
        rippleLayer.rippleWidth = 100
        rippleLayer.rippleColor = UIColor(red: 1, green: 1, blue: 100, alpha: 0.5)
        
        self.viewMic.layer.addSublayer(rippleLayer)
//        pulsator.numPulse = 2
//        pulsator.radius = 240
////        pulsator.layoutIfNeeded()
//        viewAnimation.layer.addSublayer(pulsator)
////        pulsator.position = view.center
//        pulsator.backgroundColor = UIColor(red: 1, green: 1, blue: 100, alpha: 0.5).cgColor
//        viewMic.layer.layoutIfNeeded()
        
        
    }
    
    func animateImage() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupSpeech()
    }
    
    func setupSpeech() {
        

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
        })
    }
    

    @IBAction func onClickmic(_ sender: Any) {
        
        
        if speechRecognizerUtility == nil {
            speechRecognizerUtility = SpeechRecognitionUtility(speechRecognitionAuthorizedBlock: { [weak self] in
                self?.toggleSpeechRecognitionState()
            }, stateUpdateBlock: { [weak self] (currentSpeechRecognitionState, finalOutput) in
                self?.stateChangedWithNew(state: currentSpeechRecognitionState)
                if finalOutput {
                    
                    self?.toggleSpeechRecognitionState()
                    self?.speechRecognitionDone()
                }
            }, timeoutPeriod: speechRecognitionTimeout)
            
        } else {
            self.toggleSpeechRecognitionState()
        }
        
        
    }
    
    func speechRecognitionDone() {
        
        if let query = self.lblText as? String, query.count > 0 {
            
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
        self.btnSpeech.isUserInteractionEnabled = enabled
        if enabled {
            self.btnSpeech.alpha = 1.0
        } else {
            self.btnSpeech.alpha = 1.0
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
                startTimeCounterAndUpdateUI()
               
                print("State: Audio Engine Started")
            case .audioEngineStop:
                print("State: Audio Engine Stopped")
            case .recognitionTaskCancelled:
                print("State: Recognition Task Cancelled")
            case .speechRecognized(let recognizedString):
                
//                addRippleEffect(to: viewMic, count: 25)
                
                //pulsator.start()
                rippleLayer.startAnimation()
                self.lblText.text = recognizedString
                
                print("State: Recognized String \(recognizedString)")
            case .speechNotRecognized:
                print("State: Speech Not Recognized")
            case .availabilityChanged(let availability):
//                toggleSpeechButtonAccessState(enabled: availability)
                print("State: Availability changed. New availability \(availability)")
            case .speechRecognitionStopped(let finalRecognizedString):
//                self.lblText.text = finalRecognizedString
//                print("finalRecognizedString------->",finalRecognizedString)
//                self.arrSpeech.append(SpeakResponse(name: finalRecognizedString, type: "0"))
//                self.arrSpeech.append(SpeakResponse(name: finalRecognizedString, type: "1"))
//                self.tblView.reloadData()
//                addRippleEffect(to: viewMic, count: 0)
//                pulsator.stop()
                rippleLayer.stopAnimation()
                print("State: Speech Recognition Stopped with final string \(finalRecognizedString)")
        }
    }
    
    
    func addRippleEffect(to referenceView: UIView, count : Int) {
        
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: referenceView.bounds.size.width, height: referenceView.bounds.size.height))
        let shapePosition = CGPoint(x: referenceView.bounds.size.width / 2.0, y: referenceView.bounds.size.height / 2.0)
        let rippleShape = CAShapeLayer()
        rippleShape.bounds = CGRect(x: 0, y: 0, width: referenceView.bounds.size.width, height: referenceView.bounds.size.height)
        rippleShape.path = path.cgPath
        rippleShape.fillColor = UIColor.clear.cgColor
        rippleShape.strokeColor = UIColor(red: 1, green: 1, blue: 100, alpha: 0.5).cgColor
//        viewAnimation.layer.layoutIfNeeded()
        rippleShape.lineWidth = 30
        rippleShape.position = shapePosition
        rippleShape.opacity = 0
        referenceView.layer.addSublayer(rippleShape)
        
        
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        scaleAnim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(2, 2, 1))
        
        
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1
        opacityAnim.toValue = nil
        
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnim, opacityAnim]
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = CFTimeInterval(1)
        animation.repeatCount = Float(count)
        animation.isRemovedOnCompletion = true
        
        
        rippleShape.add(animation, forKey: "rippleEffect")
    }
    
}
