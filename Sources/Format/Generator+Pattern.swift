//
//  Generator+Pattern.swift
//  Format
//
//  Created by Angel Garcia on 14/07/2017.
//

import AST

extension Generator {
    
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
