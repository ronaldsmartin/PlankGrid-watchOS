//
//  InterfaceController.swift
//  PlankGrid WatchKit Extension
//
//  Created by Ronald Martin on 7/21/18.
//  Copyright © 2018 PlanGrid. All rights reserved.
//

import WatchKit
import Foundation


final class InterfaceController: WKInterfaceController {

    // MARK: Outlets

    @IBOutlet private var titleLabel: WKInterfaceLabel!
    @IBOutlet var progressGroup: WKInterfaceGroup!
    @IBOutlet private var countdownScene: WKInterfaceSKScene!
    @IBOutlet private var timerLabel: WKInterfaceTimer!
    @IBOutlet private var progressLabel: WKInterfaceLabel!

    // MARK: - Lifecycle

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // MARK: - Actions

    @IBAction private func toggleRunning(_ sender: Any) {
    }

    @IBAction private func reset(_ sender: Any) {
    }

}
