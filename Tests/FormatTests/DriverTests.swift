/*
   Copyright 2015-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

import Foundation
import XCTest

@testable import Source
@testable import Format

class DriverTests : XCTestCase {
  func testFormat() {
    let testDriver = Driver()
    testDriver.updateOutputHandle(.nullDevice)
    let result = testDriver.format(sourceFile: SourceFile(path: "test/testDriver", content: "import foo"))
    XCTAssertEqual(result, 0)
  }

  static var allTests = [
    ("testFormat", testFormat),
  ]
}
