//
//  TimerManager.swift
//  PlankGrid
//
//  Created by Ronald Martin on 7/21/18.
//  Copyright © 2018 PlanGrid. All rights reserved.
//

import Foundation

// MARK: - TimerProgressDelegate
protocol TimerProgressDelegate: class {
    func manager(_ manager: TimerManager, started timer: TimerManager.TimerDescription)
    func manager(_ manager: TimerManager, stopped timer: TimerManager.TimerDescription)

    func manager(
        _ manager: TimerManager,
        progressedTo elapsed: TimeInterval,
        for timer: TimerManager.TimerDescription
    )

    func manager(_ manager: TimerManager, finished timer: TimerManager.TimerDescription)
    func manager(_ manager: TimerManager, movedTo timer: TimerManager.TimerDescription)
}

// MARK: - TimerManager
final class TimerManager {

    weak var progressDelegate: TimerProgressDelegate?

    // MARK: Source info

    var sources = [
        TimerDescription(name: "👐 Basic", duration: 65),
        TimerDescription(name: "👈 Left", duration: 45),
        TimerDescription(name: "👉 Right", duration: 45),
        TimerDescription(name: "💺 Wall Sit", duration: 65),
    ]

    private(set) var currentSourceIndex = 0 {
        didSet {
            let nextTimer = self.sources[currentSourceIndex]
            progressDelegate?.manager(self, movedTo: nextTimer)
        }
    }

    var currentSource: TimerDescription? {
        if currentSourceIndex < sources.count {
            return sources[currentSourceIndex]
        }
        return nil
    }

    // MARK: Timer state

    /// The NSTimer that's actually ticking for us.
    private var currentTimer: Timer?
    /// Saves the time remaining in the current timer if we need to pause and invalidate the
    /// underlying NSTimer.
    private var currentTimeLeft: TimeInterval?

    var isRunning: Bool { return currentTimer != nil }

    // MARK: - Actions

    func toggleRunning() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }

    func start() {
        guard let currentSource = currentSource else { return }
        guard !isRunning else { return }

        // TODO: Logic for resuming a previously paused timer
        startTimer(for: currentSource)
        progressDelegate?.manager(self, started: currentSource)
    }

    private func startTimer(for source: TimerDescription) {
        let endTime = Date(timeIntervalSinceNow: currentTimeLeft ?? source.duration)
        let newTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [unowned self] timer in
            guard let source = self.currentSource else {
                assertionFailure("Alas, time is fleeting")
                return
            }
            let timeLeft = endTime.timeIntervalSinceNow
            self.currentTimeLeft = timeLeft

            guard Int(timeLeft) > 0 else {
                timer.invalidate()
                self.finishTimer(source)
                return
            }

            let elapsedTime = source.duration - timeLeft
            self.progressDelegate?.manager(self, progressedTo: elapsedTime, for: source)
        }
        newTimer.fire()
        currentTimer = newTimer
    }

    private func finishTimer(_ timer: TimerDescription) {
        currentTimer = nil
        progressDelegate?.manager(self, finished: timer)
        switchToNextTimer()
    }

    func stop() {
        guard let currentSource = currentSource else { return }
        guard isRunning else { return }

        currentTimer?.invalidate()
        currentTimer = nil
        progressDelegate?.manager(self, stopped: currentSource)
    }

    func reset() {
        if isRunning {
            stop()
        }
        currentTimeLeft = nil
        if let currentSource = currentSource {
            progressDelegate?.manager(self, movedTo: currentSource)
        }
    }

    func switchToPreviousTimer() {
        let prevIndex = max(0, sources.index(before: currentSourceIndex))
        changeTimerIndex(to: prevIndex)
    }

    func switchToNextTimer() {
        // Loop back to the first timer if we're past the end.
        let nextIndex = sources.index(after: currentSourceIndex) % sources.count
        changeTimerIndex(to: nextIndex)
    }

    private func changeTimerIndex(to newIndex: Array<TimerDescription>.Index) {
        guard case (0 ..< sources.count) = newIndex else { return }
        if isRunning {
            stop()
        }
        currentSourceIndex = newIndex
        currentTimeLeft = nil
    }
}

// MARK: - TimerSource

extension TimerManager {
    struct TimerDescription: Equatable {
        let id = UUID()
        let name: String
        let duration: TimeInterval
    }
}
