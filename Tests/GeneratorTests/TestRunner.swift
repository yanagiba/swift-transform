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

import XCTest

@testable import Source

func runTest(
  _ resourceName: String,
  _ testName: String,
  convertor convert: (SourceFile) -> String
) {
  let pwd = URL(fileURLWithPath: #file).deletingLastPathComponent().path
  let testTarget = "\(resourceName)/\(testName)"
  let testPath = "\(pwd)/\(testTarget)"
  let sourcePath = "\(testPath).source"
  let resultPath = "\(testPath).result"
  guard let sourceContent = try? String(contentsOfFile: sourcePath, encoding: .utf8),
    let resultContent = try? String(contentsOfFile: resultPath, encoding: .utf8)
  else {
    XCTFail("Failed in reading contents for \(testPath)")
    return
  }

  let sourceFile = SourceFile(path: "\(testTarget)Tests.swift", content: sourceContent)
  let result = convert(sourceFile)

  AssertTextEquals(result, resultContent)
}


func AssertTextEquals(_ translate: String?, _ expected: String) {
    guard let translate = translate else {
        XCTFail("Translation failed")
        return
    }

    if translate != expected {
        //Find text difference
        let difference = prettyFirstDifferenceBetweenStrings(translate, expected)
        XCTFail(difference)
    }
}



/// Find first differing character between two strings
///
/// :param: s1 First String
/// :param: s2 Second String
///
/// :returns: .DifferenceAtIndex(i) or .NoDifference
public func firstDifferenceBetweenStrings(_ s1: String, _ s2: String) -> FirstDifferenceResult {
    let len1 = s1.characters.count
    let len2 = s2.characters.count

    let lenMin = min(len1, len2)

    for i in 0..<lenMin {
        if s1.characters[s1.index(s1.startIndex, offsetBy: i)] != s2.characters[s2.index(s2.startIndex, offsetBy: i)] {
            return .DifferenceAtIndex(i)
        }
    }

    if len1 < len2 {
        return .DifferenceAtIndex(len1)
    }

    if len2 < len1 {
        return .DifferenceAtIndex(len2)
    }

    return .NoDifference
}


/// Create a formatted String representation of difference between strings
///
/// :param: s1 First string
/// :param: s2 Second string
///
/// :returns: a string, possibly containing significant whitespace and newlines
public func prettyFirstDifferenceBetweenStrings(_ s1: String, _ s2: String) -> String {
    let firstDifferenceResult = firstDifferenceBetweenStrings(s1, s2)
    return prettyDescriptionOfFirstDifferenceResult(firstDifferenceResult, s1, s2)
}


/// Create a formatted String representation of a FirstDifferenceResult for two strings
///
/// :param: firstDifferenceResult FirstDifferenceResult
/// :param: s1 First string used in generation of firstDifferenceResult
/// :param: s2 Second string used in generation of firstDifferenceResult
///
/// :returns: a printable string, possibly containing significant whitespace and newlines
public func prettyDescriptionOfFirstDifferenceResult(
    _ firstDifferenceResult: FirstDifferenceResult,
    _ s1: String,
    _ s2: String) -> String {

    func diffString(_ index: Int, _ s1: String, _ s2: String) -> String {
        let markerArrow: Character = "👉"

        var string1 = s1
        string1.insert(markerArrow, at: string1.index(string1.startIndex, offsetBy: index))

        var string2 = s2
        string2.insert(markerArrow, at: string2.index(string2.startIndex, offsetBy: index))

        return "Difference at index \(index):\n------ Result: \n\(string1)\n------ Expected:\n\(string2)\n------\n"
    }

    switch firstDifferenceResult {
    case .NoDifference:                 return "No difference"
    case .DifferenceAtIndex(let index): return diffString(index, s1, s2)
    }
}


/// Result type for firstDifferenceBetweenStrings()
public enum FirstDifferenceResult {
    /// Strings are identical
    case NoDifference

    /// Strings differ at the specified index.
    ///
    /// This could mean that characters at the specified index are different,
    /// or that one string is longer than the other
    case DifferenceAtIndex(Int)
}


