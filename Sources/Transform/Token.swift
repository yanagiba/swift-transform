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
import AST

public struct Token {
    public let origin: ASTTokenizable?          // Element creating the token
    public let node: ASTNode?                   // Closest AST Node tree
    public let kind: Kind                       // Semantic type
    public let value: String                    // Raw string withe the output

    public enum Kind {
        case identifier
        case keyword
        case space
        case linebreak
        case indentation
        case number
        case string
        case symbol
        case delimiter
        case comment
        case startOfScope
        case endOfScope
    }
}
