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
    // TODO: Remove node parameter because statement is a node
    open func tokenize(_ statement: Statement, node: ASTNode) -> [Token] {
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
            return [node.newToken(.identifier, statement.textDescription)]
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
        let whereTokens = statement.whereExpression.map { tokenize($0, node: node) } ?? []
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
            tokenize(statement.statement, node: statement)
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
                statement.cases.map { tokenize($0, node: statement) }.joined(token: statement.newToken(.linebreak, "\n")),
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
                itemList.map { tokenize($0, node: node) }.joined(token: statement.newToken(.delimiter, ", ", node)) +
                statement.newToken(.delimiter, ":", node) +
                indent(
                    statement.newToken(.linebreak, "\n", node) +
                    tokenize(stmts, node: node))

        case .default(let stmts):
            return
                statement.newToken(.keyword, "default", node) +
                statement.newToken(.delimiter, ":", node) +
                indent(
                    statement.newToken(.linebreak, "\n", node) +
                    tokenize(stmts, node: node))
        }
    }

    open func tokenize(_ statement: SwitchStatement.Case.Item, node: ASTNode) -> [Token] {
        return [
            tokenize(statement.pattern, node: node),
            statement.whereExpression.map { _ in [statement.newToken(.keyword, "where", node)] } ?? [],
            statement.whereExpression.map { tokenize($0, node: node) } ?? []
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
        return statements.map { tokenize($0, node: node) }.joined(token: node.newToken(.linebreak, "\n"))
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
            condition.arguments.map { tokenize($0, node: node) }.joined(token: condition.newToken(.delimiter, ", ", node)) +
            condition.newToken(.endOfScope, ")", node)
    }

    open func tokenize(_ argument: AvailabilityCondition.Argument, node: ASTNode) -> [Token] {
        return [argument.newToken(.identifier, argument.textDescription, node)]
    }


    // TODO: Delete temporal generates
    open func generate(_ statement: Statement, node: ASTNode) -> String {
        return tokenize(statement, node: node).joinedValues()
    }
    open func generate(_ statements: [Statement], node: ASTNode) -> String {
        return tokenize(statements, node: node).joinedValues()
    }
    open func generate(_ statement: CompilerControlStatement) -> String {
       return tokenize(statement).joinedValues()
    }


}

extension DoStatement.CatchClause: ASTTokenizable {}
extension IfStatement.ElseClause: ASTTokenizable {}
extension SwitchStatement.Case: ASTTokenizable {}
extension SwitchStatement.Case.Item: ASTTokenizable {}
extension Condition: ASTTokenizable {}
extension AvailabilityCondition: ASTTokenizable {}
extension AvailabilityCondition.Argument: ASTTokenizable {}
