//
//  LottieAnimationViewController.swift
//  BS TASK
//
//  Created by Hardik on 11/18/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit
import Lottie
import AVFoundation


class LottieAnimationViewController: UIViewController {

    @IBOutlet weak var lottieAnimationView: AnimationView!
    var player: AVAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
//        answertoneforhousie

        playSound()
        lottieAnimationView = .init(name: "heart")
        lottieAnimationView!.frame = view.bounds
        lottieAnimationView!.contentMode = .scaleAspectFit
        lottieAnimationView!.loopMode = .repeat(5)
        lottieAnimationView!.animationSpeed = 0.5
        view.addSubview(lottieAnimationView!)
        lottieAnimationView.play(fromProgress: 0,
                                 toProgress: 1,
                                 loopMode: LottieLoopMode.repeat(5),
                                 completion: { (finished) in
                                    if finished {
                                        print("Animation Complete, Start second one")
                                    } else {
                                        print("Animation cancelled")
                                    }
                                 })
        
        
    }
    
    func playSound() {
        print("PlaySound")
        guard let url = Bundle.main.url(forResource: "answertoneforhousie", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
       
}
