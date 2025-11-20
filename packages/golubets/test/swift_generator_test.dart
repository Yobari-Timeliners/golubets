// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:golubets/src/ast.dart';
import 'package:golubets/src/swift/swift_generator.dart';
import 'package:test/test.dart';

import 'dart_generator_test.dart';

final Class emptyClass = Class(
  name: 'className',
  fields: <NamedType>[
    NamedType(
      name: 'namedTypeName',
      type: const TypeDeclaration(baseName: 'baseName', isNullable: false),
    ),
  ],
);

final Enum emptyEnum = Enum(
  name: 'enumName',
  members: <EnumMember>[EnumMember(name: 'enumMemberName')],
);

void main() {
  test('gen one class', () {
    final Class classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'int', isNullable: true),
          name: 'field1',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: Int64? = nil'));
    expect(
      code,
      contains('static func fromList(_ golubetsVar_list: [Any?]) -> Foobar?'),
    );
    expect(code, contains('func toList() -> [Any?]'));
    expect(code, isNot(contains('if (')));
  });

  test('gen one enum', () {
    final Enum anEnum = Enum(
      name: 'Foobar',
      members: <EnumMember>[
        EnumMember(name: 'one'),
        EnumMember(name: 'two'),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[],
      enums: <Enum>[anEnum],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum Foobar: Int'));
    expect(code, contains('  case one = 0'));
    expect(code, contains('  case two = 1'));
    expect(code, isNot(contains('if (')));
  });

  test('primitive enum host', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Bar',
          methods: <Method>[
            Method(
              name: 'bar',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'foo',
                  type: TypeDeclaration(
                    baseName: 'Foo',
                    associatedEnum: emptyEnum,
                    isNullable: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[
        Enum(
          name: 'Foo',
          members: <EnumMember>[
            EnumMember(name: 'one'),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public enum Foo: Int'));
    expect(
      code,
      contains(
        'let enumResultAsInt: Int? = nilOrValue(self.readValue() as! Int?)',
      ),
    );
    expect(code, contains('return Foo(rawValue: enumResultAsInt)'));
    expect(code, contains('let fooArg = args[0] as! Foo'));
    expect(code, isNot(contains('if (')));
  });

  test('gen one host api', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public protocol Api'));
    expect(code, contains('public class ApiSetup'));
    expect(code, contains('doSomethingChannel.setMessageHandler'));
    expect(code, isNot(contains('if (')));
    expect(code, contains('public class Api'));
    expect(code, contains('public final class GolubetsError'));
    expect(code, contains('public struct Output'));
    expect(code, contains('public struct Input'));
    expect(
      code,
      contains(
        'public static func setUp(binaryMessenger: FlutterBinaryMessenger, api: Api?, messageChannelSuffix: String = "")',
      ),
    );
  });

  test('all the simple datatypes header', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'bool', isNullable: true),
              name: 'aBool',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'int', isNullable: true),
              name: 'aInt',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'double', isNullable: true),
              name: 'aDouble',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'aString',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Uint8List',
                isNullable: true,
              ),
              name: 'aUint8List',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Int32List',
                isNullable: true,
              ),
              name: 'aInt32List',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Int64List',
                isNullable: true,
              ),
              name: 'aInt64List',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Float64List',
                isNullable: true,
              ),
              name: 'aFloat64List',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );

    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('var aBool: Bool? = nil'));
    expect(code, contains('var aInt: Int64? = nil'));
    expect(code, contains('var aDouble: Double? = nil'));
    expect(code, contains('var aString: String? = nil'));
    expect(code, contains('var aUint8List: FlutterStandardTypedData? = nil'));
    expect(code, contains('var aInt32List: FlutterStandardTypedData? = nil'));
    expect(code, contains('var aInt64List: FlutterStandardTypedData? = nil'));
    expect(code, contains('var aFloat64List: FlutterStandardTypedData? = nil'));
  });

  test('gen golubets error type', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();

    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class GolubetsError: Error'));
    expect(code, contains('let code: String'));
    expect(code, contains('let message: String?'));
    expect(code, contains('let details: Sendable?'));
    expect(
      code,
      contains('init(code: String, message: String?, details: Sendable?)'),
    );
  });

  test('gen one flutter api', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.flutter,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public class Api'));
    expect(
      code,
      contains(
        'public init(binaryMessenger: FlutterBinaryMessenger, messageChannelSuffix: String = "")',
      ),
    );
    expect(code, matches('public func doSomething.*Input.*Output'));
    expect(code, isNot(contains('if (')));
    expect(code, isNot(matches(RegExp(r';$', multiLine: true))));
    expect(code, contains('public protocol Api'));
    expect(code, contains('public final class GolubetsError'));
    expect(code, contains('public struct Input'));
    expect(code, contains('public struct Output'));
  });

  test('gen host void api', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(matches('.*doSomething(.*) ->')));
    expect(code, matches('doSomething(.*)'));
    expect(code, isNot(contains('if (')));
  });

  test('gen flutter void return api', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.flutter,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains('completion: @escaping (Result<Void, GolubetsError>) -> Void'),
    );
    expect(code, contains('completion(.success(()))'));
    expect(code, isNot(contains('if (')));
  });

  test('gen host void argument api', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func doSomething() throws -> Output'));
    expect(code, contains('let result = try api.doSomething()'));
    expect(code, contains('reply(wrapResult(result))'));
    expect(code, isNot(contains('if (')));
  });

  test('gen flutter void argument api', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.flutter,
              parameters: <Parameter>[],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains(
        'func doSomething(completion: @escaping (Result<Output, GolubetsError>) -> Void)',
      ),
    );
    expect(code, contains('channel.sendMessage(nil'));
    expect(code, isNot(contains('if (')));
  });

  test('gen list', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'List', isNullable: true),
              name: 'field1',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [Any?]? = nil'));
    expect(code, isNot(contains('if (')));
  });

  test('gen map', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'Map', isNullable: true),
              name: 'field1',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [AnyHashable?: Any?]? = nil'));
    expect(code, isNot(contains('if (')));
  });

  test('gen nested', () {
    final Class classDefinition = Class(
      name: 'Outer',
      fields: <NamedType>[
        NamedType(
          type: TypeDeclaration(
            baseName: 'Nested',
            associatedClass: emptyClass,
            isNullable: true,
          ),
          name: 'nested',
        ),
      ],
    );
    final Class nestedClass = Class(
      name: 'Nested',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'int', isNullable: true),
          name: 'data',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition, nestedClass],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Outer'));
    expect(code, contains('struct Nested'));
    expect(code, contains('var nested: Nested? = nil'));
    expect(
      code,
      contains('static func fromList(_ golubetsVar_list: [Any?]) -> Outer?'),
    );
    expect(
      code,
      contains('let nested: Nested? = nilOrValue(golubetsVar_list[0])'),
    );
    expect(code, contains('func toList() -> [Any?]'));
    expect(code, isNot(contains('if (')));
    // Single-element list serializations should not have a trailing comma.
    expect(code, matches(RegExp(r'return \[\s*data\s*]')));
  });

  test('gen one async Host Api', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: 'arg',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              asynchronousType: AsynchronousType.callback,
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('protocol Api'));
    expect(code, contains('api.doSomething(arg: argArg) { result in'));
    expect(code, contains('reply(wrapResult(res))'));
    expect(code, isNot(contains('if (')));
  });

  test('gen one modern async Host Api that throws', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: 'arg',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              asynchronousType: const AwaitAsynchronous(
                swiftOptions: SwiftAwaitAsynchronousOptions(throws: true),
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(
                baseName: 'String',
                isNullable: true,
              ),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(
                baseName: 'String',
                isNullable: true,
              ),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('protocol Api'));
    expect(
      code,
      contains('func doSomething(arg: Input) async throws -> Output'),
    );
    expect(code, contains('try await api.doSomething(arg: argArg)'));
    expect(code, contains('Task {'));
    expect(code, contains('reply(wrapResult(result))'));
  });

  test('gen one modern async Host Api that does not throw', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: 'arg',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              asynchronousType: const AwaitAsynchronous(
                swiftOptions: SwiftAwaitAsynchronousOptions(throws: false),
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(
                baseName: 'String',
                isNullable: true,
              ),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(
                baseName: 'String',
                isNullable: true,
              ),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('protocol Api'));
    expect(
      code,
      contains('func doSomething(arg: Input) async -> Output'),
    );
    expect(code, contains('await api.doSomething(arg: argArg)'));
    expect(code, contains('Task {'));
    expect(code, contains('reply(wrapResult(result))'));
    expect(code, isNot(contains('try')));
    expect(code, isNot(contains('catch')));
  });

  test('gen one async Flutter Api', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.flutter,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              asynchronousType: AsynchronousType.callback,
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, matches('func doSomething.*Input.*completion.*Output.*Void'));
    expect(code, isNot(contains('if (')));
  });

  test('gen one enum class', () {
    final Enum anEnum = Enum(
      name: 'Enum1',
      members: <EnumMember>[
        EnumMember(name: 'one'),
        EnumMember(name: 'two'),
      ],
    );
    final Class classDefinition = Class(
      name: 'EnumClass',
      fields: <NamedType>[
        NamedType(
          type: TypeDeclaration(
            baseName: 'Enum1',
            associatedEnum: emptyEnum,
            isNullable: true,
          ),
          name: 'enum1',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[anEnum],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum Enum1: Int'));
    expect(code, contains('case one = 0'));
    expect(code, contains('case two = 1'));
    expect(code, isNot(contains('if (')));
  });

  test('header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
      copyrightHeader: <String>['hello world', ''],
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, startsWith('// hello world'));
    // There should be no trailing whitespace on generated comments.
    expect(code, isNot(matches(RegExp(r'^//.* $', multiLine: true))));
  });

  test('generics - list', () {
    final Class classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'List',
            isNullable: true,
            typeArguments: <TypeDeclaration>[
              TypeDeclaration(baseName: 'int', isNullable: true),
            ],
          ),
          name: 'field1',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [Int64?]'));
  });

  test('generics - maps', () {
    final Class classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'Map',
            isNullable: true,
            typeArguments: <TypeDeclaration>[
              TypeDeclaration(baseName: 'String', isNullable: true),
              TypeDeclaration(baseName: 'String', isNullable: true),
            ],
          ),
          name: 'field1',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [String?: String?]'));
  });

  test('host generics argument', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(
                    baseName: 'List',
                    isNullable: false,
                    typeArguments: <TypeDeclaration>[
                      TypeDeclaration(baseName: 'int', isNullable: true),
                    ],
                  ),
                  name: 'arg',
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func doit(arg: [Int64?]'));
  });

  test('flutter generics argument', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(
                    baseName: 'List',
                    isNullable: false,
                    typeArguments: <TypeDeclaration>[
                      TypeDeclaration(baseName: 'int', isNullable: true),
                    ],
                  ),
                  name: 'arg',
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func doit(arg argArg: [Int64?]'));
  });

  test('host generics return', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(
                baseName: 'List',
                isNullable: false,
                typeArguments: <TypeDeclaration>[
                  TypeDeclaration(baseName: 'int', isNullable: true),
                ],
              ),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func doit() throws -> [Int64?]'));
    expect(code, contains('let result = try api.doit()'));
    expect(code, contains('reply(wrapResult(result))'));
  });

  test('flutter generics return', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration(
                baseName: 'List',
                isNullable: false,
                typeArguments: <TypeDeclaration>[
                  TypeDeclaration(baseName: 'int', isNullable: true),
                ],
              ),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains(
        'func doit(completion: @escaping (Result<[Int64?], GolubetsError>) -> Void)',
      ),
    );
    expect(code, contains('let result = listResponse[0] as! [Int64?]'));
    expect(code, contains('completion(.success(result))'));
  });

  test('generic class with single type parameter', () {
    final Class classDefinition = Class(
      name: 'Wrapper',
      typeArguments: <TypeDeclaration>[
        const TypeDeclaration(baseName: 'T', isNullable: false),
      ],
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'T', isNullable: false),
          name: 'value',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Wrapper<T>'));
    expect(code, contains('var value: T'));
    expect(
      code,
      contains('static func fromList(_ golubetsVar_list: [Any?]) -> Wrapper?'),
    );
    expect(code, contains('return Wrapper('));
  });

  test('generic class with multiple type parameters', () {
    final Class classDefinition = Class(
      name: 'Pair',
      typeArguments: <TypeDeclaration>[
        const TypeDeclaration(baseName: 'T', isNullable: false),
        const TypeDeclaration(baseName: 'U', isNullable: false),
      ],
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'T', isNullable: false),
          name: 'first',
        ),
        NamedType(
          type: const TypeDeclaration(baseName: 'U', isNullable: true),
          name: 'second',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Pair<T, U>'));
    expect(code, contains('var first: T'));
    expect(code, contains('var second: U? = nil'));
    expect(
      code,
      contains('static func fromList(_ golubetsVar_list: [Any?]) -> Pair?'),
    );
    expect(code, contains('return Pair('));
  });

  test('generic class with nested generic field types', () {
    final Class classDefinition = Class(
      name: 'Container',
      typeArguments: <TypeDeclaration>[
        const TypeDeclaration(baseName: 'T', isNullable: false),
      ],
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'List',
            isNullable: false,
            typeArguments: <TypeDeclaration>[
              TypeDeclaration(
                baseName: 'Map',
                isNullable: false,
                typeArguments: <TypeDeclaration>[
                  TypeDeclaration(baseName: 'String', isNullable: false),
                  TypeDeclaration(baseName: 'T', isNullable: true),
                ],
              ),
            ],
          ),
          name: 'data',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Container<T>'));
    expect(code, contains('var data: [[String: T?]]'));
    expect(
      code,
      contains(
        'static func fromList(_ golubetsVar_list: [Any?]) -> Container?',
      ),
    );
    expect(code, contains('return Container('));
  });

  test('generic class with generic superclass', () {
    final Class superClass = Class(
      name: 'BaseContainer',
      typeArguments: <TypeDeclaration>[
        const TypeDeclaration(baseName: 'T', isNullable: false),
      ],
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'T', isNullable: false),
          name: 'item',
        ),
      ],
    );
    final Class classDefinition = Class(
      name: 'SpecialList',
      typeArguments: <TypeDeclaration>[
        const TypeDeclaration(baseName: 'T', isNullable: false),
      ],
      superClassName: superClass.name,
      superClass: superClass,
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'int', isNullable: false),
          name: 'capacity',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[superClass, classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct BaseContainer<T>'));
    expect(code, contains('struct SpecialList<T>'));
    expect(code, contains('var capacity: Int64'));
    expect(
      code,
      contains(
        'static func fromList(_ golubetsVar_list: [Any?]) -> SpecialList?',
      ),
    );
  });

  test('generic class serialization methods', () {
    final Class classDefinition = Class(
      name: 'Result',
      typeArguments: <TypeDeclaration>[
        const TypeDeclaration(baseName: 'T', isNullable: false),
        const TypeDeclaration(baseName: 'E', isNullable: false),
      ],
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'T', isNullable: true),
          name: 'success',
        ),
        NamedType(
          type: const TypeDeclaration(baseName: 'E', isNullable: true),
          name: 'error',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Result<T, E>'));
    expect(code, contains('var success: T? = nil'));
    expect(code, contains('var error: E? = nil'));
    expect(
      code,
      contains('static func fromList(_ golubetsVar_list: [Any?]) -> Result?'),
    );
    expect(code, contains('return Result('));
    expect(code, contains('success: success'));
    expect(code, contains('error: error'));
    expect(code, contains('func toList() -> [Any?]'));
    expect(code, contains('success,'));
    expect(code, contains('error,'));
  });

  test('generic class with Hashable constraints for Map keys', () {
    final Class classDefinition = Class(
      name: 'KeyValueStore',
      typeArguments: <TypeDeclaration>[
        const TypeDeclaration(baseName: 'K', isNullable: false),
        const TypeDeclaration(baseName: 'V', isNullable: false),
      ],
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'Map',
            isNullable: false,
            typeArguments: <TypeDeclaration>[
              TypeDeclaration(baseName: 'K', isNullable: false),
              TypeDeclaration(baseName: 'V', isNullable: false),
            ],
          ),
          name: 'store',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct KeyValueStore<K: Hashable, V>'));
    expect(code, contains('var store: [K: V]'));
    expect(
      code,
      contains(
        'static func fromList(_ golubetsVar_list: [Any?]) -> KeyValueStore?',
      ),
    );
    expect(code, contains('return KeyValueStore('));
  });

  test('host multiple args', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'add',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  name: 'x',
                  type: const TypeDeclaration(
                    isNullable: false,
                    baseName: 'int',
                  ),
                ),
                Parameter(
                  name: 'y',
                  type: const TypeDeclaration(
                    isNullable: false,
                    baseName: 'int',
                  ),
                ),
              ],
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func add(x: Int64, y: Int64) throws -> Int64'));
    expect(code, contains('let args = message as! [Any?]'));
    expect(code, contains('let xArg = args[0] as! Int64'));
    expect(code, contains('let yArg = args[1] as! Int64'));
    expect(code, contains('let result = try api.add(x: xArg, y: yArg)'));
    expect(code, contains('reply(wrapResult(result))'));
  });

  test('flutter multiple args', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'add',
              location: ApiLocation.flutter,
              parameters: <Parameter>[
                Parameter(
                  name: 'x',
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: false,
                  ),
                ),
                Parameter(
                  name: 'y',
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: false,
                  ),
                ),
              ],
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('let channel = FlutterBasicMessageChannel'));
    expect(code, contains('let result = listResponse[0] as! Int64'));
    expect(code, contains('completion(.success(result))'));
    expect(
      code,
      contains(
        'func add(x xArg: Int64, y yArg: Int64, completion: @escaping (Result<Int64, GolubetsError>) -> Void)',
      ),
    );
    expect(
      code,
      contains('channel.sendMessage([xArg, yArg] as [Any?]) { response in'),
    );
  });

  test('return nullable host', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: true,
              ),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func doit() throws -> Int64?'));
  });

  test('return nullable host async', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: true,
              ),
              asynchronousType: AsynchronousType.callback,
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains(
        'func doit(completion: @escaping (Result<Int64?, Error>) -> Void',
      ),
    );
  });

  test('nullable argument host', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'foo',
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('let fooArg: Int64? = nilOrValue(args[0])'));
  });

  test('nullable argument flutter', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'foo',
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains(
        'func doit(foo fooArg: Int64?, completion: @escaping (Result<Void, GolubetsError>) -> Void)',
      ),
    );
  });

  test('nonnull fields', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(
                baseName: 'String',
                isNullable: false,
              ),
              name: 'input',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('var input: String\n'));
  });

  test('transfers documentation comments', () {
    final List<String> comments = <String>[
      ' api comment',
      ' api method comment',
      ' class comment',
      ' class field comment',
      ' enum comment',
      ' enum member comment',
    ];
    int count = 0;

    final List<String> unspacedComments = <String>['////////'];
    int unspacedCount = 0;

    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'api',
          documentationComments: <String>[comments[count++]],
          methods: <Method>[
            Method(
              name: 'method',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration.voidDeclaration(),
              documentationComments: <String>[comments[count++]],
              parameters: <Parameter>[
                Parameter(
                  name: 'field',
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'class',
          documentationComments: <String>[comments[count++]],
          fields: <NamedType>[
            NamedType(
              documentationComments: <String>[comments[count++]],
              type: const TypeDeclaration(
                baseName: 'Map',
                isNullable: true,
                typeArguments: <TypeDeclaration>[
                  TypeDeclaration(baseName: 'String', isNullable: true),
                  TypeDeclaration(baseName: 'int', isNullable: true),
                ],
              ),
              name: 'field1',
            ),
          ],
        ),
      ],
      enums: <Enum>[
        Enum(
          name: 'enum',
          documentationComments: <String>[
            comments[count++],
            unspacedComments[unspacedCount++],
          ],
          members: <EnumMember>[
            EnumMember(
              name: 'one',
              documentationComments: <String>[comments[count++]],
            ),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    for (final String comment in comments) {
      expect(code, contains('///$comment'));
    }
    expect(code, contains('/// ///'));
  });

  test('creates custom codecs', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.flutter,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              asynchronousType: AsynchronousType.callback,
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains(': FlutterStandardReader '));
  });

  test('swift function signature', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'set',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: false,
                  ),
                  name: 'value',
                ),
                Parameter(
                  type: const TypeDeclaration(
                    baseName: 'String',
                    isNullable: false,
                  ),
                  name: 'key',
                ),
              ],
              swiftFunction: 'setValue(_:for:)',
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func setValue(_ value: Int64, for key: String)'));
  });

  test('swift function signature with same name argument', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'set',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(
                    baseName: 'String',
                    isNullable: false,
                  ),
                  name: 'key',
                ),
              ],
              swiftFunction: 'removeValue(key:)',
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func removeValue(key: String)'));
  });

  test('swift function signature with no arguments', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'clear',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              swiftFunction: 'removeAll()',
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func removeAll()'));
  });

  test('connection error contains channel name', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'method',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'field',
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
      containsFlutterApi: true,
    );
    final StringBuffer sink = StringBuffer();
    const InternalSwiftOptions kotlinOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains(
        'completion(.failure(createConnectionError(withChannelName: channelName)))',
      ),
    );
    expect(
      code,
      contains(
        'return GolubetsError(code: "channel-error", message: "Unable to establish connection on channel: \'\\(channelName)\'.", details: "")',
      ),
    );
  });

  test('sealed class', () {
    final Class superClass = Class(
      name: 'PlatformEvent',
      isSealed: true,
      fields: const <NamedType>[],
    );
    final List<Class> children = <Class>[
      Class(
        name: 'IntEvent',
        superClass: superClass,
        superClassName: superClass.name,
        fields: <NamedType>[
          NamedType(
            type: const TypeDeclaration(
              baseName: 'int',
              isNullable: false,
            ),
            name: 'value',
          ),
        ],
      ),
      Class(
        name: 'ClassEvent',
        superClass: superClass,
        superClassName: superClass.name,
        fields: <NamedType>[
          NamedType(
            type: TypeDeclaration(
              baseName: 'Input',
              isNullable: true,
              associatedClass: emptyClass,
            ),
            name: 'value',
          ),
        ],
      ),
    ];
    superClass.children = children;
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        superClass,
        ...children,
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const SwiftGenerator generator = SwiftGenerator();
    const InternalSwiftOptions kotlinOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains('public enum PlatformEvent'),
    );
    expect(
      code,
      contains('case intEvent'),
    );
    expect(
      code,
      contains('case classEvent'),
    );
    expect(
      code,
      contains('internal static func fromListIntEvent'),
    );
    expect(
      code,
      contains('internal static func fromListClassEvent'),
    );
  });

  test('sealed class with single generic type parameter', () {
    final Class superClass = Class(
      name: 'Result',
      isSealed: true,
      typeArguments: <TypeDeclaration>[
        const TypeDeclaration(baseName: 'T', isNullable: false),
      ],
      fields: const <NamedType>[],
    );
    final List<Class> children = <Class>[
      Class(
        name: 'Success',
        superClass: superClass,
        superClassName: superClass.name,
        typeArguments: <TypeDeclaration>[
          const TypeDeclaration(baseName: 'T', isNullable: false),
        ],
        fields: <NamedType>[
          NamedType(
            type: const TypeDeclaration(
              baseName: 'T',
              isNullable: false,
            ),
            name: 'value',
          ),
        ],
      ),
      Class(
        name: 'Failure',
        superClass: superClass,
        superClassName: superClass.name,
        typeArguments: <TypeDeclaration>[
          const TypeDeclaration(baseName: 'T', isNullable: false),
        ],
        fields: <NamedType>[
          NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: false,
            ),
            name: 'error',
          ),
        ],
      ),
    ];
    superClass.children = children;
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        superClass,
        ...children,
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const SwiftGenerator generator = SwiftGenerator();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public enum Result<T>'));
    expect(code, contains('case success'));
    expect(code, contains('case failure'));
    expect(code, contains('internal static func fromListSuccess'));
    expect(code, contains('internal static func fromListFailure'));
    expect(code, contains('value: T'));
    expect(code, contains('error: String'));
  });

  test('sealed class with multiple generic type parameters', () {
    final Class superClass = Class(
      name: 'Either',
      isSealed: true,
      typeArguments: <TypeDeclaration>[
        const TypeDeclaration(baseName: 'L', isNullable: false),
        const TypeDeclaration(baseName: 'R', isNullable: false),
      ],
      fields: const <NamedType>[],
    );
    final List<Class> children = <Class>[
      Class(
        name: 'Left',
        superClass: superClass,
        superClassName: superClass.name,
        typeArguments: <TypeDeclaration>[
          const TypeDeclaration(baseName: 'L', isNullable: false),
          const TypeDeclaration(baseName: 'R', isNullable: false),
        ],
        fields: <NamedType>[
          NamedType(
            type: const TypeDeclaration(
              baseName: 'L',
              isNullable: false,
            ),
            name: 'value',
          ),
        ],
      ),
      Class(
        name: 'Right',
        superClass: superClass,
        superClassName: superClass.name,
        typeArguments: <TypeDeclaration>[
          const TypeDeclaration(baseName: 'L', isNullable: false),
          const TypeDeclaration(baseName: 'R', isNullable: false),
        ],
        fields: <NamedType>[
          NamedType(
            type: const TypeDeclaration(
              baseName: 'R',
              isNullable: false,
            ),
            name: 'value',
          ),
        ],
      ),
    ];
    superClass.children = children;
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        superClass,
        ...children,
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const SwiftGenerator generator = SwiftGenerator();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public enum Either<L, R>'));
    expect(code, contains('case left'));
    expect(code, contains('case right'));
    expect(code, contains('internal static func fromListLeft'));
    expect(code, contains('internal static func fromListRight'));
  });

  test('sealed class with generic constraints for Map keys', () {
    final Class superClass = Class(
      name: 'Container',
      isSealed: true,
      typeArguments: <TypeDeclaration>[
        const TypeDeclaration(baseName: 'K', isNullable: false),
        const TypeDeclaration(baseName: 'V', isNullable: false),
      ],
      fields: const <NamedType>[],
    );
    final List<Class> children = <Class>[
      Class(
        name: 'MapContainer',
        superClass: superClass,
        superClassName: superClass.name,
        typeArguments: <TypeDeclaration>[
          const TypeDeclaration(baseName: 'K', isNullable: false),
          const TypeDeclaration(baseName: 'V', isNullable: false),
        ],
        fields: <NamedType>[
          NamedType(
            type: const TypeDeclaration(
              baseName: 'Map',
              isNullable: false,
              typeArguments: <TypeDeclaration>[
                TypeDeclaration(baseName: 'K', isNullable: false),
                TypeDeclaration(baseName: 'V', isNullable: false),
              ],
            ),
            name: 'data',
          ),
        ],
      ),
      Class(
        name: 'ListContainer',
        superClass: superClass,
        superClassName: superClass.name,
        typeArguments: <TypeDeclaration>[
          const TypeDeclaration(baseName: 'K', isNullable: false),
          const TypeDeclaration(baseName: 'V', isNullable: false),
        ],
        fields: <NamedType>[
          NamedType(
            type: const TypeDeclaration(
              baseName: 'List',
              isNullable: false,
              typeArguments: <TypeDeclaration>[
                TypeDeclaration(baseName: 'V', isNullable: false),
              ],
            ),
            name: 'items',
          ),
        ],
      ),
    ];
    superClass.children = children;
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        superClass,
        ...children,
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const SwiftGenerator generator = SwiftGenerator();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public enum Container<K, V>'));
    expect(code, contains('case mapContainer'));
    expect(code, contains('case listContainer'));
    expect(code, contains('data: [K: V]'));
    expect(code, contains('items: [V]'));
  });

  test('sealed class with nested generic types', () {
    final Class superClass = Class(
      name: 'Response',
      isSealed: true,
      typeArguments: <TypeDeclaration>[
        const TypeDeclaration(baseName: 'T', isNullable: false),
      ],
      fields: const <NamedType>[],
    );
    final List<Class> children = <Class>[
      Class(
        name: 'DataResponse',
        superClass: superClass,
        superClassName: superClass.name,
        typeArguments: <TypeDeclaration>[
          const TypeDeclaration(baseName: 'T', isNullable: false),
        ],
        fields: <NamedType>[
          NamedType(
            type: const TypeDeclaration(
              baseName: 'List',
              isNullable: false,
              typeArguments: <TypeDeclaration>[
                TypeDeclaration(
                  baseName: 'Map',
                  isNullable: false,
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'String', isNullable: false),
                    TypeDeclaration(baseName: 'T', isNullable: true),
                  ],
                ),
              ],
            ),
            name: 'items',
          ),
        ],
      ),
      Class(
        name: 'ErrorResponse',
        superClass: superClass,
        superClassName: superClass.name,
        typeArguments: <TypeDeclaration>[
          const TypeDeclaration(baseName: 'T', isNullable: false),
        ],
        fields: <NamedType>[
          NamedType(
            type: const TypeDeclaration(
              baseName: 'int',
              isNullable: false,
            ),
            name: 'code',
          ),
          NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: false,
            ),
            name: 'message',
          ),
        ],
      ),
    ];
    superClass.children = children;
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        superClass,
        ...children,
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const SwiftGenerator generator = SwiftGenerator();
    const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
      swiftOut: '',
    );
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public enum Response<T>'));
    expect(code, contains('case dataResponse'));
    expect(code, contains('case errorResponse'));
    expect(code, contains('items: [[String: T?]]'));
    expect(code, contains('code: Int64'));
    expect(code, contains('message: String'));
  });

  group('default values', () {
    test('gen class with string default value', () {
      final Class classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(baseName: 'String', isNullable: false),
            defaultValue: const StringLiteral(
              value: 'hello world',
            ),
          ),
        ],
      );
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('struct Foobar'));
      expect(code, contains('field1: String = "hello world"'));
    });

    test('gen class with int default value', () {
      final Class classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(baseName: 'int', isNullable: false),
            defaultValue: const IntLiteral(
              value: 42,
            ),
          ),
        ],
      );
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('struct Foobar'));
      expect(code, contains('field1: Int64 = 42'));
    });

    test('gen class with int default value for double type', () {
      final Class classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(baseName: 'double', isNullable: false),
            defaultValue: const IntLiteral(
              value: 42,
            ),
          ),
        ],
      );
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('struct Foobar'));
      expect(code, contains('field1: Double = 42'));
    });

    test('gen class with double default value', () {
      final Class classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(baseName: 'double', isNullable: false),
            defaultValue: const DoubleLiteral(
              value: 3.14,
            ),
          ),
        ],
      );
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('struct Foobar'));
      expect(code, contains('field1: Double = 3.14'));
    });

    test('gen class with bool default value', () {
      final Class classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(baseName: 'bool', isNullable: false),
            defaultValue: const BoolLiteral(
              value: true,
            ),
          ),
          NamedType(
            name: 'field2',
            type: const TypeDeclaration(baseName: 'bool', isNullable: false),
            defaultValue: const BoolLiteral(
              value: false,
            ),
          ),
        ],
      );
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('struct Foobar'));
      expect(code, contains('field1: Bool = true'));
      expect(code, contains('field2: Bool = false'));
    });

    test('gen class with empty list default value', () {
      final Class classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(
              baseName: 'List',
              isNullable: false,
              typeArguments: <TypeDeclaration>[
                TypeDeclaration(baseName: 'int', isNullable: false),
              ],
            ),
            defaultValue: const ListLiteral(
              elements: <DefaultValue>[],
              elementType: TypeDeclaration(baseName: 'int', isNullable: false),
            ),
          ),
        ],
      );
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('struct Foobar'));
      expect(code, contains('field1: [Int64] = []'));
    });

    test('gen class with list default value with elements', () {
      final Class classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(
              baseName: 'List',
              isNullable: false,
              typeArguments: <TypeDeclaration>[
                TypeDeclaration(baseName: 'int', isNullable: false),
              ],
            ),
            defaultValue: const ListLiteral(
              elements: <DefaultValue>[
                IntLiteral(value: 1),
                IntLiteral(value: 2),
                IntLiteral(value: 3),
              ],
              elementType: TypeDeclaration(baseName: 'int', isNullable: false),
            ),
          ),
        ],
      );
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('struct Foobar'));
      expect(code, contains('field1: [Int64] = ['));
      expect(code, contains('1, '));
      expect(code, contains('2, '));
      expect(code, contains('3'));
    });

    test('gen class with empty map default value', () {
      final Class classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(
              baseName: 'Map',
              isNullable: false,
              typeArguments: <TypeDeclaration>[
                TypeDeclaration(baseName: 'String', isNullable: false),
                TypeDeclaration(baseName: 'int', isNullable: false),
              ],
            ),
            defaultValue: const MapLiteral(
              entries: <DefaultValue, DefaultValue>{},
              keyType: TypeDeclaration(baseName: 'String', isNullable: false),
              valueType: TypeDeclaration(baseName: 'int', isNullable: false),
            ),
          ),
        ],
      );
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('struct Foobar'));
      expect(code, contains('field1: [String: Int64] = [:]'));
    });

    test('gen class with map default value with entries', () {
      final Class classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(
              baseName: 'Map',
              isNullable: false,
              typeArguments: <TypeDeclaration>[
                TypeDeclaration(baseName: 'String', isNullable: false),
                TypeDeclaration(baseName: 'int', isNullable: false),
              ],
            ),
            defaultValue: const MapLiteral(
              entries: <DefaultValue, DefaultValue>{
                StringLiteral(value: 'key1'): IntLiteral(
                  value: 100,
                ),
                StringLiteral(value: 'key2'): IntLiteral(
                  value: 200,
                ),
              },
              keyType: TypeDeclaration(baseName: 'String', isNullable: false),
              valueType: TypeDeclaration(baseName: 'int', isNullable: false),
            ),
          ),
        ],
      );
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('struct Foobar'));
      expect(code, contains('field1: [String: Int64] = ['));
      expect(code, contains('"key1": 100, '));
      expect(code, contains('"key2": 200'));
    });

    test('gen class with enum default value', () {
      final Enum testEnum = Enum(
        name: 'TestEnum',
        members: <EnumMember>[
          EnumMember(name: 'firstValue'),
          EnumMember(name: 'secondValue'),
        ],
      );
      final Class classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: TypeDeclaration(
              baseName: 'TestEnum',
              isNullable: false,
              associatedEnum: testEnum,
            ),
            defaultValue: const EnumLiteral(
              name: 'TestEnum',
              value: 'firstValue',
            ),
          ),
        ],
      );
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition],
        enums: <Enum>[testEnum],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('struct Foobar'));
      expect(code, contains('field1: TestEnum = TestEnum.firstValue'));
      expect(code, contains('enum TestEnum: Int'));
      expect(code, contains('case firstValue = 0'));
      expect(code, contains('case secondValue = 1'));
    });

    test('gen class with object creation default value', () {
      final Class innerClass = Class(
        name: 'InnerClass',
        fields: <NamedType>[
          NamedType(
            name: 'value',
            type: const TypeDeclaration(baseName: 'int', isNullable: false),
          ),
        ],
      );
      final Class classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: TypeDeclaration(
              baseName: 'InnerClass',
              isNullable: false,
              associatedClass: innerClass,
            ),
            defaultValue: const ObjectCreation(
              type: TypeDeclaration(baseName: 'InnerClass', isNullable: false),
              arguments: <DefaultValue>[
                IntLiteral(value: 42),
              ],
            ),
          ),
        ],
      );
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition, innerClass],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('struct Foobar'));
      expect(code, contains('field1: InnerClass = InnerClass('));
      expect(code, contains('42'));
      expect(code, contains('struct InnerClass'));
    });

    test('gen class with object creation default value - no arguments', () {
      final Class innerClass = Class(
        name: 'InnerClass',
        fields: <NamedType>[],
      );
      final Class classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: TypeDeclaration(
              baseName: 'InnerClass',
              isNullable: false,
              associatedClass: innerClass,
            ),
            defaultValue: const ObjectCreation(
              type: TypeDeclaration(baseName: 'InnerClass', isNullable: false),
              arguments: <DefaultValue>[],
            ),
          ),
        ],
      );
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition, innerClass],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('struct Foobar'));
      expect(code, contains('field1: InnerClass = InnerClass()'));
    });

    test('gen class with named default value', () {
      final Class innerClass = Class(
        name: 'InnerClass',
        fields: <NamedType>[
          NamedType(
            name: 'x',
            type: const TypeDeclaration(baseName: 'int', isNullable: false),
          ),
          NamedType(
            name: 'y',
            type: const TypeDeclaration(baseName: 'int', isNullable: false),
          ),
        ],
      );
      final Class classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: TypeDeclaration(
              baseName: 'InnerClass',
              isNullable: false,
              associatedClass: innerClass,
            ),
            defaultValue: const ObjectCreation(
              type: TypeDeclaration(baseName: 'InnerClass', isNullable: false),
              arguments: <DefaultValue>[
                NamedDefaultValue(
                  name: 'x',
                  value: IntLiteral(value: 10),
                ),
                NamedDefaultValue(
                  name: 'y',
                  value: IntLiteral(value: 20),
                ),
              ],
            ),
          ),
        ],
      );
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition, innerClass],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('struct Foobar'));
      expect(code, contains('field1: InnerClass = InnerClass('));
      expect(code, contains('x: 10, '));
      expect(code, contains('y: 20'));
    });

    test('gen class with nested list default value', () {
      final Class classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(
              baseName: 'List',
              isNullable: false,
              typeArguments: <TypeDeclaration>[
                TypeDeclaration(
                  baseName: 'List',
                  isNullable: false,
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'String', isNullable: false),
                  ],
                ),
              ],
            ),
            defaultValue: const ListLiteral(
              elements: <DefaultValue>[
                ListLiteral(
                  elements: <DefaultValue>[
                    StringLiteral(value: 'a'),
                    StringLiteral(value: 'b'),
                  ],
                  elementType: TypeDeclaration(
                    baseName: 'String',
                    isNullable: false,
                  ),
                ),
                ListLiteral(
                  elements: <DefaultValue>[
                    StringLiteral(value: 'c'),
                  ],
                  elementType: TypeDeclaration(
                    baseName: 'String',
                    isNullable: false,
                  ),
                ),
              ],
              elementType: TypeDeclaration(
                baseName: 'List',
                isNullable: false,
                typeArguments: <TypeDeclaration>[
                  TypeDeclaration(baseName: 'String', isNullable: false),
                ],
              ),
            ),
          ),
        ],
      );
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('struct Foobar'));
      expect(code, contains('field1: [[String]] = ['));
      expect(code, contains('"a", '));
      expect(code, contains('"b"'));
      expect(code, contains('"c"'));
    });

    test('gen sealed class with default values', () {
      final Class superClass = Class(
        name: 'PlatformEvent',
        isSealed: true,
        fields: const <NamedType>[],
      );
      final List<Class> children = <Class>[
        Class(
          name: 'IntEvent',
          superClass: superClass,
          superClassName: superClass.name,
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(
                baseName: 'int',
                isNullable: false,
              ),
              name: 'value',
              defaultValue: const IntLiteral(
                value: 42,
              ),
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'String',
                isNullable: false,
              ),
              name: 'message',
              defaultValue: const StringLiteral(
                value: 'default message',
              ),
            ),
          ],
        ),
        Class(
          name: 'StringEvent',
          superClass: superClass,
          superClassName: superClass.name,
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(
                baseName: 'String',
                isNullable: false,
              ),
              name: 'data',
              defaultValue: const StringLiteral(
                value: 'hello world',
              ),
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'bool',
                isNullable: false,
              ),
              name: 'isValid',
              defaultValue: const BoolLiteral(
                value: true,
              ),
            ),
          ],
        ),
      ];
      superClass.children = children;
      final Root root = Root(
        apis: <Api>[],
        classes: <Class>[
          superClass,
          ...children,
        ],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const InternalSwiftOptions swiftOptions = InternalSwiftOptions(
        swiftOut: '',
      );
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        swiftOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('public enum PlatformEvent'));
      expect(code, contains('case intEvent'));
      expect(code, contains('case stringEvent'));
      expect(code, contains('value: Int64 = 42'));
      expect(code, contains('message: String = "default message"'));
      expect(code, contains('data: String = "hello world"'));
      expect(code, contains('isValid: Bool = true'));
    });
  });
}
