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
    open func generate(_ type: Type, node: ASTNode) -> String {
        switch type {
        case let type as AnyType:
            return generate(type)
        case let type as ArrayType:
            return generate(type, node: node)
        case let type as DictionaryType:
            return generate(type, node: node)
        case let type as FunctionType:
            return generate(type, node: node)
        case let type as ImplicitlyUnwrappedOptionalType:
            return generate(type, node: node)
        case let type as MetatypeType:
            return generate(type, node: node)
        case let type as OptionalType:
            return generate(type, node: node)
        case let type as ProtocolCompositionType:
            return generate(type, node: node)
        case let type as SelfType:
            return generate(type)
        case let type as TupleType:
            return generate(type, node: node)
        case let type as TypeIdentifier:
            return generate(type, node: node)
        default:
            return type.textDescription
        }
    }
    
    open func generate(_ type: AnyType) -> String {
        return "Any"
    }
    
    open func generate(_ type: ArrayType, node: ASTNode) -> String {
        return "[\(generate(type.elementType, node: node))]"
    }
    
    open func generate(_ type: DictionaryType, node: ASTNode) -> String {
        return "[\(generate(type.keyType, node: node)): \(generate(type.valueType, node: node))]"
    }
    
    open func generate(_ type: FunctionType, _ node: ASTNode) -> String {
        let attrsText = type.attributes.isEmpty ? "" : "\(generate(type.attributes)) "
        let argsText = "(\(type.arguments.map { generate($0, node: node) }.joined(separator: ", ")))"
        let throwsText = tokenize(type.throwsKind, node: node)
            .prefix(with: type.newToken(.space, " ", node))
            .joinedValues()
        return "\(attrsText)\(argsText)\(throwsText) -> \(generate(type.returnType, node: node))"
    }
    
    open func generate(_ type: FunctionType.Argument, node: ASTNode) -> String {
        let attr = type.attributes.isEmpty ? "" : "\(generate(type.attributes)) "
        let inoutStr = type.isInOutParameter ? "inout " : ""
        var nameStr = type.externalName.map({ "\($0) " }) ?? ""
        if let localName = type.localName {
            nameStr += "\(localName): "
        }
        let variadicDots = type.isVariadic ? "..." : ""
        return "\(nameStr)\(attr)\(inoutStr)\(generate(type.type, node: node))\(variadicDots)"
    }
    
    open func generate(_ type: ImplicitlyUnwrappedOptionalType, node: ASTNode) -> String {
        return "\(generate(type.wrappedType, node: node))!"
    }
    
    open func generate(_ type: MetatypeType, node: ASTNode) -> String {
        switch type.kind {
        case .type:
            return "\(generate(type.referenceType, node: node)).Type"
        case .protocol:
            return "\(generate(type.referenceType, node: node)).Protocol"
        }
    }
    
    open func generate(_ type: OptionalType, node: ASTNode) -> String {
        return "\(generate(type.wrappedType, node: node))?"
    }
    
    open func generate(_ type: ProtocolCompositionType, node: ASTNode) -> String {
        return type.protocolTypes.map { generate($0, node: node) }.joined(separator: " & ")
    }
    
    open func generate(_ type: SelfType) -> String {
        return "Self"
    }
    
    open func generate(_ type: TupleType, node: ASTNode) -> String {
        return "(\(type.elements.map { generate($0, node: node) }.joined(separator: ", ")))"
    }
    
    open func generate(_ type: TupleType.Element, node: ASTNode) -> String {
        let attr = type.attributes.isEmpty ? "" : "\(generate(type.attributes)) "
        let inoutStr = type.isInOutParameter ? "inout " : ""
        var nameStr = ""
        if let name = type.name {
            nameStr = "\(name): "
        }
        return "\(nameStr)\(attr)\(inoutStr)\(generate(type.type, node: node))"
    }
    
    open func generate(_ type: TypeAnnotation, node: ASTNode) -> String {
        let attr = type.attributes.isEmpty ? "" : "\(generate(type.attributes)) "
        let inoutStr = type.isInOutParameter ? "inout " : ""
        return ": \(attr)\(inoutStr)\(generate(type.type, node: node))"
    }
    
    open func generate(_ type: TypeIdentifier, node: ASTNode) -> String {
        return type.names
            .map({ "\($0.name)\($0.genericArgumentClause.map { generate($0, node: node) }  ?? "")" })
            .joined(separator: ".")
    }
    
    open func generate(_ type: TypeInheritanceClause, node: ASTNode) -> String {
        var prefixText = ": "
        if type.classRequirement {
            prefixText += "class"
        }
        if type.classRequirement && !type.typeInheritanceList.isEmpty {
            prefixText += ", "
        }
        return "\(prefixText)\(type.typeInheritanceList.map { generate($0, node: node) }.joined(separator: ", "))"
    }
}

extension TypeBase: ASTTokenizable {}
