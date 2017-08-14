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
import Parser
import Diagnostic
import Tooling

open class Driver {
  private var _generator: Generator

  public init(generator: Generator = Generator()) {
    _generator = generator
  }

  func udpateGenerator(_ generator: Generator) {
    _generator = generator
  }

  @discardableResult public func transform(
    sourceFile: SourceFile,
    outputHandle: FileHandle = .standardOutput
  ) -> Int32 {
    let diagnosticConsumer = SilentDiagnosticConsumer()
    let tooling = ToolAction()
    let result = tooling.run(
      sourceFiles: [sourceFile],
      diagnosticConsumer: diagnosticConsumer,
      options: [.assignLexicalParent])

    guard result.exitCode == ToolActionResult.success,
      let astUnit = result.astUnitCollection.first
    else {
      print("Failed in parsing file \(sourceFile.identifier)")
      // Ignore the errors for now
      return -1
    }

    let transformed = _generator.generate(astUnit.translationUnit)
    guard let strData = "\(transformed)\n".data(using: .utf8) else {
      return -2
    }

    outputHandle.write(strData)

    return 0
  }
}

private struct SilentDiagnosticConsumer : DiagnosticConsumer {
  func consume(diagnostics: [Diagnostic]) {}
}
