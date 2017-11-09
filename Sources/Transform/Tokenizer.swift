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

// NOTE: This class contains all the tokenizations of node elements in one unique file insetad of
// separating them into extensions to allow subclasses (implemented by other libraries using this
// one) to subclass and override its behavior.
// In Swift4, methods declared in extensions can not be overriden yet. Move this back into
// extensions when the compiler allows it in future versions

open class Tokenizer {
    public let options: [String: Any]?
    open var indentation: String {
        return "  "
    }

    public init(options: [String: Any]? = nil) {
        self.options = options
    }
    
    // MARK: - Utils

    open func indent(_ tokens: [Token]) -> [Token] {
        guard let node = tokens.first?.node else { return tokens }
        return tokens.reduce([node.newToken(.indentation, indentation)]) { (result, token) -> [Token] in
            return result + token + (token.kind == .linebreak ? token.node?.newToken(.indentation, indentation) : nil)
        }
    }
    
    // MARK: - Attributes
    
    open func tokenize(_ attributes: Attributes, node: ASTNode) -> [Token] {
        return attributes.map { tokenize($0, node: node) }.joined(token: node.newToken(.space, " ", node))
    }
    
    open func tokenize(_ attribute: Attribute, node: ASTNode) -> [Token] {
        return
            attribute.newToken(.symbol, "@", node) +
                attribute.newToken(.identifier, attribute.name, node) +
                attribute.argumentClause.map { tokenize($0, node: node) }
    }
    
    open func tokenize(_ argument: Attribute.ArgumentClause, node: ASTNode) -> [Token] {
        return
            argument.newToken(.startOfScope, "(", node) +
                tokenize(argument.balancedTokens, node: node) +
                argument.newToken(.endOfScope, ")", node)
    }
    
    open func tokenize(_ tokens: [Attribute.ArgumentClause.BalancedToken], node: ASTNode) -> [Token] {
        return tokens.map { tokenize($0, node: node) }.joined()
    }
    
    open func tokenize(_ token: Attribute.ArgumentClause.BalancedToken, node: ASTNode) -> [Token] {
        switch token {
        case .token(let tokenString):
            return [token.newToken(.identifier, tokenString, node)]
        case .parenthesis(let tokens):
            return token.newToken(.startOfScope, "(", node) +
                tokenize(tokens, node: node) + token.newToken(.endOfScope, ")", node)
        case .square(let tokens):
            return token.newToken(.startOfScope, "[", node) +
                tokenize(tokens, node: node) + token.newToken(.endOfScope, "]", node)
        case .brace(let tokens):
            return token.newToken(.startOfScope, "{", node) +
                tokenize(tokens, node: node) + token.newToken(.endOfScope, "}", node)
        }
    }
    
    // MARK: - Declarations
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
        let neckTokens = genericParameterClauseTokens + typeTokens + whereTokens

        let membersTokens = indent(declaration.members.map(tokenize)
            .joined(token: declaration.newToken(.linebreak, "\n")))
            .prefix(with: declaration.newToken(.linebreak, "\n"))
            .suffix(with: declaration.newToken(.linebreak, "\n"))

        let declTokens = headTokens +
            neckTokens +
            [declaration.newToken(.space, " "), declaration.newToken(.startOfScope, "{")] +
            membersTokens +
            [declaration.newToken(.endOfScope, "}")]

        return declTokens.prefix(with: declaration.newToken(.linebreak, "\n"))
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
        .prefix(with: declaration.newToken(.linebreak, "\n"))
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

        let declTokens = headTokens +
            neckTokens +
            [declaration.newToken(.space, " "), declaration.newToken(.startOfScope, "{")] +
            membersTokens +
            [declaration.newToken(.endOfScope, "}")]

        return declTokens.prefix(with: declaration.newToken(.linebreak, "\n"))
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

        let declTokens = headTokens +
            neckTokens +
            [declaration.newToken(.space, " "), declaration.newToken(.startOfScope, "{")] +
            membersTokens +
            [declaration.newToken(.endOfScope, "}")]

        return declTokens.prefix(with: declaration.newToken(.linebreak, "\n"))
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
        .prefix(with: declaration.newToken(.linebreak, "\n"))
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
        .prefix(with: declaration.newToken(.linebreak, "\n"))
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

        let declTokens = headTokens +
            typeTokens +
            [declaration.newToken(.space, " "), declaration.newToken(.startOfScope, "{")] +
            membersTokens +
            [declaration.newToken(.endOfScope, "}")]

        return declTokens.prefix(with: declaration.newToken(.linebreak, "\n"))
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

        let declTokens = headTokens +
            neckTokens +
            [declaration.newToken(.space, " "), declaration.newToken(.startOfScope, "{")] +
            membersTokens +
            [declaration.newToken(.endOfScope, "}")]

        return declTokens.prefix(with: declaration.newToken(.linebreak, "\n"))
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
                [body.newToken(.space, " ", node)] +
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
    
    // MARK: - Expressions

    open func tokenize(expression: Expression) -> [Token] {
        return tokenize(expression)
    }
    
    open func tokenize(_ expression: Expression) -> [Token] { /*
         swift-lint:suppress(high_cyclomatic_complexity, high_ncss) */
        switch expression {
        case let expr as AssignmentOperatorExpression:
            return tokenize(expr)
        case let expr as BinaryOperatorExpression:
            return tokenize(expr)
        case let expr as ClosureExpression:
            return tokenize(expr)
        case let expr as ExplicitMemberExpression:
            return tokenize(expr)
        case let expr as ForcedValueExpression:
            return tokenize(expr)
        case let expr as FunctionCallExpression:
            return tokenize(expr)
        case let expr as IdentifierExpression:
            return tokenize(expr)
        case let expr as ImplicitMemberExpression:
            return tokenize(expr)
        case let expr as InOutExpression:
            return tokenize(expr)
        case let expr as InitializerExpression:
            return tokenize(expr)
        case let expr as KeyPathStringExpression:
            return tokenize(expr)
        case let expr as LiteralExpression:
            return tokenize(expr)
        case let expr as OptionalChainingExpression:
            return tokenize(expr)
        case let expr as ParenthesizedExpression:
            return tokenize(expr)
        case let expr as PostfixOperatorExpression:
            return tokenize(expr)
        case let expr as PostfixSelfExpression:
            return tokenize(expr)
        case let expr as PrefixOperatorExpression:
            return tokenize(expr)
        case let expr as SelectorExpression:
            return tokenize(expr)
        case let expr as SelfExpression:
            return tokenize(expr)
        case let expr as SequenceExpression:
            return tokenize(expr)
        case let expr as SubscriptExpression:
            return tokenize(expr)
        case let expr as SuperclassExpression:
            return tokenize(expr)
        case let expr as TernaryConditionalOperatorExpression:
            return tokenize(expr)
        case let expr as TryOperatorExpression:
            return tokenize(expr)
        case let expr as TupleExpression:
            return tokenize(expr)
        case let expr as TypeCastingOperatorExpression:
            return tokenize(expr)
        case let expr as WildcardExpression:
            return tokenize(expr)
        default:
            return [Token(origin: expression as? ASTTokenizable,
                          node: expression as? ASTNode,
                          kind: .identifier,
                          value: expression.textDescription)]
        }
    }
    
    open func tokenize(_ expression: AssignmentOperatorExpression) -> [Token] {
        return tokenize(expression.leftExpression) +
            expression.newToken(.symbol, " = ") +
            tokenize(expression.rightExpression)
    }
    
    open func tokenize(_ expression: BinaryOperatorExpression) -> [Token] {
        return [
            tokenize(expression.leftExpression),
            [expression.newToken(.symbol, expression.binaryOperator)],
            tokenize(expression.rightExpression),
            ].joined(token: expression.newToken(.space, " "))
    }
    
    open func tokenize(_ expression: ClosureExpression) -> [Token] {
        let spaceToken = expression.newToken(.space, " ")
        var signatureTokens = [Token]()
        var stmtsTokens = [Token]()
        
        if let signature = expression.signature {
            signatureTokens = spaceToken +
                tokenize(signature, node: expression) +
                spaceToken +
                expression.newToken(.keyword, "in")
            if expression.statements == nil {
                stmtsTokens = [spaceToken]
            }
        }
        
        if let stmts = expression.statements {
            if expression.signature == nil && stmts.count == 1 {
                stmtsTokens = spaceToken + tokenize(stmts, node: expression) + spaceToken
            } else {
                stmtsTokens += [expression.newToken(.linebreak, "\n")]
                stmtsTokens += indent(tokenize(stmts, node: expression))
                stmtsTokens += [expression.newToken(.linebreak, "\n")]
            }
        }
        
        return [expression.newToken(.startOfScope, "{")] +
            signatureTokens +
            stmtsTokens +
            [expression.newToken(.endOfScope, "}")]
    }
    
    open func tokenize(_ expression: ClosureExpression.Signature.CaptureItem, node: ASTNode) -> [Token] {
        return [
            expression.specifier.map { tokenize($0, node: node) } ?? [],
            tokenize(expression.expression),
            ].joined(token: expression.newToken(.space, " ", node))
    }
    
    open func tokenize(_ expression: ClosureExpression.Signature.CaptureItem.Specifier, node: ASTNode) -> [Token] {
        return [expression.newToken(.identifier, expression.rawValue, node)]
    }
    
    open func tokenize(_ expression: ClosureExpression.Signature.ParameterClause, node: ASTNode) -> [Token] {
        switch expression {
        case .parameterList(let params):
            return expression.newToken(.startOfScope, "(", node) +
                params.map { tokenize($0, node: node) }.joined(token: expression.newToken(.delimiter, ", ", node)) +
                expression.newToken(.endOfScope, ")", node)
        case .identifierList(let idList):
            return [expression.newToken(.identifier, idList.textDescription, node)]
        }
    }
    
    open func tokenize(_ expression: ClosureExpression.Signature.ParameterClause.Parameter, node: ASTNode) -> [Token] {
        return expression.newToken(.identifier, expression.name, node) +
            expression.typeAnnotation.map { typeAnnotation in
                return tokenize(typeAnnotation, node: node) +
                    (expression.isVarargs ? typeAnnotation.newToken(.symbol, "...", node) : nil)
        }
    }
    
    open func tokenize(_ expression: ClosureExpression.Signature, node: ASTNode) -> [Token] {
        let captureTokens = expression.captureList.map { captureList in
            return expression.newToken(.startOfScope, "[", node) +
                captureList.map { tokenize($0, node: node) }
                    .joined(token: expression.newToken(.delimiter, ", ", node)) +
                expression.newToken(.endOfScope, "]", node)
            } ?? []
        let parameterTokens = expression.parameterClause.map { tokenize($0, node: node) } ?? []
        let throwTokens = expression.canThrow ? [expression.newToken(.keyword, "throws", node)] : []
        let resultTokens = expression.functionResult.map { tokenize($0, node: node) } ?? []
        return [
            captureTokens,
            parameterTokens,
            throwTokens,
            resultTokens,
            ].joined(token: expression.newToken(.space, " ", node))
    }
    
    open func tokenize(_ expression: ExplicitMemberExpression) -> [Token] {
        switch expression.kind {
        case let .tuple(postfixExpr, index):
            return tokenize(postfixExpr) + expression.newToken(.delimiter, ".") +
                expression.newToken(.number, "\(index)")
        case let .namedType(postfixExpr, identifier):
            return tokenize(postfixExpr) + expression.newToken(.delimiter, ".") +
                expression.newToken(.identifier, identifier)
        case let .generic(postfixExpr, identifier, genericArgumentClause):
            return tokenize(postfixExpr) + expression.newToken(.delimiter, ".") +
                expression.newToken(.identifier, identifier) +
                tokenize(genericArgumentClause, node: expression)
        case let .argument(postfixExpr, identifier, argumentNames):
            let argumentTokens = argumentNames.isEmpty ? nil : argumentNames.flatMap {
                expression.newToken(.identifier, $0) + expression.newToken(.delimiter, ":")
                }.prefix(with: expression.newToken(.startOfScope, "("))
                .suffix(with: expression.newToken(.endOfScope, ")"))
            return tokenize(postfixExpr) + expression.newToken(.delimiter, ".") +
                expression.newToken(.identifier, identifier) +
            argumentTokens
        }
    }
    
    open func tokenize(_ expression: ForcedValueExpression) -> [Token] {
        return tokenize(expression.postfixExpression) + expression.newToken(.symbol, "!")
    }
    
    open func tokenize(_ expression: FunctionCallExpression) -> [Token] {
        var parameterTokens = [Token]()
        if let argumentClause = expression.argumentClause {
            let argumentsTokens = argumentClause.map{ tokenize($0, node: expression) }
                .joined(token: expression.newToken(.delimiter, ", "))
            parameterTokens = expression.newToken(.startOfScope, "(") +
                argumentsTokens +
                expression.newToken(.endOfScope, ")")
        }
        var trailingTokens = [Token]()
        if let trailingClosure = expression.trailingClosure {
            trailingTokens = trailingClosure.newToken(.space, " ", expression) +
                tokenize(trailingClosure)
        }
        return tokenize(expression.postfixExpression) + parameterTokens + trailingTokens
    }
    
    open func tokenize(_ expression: FunctionCallExpression.Argument, node: ASTNode) -> [Token] {
        switch expression {
        case .expression(let expr):
            return tokenize(expr)
        case let .namedExpression(identifier, expr):
            return expression.newToken(.identifier, identifier, node) +
                expression.newToken(.delimiter, ": ", node) +
                tokenize(expr)
        case .memoryReference(let expr):
            return expression.newToken(.symbol, "&", node) + tokenize(expr)
        case let .namedMemoryReference(name, expr):
            return expression.newToken(.identifier, name, node) +
                expression.newToken(.delimiter, ": ", node) +
                expression.newToken(.symbol, "&", node) +
                tokenize(expr)
        case .operator(let op):
            return [expression.newToken(.symbol, op, node)]
        case let .namedOperator(identifier, op):
            return expression.newToken(.identifier, identifier, node) +
                expression.newToken(.delimiter, ": ", node) +
                expression.newToken(.symbol, op, node)
        }
    }
    
    open func tokenize(_ expression: IdentifierExpression) -> [Token] {
        switch expression.kind {
        case let .identifier(id, generic):
            return expression.newToken(.identifier, id) + generic.map { tokenize($0, node: expression) }
        case let .implicitParameterName(i, generic):
            return expression.newToken(.symbol, "$") +
                expression.newToken(.number, "\(i)") +
                generic.map { tokenize($0, node: expression) }
        }
    }
    
    open func tokenize(_ expression: ImplicitMemberExpression) -> [Token] {
        return expression.newToken(.symbol, ".") + expression.newToken(.identifier, expression.identifier)
    }
    
    open func tokenize(_ expression: InOutExpression) -> [Token] {
        return expression.newToken(.symbol, "&") + expression.newToken(.identifier, expression.identifier)
    }
    
    open func tokenize(_ expression: InitializerExpression) -> [Token] {
        var tokens = tokenize(expression.postfixExpression) +
            expression.newToken(.identifier, ".init")
        if !expression.argumentNames.isEmpty {
            let argumentNames = expression.argumentNames.flatMap {
                return expression.newToken(.identifier, $0) +
                    expression.newToken(.delimiter, ":")
            }
            tokens = tokens +
                expression.newToken(.startOfScope, "(") +
                argumentNames +
                expression.newToken(.endOfScope, ")")
        }
        return tokens
    }
    
    open func tokenize(_ expression: KeyPathStringExpression) -> [Token] {
        return expression.newToken(.keyword, "#keyPath") +
            expression.newToken(.startOfScope, "(") +
            tokenize(expression.expression) +
            expression.newToken(.endOfScope, ")")
    }
    
    open func tokenize(_ expression: LiteralExpression) -> [Token] {
        switch expression.kind {
        case .nil:
            return [expression.newToken(.keyword, "nil")]
        case .boolean(let bool):
            return [expression.newToken(.keyword, bool ? "true" : "false")]
        case let .integer(_, rawText):
            return [expression.newToken(.number, rawText)]
        case let .floatingPoint(_, rawText):
            return [expression.newToken(.number, rawText)]
        case let .staticString(_, rawText):
            return [expression.newToken(.string, rawText)]
        case let .interpolatedString(_, rawText):
            return [expression.newToken(.string, rawText)]
        case .array(let exprs):
            return
                expression.newToken(.startOfScope, "[") +
                    exprs.map { tokenize($0) }.joined(token: expression.newToken(.delimiter, ", ")) +
                    expression.newToken(.endOfScope, "]")
        case .dictionary(let entries):
            if entries.isEmpty {
                return expression.newToken(.startOfScope, "[") +
                    expression.newToken(.delimiter, ":") +
                    expression.newToken(.endOfScope, "]")
            }
            return entries.map { tokenize($0, node: expression) }.joined(token: expression.newToken(.delimiter, ", "))
                .prefix(with: expression.newToken(.startOfScope, "["))
                .suffix(with: expression.newToken(.endOfScope, "]"))
        }
    }
    
    open func tokenize(_ expression: OptionalChainingExpression) -> [Token] {
        return tokenize(expression.postfixExpression) + expression.newToken(.symbol, "?")
    }
    
    open func tokenize(_ expression: ParenthesizedExpression) -> [Token] {
        return tokenize(expression.expression)
            .prefix(with: expression.newToken(.startOfScope, "("))
            .suffix(with: expression.newToken(.endOfScope, ")"))
    }
    
    open func tokenize(_ expression: PostfixOperatorExpression) -> [Token] {
        return tokenize(expression.postfixExpression) +
            expression.newToken(.symbol, expression.postfixOperator)
    }
    
    open func tokenize(_ expression: PostfixSelfExpression) -> [Token] {
        return tokenize(expression.postfixExpression) +
            expression.newToken(.symbol, ".") +
            expression.newToken(.keyword, "self")
    }
    
    open func tokenize(_ expression: PrefixOperatorExpression) -> [Token] {
        return expression.newToken(.symbol, expression.prefixOperator) +
            tokenize(expression.postfixExpression)
    }
    
    open func tokenize(_ expression: SelectorExpression) -> [Token] {
        switch expression.kind {
        case .selector(let expr):
            return expression.newToken(.keyword, "#selector") +
                expression.newToken(.startOfScope, "(") +
                tokenize(expr) +
                expression.newToken(.endOfScope, ")")
        case .getter(let expr):
            return [expression.newToken(.keyword, "#selector"),
                    expression.newToken(.startOfScope, "("),
                    expression.newToken(.keyword, "getter"),
                    expression.newToken(.delimiter, ": ")] +
                tokenize(expr) +
                expression.newToken(.endOfScope, ")")
        case .setter(let expr):
            return [expression.newToken(.keyword, "#selector"),
                    expression.newToken(.startOfScope, "("),
                    expression.newToken(.keyword, "setter"),
                    expression.newToken(.delimiter, ": ")] +
                tokenize(expr) +
                expression.newToken(.endOfScope, ")")
        case let .selfMember(identifier, argumentNames):
            var tokens = [expression.newToken(.identifier, identifier)]
            if !argumentNames.isEmpty {
                let argumentNames = argumentNames.flatMap {
                    expression.newToken(.identifier, $0) +
                        expression.newToken(.delimiter, ":")
                }
                tokens += (argumentNames
                    .prefix(with: expression.newToken(.startOfScope, "("))
                    .suffix(with: expression.newToken(.endOfScope, ")")))
            }
            return [expression.newToken(.keyword, "#selector")] +
                [expression.newToken(.startOfScope, "(")] +
                tokens +
                [expression.newToken(.endOfScope, ")")]
        }
    }
    
    open func tokenize(_ expression: SelfExpression) -> [Token] {
        switch expression.kind {
        case .self:
            return [expression.newToken(.keyword, "self")]
        case .method(let name):
            return expression.newToken(.keyword, "self") +
                expression.newToken(.delimiter, ".") +
                expression.newToken(.identifier, name)
        case .subscript(let args):
            return expression.newToken(.keyword, "self") +
                expression.newToken(.startOfScope, "[") +
                args.map { tokenize($0, node: expression) }.joined(token: expression.newToken(.delimiter, ", ")) +
                expression.newToken(.endOfScope, "]")
        case .initializer:
            return expression.newToken(.keyword, "self") +
                expression.newToken(.delimiter, ".") +
                expression.newToken(.keyword, "init")
        }
    }
    
    open func tokenize(_ element: SequenceExpression.Element, node: ASTNode) -> [Token] {
        switch element {
        case .expression(let expr):
            return tokenize(expr)
        case .assignmentOperator:
            return [node.newToken(.symbol, "=")]
        case .binaryOperator(let op):
            return [node.newToken(.symbol, op)]
        case .ternaryConditionalOperator(let expr):
            return [
                [node.newToken(.symbol, "?")],
                tokenize(expr),
                [node.newToken(.symbol, ":")],
                ].joined(token: node.newToken(.space, " "))
        case .typeCheck(let type):
            return [
                [node.newToken(.keyword, "is")],
                tokenize(type, node: node),
                ].joined(token: node.newToken(.space, " "))
        case .typeCast(let type):
            return [
                [node.newToken(.keyword, "as")],
                tokenize(type, node: node),
                ].joined(token: node.newToken(.space, " "))
        case .typeConditionalCast(let type):
            return [
                [
                    node.newToken(.keyword, "as"),
                    node.newToken(.symbol, "?"),
                    ],
                tokenize(type, node: node),
                ].joined(token: node.newToken(.space, " "))
        case .typeForcedCast(let type):
            return [
                [
                    node.newToken(.keyword, "as"),
                    node.newToken(.symbol, "!"),
                    ],
                tokenize(type, node: node),
                ].joined(token: node.newToken(.space, " "))
        }
    }
    
    open func tokenize(_ expression: SequenceExpression) -> [Token] {
        return expression.elements
            .map({ tokenize($0, node: expression) })
            .joined(token: expression.newToken(.space, " "))
    }
    
    open func tokenize(_ expression: SubscriptExpression) -> [Token] {
        return tokenize(expression.postfixExpression) +
            expression.newToken(.startOfScope, "[") +
            expression.arguments.map { tokenize($0, node: expression) }
                .joined(token: expression.newToken(.delimiter, ", ")) +
            expression.newToken(.endOfScope, "]")
    }
    
    open func tokenize(_ expression: SuperclassExpression) -> [Token] {
        switch expression.kind {
        case .method(let name):
            return expression.newToken(.keyword, "super") +
                expression.newToken(.delimiter, ".") +
                expression.newToken(.identifier, name)
        case .subscript(let args):
            return expression.newToken(.keyword, "super") +
                expression.newToken(.startOfScope, "[") +
                args.map { tokenize($0, node: expression) }.joined(token: expression.newToken(.delimiter, ", ")) +
                expression.newToken(.endOfScope, "]")
        case .initializer:
            return expression.newToken(.keyword, "super") +
                expression.newToken(.delimiter, ".") +
                expression.newToken(.keyword, "init")
        }
    }
    
    open func tokenize(_ expression: TernaryConditionalOperatorExpression) -> [Token] {
        return [
            tokenize(expression.conditionExpression),
            [expression.newToken(.symbol, "?")],
            tokenize(expression.trueExpression),
            [expression.newToken(.symbol, ":")],
            tokenize(expression.falseExpression),
            ].joined(token: expression.newToken(.space, " "))
    }
    
    open func tokenize(_ expression: TryOperatorExpression) -> [Token] {
        switch expression.kind {
        case .try(let expr):
            return expression.newToken(.keyword, "try") +
                expression.newToken(.space, " ") +
                tokenize(expr)
        case .forced(let expr):
            return expression.newToken(.keyword, "try") +
                expression.newToken(.symbol, "!") +
                expression.newToken(.space, " ") +
                tokenize(expr)
            
        case .optional(let expr):
            return expression.newToken(.keyword, "try") +
                expression.newToken(.symbol, "?") +
                expression.newToken(.space, " ") +
                tokenize(expr)
        }
    }
    
    open func tokenize(_ expression: TupleExpression) -> [Token] {
        if expression.elementList.isEmpty {
            return expression.newToken(.startOfScope, "(") +
                expression.newToken(.endOfScope, ")")
        }
        
        return expression.elementList.map { element in
            var idTokens = [Token]()
            if let id = element.identifier {
                idTokens = element.newToken(.identifier, id, expression) +
                    element.newToken(.delimiter, ": ", expression)
            }
            return idTokens + tokenize(element.expression)
            }.joined(token: expression.newToken(.delimiter, ", "))
            .prefix(with: expression.newToken(.startOfScope, "("))
            .suffix(with: expression.newToken(.endOfScope, ")"))
    }
    
    open func tokenize(_ expression: TypeCastingOperatorExpression) -> [Token] {
        let exprTokens: [Token]
        let operatorTokens: [Token]
        let typeTokens: [Token]
        switch expression.kind {
        case let .check(expr, type):
            exprTokens = tokenize(expr)
            operatorTokens = [expression.newToken(.keyword, "is")]
            typeTokens = tokenize(type, node: expression)
        case let .cast(expr, type):
            exprTokens = tokenize(expr)
            operatorTokens = [expression.newToken(.keyword, "as")]
            typeTokens = tokenize(type, node: expression)
        case let .conditionalCast(expr, type):
            exprTokens = tokenize(expr)
            operatorTokens = [expression.newToken(.keyword, "as"), expression.newToken(.symbol, "?")]
            typeTokens = tokenize(type, node: expression)
        case let .forcedCast(expr, type):
            exprTokens = tokenize(expr)
            operatorTokens = [expression.newToken(.keyword, "as"), expression.newToken(.symbol, "!")]
            typeTokens = tokenize(type, node: expression)
        }
        return  [
            exprTokens,
            operatorTokens,
            typeTokens,
            ].joined(token: expression.newToken(.space, " "))
    }
    
    open func tokenize(_ expression: WildcardExpression) -> [Token] {
        return [expression.newToken(.symbol, "_")]
    }
    
    open func tokenize(_ entry: DictionaryEntry, node: ASTNode) -> [Token] {
        return tokenize(entry.key) +
            entry.newToken(.delimiter, ": ", node) +
            tokenize(entry.value)
    }
    
    open func tokenize(_ arg: SubscriptArgument, node: ASTNode) -> [Token] {
        return  arg.identifier.map { id in
            return arg.newToken(.identifier, id, node) + arg.newToken(.delimiter, ": ", node)
            } + tokenize(arg.expression)
    }
    
    // MARK: - Generics

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
                clause.parameterList.map { tokenize($0, node: node) }
                    .joined(token: clause.newToken(.delimiter, ", ", node)) +
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
            clause.requirementList.map { tokenize($0, node: node) }
                .joined(token: clause.newToken(.delimiter, ", ", node))
    }
    
    open func tokenize(_ clause: GenericArgumentClause, node: ASTNode) -> [Token] {
        return clause.newToken(.startOfScope, "<", node) +
            clause.argumentList.map { tokenize($0, node: node) }
                .joined(token: clause.newToken(.delimiter, ", ", node)) +
            clause.newToken(.endOfScope, ">", node)
    }
    
    // MARK: - Patterns

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
                pattern.elementList.map { tokenize($0, node: node) }
                    .joined(token: pattern.newToken(.delimiter, ", ", node)) +
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
    
    // MARK: - Statements
    
    open func tokenize(_ statement: Statement) -> [Token] { /*
         swift-lint:suppress(high_cyclomatic_complexity) */
        switch statement {
        case let decl as Declaration:
            return tokenize(decl)
        case let expr as Expression:
            return tokenize(expr)
        case let stmt as BreakStatement:
            return tokenize(stmt)
        case let stmt as CompilerControlStatement:
            return tokenize(stmt)
        case let stmt as ContinueStatement:
            return tokenize(stmt)
        case let stmt as DeferStatement:
            return tokenize(stmt)
        case let stmt as DoStatement:
            return tokenize(stmt)
        case let stmt as FallthroughStatement:
            return tokenize(stmt)
        case let stmt as ForInStatement:
            return tokenize(stmt)
        case let stmt as GuardStatement:
            return tokenize(stmt)
        case let stmt as IfStatement:
            return tokenize(stmt)
        case let stmt as LabeledStatement:
            return tokenize(stmt)
        case let stmt as RepeatWhileStatement:
            return tokenize(stmt)
        case let stmt as ReturnStatement:
            return tokenize(stmt)
        case let stmt as SwitchStatement:
            return tokenize(stmt)
        case let stmt as ThrowStatement:
            return tokenize(stmt)
        case let stmt as WhileStatement:
            return tokenize(stmt)
        default:
            return [
                Token(
                    origin: statement as? ASTTokenizable,
                    node: statement as? ASTNode,
                    kind: .identifier,
                    value: statement.textDescription
                ),
            ]
        }
    }
    
    open func tokenize(_ statement: BreakStatement) -> [Token] {
        return [
            [statement.newToken(.keyword, "break")],
            statement.labelName.map { [statement.newToken(.identifier, $0)] } ?? []
            ].joined(token: statement.newToken(.space, " "))
    }
    
    open func tokenize(_ statement: CompilerControlStatement) -> [Token] {
        switch statement.kind {
        case .if(let condition):
            return statement.newToken(.keyword, "#if") + statement.newToken(.identifier, condition)
        case .elseif(let condition):
            return statement.newToken(.keyword, "#elseif") + statement.newToken(.identifier, condition)
        case .else:
            return [statement.newToken(.keyword, "#else")]
        case .endif:
            return [statement.newToken(.keyword, "#endif")]
        case let .sourceLocation(fileName, lineNumber):
            var lineTokens = [Token]()
            if let fileName = fileName, let lineNumber = lineNumber {
                lineTokens = [statement.newToken(.identifier, "file: \"\(fileName)\", line: \(lineNumber)")]
            }
            return [
                statement.newToken(.keyword, "#sourceLocation"),
                statement.newToken(.startOfScope, "(")
                ] +
                lineTokens +
                [statement.newToken(.endOfScope, ")")]
        }
    }
    
    open func tokenize(_ statement: ContinueStatement) -> [Token] {
        return [
            [statement.newToken(.keyword, "continue")],
            statement.labelName.map { [statement.newToken(.identifier, $0)] } ?? []
            ].joined(token: statement.newToken(.space, " "))
    }
    
    open func tokenize(_ statement: DeferStatement) -> [Token] {
        return [
            [statement.newToken(.keyword, "defer")],
            tokenize(statement.codeBlock)
            ].joined(token: statement.newToken(.space, " "))
    }
    
    open func tokenize(_ statement: DoStatement) -> [Token] {
        return [
            [statement.newToken(.keyword, "do")],
            tokenize(statement.codeBlock),
            tokenize(statement.catchClauses, node: statement)
            ].joined(token: statement.newToken(.space, " "))
    }
    
    open func tokenize(_ statements: [DoStatement.CatchClause], node: ASTNode) -> [Token] {
        return statements.map { tokenize($0, node: node) }.joined(token: node.newToken(.space, " "))
    }
    
    open func tokenize(_ statement: DoStatement.CatchClause, node: ASTNode) -> [Token] {
        let catchTokens = [statement.newToken(.keyword, "catch", node)]
        let patternTokens = statement.pattern.map { tokenize($0, node: node) } ?? []
        let whereKeyword = statement.whereExpression.map { _ in [statement.newToken(.keyword, "where", node)] } ?? []
        let whereTokens = statement.whereExpression.map { tokenize($0) } ?? []
        let codeTokens = tokenize(statement.codeBlock)
        return [
            catchTokens,
            patternTokens,
            whereKeyword,
            whereTokens,
            codeTokens
            ].joined(token: statement.newToken(.space, " ", node))
    }
    
    open func tokenize(_ statement: FallthroughStatement) -> [Token] {
        return [statement.newToken(.keyword, "fallthrough")]
    }
    
    open func tokenize(_ statement: ForInStatement) -> [Token] {
        return [
            [statement.newToken(.keyword, "for")],
            statement.item.isCaseMatching ? [statement.newToken(.keyword, "case")] : [],
            tokenize(statement.item.matchingPattern, node: statement),
            [statement.newToken(.keyword, "in")],
            tokenize(statement.collection),
            statement.item.whereClause.map { _ in [statement.newToken(.keyword, "where")] } ?? [],
            statement.item.whereClause.map { tokenize($0) } ?? [],
            tokenize(statement.codeBlock)
            ].joined(token: statement.newToken(.space, " "))
    }
    
    open func tokenize(_ statement: GuardStatement) -> [Token] {
        return [
            [statement.newToken(.keyword, "guard")],
            tokenize(statement.conditionList, node: statement),
            [statement.newToken(.keyword, "else")],
            tokenize(statement.codeBlock)
            ].joined(token: statement.newToken(.space, " "))
    }
    
    open func tokenize(_ statement: IfStatement) -> [Token] {
        return [
            [statement.newToken(.keyword, "if")],
            tokenize(statement.conditionList, node: statement),
            tokenize(statement.codeBlock),
            statement.elseClause.map { tokenize($0, node: statement) } ?? []
            ].joined(token: statement.newToken(.space, " "))
    }
    
    open func tokenize(_ statement: IfStatement.ElseClause, node: ASTNode) -> [Token] {
        var blockTokens = [Token]()
        switch statement {
        case .else(let codeBlock):
            blockTokens = tokenize(codeBlock)
        case .elseif(let ifStmt):
            blockTokens = tokenize(ifStmt)
        }
        return [
            [statement.newToken(.keyword, "else", node)],
            blockTokens
            ].joined(token: statement.newToken(.space, " ", node))
    }
    
    open func tokenize(_ statement: LabeledStatement) -> [Token] {
        return
            statement.newToken(.identifier, statement.labelName, statement) +
                statement.newToken(.delimiter, ": ") +
                tokenize(statement.statement)
    }
    
    open func tokenize(_ statement: RepeatWhileStatement) -> [Token] {
        return [
            [statement.newToken(.keyword, "repeat")],
            tokenize(statement.codeBlock),
            [statement.newToken(.keyword, "while")],
            tokenize(statement.conditionExpression),
            ].joined(token: statement.newToken(.space, " "))
    }
    
    open func tokenize(_ statement: ReturnStatement) -> [Token] {
        return [
            [statement.newToken(.keyword, "return")],
            statement.expression.map { tokenize($0) } ?? []
            ].joined(token: statement.newToken(.space, " "))
    }
    
    open func tokenize(_ statement: SwitchStatement) -> [Token] {
        var casesTokens = statement.newToken(.startOfScope, "{") + statement.newToken(.endOfScope, "}")
        if !statement.cases.isEmpty {
            casesTokens = [
                [statement.newToken(.startOfScope, "{")],
                statement.cases.map { tokenize($0, node: statement) }
                    .joined(token: statement.newToken(.linebreak, "\n")),
                [statement.newToken(.endOfScope, "}")]
                ].joined(token: statement.newToken(.linebreak, "\n"))
        }
        
        return [
            [statement.newToken(.keyword, "switch")],
            tokenize(statement.expression),
            casesTokens
            ].joined(token: statement.newToken(.space, " "))
    }
    
    open func tokenize(_ statement: SwitchStatement.Case, node: ASTNode) -> [Token] {
        switch statement {
        case let .case(itemList, stmts):
            return
                statement.newToken(.keyword, "case", node) +
                    statement.newToken(.space, " ", node) +
                    itemList.map { tokenize($0, node: node) }
                        .joined(token: statement.newToken(.delimiter, ", ", node)) +
                    statement.newToken(.delimiter, ":", node) +
                    statement.newToken(.linebreak, "\n", node) +
                    indent(tokenize(stmts, node: node))
            
        case .default(let stmts):
            return
                statement.newToken(.keyword, "default", node) +
                    statement.newToken(.delimiter, ":", node) +
                    statement.newToken(.linebreak, "\n", node) +
                    indent(tokenize(stmts, node: node))
        }
    }
    
    open func tokenize(_ statement: SwitchStatement.Case.Item, node: ASTNode) -> [Token] {
        return [
            tokenize(statement.pattern, node: node),
            statement.whereExpression.map { _ in [statement.newToken(.keyword, "where", node)] } ?? [],
            statement.whereExpression.map { tokenize($0) } ?? []
            ].joined(token: statement.newToken(.space, " ", node))
    }
    
    open func tokenize(_ statement: ThrowStatement) -> [Token] {
        return
            statement.newToken(.keyword, "throw") +
                statement.newToken(.space, " ") +
                tokenize(statement.expression)
    }
    
    open func tokenize(_ statement: WhileStatement) -> [Token] {
        return [
            [statement.newToken(.keyword, "while")],
            tokenize(statement.conditionList, node: statement),
            tokenize(statement.codeBlock)
            ].joined(token: statement.newToken(.space, " "))
    }
    
    // MARK: Utils
    
    open func tokenize(_ statements: [Statement], node: ASTNode) -> [Token] {
        return statements.map(tokenize).joined(token: node.newToken(.linebreak, "\n"))
    }
    
    open func tokenize(_ conditions: ConditionList, node: ASTNode) -> [Token] {
        return conditions.map { tokenize($0, node: node) }.joined(token: node.newToken(.delimiter, ", "))
    }
    
    open func tokenize(_ condition: Condition, node: ASTNode) -> [Token] {
        switch condition {
        case .expression(let expr):
            return tokenize(expr)
        case .availability(let availabilityCondition):
            return tokenize(availabilityCondition, node: node)
        case let .case(pattern, expr):
            return [
                [condition.newToken(.keyword, "case", node)],
                tokenize(pattern, node: node),
                [condition.newToken(.symbol, "=", node)],
                tokenize(expr)
                ].joined(token: condition.newToken(.space, " ", node))
        case let .let(pattern, expr):
            return [
                [condition.newToken(.keyword, "let", node)],
                tokenize(pattern, node: node),
                [condition.newToken(.symbol, "=", node)],
                tokenize(expr)
                ].joined(token: condition.newToken(.space, " ", node))
        case let .var(pattern, expr):
            return [
                [condition.newToken(.keyword, "var", node)],
                tokenize(pattern, node: node),
                [condition.newToken(.symbol, "=", node)],
                tokenize(expr)
                ].joined(token: condition.newToken(.space, " ", node))
        }
    }
    
    open func tokenize(_ condition:  AvailabilityCondition, node: ASTNode) -> [Token] {
        return
            condition.newToken(.keyword, "#available", node) +
                condition.newToken(.startOfScope, "(", node) +
                condition.arguments.map { tokenize($0, node: node) }
                    .joined(token: condition.newToken(.delimiter, ", ", node)) +
                condition.newToken(.endOfScope, ")", node)
    }
    
    open func tokenize(_ argument: AvailabilityCondition.Argument, node: ASTNode) -> [Token] {
        return [argument.newToken(.identifier, argument.textDescription, node)]
    }
    
    // MARK: - Types

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
            type.arguments.map { tokenize($0, node: node) }
                .joined(token: type.newToken(.delimiter, ", ", node)) +
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
                    type.protocolTypes.map { tokenize($0, node: node) }
                        .joined(token: type.newToken(.delimiter, ", ", node)) +
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
    
    // MARK: - Utils
    open func tokenize(_ origin: ThrowsKind, node: ASTNode) -> [Token] {
        switch origin {
        case .nothrowing: return []
        case .throwing: return [origin.newToken(.keyword, "throws", node)]
        case .rethrowing: return [origin.newToken(.keyword, "rethrows", node)]
        }
    }
}
