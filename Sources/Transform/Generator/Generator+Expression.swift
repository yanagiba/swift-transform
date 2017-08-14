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

extension Generator {
  open func generate(_ expression: Expression) -> String {
    switch expression {
    case let expr as AssignmentOperatorExpression:
      return generate(expr)
    case let expr as BinaryOperatorExpression:
      return generate(expr)
    case let expr as ClosureExpression:
      return generate(expr)
    case let expr as ExplicitMemberExpression:
      return generate(expr)
    case let expr as ForcedValueExpression:
      return generate(expr)
    case let expr as FunctionCallExpression:
      return generate(expr)
    case let expr as IdentifierExpression:
      return generate(expr)
    case let expr as ImplicitMemberExpression:
      return generate(expr)
    case let expr as InOutExpression:
      return generate(expr)
    case let expr as InitializerExpression:
      return generate(expr)
    case let expr as KeyPathStringExpression:
      return generate(expr)
    case let expr as LiteralExpression:
      return generate(expr)
    case let expr as OptionalChainingExpression:
      return generate(expr)
    case let expr as ParenthesizedExpression:
      return generate(expr)
    case let expr as PostfixOperatorExpression:
      return generate(expr)
    case let expr as PostfixSelfExpression:
      return generate(expr)
    case let expr as PrefixOperatorExpression:
      return generate(expr)
    case let expr as SelectorExpression:
      return generate(expr)
    case let expr as SelfExpression:
      return generate(expr)
    case let expr as SequenceExpression:
      return generate(expr)
    case let expr as SubscriptExpression:
      return generate(expr)
    case let expr as SuperclassExpression:
      return generate(expr)
    case let expr as TernaryConditionalOperatorExpression:
      return generate(expr)
    case let expr as TryOperatorExpression:
      return generate(expr)
    case let expr as TupleExpression:
      return generate(expr)
    case let expr as TypeCastingOperatorExpression:
      return generate(expr)
    case let expr as WildcardExpression:
      return generate(expr)
    default:
      return expression.textDescription
    }
  }

  open func generate(_ expression: AssignmentOperatorExpression) -> String {
    return "\(generate(expression.leftExpression)) = \(generate(expression.rightExpression))"
  }

  open func generate(_ expression: BinaryOperatorExpression) -> String {
    return "\(generate(expression.leftExpression)) \(expression.binaryOperator) \(generate(expression.rightExpression))"
  }

  open func generate(_ expression: ClosureExpression) -> String {
    var signatureText = ""
    var stmtsText = ""

    if let signature = expression.signature {
      signatureText = " \(generate(signature)) in"
      if expression.statements == nil {
        stmtsText = " "
      }
    }

    if let stmts = expression.statements {
      if expression.signature == nil && stmts.count == 1 {
        stmtsText = " \(generate(stmts)) "
      } else {
        stmtsText = "\n\(generate(stmts).indent)\n"
      }
    }

    return "{\(signatureText)\(stmtsText)}"
  }

  open func generate(_ expression: ClosureExpression.Signature.CaptureItem.Specifier) -> String {
    return expression.rawValue
  }

  open func generate(_ expression: ClosureExpression.Signature.CaptureItem) -> String {
    let exprText = generate(expression.expression)
    guard let specifier = expression.specifier else {
      return exprText
    }
    return "\(generate(specifier)) \(exprText)"
  }

  open func generate(_ expression: ClosureExpression.Signature.ParameterClause.Parameter) -> String {
    var paramText = expression.name
    if let typeAnnotation = expression.typeAnnotation {
      paramText += generate(typeAnnotation, node: WildcardExpression())
            // TODO: guess this method will be removed entirely, so I just put a dummy node here ;)
      if expression.isVarargs {
        paramText += "..."
      }
    }
    return paramText
  }

  open func generate(_ expression: ClosureExpression.Signature.ParameterClause) -> String {
    switch expression {
    case .parameterList(let params):
      return "(\(params.map(generate).joined(separator: ", ")))"
    case .identifierList(let idList):
      return idList.textDescription
    }
  }

  open func generate(_ expression: ClosureExpression.Signature) -> String {
    var signatureText = [String]()
    if let captureList = expression.captureList {
      signatureText.append("[\(captureList.map(generate).joined(separator: ", "))]")
    }
    if let parameterClause = expression.parameterClause {
      signatureText.append(generate(parameterClause))
    }
    if expression.canThrow {
      signatureText.append("throws")
    }
    if let funcResult = expression.functionResult {
      signatureText.append(generate(funcResult))
    }
    return signatureText.joined(separator: " ")
  }

  open func generate(_ expression: ExplicitMemberExpression) -> String {
    switch expression.kind {
    case let .tuple(postfixExpr, index):
      return "\(generate(postfixExpr)).\(index)"
    case let .namedType(postfixExpr, identifier):
      return "\(generate(postfixExpr)).\(identifier)"
    case let .generic(postfixExpr, identifier, genericArgumentClause):
      return "\(generate(postfixExpr)).\(identifier)" +
      "\(generate(genericArgumentClause, node: expression))"
    case let .argument(postfixExpr, identifier, argumentNames):
      var textDesc = "\(generate(postfixExpr)).\(identifier)"
      if !argumentNames.isEmpty {
        let argumentNamesDesc = argumentNames.map({ "\($0):" }).joined()
        textDesc += "(\(argumentNamesDesc))"
      }
      return textDesc
    }
  }

  open func generate(_ expression: ForcedValueExpression) -> String {
    return "\(generate(expression.postfixExpression))!"
  }

  open func generate(_ expression: FunctionCallExpression) -> String {
    var parameterText = ""
    if let argumentClause = expression.argumentClause {
      let argumentsText = argumentClause.map(generate).joined(separator: ", ")
      parameterText = "(\(argumentsText))"
    }
    var trailingText = ""
    if let trailingClosure = expression.trailingClosure {
      trailingText = " \(generate(trailingClosure))"
    }
    return "\(generate(expression.postfixExpression))\(parameterText)\(trailingText)"
  }

  open func generate(_ expression: FunctionCallExpression.Argument) -> String {
    switch expression {
    case .expression(let expr):
      return generate(expr)
    case let .namedExpression(identifier, expr):
      return "\(identifier): \(generate(expr))"
    case .memoryReference(let expr):
      return "&\(generate(expr))"
    case let .namedMemoryReference(name, expr):
      return "\(name): &\(generate(expr))"
    case .operator(let op):
      return op
    case let .namedOperator(identifier, op):
      return "\(identifier): \(op)"
    }
  }

  open func generate(_ expression: IdentifierExpression) -> String {
    switch expression.kind {
    case let .identifier(id, generic):
      return "\(id)\(generic.map({ generate($0, node: expression) }) ?? "")"
    case let .implicitParameterName(i, generic):
      return "$\(i)\(generic.map({ generate($0, node: expression) }) ?? "")"
    }
  }

  open func generate(_ expression: ImplicitMemberExpression) -> String {
    return ".\(expression.identifier)"
  }

  open func generate(_ expression: InOutExpression) -> String {
    return "&\(expression.identifier)"
  }

  open func generate(_ expression: InitializerExpression) -> String {
    var textDesc = "\(generate(expression.postfixExpression)).init"
    if !expression.argumentNames.isEmpty {
      let argumentNamesDesc = expression.argumentNames.map({ "\($0):" }).joined()
      textDesc += "(\(argumentNamesDesc))"
    }
    return textDesc
  }

  open func generate(_ expression: KeyPathStringExpression) -> String {
    return "#keyPath(\(generate(expression.expression)))"
  }

  open func generate(_ expression: LiteralExpression) -> String {
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
      let arrayText = exprs.map(generate).joined(separator: ", ")
      return "[\(arrayText)]"
    case .dictionary(let entries):
      if entries.isEmpty {
        return "[:]"
      }
      let dictText = entries.map(generate).joined(separator: ", ")
      return "[\(dictText)]"
    }
  }

  open func generate(_ expression: OptionalChainingExpression) -> String {
    return "\(generate(expression.postfixExpression))?"
  }

  open func generate(_ expression: ParenthesizedExpression) -> String {
    return "(\(generate(expression.expression)))"
  }

  open func generate(_ expression: PostfixOperatorExpression) -> String {
    return "\(generate(expression.postfixExpression))\(expression.postfixOperator)"
  }

  open func generate(_ expression: PostfixSelfExpression) -> String {
    return "\(generate(expression.postfixExpression)).self"
  }

  open func generate(_ expression: PrefixOperatorExpression) -> String {
    return "\(expression.prefixOperator)\(generate(expression.postfixExpression))"
  }

  open func generate(_ expression: SelectorExpression) -> String {
    switch expression.kind {
    case .selector(let expr):
      return "#selector(\(generate(expr)))"
    case .getter(let expr):
      return "#selector(getter: \(generate(expr)))"
    case .setter(let expr):
      return "#selector(setter: \(generate(expr)))"
    case let .selfMember(identifier, argumentNames):
      var textDesc = identifier
      if !argumentNames.isEmpty {
        let argumentNamesDesc = argumentNames.map({ "\($0):" }).joined()
        textDesc += "(\(argumentNamesDesc))"
      }
      return "#selector(\(textDesc))"
    }
  }

  open func generate(_ expression: SelfExpression) -> String {
    switch expression.kind {
    case .self:
      return "self"
    case .method(let name):
      return "self.\(name)"
    case .subscript(let args):
      let argsText = args.map(generate).joined(separator: ", ")
      return "self[\(argsText)]"
    case .initializer:
      return "self.init"
    }
  }

  open func generate(_ expression: SequenceExpression) -> String {
    return expression.elements.map({ elem -> String in
      switch elem {
      case .expression(let expr):
        return generate(expr)
      case .assignmentOperator:
        return "="
      case .binaryOperator(let op):
        return op
      case .ternaryConditionalOperator(let expr):
        return "? \(generate(expr)) :"
      case .typeCheck(let type):
        return "is \(generate(type, node: expression))"
      case .typeCast(let type):
        return "as \(generate(type, node: expression))"
      case .typeConditionalCast(let type):
        return "as? \(generate(type, node: expression))"
      case .typeForcedCast(let type):
        return "as! \(generate(type, node: expression))"
      }
    }).joined(separator: " ")
  }

  open func generate(_ expression: SubscriptExpression) -> String {
    let argsText = expression.arguments.map(generate).joined(separator: ", ")
    return "\(generate(expression.postfixExpression))[\(argsText)]"
  }

  open func generate(_ expression: SuperclassExpression) -> String {
    switch expression.kind {
    case .method(let name):
      return "super.\(name)"
    case .subscript(let args):
      let argsText = args.map(generate).joined(separator: ", ")
      return "super[\(argsText)]"
    case .initializer:
      return "super.init"
    }
  }

  open func generate(_ expression: TernaryConditionalOperatorExpression) -> String {
    let conditionExpr = generate(expression.conditionExpression)
    let trueExpr = generate(expression.trueExpression)
    let falseExpr = generate(expression.falseExpression)
    return "\(conditionExpr) ? \(trueExpr) : \(falseExpr)"
  }

  open func generate(_ expression: TryOperatorExpression) -> String {
    let tryText: String
    let exprText: String
    switch expression.kind {
    case .try(let expr):
      tryText = "try"
      exprText = generate(expr)
    case .forced(let expr):
      tryText = "try!"
      exprText = generate(expr)
    case .optional(let expr):
      tryText = "try?"
      exprText = generate(expr)
    }
    return "\(tryText) \(exprText)"
  }

  open func generate(_ expression: TupleExpression) -> String {
    if expression.elementList.isEmpty {
      return "()"
    }

    let listText: [String] = expression.elementList.map { element in
      var idText = ""
      if let id = element.identifier {
        idText = "\(id): "
      }
      return "\(idText)\(generate(element.expression))"
    }
    return "(\(listText.joined(separator: ", ")))"
  }

  open func generate(_ expression: TypeCastingOperatorExpression) -> String {
    let exprText: String
    let operatorText: String
    let typeText: String
    switch expression.kind {
    case let .check(expr, type):
      exprText = generate(expr)
      operatorText = "is"
      typeText = generate(type, node: expression)
    case let .cast(expr, type):
      exprText = generate(expr)
      operatorText = "as"
      typeText = generate(type, node: expression)
    case let .conditionalCast(expr, type):
      exprText = generate(expr)
      operatorText = "as?"
      typeText = generate(type, node: expression)
    case let .forcedCast(expr, type):
      exprText = generate(expr)
      operatorText = "as!"
      typeText = generate(type, node: expression)
    }
    return "\(exprText) \(operatorText) \(typeText)"
  }

  open func generate(_ expression: WildcardExpression) -> String {
    return "_"
  }

  // MARK: Utils

  open func generate(_ expression: DictionaryEntry) -> String {
    return "\(generate(expression.key)): \(generate(expression.value))"
  }

  open func generate(_ arg: SubscriptArgument) -> String {
    var identifierText = ""
    if let id = arg.identifier {
      identifierText = "\(id): "
    }
    return "\(identifierText)\(generate(arg.expression))"
  }
}
