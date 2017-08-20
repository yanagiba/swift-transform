# Swift Transform

[![swift-ast 0.3.5](https://img.shields.io/badge/swift‐ast-0.3.5-C70025.svg)](https://github.com/yanagiba/swift-ast)
[![swift-lint master](https://img.shields.io/badge/swift‐lint-master-C70025.svg)](https://github.com/yanagiba/swift-lint)
[![swift-transform pending](https://img.shields.io/badge/swift‐transform-pending-C70025.svg)](https://github.com/yanagiba/swift-transform)

[![Travis CI Status](https://api.travis-ci.org/yanagiba/swift-transform.svg?branch=master)](https://travis-ci.org/yanagiba/swift-transform)
[![codecov](https://codecov.io/gh/yanagiba/swift-transform/branch/master/graph/badge.svg)](https://codecov.io/gh/yanagiba/swift-transform)
![Swift 4.0-beta](https://img.shields.io/badge/swift-4.0‐beta-brightgreen.svg)
![Swift Package Manager](https://img.shields.io/badge/SPM-ready-orange.svg)
![Platforms](https://img.shields.io/badge/platform-%20Linux%20|%20macOS%20-red.svg)
![License](https://img.shields.io/github/license/yanagiba/swift-transform.svg)

Swift Transform (`swift-transform`) enables source-to-source transformation that takes Swift code as input and produces the equivalent source code in other programming languages.

Swift Transform relies on [Swift Abstract Syntax Tree (`swift-ast`)](http://yanagiba.org/swift-ast)
of the source code for better accuracy and efficiency.

Swift Transform is part of [Yanagiba Project](http://yanagiba.org). Yanagiba umbrella project is a toolchain of compiler modules, libraries, and utilities, written in Swift and for Swift.

## A Work In Progress

Both Swift Abstract Syntax Tree and Swift Transform are in active development.

Swift Transform is under active development, and is NOT recommended for production use at this time.

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

The dev version of the tool will be generated to `.build/debug/swift-transform`.

### Running Tests

Compile and run the entire tests by:

```bash
make test
```

## Contact

Ryuichi Sai

- http://github.com/ryuichis
- ryuichi@yanagiba.org

## License

Swift Transform is available under the Apache License 2.0.
See the [LICENSE](LICENSE) file for more info.
