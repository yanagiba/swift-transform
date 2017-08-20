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
import Source
import Transform

let dotYanagibaTransform = DotYanagibaTransform.loadFromDisk()

var cliArgs = CommandLine.arguments
cliArgs.remove(at: 0)
let cliOption = CLIOption(cliArgs)

if cliOption.contains("help") {
  print("""
  \(SWIFT_TRANSFORM) [options] <source0> [... <sourceN>]

  <source0> ... specify the paths of source files.

  -help, --help
    Display available options
  -version, --version
    Display the version

  --formats <parameter0>=<value0>[,...,<parameterN>=<valueN>]
    Override the default coding styles

  -o, --output <path>
    Write output to <path>, default to console
    When single input source is provided,
      this needs to be the output path of the generated file
    When multiple input sources are provided,
      this should be the path to a common folder that holdes all generated files

  For more information, please visit http://yanagiba.org/\(SWIFT_TRANSFORM)
  """)
  exit(0)
}

if cliOption.contains("version") {
  print("""
  Yanagiba's \(SWIFT_TRANSFORM) (http://yanagiba.org/\(SWIFT_TRANSFORM)):
    version \(SWIFT_TRANSFORM_VERSION).

  Yanagiba's swift-ast (http://yanagiba.org/swift-ast):
    version \(SWIFT_AST_VERSION).
  """)
  exit(0)
}

let formats = computeFormats(dotYanagibaTransform, cliOption.readAsDictionary("-formats"))
let output = computeOutput(
  dotYanagibaTransform, cliOption.readAsString("o") ?? cliOption.readAsString("-output"))

let filePaths = cliOption.arguments

var sourceFiles = [SourceFile]()
for filePath in filePaths {
  guard let sourceFile = try? SourceReader.read(at: filePath) else {
    print("Can't read file \(filePath)")
    exit(-1)
  }
  sourceFiles.append(sourceFile)
}

if sourceFiles.count > 1, case .standardOutput = output {
  print("Output folder must be specified with `-o` for transforming multiple files at once.")
  exit(-1)
}

let commonPathPrefix = sourceFiles.map({ $0.identifier }).commonPathPrefix

let tokenizer = Tokenizer(options: formats)
let tokenJoiner = TokenJoiner(options: formats)
let generator = Generator(options: formats, tokenizer: tokenizer, tokenJoiner: tokenJoiner)
let driver = Driver(generator: generator)

for sourceFile in sourceFiles {
  var outputHandle: FileHandle
  switch output {
  case .standardOutput:
    outputHandle = .standardOutput
  case .fileOutput(let outputPath):
    if sourceFiles.count == 1 {
      outputHandle = outputPath.fileHandle
    } else {
      var originalFilePath = sourceFile.identifier
      let commonPrefixIndex = originalFilePath.index(originalFilePath.startIndex, offsetBy: commonPathPrefix.count)
      originalFilePath = String(originalFilePath[commonPrefixIndex...])
      let filePath = commonPathPrefix + outputPath + "/" + originalFilePath
      outputHandle = filePath.fileHandle
    }
  }

  driver.transform(sourceFile: sourceFile, outputHandle: outputHandle)
}
