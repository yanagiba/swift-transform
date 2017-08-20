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
  open func generate(_ declaration: Declaration) -> String {
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

  open func generate(_ topLevelDeclaration: TopLevelDeclaration) -> String {
    let tokens = _tokenizer.tokenize(topLevelDeclaration)
    return _tokenJoiner.join(tokens: tokens)
  }

  open func generate(_ codeBlock: CodeBlock) -> String {
    let tokens = _tokenizer.tokenize(codeBlock)
    return _tokenJoiner.join(tokens: tokens)
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
}
