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

import Source
import Transform

let dotYanagibaTransform = DotYanagibaTransform.loadFromDisk()

var cliArgs = CommandLine.arguments
cliArgs.remove(at: 0)

func argumentsContain(_ option: String) -> Bool {
  return !cliArgs.filter({ $0 == "-\(option)" || $0 == "--\(option)" }).isEmpty
}

func readOption(_ option: String) -> String? {
  guard let argIndex = cliArgs.index(of: "-\(option)") else {
    return nil
  }

  let argValueIndex = cliArgs.index(after: argIndex)
  guard argValueIndex < cliArgs.count else {
    return nil
  }

  let option = cliArgs[argValueIndex]
  cliArgs.removeSubrange(argIndex...argValueIndex)
  return option
}

func readOptionAsDictionary(_ option: String) -> [String: Any]? {
  guard let optionString = readOption(option) else {
    return nil
  }

  return optionString.components(separatedBy: ",")
    .flatMap({ opt -> (String, String)? in
      let keyValuePair = opt.components(separatedBy: "=")
      guard keyValuePair.count == 2 else {
        return nil
      }
      let key = keyValuePair[0]
      let value = keyValuePair[1]
      return (key, value)
    }).reduce([:]) { (carryOver, arg) -> [String: Any] in
      var mutableDict = carryOver
      mutableDict[arg.0] = arg.1
      return mutableDict
    }
}

func findCommonPathPrefix(_ paths: [String]) -> String {
  var shortestPath: String?
  var length = Int.max

  for path in paths {
    if path.count < length {
      length = path.count
      shortestPath = path
    }
  }

  guard var commonPrefix = shortestPath else {
    return ""
  }

  var endIndex = commonPrefix.endIndex
  for path in paths {
    while !commonPrefix.isEmpty && !path.hasPrefix(commonPrefix) {
      endIndex = commonPrefix.index(before: endIndex)
      commonPrefix = commonPrefix.substring(to: endIndex)
    }
  }

  return commonPrefix
}

if argumentsContain("help") {
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

if argumentsContain("version") {
  print("""
  Yanagiba's \(SWIFT_TRANSFORM) (http://yanagiba.org/\(SWIFT_TRANSFORM)):
    version \(SWIFT_TRANSFORM_VERSION).

  Yanagiba's swift-ast (http://yanagiba.org/swift-ast):
    version \(SWIFT_AST_VERSION).
  """)
  exit(0)
}

let formats = computeFormats(dotYanagibaTransform, readOptionAsDictionary("-formats"))
let output = computeOutput(dotYanagibaTransform, readOption("o") ?? readOption("-output"))

let filePaths = cliArgs

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

let sourcePaths = sourceFiles.map({ $0.identifier })
let commonPathPrefix = findCommonPathPrefix(sourcePaths)

func getFileHandle(atPath path: String) -> FileHandle {
  let outputPath = path.absolutePath
  let fileManager = FileManager.default
  if fileManager.fileExists(atPath: outputPath) {
    _ = try? "".write(toFile: outputPath, atomically: true, encoding: .utf8)
  } else {
    if !fileManager.createFile(atPath: outputPath, contents: nil) {
      _ = try? fileManager.createDirectory(atPath: path.parentPath, withIntermediateDirectories: true)
      _ = fileManager.createFile(atPath: outputPath, contents: nil)
    }
  }
  if let fileHandle = FileHandle(forWritingAtPath: outputPath) {
    return fileHandle
  }
  return .standardOutput
}

fileprivate extension String {
  var absolutePath: String {
    if self.hasPrefix("/") {
      return self
    }

    let currentDirectory = FileManager.default.currentDirectoryPath
    var pathHead = NSString(string: currentDirectory).pathComponents.filter { $0 != "." }
    if pathHead.count > 1 && pathHead.last == "/" {
      pathHead.removeLast()
    }
    var pathTail = NSString(string: self).pathComponents.filter { $0 != "." }
    if pathTail.count > 1 && pathTail.last == "/" {
      pathTail.removeLast()
    }

    while pathTail.first == ".." {
      pathTail.removeFirst()
      if !pathHead.isEmpty {
        pathHead.removeLast()
      }

      if pathHead.isEmpty || pathTail.isEmpty {
        break
      }
    }

    let absolutePath = pathHead.joined(separator: "/") + "/" + pathTail.joined(separator: "/")
    return absolutePath.substring(from: absolutePath.index(after: absolutePath.startIndex))
  }

  var parentPath: String {
    var components = absolutePath.split(separator: "/")
    components.removeLast()
    return "/" + components.map(String.init).joined(separator: "/")
  }
}

let generator = Generator(formats: formats)
let driver = Driver(generator: generator)

for sourceFile in sourceFiles {
  var outputHandle: FileHandle
  switch output {
  case .standardOutput:
    outputHandle = .standardOutput
  case .fileOutput(let outputPath):
    if sourceFiles.count == 1 {
      outputHandle = getFileHandle(atPath: outputPath)
    } else {
      var originalFilePath = sourceFile.identifier
      let commonPrefixIndex = originalFilePath.index(originalFilePath.startIndex, offsetBy: commonPathPrefix.count)
      originalFilePath = originalFilePath.substring(from: commonPrefixIndex)
      let filePath = commonPathPrefix + outputPath + "/" + originalFilePath
      outputHandle = getFileHandle(atPath: filePath)
    }
  }

  driver.transform(sourceFile: sourceFile, outputHandle: outputHandle)
}
