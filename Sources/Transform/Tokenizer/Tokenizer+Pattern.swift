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

    open func tokenize(_ pattern: Pattern, node: ASTNode) -> [Token] {
        switch pattern {
        case let pattern as EnumCasePattern:
            return tokenize(pattern, node: node)
        case let pattern as ExpressionPattern:
            return tokenize(pattern)
        case let pattern as IdentifierPattern:
            return tokenize(pattern, node: node)
        case let pattern as OptionalPattern:
            return tokenize(pattern, node: node)
        case let pattern as TuplePattern:
            return tokenize(pattern, node: node)
        case let pattern as TypeCastingPattern:
            return tokenize(pattern, node: node)
        case let pattern as ValueBindingPattern:
            return tokenize(pattern, node: node)
        case let pattern as WildcardPattern:
            return tokenize(pattern, node: node)
        default:
            return [node.newToken(.identifier, pattern.textDescription)]
        }
    }

    open func tokenize(_ pattern: EnumCasePattern, node: ASTNode) -> [Token] {
        return
            pattern.typeIdentifier.map { tokenize($0, node: node) } +
            pattern.newToken(.delimiter, ".", node) +
            pattern.newToken(.identifier, pattern.name, node) +
            pattern.tuplePattern.map { tokenize($0, node: node) }
    }

    open func tokenize(_ pattern: ExpressionPattern) -> [Token] {
        return tokenize(pattern.expression)
    }

    open func tokenize(_ pattern: IdentifierPattern, node: ASTNode) -> [Token] {
        return
            pattern.newToken(.identifier, pattern.identifier, node) +
            pattern.typeAnnotation.map { tokenize($0, node: node) }
    }

    open func tokenize(_ pattern: OptionalPattern, node: ASTNode) -> [Token] {
        switch pattern.kind {
        case .identifier(let idPttrn):
            return tokenize(idPttrn, node: node) + pattern.newToken(.symbol, "?", node)
        case .wildcard:
            return pattern.newToken(.symbol, "_", node) + pattern.newToken(.symbol, "?", node)
        case .enumCase(let enumCasePttrn):
            return tokenize(enumCasePttrn, node: node) + pattern.newToken(.symbol, "?", node)
        case .tuple(let tuplePttrn):
            return tokenize(tuplePttrn, node: node) + pattern.newToken(.symbol, "?", node)
        }
    }

    open func tokenize(_ pattern: TuplePattern, node: ASTNode) -> [Token] {
        return
            pattern.newToken(.startOfScope, "(", node) +
            pattern.elementList.map { tokenize($0, node: node) }.joined(token: pattern.newToken(.delimiter, ", ", node)) +
            pattern.newToken(.endOfScope, ")", node) +
            pattern.typeAnnotation.map { tokenize($0, node: node) }
    }

    open func tokenize(_ element: TuplePattern.Element, node: ASTNode) -> [Token] {
        switch element {
        case .pattern(let pattern):
            return tokenize(pattern, node: node)
        case let .namedPattern(name, pattern):
            return element.newToken(.identifier, name, node) +
                element.newToken(.delimiter, ": ", node) +
                tokenize(pattern, node: node)
        }
    }

    open func tokenize(_ pattern: TypeCastingPattern, node: ASTNode) -> [Token] {
        switch pattern.kind {
        case .is(let type):
            return pattern.newToken(.keyword, "is", node) +
                pattern.newToken(.space, " ", node) +
                tokenize(type, node: node)
        case let .as(p, type):
            return tokenize(p, node: node) +
            pattern.newToken(.space, " ", node) +
            pattern.newToken(.keyword, "as", node) +
            pattern.newToken(.space, " ", node) +
            tokenize(type, node: node)
        }
    }

    open func tokenize(_ pattern: ValueBindingPattern, node: ASTNode) -> [Token] {
        switch pattern.kind {
        case .var(let p):
            return pattern.newToken(.keyword, "var", node) +
                pattern.newToken(.space, " ", node) +
                tokenize(p, node: node)
        case .let(let p):
            return pattern.newToken(.keyword, "let", node) +
                pattern.newToken(.space, " ", node) +
                tokenize(p, node: node)
        }
    }

    open func tokenize(_ pattern: WildcardPattern, node: ASTNode) -> [Token] {
        return pattern.newToken(.keyword, "_", node) +
            pattern.typeAnnotation.map { tokenize($0, node: node) }
    }

    // TODO: Delete temporal generates
    open func generate(_ pattern: Pattern, node: ASTNode) -> String {
        return tokenize(pattern, node: node).joinedValues()
    }
}

extension PatternBase: ASTTokenizable {}
extension TuplePattern.Element: ASTTokenizable {}
