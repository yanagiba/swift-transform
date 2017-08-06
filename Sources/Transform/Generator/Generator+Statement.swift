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

  open func generate(_ statements: [Statement]) -> String {
    // let tokens = statements.map { _tokenizer.tokenize($0) }.joined(token: node.newToken(.linebreak, "\n"))
    // return _tokenJoiner.join(tokens: tokens)
    return statements.map(generate).joined(separator: "\n")
  }
}
