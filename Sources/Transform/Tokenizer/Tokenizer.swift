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

open class Tokenizer {
    let options: [String: Any]?
    let indentation = "  "
    
    public init(options: [String: Any]? = nil) {
        self.options = options
    }
    
    open func indent(_ tokens: [Token]) -> [Token] {
        guard let node = tokens.first?.node else { return tokens }
        return tokens.reduce([node.newToken(.indentation, indentation)]) { (result, token) -> [Token] in
            return result + token + (token.kind == .linebreak ? token.node?.newToken(.indentation, indentation) : nil)
        }
    }
}
