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

func computeFormats(
  _ dotYanagibaTransform: DotYanagibaTransform?,
  _ formatsOption: [String: Any]?
) -> [String: Any]? {
  var formats: [String: Any]?
  if let dotYanagibaTransform = dotYanagibaTransform, let customFormats = dotYanagibaTransform.formats {
    formats = customFormats
  }
  if let customFormats = formatsOption {
    formats = customFormats
  }
  return formats
}

enum OutputOption {
  case standardOutput
  case fileOutput(String)
}

func computeOutput(
  _ dotYanagibaTransform: DotYanagibaTransform?,
  _ outputPathOption: String?
) -> OutputOption {
  var outputPath: String?
  if let dotYanagibaTransform = dotYanagibaTransform, let outputPathOption = dotYanagibaTransform.outputPath {
    outputPath = outputPathOption
  }
  if let outputPathOption = outputPathOption {
    outputPath = outputPathOption
  }

  if let fileOutput = outputPath {
    return .fileOutput(fileOutput)
  }
  return .standardOutput
}
