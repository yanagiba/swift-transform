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
    
    open func tokenize(_ attributes: Attributes, node: ASTNode) -> [Token] {
        return attributes.map { tokenize($0, node: node) }.joined(token: node.newToken(.space, " ", node))
    }

    open func tokenize(_ attribute: Attribute, node: ASTNode) -> [Token] {
        return
            attribute.newToken(.symbol, "@", node) +
            attribute.newToken(.identifier, attribute.name, node) +
            attribute.argumentClause.map { tokenize($0, node: node) }
    }

    open func tokenize(_ argument: Attribute.ArgumentClause, node: ASTNode) -> [Token] {
        return
            argument.newToken(.startOfScope, "(", node) +
            tokenize(argument.balancedTokens, node: node) +
            argument.newToken(.endOfScope, ")", node)
    }

    open func tokenize(_ tokens: [Attribute.ArgumentClause.BalancedToken], node: ASTNode) -> [Token] {
        return tokens.map { tokenize($0, node: node) }.joined()
    }

    open func tokenize(_ token: Attribute.ArgumentClause.BalancedToken, node: ASTNode) -> [Token] {
        switch token {
        case .token(let tokenString):
            return [token.newToken(.identifier, tokenString, node)]
        case .parenthesis(let tokens):
            return token.newToken(.startOfScope, "(", node) + tokenize(tokens, node: node) + token.newToken(.endOfScope, ")", node)
        case .square(let tokens):
            return token.newToken(.startOfScope, "[", node) + tokenize(tokens, node: node) + token.newToken(.endOfScope, "]", node)
        case .brace(let tokens):
            return token.newToken(.startOfScope, "{", node) + tokenize(tokens, node: node) + token.newToken(.endOfScope, "}", node)
        }
    }

    // TODO: Delete generate methods

    open func generate(_ attributes: Attributes, node: ASTNode) -> String {
        return tokenize(attributes, node: node).joinedValues()
    }
    open func generate(_ attribute: Attribute, node: ASTNode) -> String {
       return tokenize(attribute, node: node).joinedValues()
    }
}
extension Attribute: ASTTokenizable {}
extension Attribute.ArgumentClause: ASTTokenizable {}
extension Attribute.ArgumentClause.BalancedToken: ASTTokenizable {}

