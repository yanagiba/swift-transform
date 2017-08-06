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

    // TODO: Review
    open func tokenize(_ attributes: Attributes, node: ASTNode) -> [Token] {
        return attributes.map { [node.newToken(.identifier, generate($0), node)] }
            .joined(token: node.newToken(.space, " ", node))
    }

    open func generate(_ attributes: Attributes) -> String {
        return attributes.map(generate).joined(separator: " ")
    }

    open func generate(_ attribute: Attribute) -> String {
        return "@\(attribute.name)\(attribute.argumentClause.map(generate) ?? "")"
    }

    open func generate(_ argument: Attribute.ArgumentClause) -> String {
        return "(\(generate(argument.balancedTokens)))"
    }

    open func generate(_ token: Attribute.ArgumentClause.BalancedToken) -> String {
        switch token {
        case .token(let tokenString):
            return tokenString
        case .parenthesis(let tokens):
            return "(\(generate(tokens)))"
        case .square(let tokens):
            return "[\(generate(tokens))]"
        case .brace(let tokens):
            return "{\(generate(tokens))}"
        }
    }

    open func generate(_ tokens: [Attribute.ArgumentClause.BalancedToken]) -> String {
        return tokens.map(generate).joined()
    }
}
