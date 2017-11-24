//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Matt Jones on 8/13/17.
//  Copyright © 2017 Matt Jones. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var interfaceGroup: WKInterfaceGroup!
    @IBOutlet var cooldownTimer: WKInterfaceTimer!
    weak var timer: Timer?
    
    let formatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.unitsStyle = .abbreviated
        f.allowedUnits = [.hour, .minute, .second]
        f.maximumUnitCount = 2
        return f
    }()
    
    override func willActivate() {
        super.willActivate()
        updateTimer()
        updateMenuItems()
        
        let timer = Timer(timeInterval: 0.5, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .commonModes)
        self.timer = timer
        self.timer?.fire()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        cooldownTimer.stop()
        timer?.invalidate()
    }
    
    @IBAction func swipeDown(_ sender: WKSwipeGestureRecognizer) {
        updateCooldown(multiplier: -1)
    }
    
    @objc func add2ButtonPressed(_ sender: WKInterfaceButton) {
        updateCooldown(multiplier: 2)
    }
    
    @objc func add15ButtonPressed(_ sender: WKInterfaceButton) {
        updateCooldown(multiplier: 1.5)
    }
    
    @objc func add05ButtonPressed(_ sender: WKInterfaceButton) {
        updateCooldown(multiplier: 0.5)
    }
    
    @objc func settingsButtonPressed() {
        presentController(withName: "SettingsInterfaceController", context: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: WKInterfaceButton) {
        updateCooldown()
    }
    
    func updateCooldown(multiplier: Double = 1) {
        bumpCooldown(multiplier: multiplier)
        updateUI()
        updateTimer()
    }
    
    @objc func updateUI() {
        let interval = max(State.shared.cooldown.target.timeIntervalSinceNow, 0)
        let percent = min(interval / State.shared.cooldownInterval / 3, 1)
        let color: UIColor
        if percent <= 0.5 {
            color = UIColor.cooldownGreen.blended(with: .cooldownYellow, percent: CGFloat(percent * 2))
        } else {
            color = UIColor.cooldownYellow.blended(with: .cooldownRed, percent: CGFloat((percent - 0.5) * 2))
        }
        
        interfaceGroup.setBackgroundColor(color)
    }
    
    func updateTimer() {
        if State.shared.cooldown.target > Date() {
            cooldownTimer.setDate(State.shared.cooldown.target)
            cooldownTimer.start()
        } else {
            cooldownTimer.setDate(Date())
            cooldownTimer.stop()
        }
    }
    
    func updateMenuItems() {
        clearAllMenuItems()
        let title2 = formatter.string(from: State.shared.cooldownInterval * 2)!
        let title15 = formatter.string(from: State.shared.cooldownInterval * 1.5)!
        let title05 = formatter.string(from: State.shared.cooldownInterval * 0.5)!
        addMenuItem(with: .add, title: title2, action: #selector(add2ButtonPressed))
        addMenuItem(with: .add, title: title15, action: #selector(add15ButtonPressed))
        addMenuItem(with: .add, title: title05, action: #selector(add05ButtonPressed))
        addMenuItem(with: .more, title: "Edit Interval", action: #selector(settingsButtonPressed))
    }
    
    func bumpCooldown(multiplier: Double = 1) {
        State.shared.cooldown += Cooldown(created: Date(), remaining: State.shared.cooldownInterval * multiplier)
        do { try WCSession.default.updateApplicationContext(State.shared.appContext) }
        catch { print(error) }
    }

}
