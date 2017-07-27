// swift-tools-version:4.0

/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

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
  name: "swift-transform",
  products: [
    .executable(
      name: "swift-transform",
      targets: [
        "swift-transform",
      ]
    ),
    .library(
      name: "SwiftTransform",
      targets: [
        "Transform",
      ]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/yanagiba/swift-ast",
      .revision("283e39365d1db629b932ca314afe19852318e636")
    ),
    .package(
      url: "https://github.com/yanagiba/bocho",
      .revision("25b9439a94ad26c169cf4b5f05826e811b3ba009")
    ),
  ],
  targets: [
    .target(
      name: "Transform",
      dependencies: [
        "SwiftAST",
      ]
    ),
    .target(
      name: "swift-transform",
      dependencies: [
        "Transform",
        "Bocho",
      ]
    ),

    // MARK: Tests

    .testTarget(
      name: "CrithagraTests"
    ),
    .testTarget(
      name: "TransformTests",
      dependencies: [
        "Transform",
      ]
    ),
    .testTarget(
      name: "GeneratorTests",
      dependencies: [
        "Transform",
      ]
    ),
  ],
  swiftLanguageVersions: [4]
)
