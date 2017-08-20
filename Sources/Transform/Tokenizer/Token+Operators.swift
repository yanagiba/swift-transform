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

public func +(left: Token?, right: Token?) -> [Token] {
    var tokens: [Token] = []
    if let left = left {
        tokens.append(left)
    }
    if let right = right {
        tokens.append(right)
    }
    return tokens
}

public func +(left: [Token]?, right: Token?) -> [Token] {
    var tokens = left ?? []
    if let right = right {
        tokens.append(right)
    }
    return tokens
}

public func +(left: [Token]?, right: [Token]?) -> [Token] {
    var tokens: [Token] = []
    if let left = left {
        tokens.append(contentsOf: left)
    }
    if let right = right {
        tokens.append(contentsOf: right)
    }
    return tokens
}

public func +(left: Token?, right: [Token]?) -> [Token] {
    var tokens: [Token] = []
    if let left = left {
        tokens.append(left)
    }
    if let right = right {
        tokens.append(contentsOf: right)
    }
    return tokens
}

extension Collection where Iterator.Element == [Token] {
    public func joined(token: Token) -> [Token] {
        return Array(self.filter { !$0.isEmpty }.flatMap { $0 + token }.dropLast())
    }

    public func joined() -> [Token] {
        return self.flatMap { $0 }
    }
}

extension Collection where Iterator.Element == Token {
    public func joinedValues() -> String {
        return self.map { $0.value }.joined()
    }
}

extension Array where Iterator.Element == Token {
    public func prefix(with token: Token) -> [Token] {
        guard !self.isEmpty else { return self }
        return token + self
    }

    public func suffix(with token: Token) -> [Token] {
        guard !self.isEmpty else { return self }
        return self + token
    }
}
