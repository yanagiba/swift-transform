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

open class Generator {
  let _options: [String: Any]?
  let _tokenizer: Tokenizer
  let _tokenJoiner: TokenJoiner

  public init(
    options: [String: Any]? = nil,
    tokenizer: Tokenizer = Tokenizer(),
    tokenJoiner: TokenJoiner = TokenJoiner())
  {
    _options = options
    _tokenizer = tokenizer
    _tokenJoiner = tokenJoiner
  }

  open func generate(_ topLevelDeclaration: TopLevelDeclaration) -> String {
    let tokens = _tokenizer.tokenize(topLevelDeclaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ codeBlock: CodeBlock) -> String {
    let tokens = _tokenizer.tokenize(codeBlock)
    return _tokenJoiner.join(tokens: tokens)
  }

  // MARK: Statements

  open func generate(_ statement: Statement) -> String { // swift-lint:suppress(high_cyclomatic_complexity)
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
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ statement: CompilerControlStatement) -> String {
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ statement: ContinueStatement) -> String {
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ statement: DeferStatement) -> String {
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ statement: DoStatement) -> String {
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ statement: FallthroughStatement) -> String {
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ statement: ForInStatement) -> String {
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ statement: GuardStatement) -> String {
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ statement: IfStatement) -> String {
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ statement: LabeledStatement) -> String {
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ statement: RepeatWhileStatement) -> String {
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ statement: ReturnStatement) -> String {
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ statement: SwitchStatement) -> String {
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ statement: ThrowStatement) -> String {
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ statement: WhileStatement) -> String {
    let tokens = _tokenizer.tokenize(statement)
    return _tokenJoiner.join(tokens: tokens)
  }

  // MARK: Declarations

  open func generate(_ declaration: Declaration) -> String { // swift-lint:suppress(high_cyclomatic_complexity)
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

  open func generate(_ declaration: ClassDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ declaration: ConstantDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ declaration: DeinitializerDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ declaration: EnumDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ declaration: ExtensionDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ declaration: FunctionDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ declaration: ImportDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ declaration: InitializerDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ declaration: OperatorDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ declaration: PrecedenceGroupDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ declaration: ProtocolDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ declaration: StructDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ declaration: SubscriptDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ declaration: TypealiasDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ declaration: VariableDeclaration) -> String {
    let tokens = _tokenizer.tokenize(declaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  // MARK: Statements

  open func generate(_ expression: Expression) -> String { /*
    swift-lint:suppress(high_cyclomatic_complexity, high_ncss) */
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
