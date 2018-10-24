#!/usr/bin/env bash

make xcodegen
WORKING_DIRECTORY=$(PWD) xcodebuild -project swift-transform.xcodeproj -scheme swift-transform-Package clean
WORKING_DIRECTORY=$(PWD) xcodebuild -project swift-transform.xcodeproj -scheme swift-transform-Package -sdk macosx10.14 -destination arch=x86_64 -configuration Debug -enableCodeCoverage YES test
