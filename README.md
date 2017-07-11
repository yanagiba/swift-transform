# Swift Format

[![swift-ast 0.3.5](https://img.shields.io/badge/swift‐ast-0.3.5-C70025.svg)](https://github.com/yanagiba/swift-ast)
[![swift-lint master](https://img.shields.io/badge/swift‐lint-master-C70025.svg)](https://github.com/yanagiba/swift-lint)
[![swift-format pending](https://img.shields.io/badge/swift‐format-pending-C70025.svg)](https://github.com/yanagiba/swift-format)

[![Travis CI Status](https://api.travis-ci.org/yanagiba/swift-format.svg?branch=master)](https://travis-ci.org/yanagiba/swift-format)
[![codecov](https://codecov.io/gh/yanagiba/swift-format/branch/master/graph/badge.svg)](https://codecov.io/gh/yanagiba/swift-format)
![Swift 4.0-beta](https://img.shields.io/badge/swift-4.0‐beta-brightgreen.svg)
![Swift Package Manager](https://img.shields.io/badge/SPM-ready-orange.svg)
![Platforms](https://img.shields.io/badge/platform-%20Linux%20|%20macOS%20-red.svg)
![License](https://img.shields.io/github/license/yanagiba/swift-format.svg)

Swift Format (`swift-format`) is a tool that formats Swift code.

Swift Format relies on [Swift Abstract Syntax Tree (`swift-ast`)](http://yanagiba.org/swift-ast)
of the source code for better accuracy and efficiency.

Swift Format is part of [Yanagiba Project](http://yanagiba.org). Yanagiba umbrella project is a toolchain of compiler modules, libraries, and utilities, written in Swift and for Swift.

## A Work In Progress

Both Swift Abstract Syntax Tree and Swift Format are in active development.

Swift Format is under active development, and is NOT recommended for production use at this time.

Please also check out the [status](https://github.com/yanagiba/swift-ast#a-work-in-progress) from [swift-ast](https://github.com/yanagiba/swift-ast).

## Requirements

- [Swift 4.0-DEVELOPMENT-SNAPSHOT-2017-07-06-a](https://swift.org/download/)

## Development

### Build & Run

Building the entire project can be done by simply calling:

```bash
make
```

This is equivalent to

```bash
swift build
```

The dev version of the tool will be generated to `.build/debug/swift-format`.

### Running Tests

Compile and run the entire tests by:

```bash
make test
```

## Contact

Ryuichi Saito

- http://github.com/ryuichis
- ryuichi@yanagiba.org

## License

Swift Format is available under the Apache License 2.0.
See the [LICENSE](LICENSE) file for more info.
