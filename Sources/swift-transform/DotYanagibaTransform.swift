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

import Foundation
import Bocho

struct DotYanagibaTransform {
  var formats: [String: Any]?
  var outputPath: String?

  init?(dotYanagiba: DotYanagiba) {
    guard let module = dotYanagiba.modules["transform"] else {
      return nil
    }

    for (key, option) in module.options {
      switch (key, option) {
      case ("formats", .dictInt(let options)):
        formats = options
      case ("formats", .dictString(let options)):
        formats = options
      case ("output-path", .string(let option)):
        outputPath = option
      default:
        break
      }
    }
  }

  static func loadFromDisk() -> DotYanagibaTransform? {
    guard let dotYanagiba = DotYanagibaReader.read() else {
      return nil
    }
    return DotYanagibaTransform(dotYanagiba: dotYanagiba)
  }
}
