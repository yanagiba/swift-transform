/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

extension Generator {
  open func generate(_ type: Type) -> String {
    switch type {
    case let type as AnyType:
      return generate(type)
    case let type as ArrayType:
      return generate(type)
    case let type as DictionaryType:
      return generate(type)
    case let type as FunctionType:
      return generate(type)
    case let type as ImplicitlyUnwrappedOptionalType:
      return generate(type)
    case let type as MetatypeType:
      return generate(type)
    case let type as OptionalType:
      return generate(type)
    case let type as ProtocolCompositionType:
      return generate(type)
    case let type as SelfType:
      return generate(type)
    case let type as TupleType:
      return generate(type)
    case let type as TypeAnnotation:
      return generate(type)
    case let type as TypeIdentifier:
      return generate(type)
    case let type as TypeInheritanceClause:
      return generate(type)
    default:
      return type.textDescription
    }
  }

  open func generate(_ type: AnyType) -> String {
    return "Any"
  }

  open func generate(_ type: ArrayType) -> String {
    return "[\(generate(type.elementType))]"
  }

  open func generate(_ type: DictionaryType) -> String {
    return "[\(generate(type.keyType)): \(generate(type.valueType))]"
  }

  open func generate(_ type: FunctionType) -> String {
    let attrsText = type.attributes.isEmpty ? "" : "\(generate(type.attributes)) "
    let argsText = "(\(type.arguments.map(generate).joined(separator: ", ")))"
    let throwsText = generate(type.throwsKind).isEmpty ? "" : " \(generate(type.throwsKind))"
    return "\(attrsText)\(argsText)\(throwsText) -> \(generate(type.returnType))"
  }

  open func generate(_ type: FunctionType.Argument) -> String {
    let attr = type.attributes.isEmpty ? "" : "\(generate(type.attributes)) "
    let inoutStr = type.isInOutParameter ? "inout " : ""
    var nameStr = type.externalName.map({ "\($0) " }) ?? ""
    if let localName = type.localName {
      nameStr += "\(localName): "
    }
    let variadicDots = type.isVariadic ? "..." : ""
    return "\(nameStr)\(attr)\(inoutStr)\(generate(type.type))\(variadicDots)"
  }

  open func generate(_ type: ImplicitlyUnwrappedOptionalType) -> String {
    return "\(generate(type.wrappedType))!"
  }

  open func generate(_ type: MetatypeType) -> String {
    switch type.kind {
    case .type:
      return "\(generate(type.referenceType)).Type"
    case .protocol:
      return "\(generate(type.referenceType)).Protocol"
    }
  }

  open func generate(_ type: OptionalType) -> String {
    return "\(generate(type.wrappedType))?"
  }

  open func generate(_ type: ProtocolCompositionType) -> String {
    return type.protocolTypes.map(generate).joined(separator: " & ")
  }

  open func generate(_ type: SelfType) -> String {
    return "Self"
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

  open func generate(_ type: TypeAnnotation) -> String {
    let attr = type.attributes.isEmpty ? "" : "\(generate(type.attributes)) "
    let inoutStr = type.isInOutParameter ? "inout " : ""
    return ": \(attr)\(inoutStr)\(generate(type.type))"
  }

  open func generate(_ type: TypeIdentifier) -> String {
    return type.names
    .map({ "\($0.name)\($0.genericArgumentClause.map(generate) ?? "")" })
    .joined(separator: ".")
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
}
