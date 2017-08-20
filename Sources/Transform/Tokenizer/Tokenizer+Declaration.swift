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
    open func tokenize(_ declaration: Declaration) -> [Token] { // swift-lint:suppress(high_cyclomatic_complexity)
        switch declaration {
        case let decl as ClassDeclaration:
            return tokenize(decl)
        case let decl as ConstantDeclaration:
            return tokenize(decl)
        case let decl as DeinitializerDeclaration:
            return tokenize(decl)
        case let decl as EnumDeclaration:
            return tokenize(decl)
        case let decl as ExtensionDeclaration:
            return tokenize(decl)
        case let decl as FunctionDeclaration:
            return tokenize(decl)
        case let decl as ImportDeclaration:
            return tokenize(decl)
        case let decl as InitializerDeclaration:
            return tokenize(decl)
        case let decl as OperatorDeclaration:
            return tokenize(decl)
        case let decl as PrecedenceGroupDeclaration:
            return tokenize(decl)
        case let decl as ProtocolDeclaration:
            return tokenize(decl)
        case let decl as StructDeclaration:
            return tokenize(decl)
        case let decl as SubscriptDeclaration:
            return tokenize(decl)
        case let decl as TypealiasDeclaration:
            return tokenize(decl)
        case let decl as VariableDeclaration:
            return tokenize(decl)
        default:
            return [Token(origin: declaration as? ASTTokenizable,
                          node: declaration as? ASTNode,
                          kind: .identifier,
                          value: declaration.textDescription)]
        }
    }

    open func tokenize(_ topLevelDeclaration: TopLevelDeclaration) -> [Token] {
        return topLevelDeclaration.statements.map(tokenize)
            .joined(token: topLevelDeclaration.newToken(.linebreak, "\n")) +
            topLevelDeclaration.newToken(.linebreak, "\n")
    }

    open func tokenize(_ codeBlock: CodeBlock) -> [Token] {
        if codeBlock.statements.isEmpty {
            return [codeBlock.newToken(.startOfScope, "{"), codeBlock.newToken(.endOfScope, "}")]
        }
        let lineBreakToken = codeBlock.newToken(.linebreak, "\n")
        return [
            [codeBlock.newToken(.startOfScope, "{")],
            indent(codeBlock.statements.map(tokenize).joined(token: lineBreakToken)),
            [codeBlock.newToken(.endOfScope, "}")]
        ].joined(token: lineBreakToken)
    }

    open func tokenize(_ block: GetterSetterBlock.GetterClause, node: ASTNode) -> [Token] {
        return [
            tokenize(block.attributes, node: node),
            block.mutationModifier.map { tokenize($0, node: node) } ?? [],
            [block.newToken(.keyword, "get", node)],
            tokenize(block.codeBlock)
        ].joined(token: block.newToken(.space, " ", node))
    }

    open func tokenize(_ block: GetterSetterBlock.SetterClause, node: ASTNode) -> [Token] {
        let mutationTokens = block.mutationModifier.map { tokenize($0, node: node) } ?? []
        let setTokens = block.newToken(.keyword, "set", node) +
            block.name.map { name in
                    block.newToken(.startOfScope, "(", node) +
                        block.newToken(.identifier, name, node) +
                        block.newToken(.endOfScope, ")", node)
            }

        return [
            tokenize(block.attributes, node: node),
            mutationTokens,
            setTokens,
            tokenize(block.codeBlock)
        ].joined(token: block.newToken(.space, " ", node))
    }

    open func tokenize(_ block: GetterSetterBlock, node: ASTNode) -> [Token] {
        let getterTokens = tokenize(block.getter, node: node)
        let setterTokens = block.setter.map { tokenize($0, node: node) } ?? []
        return [
            [block.newToken(.startOfScope, "{", node)],
            indent(getterTokens),
            indent(setterTokens),
            [block.newToken(.endOfScope, "}", node)]
        ].joined(token: block.newToken(.linebreak, "\n", node))
    }

    open func tokenize(_ block: GetterSetterKeywordBlock, node: ASTNode) -> [Token] {
        let getterTokens = tokenize(block.getter, node: node)
        let setterTokens = block.setter.map { tokenize($0, node: node) } ?? []
        return [
            [block.newToken(.startOfScope, "{", node)],
            indent(getterTokens),
            indent(setterTokens),
            [block.newToken(.endOfScope, "}", node)]
        ].joined(token: block.newToken(.linebreak, "\n", node))
    }

    open func tokenize(_ block: WillSetDidSetBlock.WillSetClause, node: ASTNode) -> [Token] {
        let nameTokens = block.name.map { name in
            return block.newToken(.startOfScope, "(", node) +
                block.newToken(.identifier, name, node) +
                block.newToken(.endOfScope, ")", node)
        } ?? []
        return [
            tokenize(block.attributes, node: node),
            block.newToken(.keyword, "willSet", node) + nameTokens,
            tokenize(block.codeBlock)
        ].joined(token: block.newToken(.space, " ", node))
    }

    open func tokenize(_ block: WillSetDidSetBlock.DidSetClause, node: ASTNode) -> [Token] {
        let nameTokens = block.name.map { name in
            return block.newToken(.startOfScope, "(", node) +
                block.newToken(.identifier, name, node) +
                block.newToken(.endOfScope, ")", node)
            } ?? []
        return [
            tokenize(block.attributes, node: node),
            block.newToken(.keyword, "didSet", node) + nameTokens,
            tokenize(block.codeBlock)
        ].joined(token: block.newToken(.space, " ", node))
    }

    open func tokenize(_ block: WillSetDidSetBlock, node: ASTNode) -> [Token] {
        let willSetClause = block.willSetClause.map { tokenize($0, node: node) } ?? []
        let didSetClause = block.didSetClause.map { tokenize($0, node: node) } ?? []
        return [
            [block.newToken(.startOfScope, "{", node)],
            indent(willSetClause),
            indent(didSetClause),
            [block.newToken(.endOfScope, "}", node)]
        ].joined(token: block.newToken(.linebreak, "\n", node))
    }

    open func tokenize(_ clause: GetterSetterKeywordBlock.GetterKeywordClause, node: ASTNode) -> [Token] {
        return [
            tokenize(clause.attributes, node: node),
            clause.mutationModifier.map { tokenize($0, node: node) } ?? [],
            [clause.newToken(.keyword, "get", node)],
        ].joined(token: clause.newToken(.space, " ", node))
    }

    open func tokenize(_ clause: GetterSetterKeywordBlock.SetterKeywordClause, node: ASTNode) -> [Token] {
        return [
            tokenize(clause.attributes, node: node),
            clause.mutationModifier.map { tokenize($0, node: node) } ?? [],
            [clause.newToken(.keyword, "set", node)],
        ].joined(token: clause.newToken(.space, " ", node))
    }

    open func tokenize(_ patternInitializer: PatternInitializer, node: ASTNode) -> [Token] {
        let pttrnTokens = tokenize(patternInitializer.pattern, node: node)
        guard let initExpr = patternInitializer.initializerExpression else {
            return pttrnTokens
        }
        return pttrnTokens +
            [patternInitializer.newToken(.symbol, " = ", node)] +
            tokenize(expression: initExpr)
    }

    open func tokenize(_ initializers: [PatternInitializer], node: ASTNode) -> [Token] {
        return initializers.map { tokenize($0, node: node) }.joined(token: node.newToken(.delimiter, ", "))
    }

    open func tokenize(_ member: ClassDeclaration.Member) -> [Token] {
        switch member {
        case .declaration(let decl):
            return tokenize(decl)
        case .compilerControl(let stmt):
            return tokenize(stmt)
        }
    }

    open func tokenize(_ declaration: ClassDeclaration) -> [Token] {
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let modifierTokens = declaration.accessLevelModifier.map { tokenize($0, node: declaration) } ?? []
        let finalTokens = declaration.isFinal ? [declaration.newToken(.keyword, "final")] : []
        let headTokens = [
            attrsTokens,
            modifierTokens,
            finalTokens,
            [declaration.newToken(.keyword, "class")],
            [declaration.newToken(.identifier, declaration.name)],
        ].joined(token: declaration.newToken(.space, " "))

        let genericParameterClauseTokens = declaration.genericParameterClause.map {
            tokenize($0, node: declaration)
        } ?? []
        let typeTokens = declaration.typeInheritanceClause.map { tokenize($0, node: declaration) } ?? []
        let whereTokens = declaration.genericWhereClause.map {
            declaration.newToken(.space, " ") + tokenize($0, node: declaration)
        } ?? []
        let neckTokens = genericParameterClauseTokens +
                typeTokens +
                whereTokens

        let membersTokens = indent(declaration.members.map(tokenize)
            .joined(token: declaration.newToken(.linebreak, "\n")))
            .prefix(with: declaration.newToken(.linebreak, "\n"))
            .suffix(with: declaration.newToken(.linebreak, "\n"))

        return headTokens +
            neckTokens +
            [declaration.newToken(.space, " "), declaration.newToken(.startOfScope, "{")] +
            membersTokens +
            [declaration.newToken(.endOfScope, "}")]
    }

    open func tokenize(_ constant: ConstantDeclaration) -> [Token] {
        return [
            tokenize(constant.attributes, node: constant),
            tokenize(constant.modifiers, node: constant),
            [constant.newToken(.keyword, "let")],
            tokenize(constant.initializerList, node: constant)
        ].joined(token: constant.newToken(.space, " "))
    }

    open func tokenize(_ declaration: DeinitializerDeclaration) -> [Token] {
        return [
            tokenize(declaration.attributes, node: declaration),
            [declaration.newToken(.keyword, "deinit")],
            tokenize(declaration.body)
        ].joined(token: declaration.newToken(.space, " "))
    }

    open func tokenize(_ member: EnumDeclaration.Member, node: ASTNode) -> [Token] {
        switch member {
        case .declaration(let decl):
            return tokenize(decl)
        case .union(let enumCase):
            return tokenize(enumCase, node: node)
        case .rawValue(let enumCase):
            return tokenize(enumCase, node: node)
        case .compilerControl(let stmt):
            return tokenize(stmt)
        }
    }

    open func tokenize(_ union: EnumDeclaration.UnionStyleEnumCase, node: ASTNode) -> [Token] {
        let casesTokens = union.cases.map { c in
            return c.newToken(.identifier, c.name, node) + c.tuple.map { tokenize($0, node: node) }
        }.joined(token: union.newToken(.delimiter, ", ", node))

        return [
            tokenize(union.attributes, node: node),
            union.isIndirect ? [union.newToken(.keyword, "indirect", node)] : [],
            [union.newToken(.keyword, "case", node)],
            casesTokens
        ].joined(token: union.newToken(.space, " ", node))
    }

    open func tokenize(_ raw: EnumDeclaration.RawValueStyleEnumCase, node: ASTNode) -> [Token] {
        let casesTokens = raw.cases.map { c -> [Token] in
            var assignmentTokens = [Token]()
            if let assignment = c.assignment {
                assignmentTokens += [c.newToken(.symbol, " = ", node)]
                switch assignment {
                case .integer(let i):
                    assignmentTokens += [c.newToken(.number, "\(i)", node)]
                case .floatingPoint(let d):
                    assignmentTokens += [c.newToken(.number, "\(d)", node)]
                case .string(let s):
                    assignmentTokens += [c.newToken(.string, "\"\(s)\"", node)]
                case .boolean(let b):
                    assignmentTokens += [c.newToken(.keyword, b ? "true" : "false", node)]
                }
            }
            return c.newToken(.identifier, c.name, node) + assignmentTokens
        }.joined(token: raw.newToken(.delimiter, ", ", node))

        return [
            tokenize(raw.attributes, node: node),
            [raw.newToken(.keyword, "case", node)],
            casesTokens
        ].joined(token: raw.newToken(.space, " ", node))
    }

    open func tokenize(_ declaration: EnumDeclaration) -> [Token] {
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let modifierTokens = declaration.accessLevelModifier.map { tokenize($0, node: declaration) } ?? []
        let indirectTokens = declaration.isIndirect ? [declaration.newToken(.keyword, "indirect")] : []
        let headTokens = [
            attrsTokens,
            modifierTokens,
            indirectTokens,
            [declaration.newToken(.keyword, "enum")],
            [declaration.newToken(.identifier, declaration.name)],
        ].joined(token: declaration.newToken(.space, " "))

        let genericParameterClauseTokens = declaration.genericParameterClause.map {
            tokenize($0, node: declaration)
        } ?? []
        let typeTokens = declaration.typeInheritanceClause.map { tokenize($0, node: declaration) } ?? []
        let whereTokens = declaration.genericWhereClause.map {
            declaration.newToken(.space, " ") + tokenize($0, node: declaration)
        } ?? []
        let neckTokens = genericParameterClauseTokens +
            typeTokens +
            whereTokens

        let membersTokens = indent(declaration.members.map { tokenize($0, node: declaration) }
            .joined(token: declaration.newToken(.linebreak, "\n")))
            .prefix(with: declaration.newToken(.linebreak, "\n"))
            .suffix(with: declaration.newToken(.linebreak, "\n"))

        return headTokens +
            neckTokens +
            [declaration.newToken(.space, " "), declaration.newToken(.startOfScope, "{")] +
            membersTokens +
            [declaration.newToken(.endOfScope, "}")]
    }

    open func tokenize(_ member: ExtensionDeclaration.Member) -> [Token] {
        switch member {
        case .declaration(let decl):
            return tokenize(decl)
        case .compilerControl(let stmt):
            return tokenize(stmt)
        }
    }

    open func tokenize(_ declaration: ExtensionDeclaration) -> [Token] {
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let modifierTokens = declaration.accessLevelModifier.map { tokenize($0, node: declaration) } ?? []
        let headTokens = [
            attrsTokens,
            modifierTokens,
            [declaration.newToken(.keyword, "extension")],
            tokenize(declaration.type, node: declaration)
        ].joined(token: declaration.newToken(.space, " "))

        let typeTokens = declaration.typeInheritanceClause.map { tokenize($0, node: declaration) } ?? []
        let whereTokens = declaration.genericWhereClause.map {
            declaration.newToken(.space, " ") + tokenize($0, node: declaration)
        } ?? []
        let neckTokens = typeTokens + whereTokens

        let membersTokens = indent(declaration.members.map(tokenize)
            .joined(token: declaration.newToken(.linebreak, "\n")))
            .prefix(with: declaration.newToken(.linebreak, "\n"))
            .suffix(with: declaration.newToken(.linebreak, "\n"))

        return headTokens +
            neckTokens +
            [declaration.newToken(.space, " "), declaration.newToken(.startOfScope, "{")] +
            membersTokens +
            [declaration.newToken(.endOfScope, "}")]
    }

    open func tokenize(_ declaration: FunctionDeclaration) -> [Token] {
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let modifierTokens = declaration.modifiers.map { tokenize($0, node: declaration) }
            .joined(token: declaration.newToken(.space, " "))
        let headTokens = [
            attrsTokens,
            modifierTokens,
            [declaration.newToken(.keyword, "func")],
        ].joined(token: declaration.newToken(.space, " "))

        let genericParameterClauseTokens = declaration.genericParameterClause.map {
            tokenize($0, node: declaration)
        } ?? []
        let signatureTokens = tokenize(declaration.signature, node: declaration)
        let whereTokens = declaration.genericWhereClause.map { tokenize($0, node: declaration) } ?? []
        let bodyTokens = declaration.body.map(tokenize) ?? []

        return [
            headTokens,
            [declaration.newToken(.identifier, declaration.name)] + genericParameterClauseTokens + signatureTokens,
            whereTokens,
            bodyTokens
        ].joined(token: declaration.newToken(.space, " "))
    }

    open func tokenize(_ parameter: FunctionSignature.Parameter, node: ASTNode) -> [Token] {
        let externalNameTokens = parameter.externalName.map { [parameter.newToken(.identifier, $0, node)] } ?? []
        let localNameTokens = parameter.localName.isEmpty ? [] : [
            parameter.newToken(.identifier, parameter.localName, node)
        ]
        let nameTokens = [externalNameTokens, localNameTokens].joined(token: parameter.newToken(.space, " ", node))
        let typeAnnoTokens = tokenize(parameter.typeAnnotation, node: node)
        let defaultTokens = parameter.defaultArgumentClause.map {
            return parameter.newToken(.symbol, " = ", node) + tokenize($0)
        }
        let varargsTokens = parameter.isVarargs ? [parameter.newToken(.symbol, "...", node)] : []

        return
            nameTokens +
            typeAnnoTokens +
            defaultTokens +
            varargsTokens
    }

    open func tokenize(_ signature: FunctionSignature, node: ASTNode) -> [Token] {
        let parameterTokens = signature.newToken(.startOfScope, "(", node) +
            signature.parameterList.map { tokenize($0, node: node) }
                .joined(token: signature.newToken(.delimiter, ", ", node)) +
        signature.newToken(.endOfScope, ")", node)
        let throwsKindTokens = tokenize(signature.throwsKind, node: node)
        let resultTokens = signature.result.map { tokenize($0, node: node) } ?? []
        return [parameterTokens, throwsKindTokens, resultTokens]
            .joined(token: signature.newToken(.space, " ", node))
    }

    open func tokenize(_ result: FunctionResult, node: ASTNode) -> [Token] {
        let typeTokens = tokenize(result.type, node: node)
        let attributeTokens = tokenize(result.attributes, node: node)

        return [
            [result.newToken(.symbol, "->", node)],
            attributeTokens,
            typeTokens
        ].joined(token: result.newToken(.space, " ", node))
    }

    open func tokenize(_ declaration: ImportDeclaration) -> [Token] {
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let kindTokens = declaration.kind.map { [declaration.newToken(.identifier, $0.rawValue)] } ?? []
        let pathTokens = declaration.path.isEmpty ? [] : [
            declaration.newToken(.identifier, declaration.path.joined(separator: "."))
        ]
        return [
            attrsTokens,
            [declaration.newToken(.keyword, "import")],
            kindTokens,
            pathTokens
        ].joined(token: declaration.newToken(.space, " "))
    }

    open func tokenize(_ declaration: InitializerDeclaration) -> [Token] {
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let modifierTokens = tokenize(declaration.modifiers, node: declaration)
        let headTokens = [
            attrsTokens,
            modifierTokens,
            [declaration.newToken(.keyword, "init")] + tokenize(declaration.kind, node: declaration)
        ].joined(token: declaration.newToken(.space, " "))

        let genericParamTokens = declaration.genericParameterClause.map { tokenize($0, node: declaration) } ?? []
        let parameterTokens = declaration.newToken(.startOfScope, "(") +
            declaration.parameterList.map { tokenize($0, node: declaration) }
                .joined(token: declaration.newToken(.delimiter, ", ")) +
            declaration.newToken(.endOfScope, ")")
        let throwsKindTokens = tokenize(declaration.throwsKind, node: declaration)
        let genericWhereTokens = declaration.genericWhereClause.map { tokenize($0, node: declaration) } ?? []
        let bodyTokens = tokenize(declaration.body)

        return [
            headTokens + genericParamTokens + parameterTokens,
            throwsKindTokens,
            genericWhereTokens,
            bodyTokens
        ].joined(token: declaration.newToken(.space, " "))
    }

    open func tokenize(_ declaration: InitializerDeclaration.InitKind, node: ASTNode) -> [Token] {
        switch declaration {
        case .nonfailable:
            return []
        case .optionalFailable:
            return [declaration.newToken(.symbol, "?", node)]
        case .implicitlyUnwrappedFailable:
            return [declaration.newToken(.symbol, "!", node)]
        }
    }

    open func tokenize(_ declaration: OperatorDeclaration) -> [Token] {
        switch declaration.kind {
        case .prefix(let op):
            return [
                [declaration.newToken(.keyword, "prefix")],
                [declaration.newToken(.keyword, "operator")],
                [declaration.newToken(.identifier, op)],
            ].joined(token: declaration.newToken(.space, " "))
        case .postfix(let op):
            return [
                [declaration.newToken(.keyword, "postfix")],
                [declaration.newToken(.keyword, "operator")],
                [declaration.newToken(.identifier, op)],
            ].joined(token: declaration.newToken(.space, " "))
        case .infix(let op, nil):
            return [
                [declaration.newToken(.keyword, "infix")],
                [declaration.newToken(.keyword, "operator")],
                [declaration.newToken(.identifier, op)],
            ].joined(token: declaration.newToken(.space, " "))
        case .infix(let op, let id?):
            return [
                [declaration.newToken(.keyword, "infix")],
                [declaration.newToken(.keyword, "operator")],
                [declaration.newToken(.identifier, op)],
                [declaration.newToken(.symbol, ":")],
                [declaration.newToken(.identifier, id)]
            ].joined(token: declaration.newToken(.space, " "))
        }
    }

    open func tokenize(_ declaration: PrecedenceGroupDeclaration) -> [Token] {
        let attrsTokens = declaration.attributes.map { tokenize($0, node: declaration) }
            .joined(token: declaration.newToken(.linebreak, "\n"))

        let attrsBlockTokens: [Token]
        if declaration.attributes.isEmpty {
            attrsBlockTokens = [declaration.newToken(.startOfScope, "{"), declaration.newToken(.endOfScope, "}")]
        } else {
            attrsBlockTokens = [
                [declaration.newToken(.startOfScope, "{")],
                indent(attrsTokens),
                [declaration.newToken(.endOfScope, "}")]
            ].joined(token: declaration.newToken(.linebreak, "\n"))
        }
        return [
            [declaration.newToken(.keyword, "precedencegroup")],
            [declaration.newToken(.identifier, declaration.name)],
            attrsBlockTokens
        ].joined(token: declaration.newToken(.space, " "))
    }

    open func tokenize(_ attribute: PrecedenceGroupDeclaration.Attribute, node: ASTNode) -> [Token] {
        switch attribute {
        case .higherThan(let ids):
            return [
                attribute.newToken(.keyword, "higherThan", node),
                attribute.newToken(.symbol, ":", node),
                attribute.newToken(.space, " ", node),
                attribute.newToken(.identifier, ids.textDescription, node)
            ]
        case .lowerThan(let ids):
            return [
                attribute.newToken(.keyword, "lowerThan", node),
                attribute.newToken(.symbol, ":", node),
                attribute.newToken(.space, " ", node),
                attribute.newToken(.identifier, ids.textDescription, node)
            ]
        case .assignment(let b):
            return [
                attribute.newToken(.keyword, "assignment", node),
                attribute.newToken(.symbol, ":", node),
                attribute.newToken(.space, " ", node),
                attribute.newToken(.keyword, b ? "true" : "false", node)
            ]
        case .associativityLeft:
            return [
                attribute.newToken(.keyword, "associativity", node),
                attribute.newToken(.symbol, ":", node),
                attribute.newToken(.space, " ", node),
                attribute.newToken(.keyword, "left", node)
            ]
        case .associativityRight:
            return [
                attribute.newToken(.keyword, "associativity", node),
                attribute.newToken(.symbol, ":", node),
                attribute.newToken(.space, " ", node),
                attribute.newToken(.keyword, "right", node)
            ]
        case .associativityNone:
            return [
                attribute.newToken(.keyword, "associativity", node),
                attribute.newToken(.symbol, ":", node),
                attribute.newToken(.space, " ", node),
                attribute.newToken(.keyword, "none", node)
            ]
        }
    }

    open func tokenize(_ declaration: ProtocolDeclaration) -> [Token] {
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let modifierTokens = declaration.accessLevelModifier.map { tokenize($0, node: declaration) } ?? []
        let headTokens = [
            attrsTokens,
            modifierTokens,
            [declaration.newToken(.keyword, "protocol")],
            [declaration.newToken(.identifier, declaration.name)],
        ].joined(token: declaration.newToken(.space, " "))

        let typeTokens = declaration.typeInheritanceClause.map { tokenize($0, node: declaration) } ?? []
        let membersTokens = indent(declaration.members.map { tokenize($0, node: declaration) }
            .joined(token: declaration.newToken(.linebreak, "\n")))
            .prefix(with: declaration.newToken(.linebreak, "\n"))
            .suffix(with: declaration.newToken(.linebreak, "\n"))

        return headTokens +
            typeTokens +
            [declaration.newToken(.space, " "), declaration.newToken(.startOfScope, "{")] +
            membersTokens +
            [declaration.newToken(.endOfScope, "}")]
    }

    open func tokenize(_ member: ProtocolDeclaration.Member, node: ASTNode) -> [Token] {
        switch member {
        case .property(let member):
            return tokenize(member, node: node)
        case .method(let member):
            return tokenize(member, node: node)
        case .initializer(let member):
            return tokenize(member, node: node)
        case .subscript(let member):
            return tokenize(member, node: node)
        case .associatedType(let member):
            return tokenize(member, node: node)
        case .compilerControl(let stmt):
            return tokenize(stmt)
        }
    }

    open func tokenize(_ member: ProtocolDeclaration.PropertyMember, node: ASTNode) -> [Token] {
        let attrsTokens = tokenize(member.attributes, node: node)
        let modifiersTokens = tokenize(member.modifiers, node: node)
        let blockTokens = tokenize(member.getterSetterKeywordBlock, node: node)

        return [
            attrsTokens,
            modifiersTokens,
            [member.newToken(.keyword, "var", node)],
            member.newToken(.identifier, member.name, node) + tokenize(member.typeAnnotation, node: node),
            blockTokens
        ].joined(token: member.newToken(.space, " ", node))
    }

    open func tokenize(_ member: ProtocolDeclaration.MethodMember, node: ASTNode) -> [Token] {
        let attrsTokens = tokenize(member.attributes, node: node)
        let modifierTokens = member.modifiers.map { tokenize($0, node: node) }
            .joined(token: member.newToken(.space, " ", node))
        let headTokens = [
            attrsTokens,
            modifierTokens,
            [member.newToken(.keyword, "func", node)],
        ].joined(token: member.newToken(.space, " ", node))

        let genericParameterClauseTokens = member.genericParameter.map { tokenize($0, node: node) } ?? []
        let signatureTokens = tokenize(member.signature, node: node)
        let genericWhereClauseTokens = member.genericWhere.map { (tokenize($0, node: node)) } ?? []
        return [
            headTokens,
            [member.newToken(.identifier, member.name, node)] + genericParameterClauseTokens + signatureTokens,
            genericWhereClauseTokens
        ].joined(token: member.newToken(.space, " ", node))
    }

    open func tokenize(_ member: ProtocolDeclaration.InitializerMember, node: ASTNode) -> [Token] {
        let attrsTokens = tokenize(member.attributes, node: node)
        let modifierTokens = tokenize(member.modifiers, node: node)
        let headTokens = [
            attrsTokens,
            modifierTokens,
            member.newToken(.keyword, "init", node) + tokenize(member.kind, node: node),
        ].joined(token: member.newToken(.space, " ", node))

        let genericParameterClauseTokens = member.genericParameter.map { tokenize($0, node: node) } ?? []
        let parameterTokens = member.newToken(.startOfScope, "(", node) +
            member.parameterList.map { tokenize($0, node: node) }
                .joined(token: member.newToken(.delimiter, ", ", node)) +
            member.newToken(.endOfScope, ")", node)

        let throwsKindTokens = tokenize(member.throwsKind, node: node)
        let genericWhereClauseTokens = member.genericWhere.map { tokenize($0, node: node) } ?? []

        return [
            headTokens + genericParameterClauseTokens + parameterTokens,
            throwsKindTokens,
            genericWhereClauseTokens
        ].joined(token: member.newToken(.space, " ", node))
    }

    open func tokenize(_ member: ProtocolDeclaration.SubscriptMember, node: ASTNode) -> [Token] {
        let attrsTokens = tokenize(member.attributes, node: node)
        let modifierTokens = tokenize(member.modifiers, node: node)
        let genericParameterClauseTokens = member.genericParameter.map { tokenize($0, node: node) } ?? []
        let parameterTokens = member.newToken(.startOfScope, "(", node) +
            member.parameterList.map { tokenize($0, node: node) }
                .joined(token: member.newToken(.delimiter, ", ", node)) +
            member.newToken(.endOfScope, ")", node)
        let headTokens = [
            attrsTokens,
            modifierTokens,
            [member.newToken(.keyword, "subscript", node)] + genericParameterClauseTokens + parameterTokens
        ].joined(token: member.newToken(.space, " ", node))

        let resultAttrsTokens = tokenize(member.resultAttributes, node: node)
        let resultTokens = [
            [member.newToken(.symbol, "->", node)],
            resultAttrsTokens,
            tokenize(member.resultType, node: node)
        ].joined(token: member.newToken(.space, " ", node))
        let genericWhereClauseTokens = member.genericWhere.map { tokenize($0, node: node) } ?? []

        return [
            headTokens,
            resultTokens,
            genericWhereClauseTokens,
            tokenize(member.getterSetterKeywordBlock, node: node)
        ].joined(token: member.newToken(.space, " ", node))
    }

    open func tokenize(_ member: ProtocolDeclaration.AssociativityTypeMember, node: ASTNode) -> [Token] {
        let attrsTokens = tokenize(member.attributes, node: node)
        let modifierTokens = member.accessLevelModifier.map { tokenize($0, node: node) } ?? []
        let typeTokens = member.typeInheritance.map { tokenize($0, node: node) } ?? []
        let assignmentTokens: [Token] = member.assignmentType.map {
            member.newToken(.symbol, "=", node) + member.newToken(.space, " ", node) + tokenize($0, node: node)
        } ?? []
        let genericWhereTokens = member.genericWhere.map { tokenize($0, node: node) } ?? []

        return [
            attrsTokens,
            modifierTokens,
            [member.newToken(.keyword, "associatedtype", node)],
            [member.newToken(.identifier, member.name, node)] + typeTokens,
            assignmentTokens,
            genericWhereTokens
        ].joined(token: member.newToken(.space, " ", node))
    }

    open func tokenize(_ declaration: StructDeclaration) -> [Token] {
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let modifierTokens = declaration.accessLevelModifier.map { tokenize($0, node: declaration) } ?? []
        let headTokens = [
            attrsTokens,
            modifierTokens,
            [declaration.newToken(.keyword, "struct")],
            [declaration.newToken(.identifier, declaration.name)],
        ].joined(token: declaration.newToken(.space, " "))

        let genericParameterClauseTokens = declaration.genericParameterClause.map {
            tokenize($0, node: declaration)
        } ?? []
        let typeTokens = declaration.typeInheritanceClause.map { tokenize($0, node: declaration) } ?? []
        let whereTokens = declaration.genericWhereClause.map {
            declaration.newToken(.space, " ") + tokenize($0, node: declaration)
        } ?? []
        let neckTokens = genericParameterClauseTokens +
            typeTokens +
            whereTokens

        let membersTokens = indent(declaration.members.map(tokenize)
            .joined(token: declaration.newToken(.linebreak, "\n")))
            .prefix(with: declaration.newToken(.linebreak, "\n"))
            .suffix(with: declaration.newToken(.linebreak, "\n"))

        return headTokens +
            neckTokens +
            [declaration.newToken(.space, " "), declaration.newToken(.startOfScope, "{")] +
            membersTokens +
            [declaration.newToken(.endOfScope, "}")]
    }

    open func tokenize(_ member: StructDeclaration.Member) -> [Token] {
        switch member {
        case .declaration(let decl):
            return tokenize(decl)
        case .compilerControl(let stmt):
            return tokenize(stmt)
        }
    }

    open func tokenize(_ declaration: SubscriptDeclaration) -> [Token] {
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let modifierTokens = tokenize(declaration.modifiers, node: declaration)
        let genericParameterClauseTokens = declaration.genericParameterClause.map {
            tokenize($0, node: declaration)
        } ?? []
        let parameterTokens = declaration.newToken(.startOfScope, "(") +
            declaration.parameterList.map { tokenize($0, node: declaration) }
                .joined(token: declaration.newToken(.delimiter, ", ")) +
            declaration.newToken(.endOfScope, ")")

        let headTokens = [
            attrsTokens,
            modifierTokens,
            [declaration.newToken(.keyword, "subscript")] + genericParameterClauseTokens + parameterTokens
        ].joined(token: declaration.newToken(.space, " "))

        let resultAttrsTokens = tokenize(declaration.resultAttributes, node: declaration)
        let resultTokens = [
            [declaration.newToken(.symbol, "->")],
            resultAttrsTokens,
            tokenize(declaration.resultType, node: declaration)
        ].joined(token: declaration.newToken(.space, " "))

        let genericWhereClauseTokens = declaration.genericWhereClause.map { tokenize($0, node: declaration) } ?? []

        return [
            headTokens,
            resultTokens,
            genericWhereClauseTokens,
            tokenize(declaration.body, node: declaration)
        ].joined(token: declaration.newToken(.space, " "))
    }

    open func tokenize(_ body: SubscriptDeclaration.Body, node: ASTNode) -> [Token] {
        switch body {
        case .codeBlock(let block):
            return tokenize(block)
        case .getterSetterBlock(let block):
            return tokenize(block, node: node)
        case .getterSetterKeywordBlock(let block):
            return tokenize(block, node: node)
        }
    }

    open func tokenize(_ declaration: TypealiasDeclaration) -> [Token] {
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let modifierTokens = declaration.accessLevelModifier.map { tokenize($0, node: declaration) } ?? []
        let genericTokens = declaration.generic.map { tokenize($0, node: declaration) } ?? []
        let assignmentTokens = tokenize(declaration.assignment, node: declaration)

        return [
            attrsTokens,
            modifierTokens,
            [declaration.newToken(.keyword, "typealias")],
            [declaration.newToken(.identifier, declaration.name)] + genericTokens,
            [declaration.newToken(.symbol, "=")],
            assignmentTokens
        ].joined(token: declaration.newToken(.space, " "))
    }

    open func tokenize(_ declaration: VariableDeclaration) -> [Token] {
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let modifierTokens = tokenize(declaration.modifiers, node: declaration)

        return [
            attrsTokens,
            modifierTokens,
            [declaration.newToken(.keyword, "var")],
            tokenize(declaration.body, node: declaration)
        ].joined(token: declaration.newToken(.space, " "))
    }

    open func tokenize(_ body: VariableDeclaration.Body, node: ASTNode) -> [Token] {
        switch body {
        case .initializerList(let inits):
            return inits.map { tokenize($0, node: node) }.joined(token: body.newToken(.delimiter, ", ", node))
        case let .codeBlock(name, typeAnnotation, codeBlock):
            return body.newToken(.identifier, name, node) +
                tokenize(typeAnnotation, node: node) +
                body.newToken(.space, " ", node) +
                tokenize(codeBlock)
        case let .getterSetterBlock(name, typeAnnotation, block):
            return body.newToken(.identifier, name, node) +
                tokenize(typeAnnotation, node: node) +
                body.newToken(.space, " ", node) +
                tokenize(block, node: node)
        case let .getterSetterKeywordBlock(name, typeAnnotation, block):
            return body.newToken(.identifier, name, node) +
                tokenize(typeAnnotation, node: node) +
                body.newToken(.space, " ", node) +
                tokenize(block, node: node)
        case let .willSetDidSetBlock(name, typeAnnotation, initExpr, block):
            let typeAnnoTokens = typeAnnotation.map { tokenize($0, node: node) } ?? []
            let initTokens = initExpr.map { body.newToken(.symbol, " = ", node) + tokenize($0) } ?? []
            return [body.newToken(.identifier, name, node)] +
                typeAnnoTokens +
                initTokens +
                body.newToken(.space, " ", node) +
                tokenize(block, node: node)
        }
    }

    open func tokenize(_ modifiers: [DeclarationModifier], node: ASTNode) -> [Token] {
        return modifiers.map { tokenize($0, node: node) }
            .joined(token: node.newToken(.space, " "))
    }

    open func tokenize(_ modifier: DeclarationModifier, node: ASTNode) -> [Token] { /*
      swift-lint:suppress(high_cyclomatic_complexity) */
        switch modifier {
        case .class:
            return [modifier.newToken(.keyword, "class", node)]
        case .convenience:
            return [modifier.newToken(.keyword, "convenience", node)]
        case .dynamic:
            return [modifier.newToken(.keyword, "dynamic", node)]
        case .final:
            return [modifier.newToken(.keyword, "final", node)]
        case .infix:
            return [modifier.newToken(.keyword, "infix", node)]
        case .lazy:
            return [modifier.newToken(.keyword, "lazy", node)]
        case .optional:
            return [modifier.newToken(.keyword, "optional", node)]
        case .override:
            return [modifier.newToken(.keyword, "override", node)]
        case .postfix:
            return [modifier.newToken(.keyword, "postfix", node)]
        case .prefix:
            return [modifier.newToken(.keyword, "prefix", node)]
        case .required:
            return [modifier.newToken(.keyword, "required", node)]
        case .static:
            return [modifier.newToken(.keyword, "static", node)]
        case .unowned:
            return [modifier.newToken(.keyword, "unowned", node)]
        case .unownedSafe:
            return [modifier.newToken(.keyword, "unowned(safe)", node)]
        case .unownedUnsafe:
            return [modifier.newToken(.keyword, "unowned(unsafe)", node)]
        case .weak:
            return [modifier.newToken(.keyword, "weak", node)]
        case .accessLevel(let modifier):
            return tokenize(modifier, node: node)
        case .mutation(let modifier):
            return tokenize(modifier, node: node)
        }
    }

    open func tokenize(_ modifier: AccessLevelModifier, node: ASTNode) -> [Token] {
        return [modifier.newToken(.keyword, modifier.rawValue, node)]
    }

    open func tokenize(_ modifier: MutationModifier, node: ASTNode) -> [Token] {
        return [modifier.newToken(.keyword, modifier.rawValue, node)]
    }
}



extension ProtocolDeclaration.InitializerMember: ASTTokenizable {}
extension GetterSetterBlock.GetterClause: ASTTokenizable {}
extension GetterSetterBlock.SetterClause: ASTTokenizable {}
extension GetterSetterBlock: ASTTokenizable {}
extension GetterSetterKeywordBlock: ASTTokenizable {}
extension GetterSetterKeywordBlock.SetterKeywordClause: ASTTokenizable {}
extension GetterSetterKeywordBlock.GetterKeywordClause: ASTTokenizable {}
extension WillSetDidSetBlock.WillSetClause: ASTTokenizable {}
extension WillSetDidSetBlock.DidSetClause: ASTTokenizable {}
extension WillSetDidSetBlock: ASTTokenizable {}
extension PatternInitializer: ASTTokenizable {}
extension EnumDeclaration.UnionStyleEnumCase: ASTTokenizable {}
extension EnumDeclaration.UnionStyleEnumCase.Case: ASTTokenizable {}
extension EnumDeclaration.RawValueStyleEnumCase: ASTTokenizable {}
extension EnumDeclaration.RawValueStyleEnumCase.Case: ASTTokenizable {}
extension FunctionSignature.Parameter: ASTTokenizable {}
extension FunctionResult: ASTTokenizable {}
extension InitializerDeclaration.InitKind: ASTTokenizable {}
extension PrecedenceGroupDeclaration.Attribute: ASTTokenizable {}
extension DeclarationModifier: ASTTokenizable {}
extension AccessLevelModifier: ASTTokenizable {}
extension MutationModifier: ASTTokenizable {}
extension FunctionSignature: ASTTokenizable {}
extension ProtocolDeclaration.MethodMember: ASTTokenizable {}
extension ProtocolDeclaration.PropertyMember: ASTTokenizable {}
extension ProtocolDeclaration.SubscriptMember: ASTTokenizable {}
extension ProtocolDeclaration.AssociativityTypeMember: ASTTokenizable {}
extension VariableDeclaration.Body: ASTTokenizable {}
