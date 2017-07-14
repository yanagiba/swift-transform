//
//  Generator+Types.swift
//  Format
//
//  Created by Angel Garcia on 14/07/2017.
//

import AST

extension Generator {
    
    open func generate(_ type: Type) -> String {
        // TODO: Implement all cases
        return type.textDescription
    }
    
    open func generate(_ type: TupleType) -> String {
            return "(\(type.elements.map(generate).joined(separator: ", ")))"
    }
    
    open func generate(_ type: TupleType.Element) -> String {
            let attr = type.attributes.isEmpty ? "" : "\(generate(type.attributes)) "
            let inoutStr = type.isInOutParameter ? "inout " : ""
            var nameStr = ""
            if let name = type.name {
                nameStr = "\(name): "
            }
            return "\(nameStr)\(attr)\(inoutStr)\(generate(type.type))"
    }
    
    open func generate(_ type: TypeInheritanceClause) -> String {
        var prefixText = ": "
        if type.classRequirement {
            prefixText += "class"
        }
        if type.classRequirement && !type.typeInheritanceList.isEmpty {
            prefixText += ", "
        }
        return "\(prefixText)\(type.typeInheritanceList.map(generate).joined(separator: ", "))"
    }
    
    open func generate(_ type: TypeAnnotation) -> String {
        let attr = type.attributes.isEmpty ? "" : "\(generate(type.attributes)) "
        let inoutStr = type.isInOutParameter ? "inout " : ""
        return ": \(attr)\(inoutStr)\(generate(type.type))"
    }
    
}
