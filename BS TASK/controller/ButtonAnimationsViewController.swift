//
//  ButtonAnimationsViewController.swift
//  BS TASK
//
//  Created by Hardik on 11/18/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit
import TransitionButton

class ButtonAnimationsViewController: UIViewController {

 
    @IBOutlet weak var btnNext: TransitionButton!
    @IBOutlet weak var bPluse: UIButton!
    @IBOutlet weak var bFlash: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        btnNext.backgroundColor = .red
        btnNext.setTitle("button", for: .normal)
        btnNext.layer.cornerRadius = 20
        btnNext.spinnerColor = .white
        btnNext.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        
    }
    
    @objc func buttonAction(_ button: TransitionButton) {
        print("buttonAction")
           button.startAnimation() // 2: Then start the animation when the user tap the button
           let qualityOfServiceClass = DispatchQoS.QoSClass.background
           let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
           backgroundQueue.async(execute: {
               
               sleep(3) // 3: Do your networking task or background work here.
               
               DispatchQueue.main.async(execute: { () -> Void in
                   // 4: Stop the animation, here you have three options for the `animationStyle` property:
                   // .expand: useful when the task has been compeletd successfully and you want to expand the button and transit to another view controller in the completion callback
                   // .shake: when you want to reflect to the user that the task did not complete successfly
                   // .normal
                   button.stopAnimation(animationStyle: .expand, completion: {
//                       let secondVC = QRCodeVC()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "LottieAnimationViewController") as! LottieAnimationViewController
//                    self.navigationController?.pushViewController(vc, animated: true)
                    self.present(vc, animated: true, completion: nil)
                   })
               })
           })
       }
    

    @IBAction func btnPluse(_ sender: Any) {
//        pulsate()
        bPluse.startAnimatingPressActions()
    }
    
    @IBAction func btnFlash(_ sender: Any) {
        flash()
    }
    
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 0.98
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        bPluse.layer.add(pulse, forKey: nil)
    }
    func flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.3
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 5
        bFlash.layer.add(flash, forKey: nil)
    }
    
}




extension UIButton {
    
    func startAnimatingPressActions() {
        addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
    }
    
    @objc private func animateDown(sender: UIButton) {
        animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 0.80, y: 0.80))
    }
    
    @objc private func animateUp(sender: UIButton) {
        animate(sender, transform: .identity)
    }
    
    private func animate(_ button: UIButton, transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 3,
                       options: [.curveEaseInOut],
                       animations: {
                        button.transform = transform
            }, completion: nil)
    }
    
}
