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

    open func tokenize(_ parameter: GenericParameterClause.GenericParameter, node: ASTNode) -> [Token] {
        switch parameter {
        case let .identifier(t):
            return [parameter.newToken(.identifier, t, node)]
        case let .typeConformance(t, typeIdentifier):
            return parameter.newToken(.identifier, t, node) +
                parameter.newToken(.delimiter, ": ", node) +
                tokenize(typeIdentifier, node: node)

        case let .protocolConformance(t, protocolCompositionType):
            return parameter.newToken(.identifier, t, node) +
                parameter.newToken(.delimiter, ": ", node) +
                tokenize(protocolCompositionType, node: node)
        }
    }

    open func tokenize(_ clause: GenericParameterClause, node: ASTNode) -> [Token] {
        return
            clause.newToken(.startOfScope, "<", node) +
            clause.parameterList.map { tokenize($0, node: node) }.joined(token: clause.newToken(.delimiter, ", ", node)) +
            clause.newToken(.endOfScope, ">", node)
    }

    open func tokenize(_ clause: GenericWhereClause.Requirement, node: ASTNode) -> [Token] {
        switch clause {
        case let .sameType(t, type):
            return tokenize(t, node: node) +
                clause.newToken(.symbol, " == ", node) +
                tokenize(type, node: node)

        case let .typeConformance(t, typeIdentifier):
            return tokenize(t, node: node) +
                clause.newToken(.symbol, ": ", node) +
                tokenize(typeIdentifier, node: node)

        case let .protocolConformance(t, protocolCompositionType):
            return tokenize(t, node: node) +
                clause.newToken(.symbol, ": ", node) +
                tokenize(protocolCompositionType, node: node)
        }
    }

    open func tokenize(_ clause: GenericWhereClause, node: ASTNode) -> [Token] {
        return clause.newToken(.keyword, "where", node) +
            clause.newToken(.space, " ", node) +
            clause.requirementList.map { tokenize($0, node: node) }.joined(token: clause.newToken(.delimiter, ", ", node))
    }

    open func tokenize(_ clause: GenericArgumentClause, node: ASTNode) -> [Token] {
        return clause.newToken(.startOfScope, "<", node) +
                clause.argumentList.map { tokenize($0, node: node) }.joined(token: clause.newToken(.delimiter, ", ", node)) +
                clause.newToken(.endOfScope, ">", node)
    }

    // TODO: Delete generate methods

    open func generate(_ clause: GenericParameterClause, node: ASTNode) -> String {
        return tokenize(clause, node: node).joinedValues()
    }

    open func generate(_ clause: GenericWhereClause, node: ASTNode) -> String {
        return tokenize(clause, node: node).joinedValues()
    }

    open func generate(_ clause: GenericArgumentClause, node: ASTNode) -> String {
        return tokenize(clause, node: node).joinedValues()
    }
}


extension GenericParameterClause: ASTTokenizable {}
extension GenericParameterClause.GenericParameter: ASTTokenizable {}
extension GenericWhereClause: ASTTokenizable {}
extension GenericWhereClause.Requirement: ASTTokenizable {}
extension GenericArgumentClause: ASTTokenizable {}
