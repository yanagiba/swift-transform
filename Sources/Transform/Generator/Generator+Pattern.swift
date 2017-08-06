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
  open func generate(_ pattern: Pattern, node: ASTNode) -> String {
    switch pattern {
    case let pattern as EnumCasePattern:
      return generate(pattern, node: node)
    case let pattern as ExpressionPattern:
      return generate(pattern, node: node)
    case let pattern as IdentifierPattern:
      return generate(pattern, node: node)
    case let pattern as OptionalPattern:
      return generate(pattern, node: node)
    case let pattern as TuplePattern:
      return generate(pattern, node: node)
    case let pattern as TypeCastingPattern:
      return generate(pattern, node: node)
    case let pattern as ValueBindingPattern:
      return generate(pattern, node: node)
    case let pattern as WildcardPattern:
      return generate(pattern, node: node)
    default:
      return pattern.textDescription
    }
  }

  open func generate(_ pattern: EnumCasePattern, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(pattern, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ pattern: ExpressionPattern, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(pattern, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ pattern: IdentifierPattern, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(pattern, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ pattern: OptionalPattern, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(pattern, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ pattern: TuplePattern, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(pattern, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ pattern: TypeCastingPattern, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(pattern, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ pattern: ValueBindingPattern, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(pattern, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ pattern: WildcardPattern, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(pattern, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }
}
