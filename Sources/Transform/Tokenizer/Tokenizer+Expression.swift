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
                stmtsTokens = indent(
                    expression.newToken(.linebreak, "\n") +
                        tokenize(stmts, node: expression)
                    ) + expression.newToken(.linebreak, "\n")
            }
        }

        return [expression.newToken(.startOfScope, "{")] +
            signatureTokens +
            stmtsTokens +
            expression.newToken(.endOfScope, "}")        
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
            trailingTokens = trailingClosure.newToken(.space, " ", expression) + tokenize(trailingClosure, node: expression)
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
                exprs.map(tokenize).joined(token: expression.newToken(.delimiter, ", ")) +
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
            return expression.newToken(.keyword, "#selector") +
                expression.newToken(.startOfScope, "(") +
                expression.newToken(.keyword, "getter") +
                expression.newToken(.delimiter, ": ") +
                tokenize(expr) +
                expression.newToken(.endOfScope, ")")
        case .setter(let expr):
            return expression.newToken(.keyword, "#selector") +
                expression.newToken(.startOfScope, "(") +
                expression.newToken(.keyword, "setter") +
                expression.newToken(.delimiter, ": ") +
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

    open func tokenize(_ expression: SubscriptExpression) -> [Token] {
        return tokenize(expression.postfixExpression) +
                expression.newToken(.startOfScope, "[") +
            expression.arguments.map { tokenize($0, node: expression) }.joined(token: expression.newToken(.delimiter, ", ")) +
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
            tokenize(expression.falseExpression)
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
            typeTokens
        ].joined(token: expression.newToken(.space, " "))
    }

    open func tokenize(_ expression: WildcardExpression) -> [Token] {
        return [expression.newToken(.symbol, "_")]
    }

    // MARK: Utils

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
extension TupleExpression.Element: ASTTokenizable {}
extension DictionaryEntry: ASTTokenizable {}
extension SubscriptArgument: ASTTokenizable {}
