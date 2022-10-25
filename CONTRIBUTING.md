# Contributing

> ⚠️ Tests must be added for all new functionality. Existing tests must be updated for all changed/fixed functionality, where applicable. All tests must complete without errors. All new functionality must be documented as well.

## Environment setup

We use [Carthage](https://github.com/Carthage/Carthage) to manage Lock.swift's dependencies. 

1. Clone this repository and enter its root directory.
2. Run `carthage bootstrap --use-xcframeworks` to fetch and build the dependencies.
3. Open `Lock.xcodeproj` in Xcode.
4. To build the `Lock` framework target for the first time, build the test app first. This is necessary due to the way the dependencies are set up.
