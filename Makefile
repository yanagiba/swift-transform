BUILD_DIR=.build/debug

.PHONY: all clean build test xcodegen

all: build

clean:
	swift package clean
	rm -rf .build

build:
	swift build

test: build
	swift test

xcodegen:
	swift package generate-xcodeproj --enable-code-coverage
