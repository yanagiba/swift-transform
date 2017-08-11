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
    
    open func tokenize(_ expression: Expression) -> [Token] {
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
            tokenize(expression.rightExpression)
        ].joined(token: expression.newToken(.space, " "))
    }
    
    open func tokenize(_ expression: ClosureExpression) -> [Token] {
        return [
            [expression.newToken(.startOfScope, "{")],
            expression.signature.map { tokenize($0, node: expression) } ?? [],
            expression.signature.map { [$0.newToken(.keyword, "in", expression)] } ?? [],
            expression.statements.map { stmts in
                if expression.signature == nil && stmts.count == 1 {
                    return tokenize(stmts, node: expression)
                } else {
                    return indent(
                        expression.newToken(.linebreak, "\n") +
                        tokenize(stmts, node: expression)
                    ) + expression.newToken(.linebreak, "\n")
                }
            } ?? [],
            [expression.newToken(.endOfScope, "}")],
        ].joined(token: expression.newToken(.space, " "))
    }
    
    open func tokenize(_ expression: ClosureExpression.Signature.CaptureItem, node: ASTNode) -> [Token] {
        return [
            expression.specifier.map { tokenize($0, node: node) } ?? [],
            tokenize(expression.expression)
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
                captureList.map { tokenize($0, node: node) }.joined(token: expression.newToken(.delimiter, ", ", node)) +
                expression.newToken(.endOfScope, "]", node)
        }
        return [
            captureTokens ?? [],
            expression.parameterClause.map { tokenize($0, node: node) } ?? [],
            (expression.canThrow ? expression.newToken(.keyword, "throws", node) : []),
            expression.functionResult.map { tokenize($0, node: node) } ?? [],
        ].joined(token: expression.newToken(.space, " ", node))
    }
    
    open func tokenize(_ expression: ExplicitMemberExpression) -> [Token] {
        switch expression.kind {
        case let .tuple(postfixExpr, index):
            return tokenize(postfixExpr) + expression.newToken(.delimiter, ".") + expression.newToken(.number, "\(index)")
        case let .namedType(postfixExpr, identifier):
            return tokenize(postfixExpr) + expression.newToken(.delimiter, ".") + expression.newToken(.identifier, identifier)
        case let .generic(postfixExpr, identifier, genericArgumentClause):
            return tokenize(postfixExpr) + expression.newToken(.delimiter, ".") + expression.newToken(.identifier, identifier) +
                    tokenize(genericArgumentClause, node: expression)
        case let .argument(postfixExpr, identifier, argumentNames):
            let argumentTokens = argumentNames.isEmpty ? nil : argumentNames.flatMap {
                expression.newToken(.identifier, $0) + expression.newToken(.delimiter, ":")
            }.prefix(with: expression.newToken(.startOfScope, "(")).suffix(with: expression.newToken(.endOfScope, ")"))
            return tokenize(postfixExpr) + expression.newToken(.delimiter, ".") + expression.newToken(.identifier, identifier) + argumentTokens
        }
    }
    
    open func tokenize(_ expression: ForcedValueExpression) -> [Token] {
        return tokenize(expression.postfixExpression) + expression.newToken(.symbol, "!")
    }
    
    open func tokenize(_ expression: FunctionCallExpression) -> [Token] {
        let argumentTokens = expression.argumentClause.map { argumentClause in
            return argumentClause.map { tokenize($0, node: expression) }
                .joined(token: argumentClause.newToken(.delimiter, ", ", expression))
        }?.prefix(with: expression.newToken(.startOfScope, "(")).suffix(with: expression.newToken(.endOfScope, ")"))
        return
                tokenize(expression.postfixExpression) +
                argumentTokens +
                expression.trailingClosure.map { $0.newToken(.space, " ", expression) + tokenize($0, node: expression) }
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
        var textDesc = "\(tokenize(expression.postfixExpression)).init"
        if !expression.argumentNames.isEmpty {
            let argumentNamesDesc = expression.argumentNames.map({ "\($0):" }).joined()
            textDesc += "(\(argumentNamesDesc))"
        }
        return textDesc
    }
    
    open func tokenize(_ expression: KeyPathStringExpression) -> [Token] {
        return "#keyPath(\(tokenize(expression.expression)))"
    }
    
    open func tokenize(_ expression: LiteralExpression) -> [Token] {
        switch expression.kind {
        case .nil:
            return "nil"
        case .boolean(let bool):
            return bool ? "true" : "false"
        case let .integer(_, rawText):
            return rawText
        case let .floatingPoint(_, rawText):
            return rawText
        case let .staticString(_, rawText):
            return rawText
        case let .interpolatedString(_, rawText):
            return rawText
        case .array(let exprs):
            let arrayText = exprs.map(tokenize).joined(separator: ", ")
            return "[\(arrayText)]"
        case .dictionary(let entries):
            if entries.isEmpty {
                return "[:]"
            }
            let dictText = entries.map(tokenize).joined(separator: ", ")
            return "[\(dictText)]"
        }
    }
    
    open func tokenize(_ expression: OptionalChainingExpression) -> [Token] {
        return "\(tokenize(expression.postfixExpression))?"
    }
    
    open func tokenize(_ expression: ParenthesizedExpression) -> [Token] {
        return "(\(tokenize(expression.expression)))"
    }
    
    open func tokenize(_ expression: PostfixOperatorExpression) -> [Token] {
        return "\(tokenize(expression.postfixExpression))\(expression.postfixOperator)"
    }
    
    open func tokenize(_ expression: PostfixSelfExpression) -> [Token] {
        return "\(tokenize(expression.postfixExpression)).self"
    }
    
    open func tokenize(_ expression: PrefixOperatorExpression) -> [Token] {
        return "\(expression.prefixOperator)\(tokenize(expression.postfixExpression))"
    }
    
    open func tokenize(_ expression: SelectorExpression) -> [Token] {
        switch expression.kind {
        case .selector(let expr):
            return "#selector(\(tokenize(expr)))"
        case .getter(let expr):
            return "#selector(getter: \(tokenize(expr)))"
        case .setter(let expr):
            return "#selector(setter: \(tokenize(expr)))"
        case let .selfMember(identifier, argumentNames):
            var textDesc = identifier
            if !argumentNames.isEmpty {
                let argumentNamesDesc = argumentNames.map({ "\($0):" }).joined()
                textDesc += "(\(argumentNamesDesc))"
            }
            return "#selector(\(textDesc))"
        }
    }
    
    open func tokenize(_ expression: SelfExpression) -> [Token] {
        switch expression.kind {
        case .self:
            return "self"
        case .method(let name):
            return "self.\(name)"
        case .subscript(let args):
            let argsText = args.map(tokenize).joined(separator: ", ")
            return "self[\(argsText)]"
        case .initializer:
            return "self.init"
        }
    }
    
    open func tokenize(_ expression: SubscriptExpression) -> [Token] {
        let argsText = expression.arguments.map(tokenize).joined(separator: ", ")
        return "\(tokenize(expression.postfixExpression))[\(argsText)]"
    }
    
    open func tokenize(_ expression: SuperclassExpression) -> [Token] {
        switch expression.kind {
        case .method(let name):
            return "super.\(name)"
        case .subscript(let args):
            let argsText = args.map(tokenize).joined(separator: ", ")
            return "super[\(argsText)]"
        case .initializer:
            return "super.init"
        }
    }
    
    open func tokenize(_ expression: TernaryConditionalOperatorExpression) -> [Token] {
        let conditionExpr = tokenize(expression.conditionExpression)
        let trueExpr = tokenize(expression.trueExpression)
        let falseExpr = tokenize(expression.falseExpression)
        return "\(conditionExpr) ? \(trueExpr) : \(falseExpr)"
    }
    
    open func tokenize(_ expression: TryOperatorExpression) -> [Token] {
        let tryText: String
        let exprText: String
        switch expression.kind {
        case .try(let expr):
            tryText = "try"
            exprText = tokenize(expr)
        case .forced(let expr):
            tryText = "try!"
            exprText = tokenize(expr)
        case .optional(let expr):
            tryText = "try?"
            exprText = tokenize(expr)
        }
        return "\(tryText) \(exprText)"
    }
    
    open func tokenize(_ expression: TupleExpression) -> [Token] {
        if expression.elementList.isEmpty {
            return "()"
        }
        
        let listText: [String] = expression.elementList.map { element in
            var idText = ""
            if let id = element.identifier {
                idText = "\(id): "
            }
            return "\(idText)\(tokenize(element.expression))"
        }
        return "(\(listText.joined(separator: ", ")))"
    }
    
    open func tokenize(_ expression: TypeCastingOperatorExpression) -> [Token] {
        let exprText: String
        let operatorText: String
        let typeText: String
        switch expression.kind {
        case let .check(expr, type):
            exprText = tokenize(expr)
            operatorText = "is"
            typeText = tokenize(type, node: expression)
        case let .cast(expr, type):
            exprText = tokenize(expr)
            operatorText = "as"
            typeText = tokenize(type, node: expression)
        case let .conditionalCast(expr, type):
            exprText = tokenize(expr)
            operatorText = "as?"
            typeText = tokenize(type, node: expression)
        case let .forcedCast(expr, type):
            exprText = tokenize(expr)
            operatorText = "as!"
            typeText = tokenize(type, node: expression)
        }
        return "\(exprText) \(operatorText) \(typeText)"
    }
    
    open func tokenize(_ expression: WildcardExpression) -> [Token] {
        return "_"
    }
    
    // MARK: Utils
    
    open func tokenize(_ expression: DictionaryEntry) -> [Token] {
        return "\(tokenize(expression.key)): \(tokenize(expression.value))"
    }
    
    open func tokenize(_ arg: SubscriptArgument) -> [Token] {
        var identifierText = ""
        if let id = arg.identifier {
            identifierText = "\(id): "
        }
        return "\(identifierText)\(tokenize(arg.expression))"
    }
    
    // TODO: Delete generate methods
    open func generate(_ expression: Expression) -> String {
        return tokenize(expression).joinedValues()
    }

}


extension ClosureExpression.Signature: ASTTokenizable {}
extension ClosureExpression.Signature.CaptureItem: ASTTokenizable {}
extension ClosureExpression.Signature.CaptureItem.Specifier: ASTTokenizable {}
extension ClosureExpression.Signature.ParameterClause: ASTTokenizable {}
extension ClosureExpression.Signature.ParameterClause.Parameter: ASTTokenizable {}
extension FunctionCallExpression.Argument: ASTTokenizable {}
