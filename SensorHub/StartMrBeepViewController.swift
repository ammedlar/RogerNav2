//
//  StartMrBeepViewController.swift
//  SensorHub
//
//  Created by James Yu on 11/15/18.
//  Copyright © 2018 James Yu. All rights reserved.
//

import UIKit
import AVFoundation

enum TurnDirection {
    case Left
    case Right
}

class StartMrBeepViewController: UIViewController {
    @IBOutlet var lbl_setHeading: UILabel!
    @IBOutlet var lbl_currHeading: UILabel!
    @IBOutlet var lbl_headingDiff: UILabel!
    @IBOutlet var lbl_action: UILabel!
    
    var setHeading: Double?
    var currHeading: Double?
    var absHeadingDiff: Double!
    var turnDirection: TurnDirection?
    var timer = Timer()
    let synthesizer = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SensorManager.shared.delegate = self
        scheduledTimerWithTimeInterval()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let setHeading = setHeading {
            lbl_setHeading.text = String(format: "%f˚", setHeading)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer.invalidate()
    }
    
    func scheduledTimerWithTimeInterval() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.sendUpdates), userInfo: nil, repeats: true)
    }
    
    @objc func sendUpdates() {
        var utterance = AVSpeechUtterance(string: lbl_action.text!)
        synthesizer.speak(utterance)
        
        if (turnDirection != nil) {
            utterance = AVSpeechUtterance(string: String(format: "%d degrees", Int(absHeadingDiff)))
            synthesizer.speak(utterance)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension StartMrBeepViewController: SensorDelegate {
    func didUpdateLocation(lat: Double, lon: Double) {
        //
    }
    
    func didUpdateHeading(heading: Double) {
        currHeading = heading
        lbl_currHeading.text = String(format: "%f˚", heading)
        
        let headingDiff = setHeading! - currHeading!
        absHeadingDiff = abs(headingDiff)
        lbl_headingDiff.text = String(format: "%f˚", absHeadingDiff)
        
        if (headingDiff > 0.0) {
            if (absHeadingDiff < 180.0) {
                // turn right
                turnDirection = .Right
            }
            else {
                // turn left
                turnDirection = .Left
            }
        }
        else {
            if (absHeadingDiff < 180.0) {
                // turn left
                turnDirection = .Left
            }
            else {
                // turn right
                turnDirection = .Right
            }
        }
        
        if (absHeadingDiff <= 5.0) {
            lbl_action.text = "Keep straight"
            turnDirection = nil
        }
        else {
            switch turnDirection {
            case .Left?:
                lbl_action.text = "Turn left"
                break
            case .Right?:
                lbl_action.text = "Turn right"
                break
            default:
                break
            }
        }
    }
    
    func didFail(error: Error) {
        //
    }
    
}