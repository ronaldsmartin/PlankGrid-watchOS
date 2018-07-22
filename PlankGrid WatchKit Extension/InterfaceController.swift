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

    private var timerManager = TimerManager.shared

    // MARK: Outlets

    @IBOutlet private var progressGroup: WKInterfaceGroup!
    @IBOutlet private var countdownScene: WKInterfaceSKScene!
    @IBOutlet private var timeLabel: WKInterfaceLabel!

    @IBOutlet private var sourceDescriptionGroup: WKInterfaceGroup!
    @IBOutlet private var titleLabel: WKInterfaceLabel!
    @IBOutlet private var progressLabel: WKInterfaceLabel!

    @IBOutlet private var emptyStateGroup: WKInterfaceGroup!

    // MARK: - Lifecycle

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        if let timer = timerManager.currentSource {
            resetLabels(with: timer)
        } else {
            showEmptyState()
        }
        timerManager.progressDelegate = self
    }

    private func showEmptyState() {
        sourceDescriptionGroup.setHidden(true)
        timeLabel.setHidden(true)
        emptyStateGroup.setHidden(false)
    }

    private func resetLabels(with timer: TimerManager.TimerDescription) {
        timeLabel.setTextColor(.white)
        timeLabel.setText("\(Int(timer.duration))")
        titleLabel.setText(timer.name)

        let newText = "\(timerManager.currentSourceIndex + 1) of \(timerManager.sources.count)"
        progressLabel.setText(newText)
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
        timerManager.toggleRunning()
    }

    @IBAction private func reset(_ sender: Any) {
        timerManager.reset()
        WKInterfaceDevice.current().play(.success)
    }

    @IBAction private func previousTimer(_ sender: Any) {
        timerManager.switchToPreviousTimer()
    }

    @IBAction private func nextTimer(_ sender: Any) {
        timerManager.switchToNextTimer()
    }
}

extension InterfaceController: TimerProgressDelegate {
    func manager(_ manager: TimerManager, started timer: TimerManager.TimerDescription) {
        print("Started timer: \(timer)")
        WKInterfaceDevice.current().play(.start)
    }

    func manager(_ manager: TimerManager, stopped timer: TimerManager.TimerDescription) {
        print("Stopped timer: \(timer)")
        WKInterfaceDevice.current().play(.stop)
    }

    func manager(
        _ manager: TimerManager,
        progressedTo elapsed: TimeInterval,
        for timer: TimerManager.TimerDescription
    ) {
        print("Elapsed time: \(elapsed), duration: \(timer.duration)")

        let timeLeft = Int(timer.duration - elapsed)

        switch timeLeft {
        case Int(timer.duration / 2):
            // "Halfway mark!"
            WKInterfaceDevice.current().play(.directionUp)
        case 6:
            WKInterfaceDevice.current().play(.directionDown)
            timeLabel.setTextColor(.green)
        case 0...5:
            // "5, 4, 3, 2, 1..."
            WKInterfaceDevice.current().play(.click)
        default:
            break
        }
        timeLabel.setText("\(Int(timeLeft))")
    }

    func manager(_ manager: TimerManager, finished timer: TimerManager.TimerDescription) {
        print("Finished timer: \(timer)")
        WKInterfaceDevice.current().play(.success)
    }

    func manager(_ manager: TimerManager, movedTo timer: TimerManager.TimerDescription) {
        resetLabels(with: timer)
    }
}
