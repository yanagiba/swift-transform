//
//  Generator+Statement.swift
//  Format
//
//  Created by Angel Garcia on 14/07/2017.
//

import AST

extension Generator {
    
    open func generate(_ statement: Statement) -> String {
        switch statement {
        case let decl as Declaration:
            return generate(decl)
        case let expr as Expression:
            return generate(expr)
        case let stmt as BreakStatement:
            return generate(stmt)
        case let stmt as CompilerControlStatement:
            return generate(stmt)
        case let stmt as ContinueStatement:
            return generate(stmt)
        case let stmt as DeferStatement:
            return generate(stmt)
        case let stmt as DoStatement:
            return generate(stmt)
        case let stmt as FallthroughStatement:
            return generate(stmt)
        case let stmt as ForInStatement:
            return generate(stmt)
        case let stmt as GuardStatement:
            return generate(stmt)
        case let stmt as IfStatement:
            return generate(stmt)
        case let stmt as LabeledStatement:
            return generate(stmt)
        case let stmt as RepeatWhileStatement:
            return generate(stmt)
        case let stmt as ReturnStatement:
            return generate(stmt)
        case let stmt as SwitchStatement:
            return generate(stmt)
        case let stmt as ThrowStatement:
            return generate(stmt)
        case let stmt as WhileStatement:
            return generate(stmt)
        default:
            return statement.textDescription
        }
    }
    
    open func generate(_ statement: BreakStatement) -> String {
        if let labelName = statement.labelName {
            return "break \(labelName)"
        }
        return "break"
    }
    
    open func generate(_ statement: CompilerControlStatement) -> String {
        switch statement.kind {
        case .if(let condition):
            return "#if\(condition)"
        case .elseif(let condition):
            return "#elseif\(condition)"
        case .else:
            return "#else"
        case .endif:
            return "#endif"
        case let .sourceLocation(fileName, lineNumber):
            if let fileName = fileName, let lineNumber = lineNumber {
                return "#sourceLocation(file: \"\(fileName)\", line: \(lineNumber))"
            }
            return "#sourceLocation()"
        }
    }
    
    open func generate(_ statement: ContinueStatement) -> String {
        if let labelName = statement.labelName {
            return "continue \(labelName)"
        }
        return "continue"
    }
    
    open func generate(_ statement: DeferStatement) -> String {
        return "defer \(generate(statement.codeBlock))"
    }
    
    open func generate(_ statement: DoStatement) -> String {
        return (["do \(generate(statement.codeBlock))"] +
            statement.catchClauses.map(generate)).joined(separator: " ")
    }
    
    open func generate(_ statement: DoStatement.CatchClause) -> String {
        var patternText = ""
        if let pattern = statement.pattern {
            patternText = " \(generate(pattern))"
        }
        var whereText = ""
        if let whereExpr = statement.whereExpression {
            whereText = " where \(generate(whereExpr))"
        }
        return "catch\(patternText)\(whereText) \(generate(statement.codeBlock))"
    }
    
    open func generate(_ statement: FallthroughStatement) -> String {
        return "fallthrough"
    }
    
    open func generate(_ statement: ForInStatement) -> String {
        var descr = "for"
        if statement.item.isCaseMatching {
            descr += " case"
        }
        descr += " \(generate(statement.item.matchingPattern)) in \(generate(statement.collection)) "
        if let whereClause = statement.item.whereClause {
            descr += "where \(generate(whereClause)) "
        }
        descr += generate(statement.codeBlock)
        return descr
    }
    
    open func generate(_ statement: GuardStatement ) -> String {
        return "guard \(generate(statement.conditionList)) else \(generate(statement.codeBlock))"
    }
    
    open func generate(_ statement: IfStatement) -> String {
        var elseText = ""
        if let elseClause = statement.elseClause {
            elseText = " \(generate(elseClause))"
        }
        return "if \(generate(statement.conditionList)) \(generate(statement.codeBlock))\(elseText)"
    }
    
    open func generate(_ statement: IfStatement.ElseClause ) -> String {
        switch statement {
        case .else(let codeBlock):
            return "else \(generate(codeBlock))"
        case .elseif(let ifStmt):
            return "else \(generate(ifStmt))"
        }
    }
    
    open func generate(_ statement: LabeledStatement) -> String {
        return "\(statement.labelName): \(generate(statement))"
    }
    
    open func generate(_ statement: RepeatWhileStatement) -> String {
        return "repeat \(generate(statement.codeBlock)) while \(generate(statement.conditionExpression))"
    }
    
    open func generate(_ statement: ReturnStatement) -> String {
        if let expression = statement.expression {
            return "return \(generate(expression))"
        }
        return "return"
    }
    
    open func generate(_ statement: SwitchStatement) -> String {
        var casesDescr = "{}"
        if !statement.cases.isEmpty {
            let casesText = statement.cases.map(generate).joined(separator: "\n")
            casesDescr = "{\n\(casesText)\n}"
        }
        return "switch \(generate(statement.expression)) \(casesDescr)"
    }
    
    open func generate(_ statement: SwitchStatement.Case.Item) -> String {
        var whereText = ""
        if let whereExpr = statement.whereExpression {
            whereText = " where \(generate(whereExpr))"
        }
        return "\(generate(statement.pattern))\(whereText)"
    }
    
    open func generate(_ statement: SwitchStatement.Case) -> String {
        switch statement {
        case let .case(itemList, stmts):
            let itemListText = itemList.map(generate).joined(separator: ", ")
            return "case \(itemListText):\n\(generate(stmts))"
        case .default(let stmts):
            return "default:\n\(generate(stmts))"
        }
    }
    
    open func generate(_ statement: ThrowStatement) -> String {
        return "throw \(generate(statement.expression))"
    }
    
    open func generate(_ statement: WhileStatement) -> String {
        return "while \(generate(statement.conditionList)) \(generate(statement.codeBlock))"
    }
    
    
    // MARK: Utils
    
    open func generate(_ statements: [Statement]) -> String {
        return statements.map(generate).joined(separator: "\n")
    }
    
    open func generate(_ conditions: ConditionList) -> String {
        return conditions.map(generate).joined(separator: ", ")
    }
    
    open func generate(_ condition: Condition) -> String {
        switch condition {
        case .expression(let expr):
            return generate(expr)
        case .availability(let availabilityCondition):
            return generate(availabilityCondition)
        case let .case(pattern, expr):
            return "case \(pattern) = \(expr)"
        case let .let(pattern, expr):
            return "let \(pattern) = \(expr)"
        case let .var(pattern, expr):
            return "var \(pattern) = \(expr)"
            
        }
    }
    
    open func generate(_ argument: AvailabilityCondition.Argument) -> String {
        switch argument {
        case let .major(platformName, majorVersion):
            return "\(platformName) \(majorVersion)"
        case let .minor(platformName, majorVersion, minorVersion):
            return "\(platformName) \(majorVersion).\(minorVersion)"
        case let .patch(platformName, majorVersion, minorVersion, patchVersion):
            return "\(platformName) \(majorVersion).\(minorVersion).\(patchVersion)"
        case .all:
            return "*"
        }
    }
    
    open func generate(_ condition:  AvailabilityCondition) -> String {
        let argumentsText = condition.arguments.map(generate).joined(separator: ", ")
        return "#available(\(argumentsText))"
    }
    
    
}
