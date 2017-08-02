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
    open func tokenize(_ pattern: Pattern, node: ASTNode) -> [Token] {
        return [node.newToken(.identifier, generate(pattern, node: node))]
    }
    open func generate(_ pattern: Pattern, node: ASTNode) -> String {
        switch pattern {
        case let pattern as EnumCasePattern:
            return generate(pattern, node: node)
        case let pattern as ExpressionPattern:
            return generate(pattern)
        case let pattern as IdentifierPattern:
            return generate(pattern, node: node)
        case let pattern as OptionalPattern:
            return generate(pattern, node: node)
        case let pattern as TuplePattern:
            return generate(pattern, node: node)
        case let pattern as TypeCastingPattern:
            return generate(pattern, node: node)
        case let pattern as ValueBindingPattern:
            return generate(pattern, node: node)
        case let pattern as WildcardPattern:
            return generate(pattern, node: node)
        default:
            return pattern.textDescription
        }
    }
    
    open func generate(_ pattern: EnumCasePattern, node: ASTNode) -> String {
        return "\(pattern.typeIdentifier.map { generate($0, node: node) } ?? "").\(pattern.name)\(pattern.tuplePattern.map { generate($0, node: node) } ?? "")"
    }
    
    open func generate(_ pattern: ExpressionPattern) -> String {
        return generate(pattern.expression)
    }
    
    open func generate(_ pattern: IdentifierPattern, node: ASTNode) -> String {
        return "\(pattern.identifier)\(pattern.typeAnnotation.map { generate($0, node: node) } ?? "")"
    }
    
    open func generate(_ pattern: OptionalPattern, node: ASTNode) -> String {
        switch pattern.kind {
        case .identifier(let idPttrn):
            return "\(generate(idPttrn, node: node))?"
        case .wildcard:
            return "_?"
        case .enumCase(let enumCasePttrn):
            return "\(generate(enumCasePttrn, node: node))?"
        case .tuple(let tuplePttrn):
            return "\(generate(tuplePttrn, node: node))?"
        }
    }
    
    open func generate(_ pattern: TuplePattern, node: ASTNode) -> String {
        let elemStr = pattern.elementList.map { generate($0, node: node) }.joined(separator: ", ")
        let annotationStr = pattern.typeAnnotation.map { generate($0, node: node) } ?? ""
        return "(\(elemStr))\(annotationStr)"
    }
    
    open func generate(_ pattern: TuplePattern.Element, node: ASTNode) -> String {
        switch pattern {
        case .pattern(let pattern):
            return generate(pattern, node: node)
        case let .namedPattern(name, pattern):
            return "\(name): \(generate(pattern, node: node))"
        }
    }
    
    open func generate(_ pattern: TypeCastingPattern, node: ASTNode) -> String {
        switch pattern.kind {
        case .is(let type):
            return "is \(generate(type, node: node))"
        case let .as(pattern, type):
            return "\(generate(pattern, node: node)) as \(generate(type, node: node))"
        }
    }
    
    open func generate(_ pattern: ValueBindingPattern, node: ASTNode) -> String {
        switch pattern.kind {
        case .var(let pattern):
            return "var \(generate(pattern, node: node))"
        case .let(let pattern):
            return "let \(generate(pattern, node: node))"
        }
    }
    
    open func generate(_ pattern: WildcardPattern, node: ASTNode) -> String {
        return "_\(pattern.typeAnnotation.map { generate($0, node: node) } ?? "")"
    }
}

