//
//  InterfaceController.swift
//  PlankGrid WatchKit Extension
//
//  Created by Ronald Martin on 7/21/18.
//  Copyright © 2018 PlanGrid. All rights reserved.
//

import Foundation
import HealthKit
import WatchKit

final class InterfaceController: WKInterfaceController {

    private let timerManager = TimerManager()
    private let healthKitStore = HKHealthStore()
    private var workout: HKWorkoutSession?

    // MARK: Outlets

    @IBOutlet private var progressGroup: WKInterfaceGroup!
    @IBOutlet private var timeLabel: WKInterfaceLabel!

    @IBOutlet private var sourceDescriptionGroup: WKInterfaceGroup!
    @IBOutlet private var titleLabel: WKInterfaceLabel!
    @IBOutlet private var progressLabel: WKInterfaceLabel!

    @IBOutlet private var emptyStateGroup: WKInterfaceGroup!

    // MARK: - Lifecycle

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        setupTimerView()
        timerManager.progressDelegate = self
    }

    private func setupTimerView() {
        if let timer = timerManager.currentSource {
            resetLabels(with: timer)
        } else {
            showEmptyState()
        }
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

        if workout == nil {
            startWorkout()
        }
    }

    private func startWorkout() {
        let config = HKWorkoutConfiguration()
        config.locationType = .indoor
        config.activityType = .coreTraining

        let session = try! HKWorkoutSession(configuration: config)
        defer { workout = session }
        session.delegate = self
        healthKitStore.start(session)
    }

    func manager(_ manager: TimerManager, stopped timer: TimerManager.TimerDescription) {
        print("Stopped timer: \(timer)")

        WKInterfaceDevice.current().play(.stop)

        if let workout = workout {
            healthKitStore.pause(workout)
        }
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
            timeLabel.setTextColor(.green)
        default:
            break
        }
        timeLabel.setText("\(Int(timeLeft))")
    }

    func manager(_ manager: TimerManager, finished timer: TimerManager.TimerDescription) {
        print("Finished timer: \(timer)")
        WKInterfaceDevice.current().play(.success)

        if manager.sources.last == timer,
            let workout = workout {
            healthKitStore.end(workout)
            self.workout = nil
        }
    }

    func manager(_ manager: TimerManager, movedTo timer: TimerManager.TimerDescription) {
        resetLabels(with: timer)
    }
}

// MARK: - HKWorkoutSessionDelegate
extension InterfaceController: HKWorkoutSessionDelegate {

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("State change from \(fromState) to \(toState) on \(date)")
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("\(error)")
    }
}
