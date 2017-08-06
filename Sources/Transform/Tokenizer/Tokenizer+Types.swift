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

    open func tokenize(_ type: Type, node: ASTNode) -> [Token] {
        switch type {
        case let type as AnyType:
            return tokenize(type, node: node)
        case let type as ArrayType:
            return tokenize(type, node: node)
        case let type as DictionaryType:
            return tokenize(type, node: node)
        case let type as FunctionType:
            return tokenize(type, node: node)
        case let type as ImplicitlyUnwrappedOptionalType:
            return tokenize(type, node: node)
        case let type as MetatypeType:
            return tokenize(type, node: node)
        case let type as OptionalType:
            return tokenize(type, node: node)
        case let type as ProtocolCompositionType:
            return tokenize(type, node: node)
        case let type as SelfType:
            return tokenize(type, node: node)
        case let type as TupleType:
            return tokenize(type, node: node)
        case let type as TypeIdentifier:
            return tokenize(type, node: node)
        default:
            return [node.newToken(.identifier, type.textDescription)]
        }
    }

    open func tokenize(_ type: AnyType, node: ASTNode) -> [Token] {
        return [type.newToken(.keyword, "Any", node)]
    }

    open func tokenize(_ type: ArrayType, node: ASTNode) -> [Token] {
        return type.newToken(.startOfScope, "[", node) +
                tokenize(type.elementType, node: node) +
                type.newToken(.endOfScope, "]", node)
    }

    open func tokenize(_ type: DictionaryType, node: ASTNode) -> [Token] {
        return (
            tokenize(type.keyType, node: node) +
            type.newToken(.delimiter, ":", node) +
            type.newToken(.space, " ", node) +
            tokenize(type.valueType, node: node)
        ).prefix(with: type.newToken(.startOfScope, "[", node))
        .suffix(with: type.newToken(.endOfScope, "]", node))
    }

    open func tokenize(_ type: FunctionType, node: ASTNode) -> [Token] {
        let attrs = tokenize(type.attributes, node: node)
        let args = type.newToken(.startOfScope, "(", node) +
                    type.arguments.map { tokenize($0, node: node) }.joined(token: type.newToken(.delimiter, ", ", node)) +
                    type.newToken(.endOfScope, ")", node)

        let throwTokens = tokenize(type.throwsKind, node: node)
        let returnTokens = tokenize(type.returnType, node: node)

        return [
            attrs,
            args,
            throwTokens,
            [type.newToken(.symbol, "->", node)],
            returnTokens
        ].joined(token: type.newToken(.space, " ", node))
    }

    open func tokenize(_ type: FunctionType.Argument, node: ASTNode) -> [Token] {
        let tokens = [
            type.externalName.map { [type.newToken(.identifier, $0, node)]} ?? [],
            type.localName.map { [
                type.newToken(.identifier, $0, node),
                type.newToken(.delimiter, ":", node)
            ]} ?? [],
            tokenize(type.attributes, node: node),
            type.isInOutParameter ? [type.newToken(.keyword, "inout", node)] : [],
            tokenize(type.type, node: node),
        ]
        let variadicDots = type.isVariadic ? [type.newToken(.keyword, "...", node)] : []
        return tokens.joined(token: type.newToken(.space, " ", node)) +
            variadicDots
    }

    open func tokenize(_ type: ImplicitlyUnwrappedOptionalType, node: ASTNode) -> [Token] {
        return tokenize(type.wrappedType, node: node) +
                type.newToken(.symbol, "!", node)
    }

    open func tokenize(_ type: MetatypeType, node: ASTNode) -> [Token] {
        let kind: Token
        switch type.kind {
        case .type:
            kind =  type.newToken(.keyword, "Type", node)
        case .protocol:
            kind =  type.newToken(.keyword, "Protocol", node)
        }
        return [tokenize(type.referenceType, node: node),
                [type.newToken(.delimiter, ".", node)],
                [kind]
        ].joined()
    }

    open func tokenize(_ type: OptionalType, node: ASTNode) -> [Token] {
        return tokenize(type.wrappedType, node: node) +
                type.newToken(.symbol, "?", node)
    }

    open func tokenize(_ type: ProtocolCompositionType, node: ASTNode) -> [Token] {
        if node is ClassDeclaration || node is StructDeclaration || node is EnumDeclaration {
            return
                type.newToken(.keyword, "protocol", node) +
                type.newToken(.startOfScope, "<", node) +
                type.protocolTypes.map { tokenize($0, node: node) }.joined(token: type.newToken(.delimiter, ", ", node)) +
                type.newToken(.endOfScope, ">", node)
        } else {
            return type.protocolTypes.map { tokenize($0, node: node) }
                .joined(token: type.newToken(.delimiter, " & ", node))
        }
    }

    open func tokenize(_ type: SelfType, node: ASTNode) -> [Token] {
        return [type.newToken(.keyword, "Self", node)]
    }

    open func tokenize(_ type: TupleType, node: ASTNode) -> [Token] {
        return type.newToken(.startOfScope, "(", node) +
            type.elements.map { tokenize($0, node: node) }.joined(token: type.newToken(.delimiter, ", ", node)) +
            type.newToken(.endOfScope, ")", node)
    }

    open func tokenize(_ type: TupleType.Element, node: ASTNode) -> [Token] {
        let inoutTokens = type.isInOutParameter ? [type.newToken(.keyword, "inout", node)] : []
        var nameTokens = [Token]()
        if let name = type.name {
            nameTokens = type.newToken(.identifier, name, node) +
                        type.newToken(.delimiter, ":", node)
        }
        return [
            nameTokens,
            tokenize(type.attributes, node: node),
            inoutTokens,
            tokenize(type.type, node: node)
        ].joined(token: type.newToken(.space, " ", node))
    }

    open func tokenize(_ type: TypeAnnotation, node: ASTNode) -> [Token] {
        let inoutTokens = type.isInOutParameter ? [type.newToken(.keyword, "inout", node)] : []
        return [
            [type.newToken(.delimiter, ":", node)],
            tokenize(type.attributes, node: node),
            inoutTokens,
            tokenize(type.type, node: node)
        ].joined(token: type.newToken(.space, " ", node))
    }

    open func tokenize(_ type: TypeIdentifier, node: ASTNode) -> [Token] {
        return type.names.map { tokenize($0, node: node) }
                .joined(token: type.newToken(.delimiter, ".", node))
    }

    open func tokenize(_ type: TypeIdentifier.TypeName, node: ASTNode) -> [Token] {
        return type.newToken(.identifier, type.name, node) +
            type.genericArgumentClause.map { tokenize($0, node: node) }
    }

    open func tokenize(_ type: TypeInheritanceClause, node: ASTNode) -> [Token] {
        var inheritanceTokens = type.classRequirement ? [[type.newToken(.keyword, "class", node)]] : [[]]
        inheritanceTokens += type.typeInheritanceList.map { tokenize($0, node: node) }

        return type.newToken(.symbol, ": ", node) +
                inheritanceTokens.joined(token: type.newToken(.delimiter, ", ", node))
    }


    // TODO: Delete temporal generates
    open func generate(_ type: Type, node: ASTNode) -> String {
        return tokenize(type, node: node).joinedValues()
    }

    open func generate(_ type: TypeAnnotation, node: ASTNode) -> String {
        return tokenize(type, node: node).joinedValues()
    }

    open func generate(_ type: TypeInheritanceClause, node: ASTNode) -> String {
        return tokenize(type, node: node).joinedValues()
    }

}

extension TypeBase: ASTTokenizable {}
extension FunctionType.Argument: ASTTokenizable {}
extension TupleType.Element: ASTTokenizable {}
extension TypeAnnotation: ASTTokenizable {}
extension TypeIdentifier.TypeName: ASTTokenizable {}
extension TypeInheritanceClause: ASTTokenizable {}
