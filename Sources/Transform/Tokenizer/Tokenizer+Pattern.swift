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
    open func generate(_ pattern: Pattern) -> String {
        switch pattern {
        case let pattern as EnumCasePattern:
            return generate(pattern)
        case let pattern as ExpressionPattern:
            return generate(pattern)
        case let pattern as IdentifierPattern:
            return generate(pattern)
        case let pattern as OptionalPattern:
            return generate(pattern)
        case let pattern as TuplePattern:
            return generate(pattern)
        case let pattern as TypeCastingPattern:
            return generate(pattern)
        case let pattern as ValueBindingPattern:
            return generate(pattern)
        case let pattern as WildcardPattern:
            return generate(pattern)
        default:
            return pattern.textDescription
        }
    }
    
    open func generate(_ pattern: EnumCasePattern) -> String {
        return "\(pattern.typeIdentifier.map(generate) ?? "").\(pattern.name)\(pattern.tuplePattern.map(generate) ?? "")"
    }
    
    open func generate(_ pattern: ExpressionPattern) -> String {
        return generate(pattern.expression)
    }
    
    open func generate(_ pattern: IdentifierPattern) -> String {
        return "\(pattern.identifier)\(pattern.typeAnnotation.map(generate) ?? "")"
    }
    
    open func generate(_ pattern: OptionalPattern) -> String {
        switch pattern.kind {
        case .identifier(let idPttrn):
            return "\(generate(idPttrn))?"
        case .wildcard:
            return "_?"
        case .enumCase(let enumCasePttrn):
            return "\(generate(enumCasePttrn))?"
        case .tuple(let tuplePttrn):
            return "\(generate(tuplePttrn))?"
        }
    }
    
    open func generate(_ pattern: TuplePattern) -> String {
        let elemStr = pattern.elementList.map(generate).joined(separator: ", ")
        let annotationStr = pattern.typeAnnotation.map(generate) ?? ""
        return "(\(elemStr))\(annotationStr)"
    }
    
    open func generate(_ pattern: TuplePattern.Element) -> String {
        switch pattern {
        case .pattern(let pattern):
            return generate(pattern)
        case let .namedPattern(name, pattern):
            return "\(name): \(generate(pattern))"
        }
    }
    
    open func generate(_ pattern: TypeCastingPattern) -> String {
        switch pattern.kind {
        case .is(let type):
            return "is \(generate(type))"
        case let .as(pattern, type):
            return "\(generate(pattern)) as \(generate(type))"
        }
    }
    
    open func generate(_ pattern: ValueBindingPattern) -> String {
        switch pattern.kind {
        case .var(let pattern):
            return "var \(generate(pattern))"
        case .let(let pattern):
            return "let \(generate(pattern))"
        }
    }
    
    open func generate(_ pattern: WildcardPattern) -> String {
        return "_\(pattern.typeAnnotation.map(generate) ?? "")"
    }
}

