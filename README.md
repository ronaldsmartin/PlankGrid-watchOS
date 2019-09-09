# :watch: PlankGrid for watchOS

*PlankGrid is an Apple Watch-based timer that tracks core mini-workouts.*

> :warning: **Warning:** Unmaintained and probably abandoned. It works fine, and there isn't a great need for improvement.

```swift
// All times are in seconds (NSTimeInterval)
var sources = [
    TimerDescription(name: "👐 Basic", duration: 65),
    TimerDescription(name: "👈 Left", duration: 45),
    TimerDescription(name: "👉 Right", duration: 45),
    TimerDescription(name: "💺 Wall Sit", duration: 65),
]
```

Early in my time at [PlanGrid](https://www.plangrid.com), I built [a React Native app for our daily afternoon microworkout](https://github.com/ronaldsmartin/PlankGrid). It's a very specific timer in four parts.

By 2018, we'd increased the time for each segment (everyone got stronger through planking!), and I got an Apple Watch to dabble in watch app development. It's much better suited for this kind of app, and this version does the following:

* Counts down each segment of the PlankGrid workout (the ones defined in code above)
* Actually tracks the workout activity through your heart rate (as an indoor `.coreWorkout`) and sends the data to HealthKit :heart:
* Provides useful haptic feedback notifications during the last few seconds of a timer and when a timer completes, so you don't have to stare at the UI to know how far you are in the session. This was the #1 feature request for React Native PlankGrid for phones!
* The timer changes color at relevant points if you _are_ staring at it though, which is kinda nice.

## Usage
The UI is entirely watch-based. This was built before [Apple allowed Indepenent Watch apps](https://developer.apple.com/videos/play/wwdc2019/208/), so there's a corresponding host :iphone: app that you can just ignore.

* Start/pause the timer by tapping on the watchface.
* Switch between segments/timers by swiping left or right across the watch (in case you join late! Or, are injured.)
* Reset the current timer by long-pressing the watchface.

## Building and running locally

1. Download Xcode
2. Check out the repo
3. `$ open PlankGrid.xcodeproj`
4. Select the `PlankGrid WatchKit App` target and your device, and press **Play**.

### Notes about the code

I hacked this together over the course of <= 2h in 2018 and haven't looked at it since then, so please forgive the code quality!

* Timing logic lives in [TimerManager](https://github.com/ronaldsmartin/PlankGrid-watchOS/blob/master/PlankGrid/Model/TimerManager.swift). It's all hard-coded.
* The view and gesture recognizers are defined in [the WatchKit app's storyboard](https://github.com/ronaldsmartin/PlankGrid-watchOS/blob/master/PlankGrid%20WatchKit%20App/Base.lproj/Interface.storyboard).
* UI interaction logic lives in the [InterfaceController](https://github.com/ronaldsmartin/PlankGrid-watchOS/blob/master/PlankGrid%20WatchKit%20Extension/InterfaceController.swift).

## License

**PlankGrid** is licensed under Apache 2.0.

    Copyright 2018 Ronald Martin

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0
       
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
