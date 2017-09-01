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

// MARK: - ASTNode

extension ASTNode: ASTTokenizable {}

// MARK: - Attribute

extension Attribute: ASTTokenizable {}
extension Attribute.ArgumentClause: ASTTokenizable {}
extension Attribute.ArgumentClause.BalancedToken: ASTTokenizable {}

// MARK: - Declaration

extension ProtocolDeclaration.InitializerMember: ASTTokenizable {}
extension GetterSetterBlock.GetterClause: ASTTokenizable {}
extension GetterSetterBlock.SetterClause: ASTTokenizable {}
extension GetterSetterBlock: ASTTokenizable {}
extension GetterSetterKeywordBlock: ASTTokenizable {}
extension GetterSetterKeywordBlock.SetterKeywordClause: ASTTokenizable {}
extension GetterSetterKeywordBlock.GetterKeywordClause: ASTTokenizable {}
extension WillSetDidSetBlock.WillSetClause: ASTTokenizable {}
extension WillSetDidSetBlock.DidSetClause: ASTTokenizable {}
extension WillSetDidSetBlock: ASTTokenizable {}
extension PatternInitializer: ASTTokenizable {}
extension EnumDeclaration.UnionStyleEnumCase: ASTTokenizable {}
extension EnumDeclaration.UnionStyleEnumCase.Case: ASTTokenizable {}
extension EnumDeclaration.RawValueStyleEnumCase: ASTTokenizable {}
extension EnumDeclaration.RawValueStyleEnumCase.Case: ASTTokenizable {}
extension FunctionSignature.Parameter: ASTTokenizable {}
extension FunctionResult: ASTTokenizable {}
extension InitializerDeclaration.InitKind: ASTTokenizable {}
extension PrecedenceGroupDeclaration.Attribute: ASTTokenizable {}
extension DeclarationModifier: ASTTokenizable {}
extension AccessLevelModifier: ASTTokenizable {}
extension MutationModifier: ASTTokenizable {}
extension FunctionSignature: ASTTokenizable {}
extension ProtocolDeclaration.MethodMember: ASTTokenizable {}
extension ProtocolDeclaration.PropertyMember: ASTTokenizable {}
extension ProtocolDeclaration.SubscriptMember: ASTTokenizable {}
extension ProtocolDeclaration.AssociativityTypeMember: ASTTokenizable {}
extension VariableDeclaration.Body: ASTTokenizable {}

// MARK: - Expression

extension ClosureExpression.Signature: ASTTokenizable {}
extension ClosureExpression.Signature.CaptureItem: ASTTokenizable {}
extension ClosureExpression.Signature.CaptureItem.Specifier: ASTTokenizable {}
extension ClosureExpression.Signature.ParameterClause: ASTTokenizable {}
extension ClosureExpression.Signature.ParameterClause.Parameter: ASTTokenizable {}
extension FunctionCallExpression.Argument: ASTTokenizable {}
extension TupleExpression.Element: ASTTokenizable {}
extension DictionaryEntry: ASTTokenizable {}
extension SubscriptArgument: ASTTokenizable {}

// MARK: -  Generic

extension GenericParameterClause: ASTTokenizable {}
extension GenericParameterClause.GenericParameter: ASTTokenizable {}
extension GenericWhereClause: ASTTokenizable {}
extension GenericWhereClause.Requirement: ASTTokenizable {}
extension GenericArgumentClause: ASTTokenizable {}

// MARK: - Pattern

extension PatternBase: ASTTokenizable {}
extension TuplePattern.Element: ASTTokenizable {}

// MARK: -  statement

extension DoStatement.CatchClause: ASTTokenizable {}
extension IfStatement.ElseClause: ASTTokenizable {}
extension SwitchStatement.Case: ASTTokenizable {}
extension SwitchStatement.Case.Item: ASTTokenizable {}
extension Condition: ASTTokenizable {}
extension AvailabilityCondition: ASTTokenizable {}
extension AvailabilityCondition.Argument: ASTTokenizable {}

// MARK: - Type

extension TypeBase: ASTTokenizable {}
extension FunctionType.Argument: ASTTokenizable {}
extension TupleType.Element: ASTTokenizable {}
extension TypeAnnotation: ASTTokenizable {}
extension TypeIdentifier.TypeName: ASTTokenizable {}
extension TypeInheritanceClause: ASTTokenizable {}

// MARK: - Throws

extension ThrowsKind: ASTTokenizable {}
