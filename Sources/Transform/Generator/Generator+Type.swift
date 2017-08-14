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
  open func generate(_ type: Type, node: ASTNode) -> String {
    switch type {
    case let type as AnyType:
      return generate(type, node: node)
    case let type as ArrayType:
      return generate(type, node: node)
    case let type as DictionaryType:
      return generate(type, node: node)
    case let type as FunctionType:
      return generate(type, node: node)
    case let type as ImplicitlyUnwrappedOptionalType:
      return generate(type, node: node)
    case let type as MetatypeType:
      return generate(type, node: node)
    case let type as OptionalType:
      return generate(type, node: node)
    case let type as ProtocolCompositionType:
      return generate(type, node: node)
    case let type as SelfType:
      return generate(type, node: node)
    case let type as TupleType:
      return generate(type, node: node)
    case let type as TypeIdentifier:
      return generate(type, node: node)
    default:
      return type.textDescription
    }
  }

  open func generate(_ type: AnyType, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(type, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ type: ArrayType, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(type, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ type: DictionaryType, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(type, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ type: FunctionType, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(type, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ type: ImplicitlyUnwrappedOptionalType, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(type, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ type: MetatypeType, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(type, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ type: OptionalType, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(type, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ type: ProtocolCompositionType, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(type, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ type: SelfType, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(type, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ type: TupleType, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(type, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ type: TupleType.Element, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(type, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ type: TypeAnnotation, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(type, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ type: TypeIdentifier, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(type, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ type: TypeInheritanceClause, node: ASTNode) -> String {
    let tokens = _tokenizer.tokenize(type, node: node)
    return _tokenJoiner.join(tokens: tokens)
  }
}
