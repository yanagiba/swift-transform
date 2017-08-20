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

import AST

extension Tokenizer {
    open func tokenize(_ origin: ThrowsKind, node: ASTNode) -> [Token] {
        switch origin {
        case .nothrowing: return []
        case .throwing: return [origin.newToken(.keyword, "throws", node)]
        case .rethrowing: return [origin.newToken(.keyword, "rethrows", node)]
        }
    }
}

extension ThrowsKind: ASTTokenizable {}
