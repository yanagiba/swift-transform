// swift-tools-version:4.0

/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import PackageDescription

let package = Package(
  name: "swift-format",
  products: [
    .executable(
      name: "swift-format",
      targets: [
        "swift-format",
      ]
    ),
    .library(
      name: "SwiftFormat",
      targets: [
        "Format",
      ]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/yanagiba/swift-ast",
      .exact("0.3.5")
    ),
  ],
  targets: [
    .target(
      name: "Format",
      dependencies: [
        "SwiftAST",
      ]
    ),
    .target(
      name: "swift-format",
      dependencies: [
        "Format",
      ]
    ),

    // MARK: Tests

    .testTarget(
      name: "CrithagraTests"
    ),
    .testTarget(
      name: "FormatTests",
      dependencies: [
        "Format",
      ]
    ),
  ],
  swiftLanguageVersions: [4]
)
