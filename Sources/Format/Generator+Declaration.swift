//
//  Generator+Declaration.swift
//  Format
//
//  Created by Angel Garcia on 14/07/2017.
//

import AST

extension Generator {
    
    // MARK: Declarations
    
    open func generate(_ declaration: Declaration) -> String {
        switch declaration {
        case let decl as ClassDeclaration:
            return generate(decl)
        case let decl as ConstantDeclaration:
            return generate(decl)
        case let decl as DeinitializerDeclaration:
            return generate(decl)
        case let decl as EnumDeclaration:
            return generate(decl)
        case let decl as ExtensionDeclaration:
            return generate(decl)
        case let decl as FunctionDeclaration:
            return generate(decl)
        case let decl as ImportDeclaration:
            return generate(decl)
        case let decl as InitializerDeclaration:
            return generate(decl)
        case let decl as OperatorDeclaration:
            return generate(decl)
        case let decl as PrecedenceGroupDeclaration:
            return generate(decl)
        case let decl as ProtocolDeclaration:
            return generate(decl)
        case let decl as StructDeclaration:
            return generate(decl)
        case let decl as SubscriptDeclaration:
            return generate(decl)
        case let decl as TypealiasDeclaration:
            return generate(decl)
        case let decl as VariableDeclaration:
            return generate(decl)
        default:
            return declaration.textDescription // no implementation for this declaration, just continue
        }
    }
    
    open func generate(_ topLevelDeclaration: TopLevelDeclaration) -> String {
        return topLevelDeclaration.statements.map(generate).joined(separator: "\n")
    }
    
    open func generate(_ codeBlock: CodeBlock) -> String {
        if codeBlock.statements.isEmpty {
            return "{}"
        }
        return "{\n\(codeBlock.statements.map(generate).joined(separator: "\n"))\n}"
    }
    
    open func generate(_ block: GetterSetterBlock.GetterClause) -> String {
        let attrsText = block.attributes.isEmpty ? "" : "\(generate(block.attributes)) "
        let modifierText = block.mutationModifier.map({ "\(generate($0)) " }) ?? ""
        return "\(attrsText)\(modifierText)get \(generate(block.codeBlock))"
    }
    
    open func generate(_ block: GetterSetterBlock.SetterClause) -> String {
        let attrsText = block.attributes.isEmpty ? "" : "\(generate(block.attributes)) "
        let modifierText = block.mutationModifier.map({ "\(generate($0)) " }) ?? ""
        let nameText = block.name.map({ "(\($0))" }) ?? ""
        return "\(attrsText)\(modifierText)set\(nameText) \(generate(block.codeBlock))"
    }
    
    open func generate(_ block: GetterSetterBlock) -> String {
        let setterStr = block.setter.map({ "\n\(generate($0))" }) ?? ""
        return "{\n" + "\(generate(block.getter))\(setterStr)" + "\n}"
    }
    
    open func generate(_ block: GetterSetterKeywordBlock) -> String {
        let setterStr = block.setter.map({ "\n\(generate($0))" }) ?? ""
        return "{\n\(generate(block.getter))\(setterStr)\n}"
    }
    
    open func generate(_ block: WillSetDidSetBlock.WillSetClause) -> String {
        let attrsText = block.attributes.isEmpty ? "" : "\(generate(block.attributes)) "
        let nameText = block.name.map({ "(\($0))" }) ?? ""
        return "\(attrsText)willSet\(nameText) \(generate(block.codeBlock))"
    }
    
    open func generate(_ block: WillSetDidSetBlock.DidSetClause) -> String {
        let attrsText = block.attributes.isEmpty ? "" : "\(generate(block.attributes)) "
        let nameText = block.name.map({ "(\($0))" }) ?? ""
        return "\(attrsText)didSet\(nameText) \(generate(block.codeBlock))"
    }
    
    open func generate(_ block: WillSetDidSetBlock) -> String {
        let willSetClauseStr = block.willSetClause.map({ "\n\(generate($0))" }) ?? ""
        let didSetClauseStr = block.didSetClause.map({ "\n\(generate($0))" }) ?? ""
        return "{\(willSetClauseStr)\(didSetClauseStr)\n}"
    }
    
    open func generate(_ clause: GetterSetterKeywordBlock.GetterKeywordClause) -> String {
        let attrsText = clause.attributes.isEmpty ? "" : "\(generate(clause.attributes)) "
        let modifierText = clause.mutationModifier.map({ "\(generate($0)) " }) ?? ""
        return "\(attrsText)\(modifierText)get"
    }
    
    open func generate(_ clause: GetterSetterKeywordBlock.SetterKeywordClause) -> String {
        let attrsText = clause.attributes.isEmpty ? "" : "\(generate(clause.attributes)) "
        let modifierText = clause.mutationModifier.map({ "\(generate($0)) " }) ?? ""
        return "\(attrsText)\(modifierText)set"
    }
    
    open func generate(_ patternInitializer: PatternInitializer) -> String {
        let pttrnText = generate(patternInitializer.pattern)
        guard let initExpr = patternInitializer.initializerExpression else {
            return pttrnText
        }
        return "\(pttrnText) = \(generate(initExpr))"
    }
    
    open func generate(_ initializers: [PatternInitializer]) -> String {
        return initializers.map(generate).joined(separator: ", ")
    }
    
    open func generate(_ member: ClassDeclaration.Member) -> String {
        switch member {
        case .declaration(let decl):
            return generate(decl)
        case .compilerControl(let stmt):
            return generate(stmt)
        }
    }
    
    open func generate(_ declaration: ClassDeclaration) -> String {
        let attrsText = declaration.attributes.isEmpty ? "" : "\(generate(declaration.attributes)) "
        let modifierText = declaration.accessLevelModifier.map({ "\(generate($0)) " }) ?? ""
        let finalText = declaration.isFinal ? "final " : ""
        let headText = "\(attrsText)\(modifierText)\(finalText)class \(declaration.name)"
        let genericParameterClauseText = declaration.genericParameterClause.map(generate) ?? ""
        let typeText = declaration.typeInheritanceClause.map(generate) ?? ""
        let whereText = declaration.genericWhereClause.map({ " \(generate($0))" }) ?? ""
        let neckText = "\(genericParameterClauseText)\(typeText)\(whereText)"
        let membersText = declaration.members.map(generate).joined(separator: "\n")
        let memberText = declaration.members.isEmpty ? "" : "\n\(membersText)\n"
        return "\(headText)\(neckText) {" + memberText + "}"
    }
    
    open func generate(_ constant: ConstantDeclaration) -> String {
        let attrsText = constant.attributes.isEmpty ? "" : "\(generate(constant.attributes)) "
        let modifiersText = constant.modifiers.isEmpty ? "" : "\(generate(constant.modifiers)) "
        return "\(attrsText)\(modifiersText)let \(generate(constant.initializerList))"
    }
    
    open func generate(_ declaration: DeinitializerDeclaration) -> String {
        let attrsText = declaration.attributes.isEmpty ? "" : "\(generate(declaration.attributes)) "
        return "\(attrsText)deinit \(generate(declaration.body))"
    }
    
    open func generate(_ member: EnumDeclaration.Member) -> String {
        switch member {
        case .declaration(let decl):
            return generate(decl)
        case .union(let enumCase):
            return generate(enumCase)
        case .rawValue(let enumCase):
            return generate(enumCase)
        case .compilerControl(let stmt):
            return generate(stmt)
        }
    }
    
    open func generate(_ union: EnumDeclaration.UnionStyleEnumCase) -> String {
        let attrsText = union.attributes.isEmpty ? "" : "\(generate(union.attributes)) "
        let indirectText = union.isIndirect ? "indirect " : ""
        let casesText = union.cases.map({ "\($0.name)\($0.tuple.map(generate) ?? "")" }).joined(separator: ", ")
        return "\(attrsText)\(indirectText)case \(casesText)"
    }
    
    open func generate(_ raw: EnumDeclaration.RawValueStyleEnumCase) -> String {
        let attrsText = raw.attributes.isEmpty ? "" : "\(generate(raw.attributes)) "
        let casesText = raw.cases.map { c -> String in
            let assignmentText: String
            if let assignment = c.assignment {
                switch assignment {
                case .integer(let i):
                    assignmentText = " = \(i)"
                case .floatingPoint(let d):
                    assignmentText = " = \(d)"
                case .string(let s):
                    assignmentText = " = \"\(s)\""
                case .boolean(let b):
                    assignmentText = b ? " = true" : " = false"
                }
            } else {
                assignmentText = ""
            }
            return "\(c.name)\(assignmentText)"
        }
        return "\(attrsText)case \(casesText.joined(separator: ", "))"
    }
    
    open func generate(_ declaration: EnumDeclaration) -> String {
        let attrsText = declaration.attributes.isEmpty ? "" : "\(generate(declaration.attributes)) "
        let modifierText = declaration.accessLevelModifier.map({ "\(generate($0)) " }) ?? ""
        let indirectText = declaration.isIndirect ? "indirect " : ""
        let headText = "\(attrsText)\(modifierText)\(indirectText)enum \(declaration.name)"
        let genericParameterClauseText = declaration.genericParameterClause.map(generate) ?? ""
        let typeText = declaration.typeInheritanceClause.map(generate) ?? ""
        let whereText = declaration.genericWhereClause.map({ " \(generate($0))" }) ?? ""
        let neckText = "\(genericParameterClauseText)\(typeText)\(whereText)"
        let membersText = declaration.members.map(generate).joined(separator: "\n")
        let memberText = declaration.members.isEmpty ? "" : "\n\(membersText)\n"
        return "\(headText)\(neckText) {\(memberText)}"
    }
    
    open func generate(_ member: ExtensionDeclaration.Member) -> String {
        switch member {
        case .declaration(let decl):
            return generate(decl)
        case .compilerControl(let stmt):
            return generate(stmt)
        }        
    }
    
    open func generate(_ declaration: ExtensionDeclaration) -> String {
        let attrsText = declaration.attributes.isEmpty ? "" : "\(generate(declaration.attributes)) "
        let modifierText = declaration.accessLevelModifier.map({ "\(generate($0)) " }) ?? ""
        let headText = "\(attrsText)\(modifierText)extension \(generate(declaration.type))"
        let typeInheritanceText = declaration.typeInheritanceClause.map(generate) ?? ""
        let whereText = declaration.genericWhereClause.map({ " \(generate($0))" }) ?? ""
        let neckText = "\(typeInheritanceText)\(whereText)"
        let membersText = declaration.members.map(generate).joined(separator: "\n")
        let memberText = declaration.members.isEmpty ? "" : "\n\(membersText)\n"
        return "\(headText)\(neckText) {\(memberText)}"
    }
    
    open func generate(_ declaration: FunctionDeclaration) -> String {
        let attrsText = declaration.attributes.isEmpty ? "" : "\(generate(declaration.attributes)) "
        let modifiersText = declaration.modifiers.isEmpty ? "" : "\(generate(declaration.modifiers)) "
        let headText = "\(attrsText)\(modifiersText)func"
        let genericParameterClauseText = declaration.genericParameterClause.map(generate) ?? ""
        let signatureText = generate(declaration.signature)
        let genericWhereClauseText = declaration.genericWhereClause.map({ " \(generate($0))" }) ?? ""
        let bodyText = declaration.body.map({ " \(generate($0))" }) ?? ""
        return "\(headText) \(declaration.name)\(genericParameterClauseText)\(signatureText)\(genericWhereClauseText)\(bodyText)"
    }
    
    open func generate(_ parameter: FunctionSignature.Parameter) -> String {
        let externalNameText = parameter.externalName.map({ [$0] }) ?? []
        let localNameText = parameter.localName.isEmpty ? [] : [parameter.localName]
        let nameText = (externalNameText + localNameText).joined(separator: " ")
        let typeAnnoText = generate(parameter.typeAnnotation)
        let defaultText = parameter.defaultArgumentClause.map({ " = \(generate($0))" }) ?? ""
        let varargsText = parameter.isVarargs ? "..." : ""
        return "\(nameText)\(typeAnnoText)\(defaultText)\(varargsText)"
    }
    
    open func generate(_ signature: FunctionSignature) -> String {
        let parameterText = ["(\(signature.parameterList.map(generate).joined(separator: ", ")))"]
        let throwsKindText = generate(signature.throwsKind).isEmpty ? [] : [generate(signature.throwsKind)]
        let resultText = signature.result.map({ [generate($0)] }) ?? []
        return (parameterText + throwsKindText + resultText).joined(separator: " ")
    }
    
    open func generate(_ result: FunctionResult) -> String {
        let typeText = generate(result.type)
        if result.attributes.isEmpty {
            return "-> \(typeText)"
        }
        return "-> \(generate(result.attributes)) \(typeText)"
    }
    
    open func generate(_ declaration: ImportDeclaration) -> String {
        let attrsText = declaration.attributes.isEmpty ? "" : "\(generate(declaration.attributes)) "
        let kindText = declaration.kind.map({ " \($0.rawValue)" }) ?? ""
        let pathText = declaration.path.joined(separator: ".")
        return "\(attrsText)import\(kindText) \(pathText)"
    }
    
    open func generate(_ declaration: InitializerDeclaration) -> String {
        let attrsText = declaration.attributes.isEmpty ? "" : "\(generate(declaration.attributes)) "
        let modifiersText = declaration.modifiers.isEmpty ? "" : "\(generate(declaration.modifiers)) "
        let headText = "\(attrsText)\(modifiersText)init\(generate(declaration.kind))"
        let genericParameterClauseText = declaration.genericParameterClause.map(generate) ?? ""
        let parameterText = "(\(declaration.parameterList.map(generate).joined(separator: ", ")))"
        let throwsKindText = generate(declaration.throwsKind).isEmpty ? "" : " \(generate(declaration.throwsKind))"
        let genericWhereClauseText = declaration.genericWhereClause.map({ " \(generate($0))" }) ?? ""
        let bodyText = generate(declaration.body)
        return "\(headText)\(genericParameterClauseText)\(parameterText)\(throwsKindText)\(genericWhereClauseText) \(bodyText)"
    }
    
    open func generate(_ declaration: InitializerDeclaration.InitKind) -> String {
        switch declaration {
        case .nonfailable:
            return ""
        case .optionalFailable:
            return "?"
        case .implicitlyUnwrappedFailable:
            return "!"
        }
    }
    
    open func generate(_ declaration: OperatorDeclaration) -> String {
        switch declaration.kind {
        case .prefix(let op):
            return "prefix operator \(op)"
        case .postfix(let op):
            return "postfix operator \(op)"
        case .infix(let op, nil):
            return "infix operator \(op)"
        case .infix(let op, let id?):
            return "infix operator \(op) : \(id)"
        }
    }
    
    open func generate(_ declaration: PrecedenceGroupDeclaration) -> String {
        let attrsText = declaration.attributes.map(generate).joined(separator: "\n")
        let attrsBlockText = declaration.attributes.isEmpty ? "{}" : "{\n\(attrsText)\n}"
        return "precedencegroup \(declaration.name) \(attrsBlockText)"
    }
    
    open func generate(_ attribute: PrecedenceGroupDeclaration.Attribute) -> String {
        switch attribute {
        case .higherThan(let ids):
            return "higherThan: \(ids.textDescription)"
        case .lowerThan(let ids):
            return "lowerThan: \(ids.textDescription)"
        case .assignment(let b):
            let boolText = b ? "true" : "false"
            return "assignment: \(boolText)"
        case .associativityLeft:
            return "associativity: left"
        case .associativityRight:
            return "associativity: right"
        case .associativityNone:
            return "associativity: none"
        }
    }
    
    open func generate(_ declaration: ProtocolDeclaration) -> String {
        let attrsText = declaration.attributes.isEmpty ? "" : "\(generate(declaration.attributes)) "
        let modifierText = declaration.accessLevelModifier.map({ "\(generate($0)) " }) ?? ""
        let headText = "\(attrsText)\(modifierText)protocol \(declaration.name)"
        let typeText = declaration.typeInheritanceClause.map(generate) ?? ""
        let membersText = declaration.members.map(generate).joined(separator: "\n")
        let memberText = declaration.members.isEmpty ? "" : "\n\(membersText)\n"
        return "\(headText)\(typeText) {\(memberText)}"
    }

    open func generate(_ member: ProtocolDeclaration.Member) -> String {
        switch member {
        case .property(let member):
            return generate(member)
        case .method(let member):
            return generate(member)
        case .initializer(let member):
            return generate(member)
        case .subscript(let member):
            return generate(member)
        case .associatedType(let member):
            return generate(member)
        case .compilerControl(let stmt):
            return generate(stmt)
        }
    }
    
    open func generate(_ member: ProtocolDeclaration.PropertyMember) -> String {
        let attrsText = member.attributes.isEmpty ? "" : "\(generate(member.attributes)) "
        let modifiersText = member.modifiers.isEmpty ? "" : "\(generate(member.modifiers)) "
        let blockText = generate(member.getterSetterKeywordBlock)
        return "\(attrsText)\(modifiersText)var \(member.name)\(member.typeAnnotation) \(blockText)"
    }
    
    open func generate(_ member: ProtocolDeclaration.MethodMember) -> String {
        let attrsText = member.attributes.isEmpty ? "" : "\(generate(member.attributes)) "
        let modifiersText = member.modifiers.isEmpty ? "" : "\(generate(member.modifiers)) "
        let headText = "\(attrsText)\(modifiersText)func"
        let genericParameterClauseText = member.genericParameter.map(generate) ?? ""
        let signatureText = generate(member.signature)
        let genericWhereClauseText = member.genericWhere.map({ " \(generate($0))" }) ?? ""
        return "\(headText) \(member.name)\(genericParameterClauseText)\(signatureText)\(genericWhereClauseText)"
    }
    
    open func generate(_ member: ProtocolDeclaration.InitializerMember) -> String {
        let attrsText = member.attributes.isEmpty ? "" : "\(generate(member.attributes)) "
        let modifiersText = member.modifiers.isEmpty ? "" : "\(generate(member.modifiers)) "
        let headText = "\(attrsText)\(modifiersText)init\(generate(member.kind))"
        let genericParameterClauseText = member.genericParameter.map(generate) ?? ""
        let parameterText = "(\(member.parameterList.map(generate).joined(separator: ", ")))"
        let throwsKindText = generate(member.throwsKind).isEmpty ? "" : " \(generate(member.throwsKind))"
        let genericWhereClauseText = member.genericWhere.map({ " \(generate($0))" }) ?? ""
        return "\(headText)\(genericParameterClauseText)\(parameterText)\(throwsKindText)\(genericWhereClauseText)"
    }
    
    open func generate(_ member: ProtocolDeclaration.SubscriptMember) -> String {
        let attrsText = member.attributes.isEmpty ? "" : "\(generate(member.attributes)) "
        let modifiersText = member.modifiers.isEmpty ? "" : "\(generate(member.modifiers)) "
        let genericParamClauseText = member.genericParameter.map(generate) ?? ""
        let parameterText = "(\(member.parameterList.map(generate).joined(separator: ", ")))"
        let headText = "\(attrsText)\(modifiersText)subscript\(genericParamClauseText)\(parameterText)"
        
        let resultAttrsText = member.resultAttributes.isEmpty ? "" : "\(generate(member.resultAttributes)) "
        let resultText = "-> \(resultAttrsText)\(generate(member.resultType))"
        
        let genericWhereClauseText = member.genericWhere.map({ " \(generate($0))" }) ?? ""
        
        return "\(headText) \(resultText)\(genericWhereClauseText) \(generate(member.getterSetterKeywordBlock))"
    }
    
    open func generate(_ member: ProtocolDeclaration.AssociativityTypeMember) -> String {
        let attrsText = member.attributes.isEmpty ? "" : "\(generate(member.attributes)) "
        let modifierText = member.accessLevelModifier.map({ "\(generate($0)) " }) ?? ""
        let typeText = member.typeInheritance.map(generate) ?? ""
        let assignmentText = member.assignmentType.map({ " = \(generate($0))" }) ?? ""
        let genericWhereClauseText = member.genericWhere.map({ " \(generate($0))" }) ?? ""
        return "\(attrsText)\(modifierText)associatedtype \(member.name)\(typeText)\(assignmentText)\(genericWhereClauseText)"
    }
    
    open func generate(_ declaration: StructDeclaration) -> String {
        let attrsText = declaration.attributes.isEmpty ? "" : "\(generate(declaration.attributes)) "
        let modifierText = declaration.accessLevelModifier.map({ "\(generate($0)) " }) ?? ""
        let headText = "\(attrsText)\(modifierText)struct \(declaration.name)"
        let genericParameterClauseText = declaration.genericParameterClause.map(generate) ?? ""
        let typeText = declaration.typeInheritanceClause.map(generate) ?? ""
        let whereText = declaration.genericWhereClause.map({ " \(generate($0))" }) ?? ""
        let neckText = "\(genericParameterClauseText)\(typeText)\(whereText)"
        let membersText = declaration.members.map(generate).joined(separator: "\n")
        let memberText = declaration.members.isEmpty ? "" : "\n\(membersText)\n"
        return "\(headText)\(neckText) {\(memberText)}"
    }
    
    open func generate(_ member: StructDeclaration.Member) -> String {
        switch member {
        case .declaration(let decl):
            return generate(decl)
        case .compilerControl(let stmt):
            return generate(stmt)
        }
    }
    
    open func generate(_ declaration: SubscriptDeclaration) -> String {
        let attrsText = declaration.attributes.isEmpty ? "" : "\(generate(declaration.attributes)) "
        let modifiersText = declaration.modifiers.isEmpty ? "" : "\(generate(declaration.modifiers)) "
        let genericParamClauseText = declaration.genericParameterClause.map(generate) ?? ""
        let parameterText = "(\(declaration.parameterList.map(generate).joined(separator: ", ")))"
        let headText = "\(attrsText)\(modifiersText)subscript\(genericParamClauseText)\(parameterText)"
        
        let resultAttrsText = declaration.resultAttributes.isEmpty ? "" : "\(generate(declaration.resultAttributes)) "
        let resultText = "-> \(resultAttrsText)\(generate(declaration.resultType))"
        
        let genericWhereClauseText = declaration.genericWhereClause.map({ " \(generate($0))" }) ?? ""
        
        return "\(headText) \(resultText)\(genericWhereClauseText) \(generate(declaration.body))"
    }
    
    open func generate(_ body: SubscriptDeclaration.Body) -> String {
        switch body {
        case .codeBlock(let block):
            return generate(block)
        case .getterSetterBlock(let block):
            return generate(block)
        case .getterSetterKeywordBlock(let block):
            return generate(block)
        }
    }
    
    open func generate(_ declaration: TypealiasDeclaration) -> String {
        let attrsText = declaration.attributes.isEmpty ? "" : "\(generate(declaration.attributes)) "
        let modifierText = declaration.accessLevelModifier.map({ "\(generate($0)) " }) ?? ""
        let genericText = declaration.generic.map(generate) ?? ""
        return "\(attrsText)\(modifierText)typealias \(declaration.name)\(genericText) = \(generate(declaration.assignment))"
    }
    
    open func generate(_ declaration: VariableDeclaration) -> String {
        let attrsText = declaration.attributes.isEmpty ? "" : "\(generate(declaration.attributes)) "
        let modifiersText = declaration.modifiers.isEmpty ? "" : "\(generate(declaration.modifiers)) "
        return "\(attrsText)\(modifiersText)var \(generate(declaration.body))"
    }
    
    open func generate(_ body: VariableDeclaration.Body) -> String {
        switch body {
        case .initializerList(let inits):
            return inits.map(generate).joined(separator: ", ")
        case let .codeBlock(name, typeAnnotation, codeBlock):
            return "\(name)\(typeAnnotation) \(generate(codeBlock))"
        case let .getterSetterBlock(name, typeAnnotation, block):
            return "\(name)\(typeAnnotation) \(generate(block))"
        case let .getterSetterKeywordBlock(name, typeAnnotation, block):
            return "\(name)\(typeAnnotation) \(generate(block))"
        case let .willSetDidSetBlock(name, typeAnnotation, initExpr, block):
            let typeAnnoStr = typeAnnotation.map(generate) ?? ""
            let initStr = initExpr.map({ " = \(generate($0))" }) ?? ""
            return "\(name)\(typeAnnoStr)\(initStr) \(generate(block))"
        }
    }
    
    open func generate(_ modifiers: [DeclarationModifier]) -> String {
        return modifiers.map(generate).joined(separator: " ")
    }
    
    open func generate(_ modifier: DeclarationModifier ) -> String {
        switch modifier {
        case .class:
            return "class"
        case .convenience:
            return "convenience"
        case .dynamic:
            return "dynamic"
        case .final:
            return "final"
        case .infix:
            return "infix"
        case .lazy:
            return "lazy"
        case .optional:
            return "optional"
        case .override:
            return "override"
        case .postfix:
            return "postfix"
        case .prefix:
            return "prefix"
        case .required:
            return "required"
        case .static:
            return "static"
        case .unowned:
            return "unowned"
        case .unownedSafe:
            return "unowned(safe)"
        case .unownedUnsafe:
            return "unowned(unsafe)"
        case .weak:
            return "weak"
        case .accessLevel(let modifier):
            return generate(modifier)
        case .mutation(let modifier):
            return generate(modifier)
        }
    }
    
    open func generate(_ modifier: AccessLevelModifier) -> String {
        return modifier.rawValue
    }
    
    open func generate(_ modifier: MutationModifier) -> String {
        return modifier.rawValue
    }
}
