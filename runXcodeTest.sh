#!/usr/bin/env bash

make xcodegen
WORKING_DIRECTORY=$(PWD) xcodebuild -project swift-format.xcodeproj -scheme swift-format-Package clean
WORKING_DIRECTORY=$(PWD) xcodebuild -project swift-format.xcodeproj -scheme swift-format-Package -sdk macosx10.13 -destination arch=x86_64 -configuration Debug -enableCodeCoverage YES test
