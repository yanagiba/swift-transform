//
//  Generator+Statement.swift
//  Format
//
//  Created by Angel Garcia on 14/07/2017.
//

import AST

extension Generator {
    
    open func generate(_ statement: Statement) -> String {
        // TODO: Implement all to prevent recursive calls
        switch statement {
        case let decl as Declaration:
            return generate(decl)
        case let expr as Expression:
            return generate(expr)
            //        case let stmt as BreakStatement:
            //            return generate(stmt)
            //        case let stmt as CompilerControlStatement:
            //            return generate(stmt)
            //        case let stmt as ContinueStatement:
            //            return generate(stmt)
            //        case let stmt as DeferStatement:
            //            return generate(stmt)
            //        case let stmt as DoStatement:
            //            return generate(stmt)
            //        case let stmt as FallthroughStatement:
            //            return generate(stmt)
            //        case let stmt as ForInStatement:
            //            return generate(stmt)
            //        case let stmt as GuardStatement:
            //            return generate(stmt)
            //        case let stmt as IfStatement:
            //            return generate(stmt)
            //        case let stmt as LabeledStatement:
            //            return generate(stmt)
            //        case let stmt as RepeatWhileStatement:
            //            return generate(stmt)
            //        case let stmt as ReturnStatement:
            //            return generate(stmt)
            //        case let stmt as SwitchStatement:
            //            return generate(stmt)
            //        case let stmt as ThrowStatement:
            //            return generate(stmt)
            //        case let stmt as WhileStatement:
        //            return generate(stmt)
        default:
            return statement.textDescription
        }
    }
    
}
