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
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: BinaryOperatorExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: ClosureExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: ExplicitMemberExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: ForcedValueExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: FunctionCallExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: IdentifierExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: ImplicitMemberExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: InOutExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: InitializerExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: KeyPathStringExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: LiteralExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: OptionalChainingExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: ParenthesizedExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: PostfixOperatorExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: PostfixSelfExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: PrefixOperatorExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: SelectorExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: SelfExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: SequenceExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: SubscriptExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: SuperclassExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: TernaryConditionalOperatorExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: TryOperatorExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: TupleExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: TypeCastingOperatorExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ expression: WildcardExpression) -> String {
    let tokens = _tokenizer.tokenize(expression)
    return _tokenJoiner.join(tokens: tokens)
  }
}
