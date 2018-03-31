//
//  SettingsViewController.swift
//  Cooldown
//
//  Created by Matt Jones on 8/9/17.
//  Copyright © 2017 Matt Jones. All rights reserved.
//

import UIKit
import WatchConnectivity
import Core_iOS

class SettingsViewController: UIViewController {
    
    @IBOutlet var shadowView: UIView!
    @IBOutlet var cooldownDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shadowView.layer.shadowOffset = CGSize(width: 0, height: -2)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.15
        shadowView.layer.shadowRadius = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            // Workaround for a UIDatePicker bug not firing the first value change event
            self.cooldownDatePicker.countDownDuration = State.shared.cooldownInterval
        }
    }
    
    @IBAction func cooldownDatePickerValueChanged(_ sender: UIDatePicker) {
        State.shared.cooldownInterval = TimeInterval(sender.countDownDuration)
        do { try WCSession.default.updateApplicationContext(State.shared.appContext) }
        catch { print(error) }
    }

    @IBAction func dismiss() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
