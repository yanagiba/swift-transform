//
//  Generator+Expression.swift
//  Format
//
//  Created by Angel Garcia on 14/07/2017.
//

import AST

extension Generator {
    
    open func generate(_ expression: Expression) -> String {
        // TODO: Implement all to prevent recursive calls
        switch expression {
            //        case let expr as AssignmentOperatorExpression:
            //            return generate(expr)
            //        case let expr as BinaryOperatorExpression:
            //            return generate(expr)
            //        case let expr as ClosureExpression:
            //            return generate(expr)
            //        case let expr as ExplicitMemberExpression:
            //            return generate(expr)
            //        case let expr as ForcedValueExpression:
            //            return generate(expr)
            //        case let expr as FunctionCallExpression:
            //            return generate(expr)
            //        case let expr as IdentifierExpression:
            //            return generate(expr)
            //        case let expr as ImplicitMemberExpression:
            //            return generate(expr)
            //        case let expr as InOutExpression:
            //            return generate(expr)
            //        case let expr as InitializerExpression:
            //            return generate(expr)
            //        case let expr as KeyPathStringExpression:
            //            return generate(expr)
            //        case let expr as LiteralExpression:
            //            return generate(expr)
            //        case let expr as OptionalChainingExpression:
            //            return generate(expr)
            //        case let expr as ParenthesizedExpression:
            //            return generate(expr)
            //        case let expr as PostfixOperatorExpression:
            //            return generate(expr)
            //        case let expr as PostfixSelfExpression:
            //            return generate(expr)
            //        case let expr as PrefixOperatorExpression:
            //            return generate(expr)
            //        case let expr as SelectorExpression:
            //            return generate(expr)
            //        case let expr as SelfExpression:
            //            return generate(expr)
            //        case let expr as SubscriptExpression:
            //            return generate(expr)
            //        case let expr as SuperclassExpression:
            //            return generate(expr)
            //        case let expr as TernaryConditionalOperatorExpression:
            //            return generate(expr)
            //        case let expr as TryOperatorExpression:
            //            return generate(expr)
            //        case let expr as TupleExpression:
            //            return generate(expr)
            //        case let expr as TypeCastingOperatorExpression:
            //            return generate(expr)
            //        case let expr as WildcardExpression:
        //            return generate(expr)
        default:
            return expression.textDescription
        }
    }
}
