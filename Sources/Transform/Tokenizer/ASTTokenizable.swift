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

public protocol ASTTokenizable {}

extension ASTTokenizable where Self : ASTNode {
    func newToken(_ kind: Token.Kind, _ value: String) -> Token {
        return Token(origin: self, node: self, kind: kind, value: value)
    }
}

extension ASTTokenizable {
    func newToken(_ kind: Token.Kind, _ value: String, _ node: ASTNode) -> Token {
        return Token(origin: self, node: node, kind: kind, value: value)
    }
}


// TODO: Remove and make it per element?
extension ASTNode: ASTTokenizable {}
