// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Directory, File;

import 'package:golubets/src/ast.dart';
import 'package:golubets/src/dart/dart_generator.dart';
import 'package:golubets/src/generator_tools.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

const String DEFAULT_PACKAGE_NAME = 'test_package';

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
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: TypeDeclaration(
            baseName: 'dataType1',
            isNullable: true,
            associatedClass: emptyClass,
          ),
          name: 'field1',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('  dataType1? field1;'));
  });

  test('gen one enum', () {
    final anEnum = Enum(
      name: 'Foobar',
      members: <EnumMember>[
        EnumMember(name: 'one'),
        EnumMember(name: 'two'),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[anEnum]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('enum Foobar'));
    expect(code, contains('  one,'));
    expect(code, contains('  two;'));
  });

  test('gen event channel api with usage docs on the generated method', () {
    final api = AstEventChannelApi(
      name: 'EventApi',
      methods: <Method>[
        Method(
          name: 'streamEvents',
          location: ApiLocation.host,
          returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
          parameters: <Parameter>[],
          documentationComments: <String>[' An example event stream.'],
        ),
      ],
    );
    final root = Root(apis: <Api>[api], classes: <Class>[], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Stream<int> streamEvents('));
    // The user's own documentation comments are emitted.
    expect(code, contains('/// An example event stream.'));
    // The generated usage documentation explains the channel-owning and
    // broadcast semantics.
    expect(
      code,
      contains('/// Returns a broadcast [Stream] of events from the `streamEvents` event channel.'),
    );
    expect(code, contains('not be called multiple times for the same `instanceName`'));
    // The usage documentation is attached directly above the generated method.
    expect(
      code.indexOf('not be called multiple times'),
      lessThan(code.indexOf('Stream<int> streamEvents(')),
    );
  });

  test('gen one host api', () {
    final root = Root(
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
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: 'input',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                isNullable: false,
                associatedClass: emptyClass,
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, contains('Future<Output> doSomething(Input input)'));
  });

  test('host multiple args', () {
    final root = Root(
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
                  type: const TypeDeclaration(isNullable: false, baseName: 'int'),
                ),
                Parameter(
                  name: 'y',
                  type: const TypeDeclaration(isNullable: false, baseName: 'int'),
                ),
              ],
              returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, contains('Future<int> add(int x, int y)'));
    expect(code, contains('golubetsVar_sendFuture = golubetsVar_channel.send(<Object?>[x, y])'));
    expect(code, contains('await golubetsVar_sendFuture'));
  });

  test('flutter multiple args', () {
    final root = Root(
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
                  type: const TypeDeclaration(isNullable: false, baseName: 'int'),
                ),
                Parameter(
                  name: 'y',
                  type: const TypeDeclaration(isNullable: false, baseName: 'int'),
                ),
              ],
              returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, contains('int add(int x, int y)'));
    expect(code, contains('final List<Object?> args = message! as List<Object?>'));
    expect(code, contains('final int arg_x = args[0]! as int'));
    expect(code, contains('final int arg_y = args[1]! as int'));
    expect(code, contains('final int output = api.add(arg_x, arg_y)'));
  });

  test('nested class', () {
    final root = Root(
      apis: <Api>[],
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
          name: 'Nested',
          fields: <NamedType>[
            NamedType(
              type: TypeDeclaration(
                baseName: 'Input',
                isNullable: true,
                associatedClass: emptyClass,
              ),
              name: 'nested',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('nested,'));
    expect(code, contains('nested: result[0] as Input?'));
  });

  test('nested non-nullable class', () {
    final root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: false),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Nested',
          fields: <NamedType>[
            NamedType(
              type: TypeDeclaration(
                baseName: 'Input',
                isNullable: false,
                associatedClass: emptyClass,
              ),
              name: 'nested',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('nested,'));
    expect(code, contains('nested: result[0]! as Input'));
  });

  test('flutterApi', () {
    final root = Root(
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
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: 'input',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                isNullable: false,
                associatedClass: emptyClass,
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('abstract class Api'));
    expect(code, contains('static void setUp(Api'));
    expect(code, contains('Output doSomething(Input input)'));
  });

  test('host void', () {
    final root = Root(
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
                    isNullable: false,
                    associatedClass: emptyClass,
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Future<void> doSomething'));
  });

  test('flutter void return', () {
    final root = Root(
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
                    isNullable: false,
                    associatedClass: emptyClass,
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    // The next line verifies that we're not setting a variable to the value of "doSomething", but
    // ignores the line where we assert the value of the argument isn't null, since on that line
    // we mention "doSomething" in the assertion message.
    expect(code, isNot(matches('[^!]=.*doSomething')));
    expect(code, contains('doSomething('));
  });

  test('flutter void argument', () {
    final root = Root(
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
                isNullable: false,
                associatedClass: emptyClass,
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, matches('output.*=.*doSomething[(][)]'));
    expect(code, contains('Output doSomething();'));
  });

  test('flutter enum argument with enum class', () {
    final root = Root(
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
                    baseName: 'EnumClass',
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: 'enumClass',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'EnumClass',
                isNullable: false,
                associatedClass: emptyClass,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'EnumClass',
          fields: <NamedType>[
            NamedType(
              type: TypeDeclaration(baseName: 'Enum', isNullable: true, associatedEnum: emptyEnum),
              name: 'enum1',
            ),
          ],
        ),
      ],
      enums: <Enum>[
        Enum(
          name: 'Enum',
          members: <EnumMember>[
            EnumMember(name: 'one'),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('return value == null ? null : Enum.values[value];'));
    expect(code, contains('writeValue(buffer, value.index);'));
    expect(code, contains('final EnumClass arg_enumClass = args[0]! as EnumClass;'));
    expect(code, contains('EnumClass doSomething(EnumClass enumClass);'));
  });

  test('primitive enum host', () {
    final root = Root(
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
                    isNullable: true,
                    associatedEnum: emptyEnum,
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('enum Foo {'));
    expect(code, contains('Future<void> bar(Foo? foo) async'));
    expect(code, contains('golubetsVar_sendFuture = golubetsVar_channel.send(<Object?>[foo])'));
    expect(code, contains('await golubetsVar_sendFuture'));
  });

  test('flutter non-nullable enum argument with enum class', () {
    final root = Root(
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
                    baseName: 'EnumClass',
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'EnumClass',
                isNullable: false,
                associatedClass: emptyClass,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'EnumClass',
          fields: <NamedType>[
            NamedType(
              type: TypeDeclaration(baseName: 'Enum', isNullable: false, associatedEnum: emptyEnum),
              name: 'enum1',
            ),
          ],
        ),
      ],
      enums: <Enum>[
        Enum(
          name: 'Enum',
          members: <EnumMember>[
            EnumMember(name: 'one'),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('writeValue(buffer, value.index)'));
    expect(code, contains('return value == null ? null : Enum.values[value];'));
    expect(code, contains('enum1: result[0]! as Enum,'));
  });

  test('host void argument', () {
    final root = Root(
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
                isNullable: false,
                associatedClass: emptyClass,
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, matches('golubetsVar_sendFuture = golubetsVar_channel.send[(]null[)]'));
  });

  test('mock Dart handler', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          dartHostTestHandler: 'ApiMock',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                isNullable: false,
                associatedClass: emptyClass,
              ),
            ),
            Method(
              name: 'voidReturner',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                    associatedClass: emptyClass,
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
    final mainCodeSink = StringBuffer();
    final testCodeSink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      mainCodeSink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final mainCode = mainCodeSink.toString();
    expect(mainCode, isNot(contains(r"import 'fo\'o.dart';")));
    expect(mainCode, contains('class Api {'));
    expect(mainCode, isNot(contains('abstract class ApiMock')));
    expect(mainCode, isNot(contains('.ApiMock.doSomething')));
    expect(mainCode, isNot(contains("'${Keys.result}': output")));
    expect(mainCode, isNot(contains('return <Object>[];')));

    const testGenerator = DartGenerator();
    testGenerator.generateTest(
      const InternalDartOptions(dartOut: "fo'o.dart", testOut: 'test.dart', ignoreLints: false),
      root,
      testCodeSink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
      dartOutputPackageName: DEFAULT_PACKAGE_NAME,
    );
    final testCode = testCodeSink.toString();
    expect(testCode, contains(r"import 'fo\'o.dart';"));
    expect(testCode, isNot(contains('class Api {')));
    expect(testCode, contains('abstract class ApiMock'));
    expect(testCode, isNot(contains('.ApiMock.doSomething')));
    expect(testCode, contains('output'));
    expect(testCode, contains('return <Object?>[output];'));
  });

  test('gen one async Flutter Api', () {
    final root = Root(
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
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: 'input',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                isNullable: false,
                associatedClass: emptyClass,
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('abstract class Api'));
    expect(code, contains('Future<Output> doSomething(Input input);'));
    expect(code, contains('final Output output = await api.doSomething(arg_input);'));
  });

  test('gen one async Flutter Api with void return', () {
    final root = Root(
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
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: '',
                ),
              ],
              returnType: const TypeDeclaration.voidDeclaration(),
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, isNot(matches('=.s*doSomething')));
    expect(code, contains('await api.doSomething('));
    expect(code, isNot(contains('._toMap()')));
  });

  test('gen one async Host Api', () {
    final root = Root(
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
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                isNullable: false,
                associatedClass: emptyClass,
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, matches('Output.*doSomething.*Input'));
  });

  test('async host void argument', () {
    final root = Root(
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
                isNullable: false,
                associatedClass: emptyClass,
              ),
              asynchronousType: AsynchronousType.callback,
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, matches('golubetsVar_channel.send[(]null[)]'));
  });

  Iterable<String> makeIterable(String string) sync* {
    yield string;
  }

  test('header', () {
    final root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final sink = StringBuffer();

    const generator = DartGenerator();
    generator.generate(
      InternalDartOptions(copyrightHeader: makeIterable('hello world'), ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, startsWith('// hello world'));
  });

  test('generics', () {
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'List',
            isNullable: true,
            typeArguments: <TypeDeclaration>[TypeDeclaration(baseName: 'int', isNullable: true)],
          ),
          name: 'field1',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('  List<int?>? field1;'));
  });

  test('map generics', () {
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
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
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('  Map<String?, int?>? field1;'));
  });

  test('host generics argument', () {
    final root = Root(
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('doit(List<int?> arg'));
  });

  test('flutter generics argument with void return', () {
    final root = Root(
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('doit(List<int?> arg'));
  });

  test('host generics return', () {
    final root = Root(
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Future<List<int?>> doit('));
    expect(code, contains('return (golubetsVar_replyValue! as List<Object?>).cast<int?>();'));
  });

  test('flutter generics argument non void return', () {
    final root = Root(
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
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(
                    baseName: 'List',
                    isNullable: false,
                    typeArguments: <TypeDeclaration>[
                      TypeDeclaration(baseName: 'int', isNullable: true),
                    ],
                  ),
                  name: 'foo',
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('List<int?> doit('));
    expect(code, contains('final List<int?> arg_foo = (args[0]! as List<Object?>).cast<int?>()'));
    expect(code, contains('final List<int?> output = api.doit(arg_foo)'));
  });

  test('generic class with single type parameter', () {
    final classDefinition = Class(
      name: 'Wrapper',
      typeArguments: <TypeDeclaration>[const TypeDeclaration(baseName: 'T', isNullable: false)],
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'T', isNullable: false),
          name: 'value',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Wrapper<T>'));
    expect(code, contains('T value;'));
    expect(code, contains('Wrapper({'));
    // Generic classes intentionally do not get a shared `decode<T>` method;
    // the codec emits an inline constructor per concrete instantiation.
    expect(code, isNot(contains('decode<T>')));
  });

  test('generic class with multiple type parameters', () {
    final classDefinition = Class(
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
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Pair<T, U>'));
    expect(code, contains('T first;'));
    expect(code, contains('U? second;'));
    expect(code, contains('Pair({'));
    expect(code, isNot(contains('decode<T, U>')));
  });

  test('generic class with nested generic field types', () {
    final classDefinition = Class(
      name: 'Container',
      typeArguments: <TypeDeclaration>[const TypeDeclaration(baseName: 'T', isNullable: false)],
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
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Container<T>'));
    expect(code, contains('List<Map<String, T?>> data;'));
    expect(code, contains('Container({'));
    expect(code, isNot(contains('decode<T>')));
  });

  test('generic class with generic superclass', () {
    final superClass = Class(
      name: 'BaseContainer',
      typeArguments: <TypeDeclaration>[const TypeDeclaration(baseName: 'T', isNullable: false)],
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'T', isNullable: false),
          name: 'item',
        ),
      ],
    );
    final classDefinition = Class(
      name: 'SpecialList',
      typeArguments: <TypeDeclaration>[const TypeDeclaration(baseName: 'T', isNullable: false)],
      superClassName: superClass.name,
      superClass: superClass,
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'int', isNullable: false),
          name: 'capacity',
        ),
      ],
    );
    final root = Root(
      apis: <Api>[],
      classes: <Class>[superClass, classDefinition],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class SpecialList<T> extends BaseContainer'));
    expect(code, contains('int capacity;'));
    expect(code, contains('SpecialList({'));
    expect(code, isNot(contains('decode<T>')));
    expect(code, contains('class BaseContainer<T>'));
  });

  test('generic class serialization methods', () {
    final classDefinition = Class(
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
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Result<T, E>'));
    expect(code, contains('T? success;'));
    expect(code, contains('E? error;'));
    expect(code, isNot(contains('decode<T, E>')));
    expect(code, contains('Object encode()'));
    expect(code, contains('return _toList();'));
    expect(code, contains('List<Object?> _toList()'));
    expect(code, contains('success,'));
    expect(code, contains('error,'));
  });

  test('generic class with nullable type parameters', () {
    final classDefinition = Class(
      name: 'Optional',
      typeArguments: <TypeDeclaration>[const TypeDeclaration(baseName: 'T', isNullable: true)],
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'T', isNullable: true),
          name: 'value',
        ),
        NamedType(
          type: const TypeDeclaration(baseName: 'bool', isNullable: false),
          name: 'hasValue',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Optional<T?>'));
    expect(code, contains('T? value;'));
    expect(code, contains('bool hasValue;'));
    expect(code, isNot(contains('decode<T?>')));
  });

  test('complex generic class with mixed type constraints', () {
    final classDefinition = Class(
      name: 'ApiResponse',
      typeArguments: <TypeDeclaration>[
        const TypeDeclaration(baseName: 'TData', isNullable: false),
        const TypeDeclaration(baseName: 'TError', isNullable: true),
      ],
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'Map',
            isNullable: false,
            typeArguments: <TypeDeclaration>[
              TypeDeclaration(baseName: 'String', isNullable: false),
              TypeDeclaration(baseName: 'TData', isNullable: true),
            ],
          ),
          name: 'data',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'List',
            isNullable: true,
            typeArguments: <TypeDeclaration>[TypeDeclaration(baseName: 'TError', isNullable: true)],
          ),
          name: 'errors',
        ),
        NamedType(
          type: const TypeDeclaration(baseName: 'int', isNullable: false),
          name: 'statusCode',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class ApiResponse<TData, TError?>'));
    expect(code, contains('Map<String, TData?> data;'));
    expect(code, contains('List<TError?>? errors;'));
    expect(code, contains('int statusCode;'));
    expect(code, isNot(contains('decode<TData, TError?>')));
  });

  test('return nullable host', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(baseName: 'int', isNullable: true),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Future<int?> doit()'));
    expect(code, contains('return golubetsVar_replyValue as int?;'));
  });

  test('return nullable collection host', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(
                baseName: 'List',
                isNullable: true,
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Future<List<int?>?> doit()'));
    expect(code, contains('return (golubetsVar_replyValue as List<Object?>?)?.cast<int?>();'));
  });

  test('return nullable async host', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(baseName: 'int', isNullable: true),
              parameters: <Parameter>[],
              asynchronousType: AsynchronousType.callback,
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Future<int?> doit()'));
    expect(code, contains('return golubetsVar_replyValue as int?;'));
  });

  test('return nullable flutter', () {
    final root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration(baseName: 'int', isNullable: true),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('int? doit();'));
    expect(code, contains('final int? output = api.doit();'));
  });

  test('return nullable async flutter', () {
    final root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration(baseName: 'int', isNullable: true),
              parameters: <Parameter>[],
              asynchronousType: AsynchronousType.callback,
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Future<int?> doit();'));
    expect(code, contains('final int? output = await api.doit();'));
  });

  test('platform error for return nil on nonnull', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
      containsHostApi: true,
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Host platform returned null value for non-null return value.'));
  });

  test('nullable argument host', () {
    final root = Root(
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
                  type: const TypeDeclaration(baseName: 'int', isNullable: true),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Future<void> doit(int? foo) async {'));
  });

  test('nullable argument flutter', () {
    final root = Root(
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
                  type: const TypeDeclaration(baseName: 'int', isNullable: true),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('void doit(int? foo);'));
  });

  test('named argument flutter', () {
    final root = Root(
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
                  type: const TypeDeclaration(baseName: 'int', isNullable: false),
                  isNamed: true,
                  isPositional: false,
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('void doit({required int foo});'));
    expect(code, contains('api.doit(foo: arg_foo)'));
  });

  test('uses output package name for imports', () {
    const overriddenPackageName = 'custom_name';
    const outputPackageName = 'some_output_package';
    assert(outputPackageName != DEFAULT_PACKAGE_NAME);
    final Directory tempDir = Directory.systemTemp.createTempSync('golubets');
    try {
      final foo = Directory(path.join(tempDir.path, 'lib', 'foo'));
      foo.createSync(recursive: true);
      final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
name: foobar
''');
      final root = Root(classes: <Class>[], apis: <Api>[], enums: <Enum>[]);
      final sink = StringBuffer();
      const testGenerator = DartGenerator();
      testGenerator.generateTest(
        InternalDartOptions(
          dartOut: path.join(foo.path, 'bar.dart'),
          testOut: path.join(tempDir.path, 'test', 'bar_test.dart'),
          ignoreLints: false,
        ),
        root,
        sink,
        dartPackageName: overriddenPackageName,
        dartOutputPackageName: outputPackageName,
      );
      final code = sink.toString();
      expect(code, contains("import 'package:$outputPackageName/foo/bar.dart';"));
    } finally {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('transfers documentation comments', () {
    final comments = <String>[
      ' api comment',
      ' api method comment',
      ' class comment',
      ' class field comment',
      ' enum comment',
      ' enum member comment',
    ];
    var count = 0;

    final unspacedComments = <String>['////////'];
    var unspacedCount = 0;

    final root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
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
                  type: const TypeDeclaration(baseName: 'int', isNullable: true),
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
          documentationComments: <String>[comments[count++], unspacedComments[unspacedCount++]],
          members: <EnumMember>[
            EnumMember(name: 'one', documentationComments: <String>[comments[count++]]),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    for (final comment in comments) {
      expect(code, contains('///$comment'));
    }
    expect(code, contains('/// ///'));
  });

  test('creates custom codecs', () {
    final root = Root(
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
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                isNullable: false,
                associatedClass: emptyClass,
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('extends StandardMessageCodec'));
  });

  test('host test code handles enums', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          dartHostTestHandler: 'ApiMock',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Enum',
                    isNullable: false,
                    associatedEnum: emptyEnum,
                  ),
                  name: 'anEnum',
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[
        Enum(
          name: 'Enum',
          members: <EnumMember>[
            EnumMember(name: 'one'),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    final sink = StringBuffer();

    const testGenerator = DartGenerator();
    testGenerator.generateTest(
      const InternalDartOptions(dartOut: 'code.dart', testOut: 'test.dart', ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
      dartOutputPackageName: DEFAULT_PACKAGE_NAME,
    );

    final testCode = sink.toString();
    expect(testCode, contains('final Enum arg_anEnum = args[0]! as Enum;'));
    expect(testCode, contains('return value == null ? null : Enum.values[value];'));
    expect(testCode, contains('writeValue(buffer, value.index);'));
  });

  test('connection error contains channel name', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'method',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'Output', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
      containsHostApi: true,
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('\'Unable to establish connection on channel: "\$channelName".\''));
  });

  test('generate wrapResponse if is generating tests', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          dartHostTestHandler: 'ApiMock',
          methods: <Method>[
            Method(
              name: 'foo',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );

    final mainCodeSink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(testOut: 'test.dart', ignoreLints: false),
      root,
      mainCodeSink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final mainCode = mainCodeSink.toString();
    expect(mainCode, contains('List<Object?> wrapResponse('));
  });

  test('writes custom int codec without custom types', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(baseName: 'int', isNullable: true),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('if (value is int) {'));
    expect(code, contains('buffer.putUint8(4);'));
    expect(code, contains('buffer.putInt64(value);'));
  });

  test('sealed class', () {
    final superClass = Class(name: 'PlatformEvent', isSealed: true, fields: const <NamedType>[]);
    final root = Root(
      apis: <Api>[],
      classes: <Class>[
        superClass,
        Class(
          name: 'IntEvent',
          superClass: superClass,
          superClassName: superClass.name,
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'int', isNullable: false),
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
      ],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('sealed class PlatformEvent'));
    expect(code, contains('class IntEvent extends PlatformEvent'));
    expect(code, contains('class ClassEvent extends PlatformEvent'));
    expect(code, contains('result[0]! as int'));
    expect(code, contains('result[0] as Input?'));
  });

  test('empty class', () {
    final root = Root(
      apis: <Api>[],
      classes: <Class>[Class(name: 'EmptyClass', fields: <NamedType>[])],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('static EmptyClass decode(Object _)'));
    expect(code, isNot(contains('result as List<Object?>')));
  });

  test('gen class with constructors from the input', () {
    final classDefinition =
        Class(
            name: 'Foobar',
            fields: <NamedType>[
              NamedType(
                name: 'x',
                type: const TypeDeclaration(baseName: 'int', isNullable: false),
              ),
              NamedType(
                name: 'y',
                type: const TypeDeclaration(baseName: 'int', isNullable: true),
              ),
            ],
          )
          ..dartConstructors = <String>[
            'Foobar(this.x, {this.y});',
            '/// Doc.\nFoobar.fromX(this.x);',
          ]
          ..dartUnnamedConstructorPositionalFields = <String>['x'];
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('  Foobar(this.x, {this.y});'));
    expect(code, contains('  /// Doc.\n  Foobar.fromX(this.x);'));
    expect(code, isNot(contains('required this.x')));
    expect(code, contains('result[0]! as int,\n      y: result[1] as int?,'));
  });

  group('default values', () {
    test('gen class with string default value', () {
      final classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(baseName: 'String', isNullable: false),
            defaultValue: const StringLiteral(value: 'hello world'),
          ),
        ],
      );
      final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(ignoreLints: false),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains("this.field1 = 'hello world'"));
    });

    test('gen class with int default value', () {
      final classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(baseName: 'int', isNullable: false),
            defaultValue: const IntLiteral(value: 42),
          ),
        ],
      );
      final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(ignoreLints: false),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = 42'));
    });

    test('gen class with int default value for double type', () {
      final classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(baseName: 'double', isNullable: false),
            defaultValue: const IntLiteral(value: 42),
          ),
        ],
      );
      final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(ignoreLints: false),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = 42'));
    });

    test('gen class with double default value', () {
      final classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(baseName: 'double', isNullable: false),
            defaultValue: const DoubleLiteral(value: 3.14),
          ),
        ],
      );
      final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(ignoreLints: false),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = 3.14'));
    });

    test('gen class with bool default value', () {
      final classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(baseName: 'bool', isNullable: false),
            defaultValue: const BoolLiteral(value: true),
          ),
          NamedType(
            name: 'field2',
            type: const TypeDeclaration(baseName: 'bool', isNullable: false),
            defaultValue: const BoolLiteral(value: false),
          ),
        ],
      );
      final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(ignoreLints: false),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = true'));
      expect(code, contains('this.field2 = false'));
    });

    test('gen class with empty list default value', () {
      final classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(
              baseName: 'List',
              isNullable: false,
              typeArguments: <TypeDeclaration>[TypeDeclaration(baseName: 'int', isNullable: false)],
            ),
            defaultValue: const ListLiteral(
              elements: <DefaultValue>[],
              elementType: TypeDeclaration(baseName: 'int', isNullable: false),
            ),
          ),
        ],
      );
      final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(ignoreLints: false),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const <int>[]'));
    });

    test('gen class with list default value with elements', () {
      final classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: const TypeDeclaration(
              baseName: 'List',
              isNullable: false,
              typeArguments: <TypeDeclaration>[TypeDeclaration(baseName: 'int', isNullable: false)],
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
      final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(ignoreLints: false),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const <int>['));
      expect(code, contains('1,'));
      expect(code, contains('2,'));
      expect(code, contains('3'));
    });

    test('gen class with empty map default value', () {
      final classDefinition = Class(
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
      final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(ignoreLints: false),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const <String, int>{}'));
    });

    test('gen class with map default value with entries', () {
      final classDefinition = Class(
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
                StringLiteral(value: 'key1'): IntLiteral(value: 100),
                StringLiteral(value: 'key2'): IntLiteral(value: 200),
              },
              keyType: TypeDeclaration(baseName: 'String', isNullable: false),
              valueType: TypeDeclaration(baseName: 'int', isNullable: false),
            ),
          ),
        ],
      );
      final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(ignoreLints: false),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const <String, int>{'));
      expect(code, contains("'key1': 100,"));
      expect(code, contains("'key2': 200"));
    });

    test('gen class with enum default value', () {
      final testEnum = Enum(
        name: 'TestEnum',
        members: <EnumMember>[
          EnumMember(name: 'firstValue'),
          EnumMember(name: 'secondValue'),
        ],
      );
      final classDefinition = Class(
        name: 'Foobar',
        fields: <NamedType>[
          NamedType(
            name: 'field1',
            type: TypeDeclaration(
              baseName: 'TestEnum',
              isNullable: false,
              associatedEnum: testEnum,
            ),
            defaultValue: const EnumLiteral(name: 'TestEnum', value: 'firstValue'),
          ),
        ],
      );
      final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[testEnum]);
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(ignoreLints: false),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = TestEnum.firstValue'));
      expect(code, contains('enum TestEnum {'));
      expect(code, contains('firstValue,'));
      expect(code, contains('secondValue;'));
    });

    test('gen class with object creation default value', () {
      final innerClass = Class(
        name: 'InnerClass',
        fields: <NamedType>[
          NamedType(
            name: 'value',
            type: const TypeDeclaration(baseName: 'int', isNullable: false),
          ),
        ],
      );
      final classDefinition = Class(
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
              arguments: <DefaultValue>[IntLiteral(value: 42)],
            ),
          ),
        ],
      );
      final root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition, innerClass],
        enums: <Enum>[],
      );
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(ignoreLints: false),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const InnerClass('));
      expect(code, contains('42'));
      expect(code, contains('class InnerClass'));
    });

    test('gen class with object creation default value - no arguments', () {
      final innerClass = Class(name: 'InnerClass', fields: <NamedType>[]);
      final classDefinition = Class(
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
      final root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition, innerClass],
        enums: <Enum>[],
      );
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(ignoreLints: false),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const InnerClass()'));
    });

    test('gen class with named default value', () {
      final innerClass = Class(
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
      final classDefinition = Class(
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
                NamedDefaultValue(name: 'x', value: IntLiteral(value: 10)),
                NamedDefaultValue(name: 'y', value: IntLiteral(value: 20)),
              ],
            ),
          ),
        ],
      );
      final root = Root(
        apis: <Api>[],
        classes: <Class>[classDefinition, innerClass],
        enums: <Enum>[],
      );
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(ignoreLints: false),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const InnerClass('));
      expect(code, contains('x: 10,'));
      expect(code, contains('y: 20'));
    });

    test('gen class with nested list default value', () {
      final classDefinition = Class(
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
                  elementType: TypeDeclaration(baseName: 'String', isNullable: false),
                ),
                ListLiteral(
                  elements: <DefaultValue>[StringLiteral(value: 'c')],
                  elementType: TypeDeclaration(baseName: 'String', isNullable: false),
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
      final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(ignoreLints: false),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const <List<String>>['));
      expect(code, contains('const <String>['));
      expect(code, contains("'a',"));
      expect(code, contains("'b'"));
      expect(code, contains("'c'"));
    });
  });

  test('api with interface [useApiInterface] = true', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'SomeApi',
          methods: <Method>[
            Method(
              name: 'getNumber',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(baseName: 'int', isNullable: false),
                  name: 'number',
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false, useApiInterface: true),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('abstract interface class ISomeApi {'));
    expect(code, contains('Future<int> getNumber(int number);'));
    expect(code, contains('class SomeApi implements ISomeApi {'));
  });

  test('api without interface [useApiInterface] = false', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'SomeApi',
          methods: <Method>[
            Method(
              name: 'getNumber',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(baseName: 'int', isNullable: false),
                  name: 'number',
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, isNot(contains('abstract interface class ISomeApi {')));
    expect(code, isNot(contains('Future<int> getNumber(int number);')));
    expect(code, isNot(contains('class SomeApi implements ISomeApi {')));
  });

  test('data class equality', () {
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'int', isNullable: true),
          name: 'field1',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('bool operator ==(Object other) {'));
    expect(code, contains('int get hashCode =>'));
  });

  test('data class equality multi-field', () {
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'int', isNullable: true),
          name: 'field1',
        ),
        NamedType(
          type: const TypeDeclaration(baseName: 'String', isNullable: true),
          name: 'field2',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('bool operator ==(Object other) {'));
    expect(code, contains('int get hashCode =>'));
  });

  test('data class toString', () {
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'int', isNullable: true),
          name: 'field1',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('String toString() {'));
    expect(code, contains(r"return 'Foobar(field1: $field1)';"));
  });

  test('native interop host api unsupported error - getInstance', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'void', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    const options = InternalDartOptions(
      ignoreLints: false,
      useFfi: true,
      useJni: true,
      dartOut: 'lib/foo.dart',
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(options, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();

    expect(code, contains('Native Interop is not supported on this platform. Use Api instead.'));

    final nativeInteropSink = StringBuffer();
    generator.generateNativeInterop(
      options,
      root,
      nativeInteropSink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    expect(
      nativeInteropSink.toString(),
      contains('Native Interop is not supported on this platform. Use Api instead.'),
    );
  });

  test('native interop host api unsupported error - createWithNativeInteropApi', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'void', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(
        ignoreLints: false,
        useFfi: true,
        useJni: true,
        dartOut: 'lib/foo.dart',
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(
      code,
      contains(
        'Native Interop is not supported on this platform. Use the default constructor of Api instead.',
      ),
    );
  });

  test('gen constants', () {
    final root = Root(
      apis: <Api>[],
      classes: <Class>[],
      enums: <Enum>[],
      constants: <Constant>[
        Constant(
          name: 'stringConst',
          type: const TypeDeclaration(baseName: 'String', isNullable: false),
          value: 'hello',
        ),
        Constant(
          name: 'intConst',
          type: const TypeDeclaration(baseName: 'int', isNullable: false),
          value: 42,
        ),
        Constant(
          name: 'doubleConst',
          type: const TypeDeclaration(baseName: 'double', isNullable: false),
          value: 3.14,
        ),
        Constant(
          name: 'boolConst',
          type: const TypeDeclaration(baseName: 'bool', isNullable: false),
          value: true,
        ),
      ],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains("const String stringConst = 'hello';"));
    expect(code, contains('const int intConst = 42;'));
    expect(code, contains('const double doubleConst = 3.14;'));
    expect(code, contains('const bool boolConst = true;'));
  });

  test('fromJni handles field named type without colliding with static JType member', () {
    final root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foo',
          fields: <NamedType>[
            NamedType(
              name: 'type',
              type: const TypeDeclaration(baseName: 'int', isNullable: false),
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(ignoreLints: false, useJni: true, dartOut: 'lib/foo.dart'),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains(r'type: jniClass.type$1'));
  });

  test('native interop host api invokes jni methods correctly', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'isGetter',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'bool', isNullable: false),
            ),
            Method(
              name: 'getGetter',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
            ),
            Method(
              name: 'setSetter',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  name: 'value',
                  type: const TypeDeclaration(baseName: 'int', isNullable: false),
                ),
              ],
              returnType: const TypeDeclaration(baseName: 'void', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(
        ignoreLints: false,
        useJni: true,
        dartOut: 'lib/foo.dart',
        nativeInteropTransport: NativeInteropTransport.objects,
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('return _jniApi.isGetter;'));
    expect(code, contains('return _jniApi.getter;'));
    expect(code, contains('_jniApi.setter = value;'));
  });

  test('native interop converts sealed classes through their subclasses', () {
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(
        ignoreLints: false,
        useJni: true,
        useFfi: true,
        dartOut: 'lib/foo.dart',
        nativeInteropTransport: NativeInteropTransport.objects,
      ),
      buildSealedClassRoot(),
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('jni_bridge.Shape toJni() {'));
    expect(code, contains('final Circle child => child.toJni(),'));
    expect(code, contains('static Shape? fromJni(jni_bridge.Shape? jniClass) {'));
    expect(code, contains('if (jniClass.isA<jni_bridge.Circle>(jni_bridge.Circle.type)) {'));
    expect(
      code,
      contains(
        'return GolubetsInternalCircleNativeInterop.fromJni(jniClass.as(jni_bridge.Circle.type));',
      ),
    );
    expect(code, contains('ffi_bridge.ShapeBridge toFfi() {'));
    expect(code, contains('final Circle child => child.toFfi(),'));
    expect(code, contains('static Shape? fromFfi(ffi_bridge.ShapeBridge? ffiClass) {'));
    expect(code, contains('if (ffi_bridge.CircleBridge.isA(ffiClass)) {'));
    expect(
      code,
      contains(
        'return GolubetsInternalCircleNativeInterop.fromFfi(ffi_bridge.CircleBridge.as(ffiClass));',
      ),
    );
    expect(code, contains('jni_bridge.Circle toJni() {'));
    expect(code, contains('ffi_bridge.CircleBridge toFfi() {'));
    expect(
      code,
      contains('final jni_bridge.Shape golubetsVar_res = _jniApi.echoShape(shape.toJni());'),
    );
    expect(
      code,
      contains(
        'final Shape golubetsVar_dartTypeRes = GolubetsInternalShapeNativeInterop.fromJni(golubetsVar_res)!;',
      ),
    );
  });

  test('native interop codecs have no branch for sealed classes', () {
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(
        ignoreLints: false,
        useJni: true,
        useFfi: true,
        dartOut: 'lib/foo.dart',
      ),
      buildSealedClassRoot(),
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('value.isInstanceOf(_classCircle)'));
    expect(code, isNot(contains('value.isInstanceOf(_classShape)')));
    expect(code, contains('ffi_bridge.CircleBridge.isA(value)'));
    expect(code, isNot(contains('ffi_bridge.ShapeBridge.isA(value)')));
    expect(code, contains('value is Circle)'));
    expect(code, isNot(contains('value is Shape)')));
  });

  test('ffi toFfi allocates the bridge for a class without fields', () {
    final root = Root(
      apis: <Api>[],
      classes: <Class>[Class(name: 'Empty', fields: <NamedType>[])],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(ignoreLints: false, useFfi: true, dartOut: 'lib/foo.dart'),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('return ffi_bridge.EmptyBridge.alloc().init();'));
  });

  test('native interop code uses the member names that JNIgen generates', () {
    const string = TypeDeclaration(baseName: 'String', isNullable: false);
    const nullableString = TypeDeclaration(baseName: 'String', isNullable: true);
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'release',
              location: ApiLocation.host,
              parameters: <Parameter>[Parameter(name: 'value', type: string)],
              returnType: string,
            ),
            Method(
              name: 'register',
              location: ApiLocation.host,
              parameters: <Parameter>[Parameter(name: 'value', type: string)],
              returnType: string,
            ),
            Method(
              name: 'isNullable',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'bool', isNullable: true),
            ),
            Method(
              name: 'getDefault',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: string,
            ),
          ],
        ),
        AstFlutterApi(
          name: 'Callbacks',
          methods: <Method>[
            Method(
              name: 'type',
              location: ApiLocation.flutter,
              parameters: <Parameter>[],
              returnType: string,
            ),
            Method(
              name: 'implementIn',
              location: ApiLocation.flutter,
              parameters: <Parameter>[Parameter(name: 'value', type: string)],
              returnType: string,
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Data',
          fields: <NamedType>[
            NamedType(name: 'release', type: nullableString),
            NamedType(name: 'isNull', type: nullableString),
            NamedType(name: 'equals', type: nullableString),
            NamedType(
              name: 'isEnabled',
              type: const TypeDeclaration(baseName: 'bool', isNullable: false),
            ),
            NamedType(
              name: 'isMaybe',
              type: const TypeDeclaration(baseName: 'bool', isNullable: true),
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(
        ignoreLints: false,
        useJni: true,
        dartOut: 'lib/foo.dart',
        nativeInteropTransport: NativeInteropTransport.objects,
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    // Data class properties.
    expect(code, contains(r'release: jniClass.release$1?.'));
    expect(code, contains(r'isNull: jniClass.isNull$1()?.'));
    expect(code, contains('equals: jniClass.equals?.'));
    expect(code, contains('isEnabled: jniClass.isEnabled,'));
    expect(code, contains('isMaybe: jniClass.isMaybe()?.'));
    // Host API registrar members.
    expect(code, contains(r'_jniApi.release$1('));
    expect(code, contains(r'_jniApi.register$2('));
    expect(code, contains('_jniApi.isNullable()'));
    expect(code, contains(r'_jniApi.default$;'));
    // Flutter API interface overrides.
    expect(code, contains(r'JString type$1()'));
    expect(code, contains(r'JString implementIn$1(JString arg_value)'));
  });

  test('native interop code does not shadow parameters', () {
    const string = TypeDeclaration(baseName: 'String', isNullable: false);
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'echo',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(name: 'res', type: string),
                Parameter(name: 'error', type: string),
              ],
              returnType: string,
            ),
            Method(
              name: 'later',
              location: ApiLocation.host,
              asynchronousType: AsynchronousType.callback,
              parameters: <Parameter>[Parameter(name: 'completer', type: string)],
              returnType: string,
            ),
            Method(
              name: 'convert',
              location: ApiLocation.host,
              parameters: <Parameter>[Parameter(name: 'dartTypeRes', type: string)],
              returnType: string,
            ),
          ],
        ),
        AstFlutterApi(
          name: 'Callbacks',
          methods: <Method>[
            Method(
              name: 'send',
              location: ApiLocation.flutter,
              parameters: <Parameter>[
                Parameter(name: 'response', type: string),
                Parameter(name: 'errorOut', type: string),
              ],
              returnType: string,
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(
        ignoreLints: false,
        useFfi: true,
        useJni: true,
        ffiErrorClassName: 'GolubetsError',
        dartOut: 'lib/foo.dart',
        nativeInteropTransport: NativeInteropTransport.objects,
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(
      code,
      contains(
        'final JString golubetsVar_res = _jniApi.echo(_GolubetsJniCodec.writeValue<JString>(res), _GolubetsJniCodec.writeValue<JString>(error));',
      ),
    );
    expect(code, contains('final golubetsVar_error = ffi_bridge.GolubetsError();'));
    expect(
      code,
      contains(
        'error: _GolubetsFfiCodec.writeValue<NSString>(error), wrappedError: golubetsVar_error)',
      ),
    );
    expect(code, contains('final Completer<String> golubetsVar_completer = Completer<String>();'));
    expect(code, contains('_jniApi.convert(_GolubetsJniCodec.writeValue<JString>(dartTypeRes))'));
    expect(
      code,
      contains(
        '_GolubetsFfiCodec.writeValue<NSString>(dartTypeRes), wrappedError: golubetsVar_error)',
      ),
    );
    expect(code, contains('return golubetsVar_dartTypeRes;'));
    expect(code, isNot(contains(' dartTypeRes = ')));
    expect(code, contains('JString send(JString arg_response,JString arg_errorOut,)'));
    expect(
      code,
      contains(
        '(NSString? arg_response, NSString? arg_errorOut, ffi_bridge.GolubetsError errorOut)',
      ),
    );
  });

  test('test file does not include native interop code', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          dartHostTestHandler: 'ApiMock',
          methods: <Method>[
            Method(
              name: 'echo',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  name: 'value',
                  type: const TypeDeclaration(baseName: 'String', isNullable: false),
                ),
              ],
              returnType: const TypeDeclaration(baseName: 'String', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateTest(
      const InternalDartOptions(
        ignoreLints: false,
        useFfi: true,
        useJni: true,
        dartOut: 'lib/foo.dart',
        testOut: 'test/foo_test.dart',
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
      dartOutputPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('abstract class ApiMock'));
    expect(code, isNot(contains('jni_bridge')));
    expect(code, isNot(contains('ffi_bridge')));
    expect(code, isNot(contains('JString')));
    expect(code, isNot(contains('NSString')));
  });

  test('native interop codecs skip collections of ProxyApis', () {
    final proxyApi = AstProxyApi(
      name: 'Proxy',
      constructors: <Constructor>[],
      fields: <ApiField>[],
      methods: <Method>[],
    );
    final proxyType = TypeDeclaration(
      baseName: 'Proxy',
      isNullable: false,
      associatedProxyApi: proxyApi,
    );
    final root = Root(
      apis: <Api>[
        proxyApi,
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
      lists: <String, TypeDeclaration>{
        'List<Proxy>': TypeDeclaration(
          baseName: 'List',
          isNullable: false,
          typeArguments: <TypeDeclaration>[proxyType],
        ),
      },
      maps: <String, TypeDeclaration>{
        'Map<String, Proxy>': TypeDeclaration(
          baseName: 'Map',
          isNullable: false,
          typeArguments: <TypeDeclaration>[
            const TypeDeclaration(baseName: 'String', isNullable: false),
            proxyType,
          ],
        ),
      },
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(
        ignoreLints: false,
        useFfi: true,
        useJni: true,
        dartOut: 'lib/foo.dart',
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('class _GolubetsJniCodec'));
    expect(code, contains('class _GolubetsFfiCodec'));
    expect(code, isNot(contains('There is something wrong')));
  });

  test('ffi code uses the selectors that Swift infers', () {
    const string = TypeDeclaration(baseName: 'String', isNullable: false);
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'signIn',
              location: ApiLocation.host,
              parameters: <Parameter>[Parameter(name: 'value', type: string)],
              returnType: string,
            ),
            Method(
              name: 'signOut',
              location: ApiLocation.host,
              parameters: <Parameter>[Parameter(name: 'value', type: string)],
              returnType: string,
            ),
            Method(
              name: 'lookUp',
              location: ApiLocation.host,
              parameters: <Parameter>[Parameter(name: 'inList', type: string)],
              returnType: string,
            ),
            Method(
              name: 'goTo',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: string,
            ),
          ],
        ),
        AstFlutterApi(
          name: 'Callbacks',
          methods: <Method>[
            Method(
              name: 'implementIn',
              location: ApiLocation.flutter,
              parameters: <Parameter>[Parameter(name: 'value', type: string)],
              returnType: string,
            ),
            Method(
              name: 'goTo',
              location: ApiLocation.flutter,
              parameters: <Parameter>[],
              returnType: string,
            ),
            Method(
              name: 'goToAsync',
              location: ApiLocation.flutter,
              asynchronousType: AsynchronousType.callback,
              parameters: <Parameter>[],
              returnType: string,
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Data',
          fields: <NamedType>[
            NamedType(
              name: 'forKey',
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(
        ignoreLints: false,
        useFfi: true,
        ffiErrorClassName: 'GolubetsError',
        dartOut: 'lib/foo.dart',
        nativeInteropTransport: NativeInteropTransport.objects,
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('_ffiApi.signInValue('));
    expect(code, contains('_ffiApi.signOutWithValue('));
    expect(code, contains('_ffiApi.lookUpInList('));
    expect(code, contains('_ffiApi.goToWrappedError('));
    expect(code, contains('.implementInValue_error_'));
    expect(code, contains('.goToError_'));
    expect(code, contains('.goToAsyncWithError_completionHandler_'));
    expect(code, contains('DataBridge.alloc().initForKey('));
  });

  group('hybrid native interop transport', () {
    final dataClass = Class(
      name: 'Data',
      fields: <NamedType>[
        NamedType(
          name: 'value',
          type: const TypeDeclaration(baseName: 'int', isNullable: false),
        ),
      ],
    );
    final anEnum = Enum(
      name: 'Color',
      members: <EnumMember>[
        EnumMember(name: 'red'),
        EnumMember(name: 'green'),
      ],
    );
    TypeDeclaration dataType({bool isNullable = false}) =>
        TypeDeclaration(baseName: 'Data', isNullable: isNullable, associatedClass: dataClass);
    TypeDeclaration enumType({bool isNullable = false}) =>
        TypeDeclaration(baseName: 'Color', isNullable: isNullable, associatedEnum: anEnum);
    const intType = TypeDeclaration(baseName: 'int', isNullable: false);

    List<Method> methods(ApiLocation location) => <Method>[
      Method(
        name: 'echoData',
        location: location,
        parameters: <Parameter>[
          Parameter(name: 'count', type: intType),
          Parameter(name: 'data', type: dataType()),
          Parameter(
            name: 'list',
            type: TypeDeclaration(
              baseName: 'List',
              isNullable: false,
              typeArguments: <TypeDeclaration>[dataType(isNullable: true)],
            ),
          ),
        ],
        returnType: dataType(isNullable: true),
      ),
      Method(
        name: 'add',
        location: location,
        parameters: <Parameter>[
          Parameter(name: 'a', type: intType),
          Parameter(name: 'b', type: intType),
        ],
        returnType: intType,
      ),
      Method(
        name: 'echoColor',
        location: location,
        parameters: <Parameter>[Parameter(name: 'color', type: enumType(isNullable: true))],
        returnType: enumType(isNullable: true),
      ),
      Method(
        name: 'echoAsyncData',
        location: location,
        asynchronousType: AsynchronousType.callback,
        parameters: <Parameter>[Parameter(name: 'data', type: dataType())],
        returnType: dataType(isNullable: true),
      ),
    ];

    String generate({required bool useJni, required bool useFfi, bool hybrid = true}) {
      final root = Root(
        apis: <Api>[
          AstHostApi(name: 'HostApi', methods: methods(ApiLocation.host)),
          AstFlutterApi(name: 'FlutterApi', methods: methods(ApiLocation.flutter)),
        ],
        classes: <Class>[dataClass],
        enums: <Enum>[anEnum],
      );
      final sink = StringBuffer();
      const DartGenerator().generateNativeInterop(
        InternalDartOptions(
          ignoreLints: false,
          useJni: useJni,
          useFfi: useFfi,
          ffiErrorClassName: 'GolubetsError',
          jniErrorClassName: 'FlutterError',
          dartOut: 'lib/foo.dart',
          nativeInteropTransport: hybrid
              ? NativeInteropTransport.hybrid
              : NativeInteropTransport.objects,
        ),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      return sink.toString();
    }

    test('jni host methods encode structured arguments into one buffer', () {
      final String code = generate(useJni: true, useFfi: false);
      expect(
        code,
        contains(
          'final JByteArray golubetsVar_args = _GolubetsJniBuffers.encode(<Object?>[data, list]);',
        ),
      );
      expect(code, contains('_jniApi.echoData(count, golubetsVar_args)'));
      expect(code, contains('await _jniApi.echoAsyncData(golubetsVar_args)'));
      expect(code, contains('return _GolubetsJniBuffers.decode(golubetsVar_res) as Data?;'));
      expect(code, contains('golubetsVar_args.release();'));
    });

    test('jni host methods pass scalars and enums directly', () {
      final String code = generate(useJni: true, useFfi: false);
      expect(code, contains('return _jniApi.add(a, b);'));
      expect(code, contains('_jniApi.echoColor(color?.index ?? -1)'));
      expect(
        code,
        contains('return golubetsVar_res == -1 ? null : Color.values[golubetsVar_res];'),
      );
    });

    test('jni flutter api implements the buffer bridge', () {
      final String code = generate(useJni: true, useFfi: false);
      expect(code, contains(r'final class _FlutterApiRegistrar with jni_bridge.$FlutterApiBridge'));
      expect(code, contains('jni_bridge.FlutterApiBridge.implement(this)'));
      expect(code, contains('JByteArray? echoData(int arg_count, JByteArray golubetsVar_args)'));
      expect(code, contains('return _GolubetsJniBuffers.encodeOrNull(response);'));
      expect(code, contains('int add(int arg_a, int arg_b)'));
    });

    test('jni error details are decoded from the buffer', () {
      final String code = generate(useJni: true, useFfi: false);
      expect(
        code,
        contains('details: _GolubetsJniBuffers.decode(golubetsError.details as JByteArray?)'),
      );
    });

    test('ffi host methods encode structured arguments into one buffer', () {
      final String code = generate(useJni: false, useFfi: true);
      expect(
        code,
        contains(
          'final NSData golubetsVar_args = _GolubetsFfiBuffers.encode(<Object?>[data, list]);',
        ),
      );
      expect(
        code,
        contains(
          '_ffiApi.echoDataWithCount(count, golubetsVar_args: golubetsVar_args, wrappedError: golubetsVar_error)',
        ),
      );
      expect(code, contains('return _GolubetsFfiBuffers.decode(golubetsVar_res) as Data?;'));
      expect(code, contains('_ffiApi.addWithA(a, b: b, wrappedError: golubetsVar_error)'));
    });

    test('ffi flutter api implements the buffer protocol', () {
      final String code = generate(useJni: false, useFfi: true);
      expect(
        code,
        contains(r'FlutterApiBridge$Builder.echoDataWithCount_golubetsVar_args_error_.implement('),
      );
      expect(code, contains(r'FlutterApiBridge$Builder.addWithA_b_error_.implement('));
      expect(code, contains('return _GolubetsFfiBuffers.encodeOrNull(response);'));
    });

    test('objects transport does not generate buffer helpers', () {
      final String code = generate(useJni: true, useFfi: true, hybrid: false);
      expect(code, isNot(contains('_GolubetsJniBuffers')));
      expect(code, isNot(contains('_GolubetsFfiBuffers')));
      expect(code, isNot(contains('golubetsVar_args')));
    });

    test('jni codec looks up each class once', () {
      final String code = generate(useJni: true, useFfi: false, hybrid: false);
      expect(code, contains('static final JClass _longClass = JLong.type.jClass;'));
      expect(code, contains('static final JClass _classData = jni_bridge.Data.type.jClass;'));
      expect(code, contains('if (value.isInstanceOf(_longClass)) {'));
      expect(code, isNot(contains('value.isA<')));
    });

    test(
      'jni hybrid binding namer resolves JavaBean property collisions across enums and buffers',
      () {
        final root = Root(
          apis: <Api>[
            AstHostApi(
              name: 'BeanHostApi',
              methods: <Method>[
                Method(
                  name: 'getMode',
                  location: ApiLocation.host,
                  parameters: <Parameter>[],
                  returnType: enumType(),
                ),
                Method(
                  name: 'setMode',
                  location: ApiLocation.host,
                  parameters: <Parameter>[
                    Parameter(name: 'mode', type: enumType(isNullable: true)),
                  ],
                  returnType: const TypeDeclaration.voidDeclaration(),
                ),
                Method(
                  name: 'getCount',
                  location: ApiLocation.host,
                  parameters: <Parameter>[],
                  returnType: intType,
                ),
                Method(
                  name: 'setCount',
                  location: ApiLocation.host,
                  parameters: <Parameter>[
                    Parameter(name: 'count', type: enumType(isNullable: true)),
                  ],
                  returnType: const TypeDeclaration.voidDeclaration(),
                ),
                Method(
                  name: 'getData',
                  location: ApiLocation.host,
                  parameters: <Parameter>[],
                  returnType: dataType(),
                ),
                Method(
                  name: 'setData',
                  location: ApiLocation.host,
                  parameters: <Parameter>[
                    Parameter(
                      name: 'items',
                      type: const TypeDeclaration(
                        baseName: 'List',
                        isNullable: false,
                        typeArguments: <TypeDeclaration>[intType],
                      ),
                    ),
                  ],
                  returnType: const TypeDeclaration.voidDeclaration(),
                ),
              ],
            ),
          ],
          classes: <Class>[dataClass],
          enums: <Enum>[anEnum],
        );
        final sink = StringBuffer();
        const DartGenerator().generateNativeInterop(
          const InternalDartOptions(
            ignoreLints: false,
            useJni: true,
            jniErrorClassName: 'FlutterError',
            dartOut: 'lib/foo.dart',
          ),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final code = sink.toString();
        expect(code, contains('final int golubetsVar_res = _jniApi.mode;'));
        expect(code, contains('_jniApi.mode = mode?.index ?? -1;'));
        expect(code, contains('return _jniApi.count;'));
        expect(code, contains('_jniApi.count = count?.index ?? -1;'));
        expect(code, contains('final JByteArray? golubetsVar_res = _jniApi.data;'));
        expect(code, contains('_jniApi.data = golubetsVar_args;'));
      },
    );

    test(
      'jni hybrid host and flutter methods avoid parameter name collisions and release JNI temporaries',
      () {
        const stringType = TypeDeclaration(baseName: 'String', isNullable: false);
        final collisionMethods = <Method>[
          Method(
            name: 'sendWithArgsName',
            location: ApiLocation.host,
            parameters: <Parameter>[
              Parameter(name: 'args', type: stringType),
              Parameter(name: 'data', type: dataType()),
            ],
            returnType: dataType(isNullable: true),
          ),
        ];
        final flutterCollisionMethods = <Method>[
          Method(
            name: 'onWithArgsName',
            location: ApiLocation.flutter,
            parameters: <Parameter>[
              Parameter(name: 'args', type: stringType),
              Parameter(name: 'data', type: dataType()),
            ],
            returnType: dataType(isNullable: true),
          ),
        ];
        final root = Root(
          apis: <Api>[
            AstHostApi(name: 'HostApi', methods: collisionMethods),
            AstFlutterApi(name: 'FlutterApi', methods: flutterCollisionMethods),
          ],
          classes: <Class>[dataClass],
          enums: <Enum>[anEnum],
        );
        final sink = StringBuffer();
        const DartGenerator().generateNativeInterop(
          const InternalDartOptions(
            ignoreLints: false,
            useJni: true,
            jniErrorClassName: 'FlutterError',
            dartOut: 'lib/foo.dart',
          ),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final code = sink.toString();
        // Verify `golubetsVar_args` is encoded before allocating `golubetsVar_arg_args`,
        // and that `args` does not collide with `golubetsVar_args`.
        final int encodeIndex = code.indexOf(
          'final JByteArray golubetsVar_args = _GolubetsJniBuffers.encode(<Object?>[data]);',
        );
        final int allocDirectIndex = code.indexOf(
          'final JString golubetsVar_arg_args = args.toJString();',
        );
        expect(encodeIndex, greaterThanOrEqualTo(0));
        expect(allocDirectIndex, greaterThan(encodeIndex));
        expect(code, contains('_jniApi.sendWithArgsName(golubetsVar_arg_args, golubetsVar_args)'));
        expect(code, contains('golubetsVar_arg_args.release();'));

        // Verify FlutterApi releases direct JNI parameters before decoding the buffer.
        final int releaseDirectFlutterIndex = code.indexOf(
          'final String golubetsVar_arg_args = arg_args.toDartString(releaseOriginal: true);',
        );
        final int decodeFlutterIndex = code.indexOf(
          'final List<Object?> golubetsVar_decodedArgs = _GolubetsJniBuffers.decode(golubetsVar_args)!',
        );
        expect(releaseDirectFlutterIndex, greaterThanOrEqualTo(0));
        expect(decodeFlutterIndex, greaterThan(releaseDirectFlutterIndex));
      },
    );
  });

  test(
    'main dart output with native interop is web-safe and conditionally imports native interop file',
    () {
      expect(getNativeInteropDartPath('lib/src/foo.g.dart'), 'lib/src/foo.native_interop.g.dart');
      expect(
        getNativeInteropDartPath('lib/src/foo.gen.dart'),
        'lib/src/foo.native_interop.gen.dart',
      );
      expect(getNativeInteropDartPath('lib/src/foo.dart'), 'lib/src/foo.native_interop.dart');

      const string = TypeDeclaration(baseName: 'String', isNullable: false);
      final root = Root(
        apis: <Api>[
          AstHostApi(
            name: 'Api',
            methods: <Method>[
              Method(
                name: 'echo',
                location: ApiLocation.host,
                parameters: <Parameter>[Parameter(name: 'value', type: string)],
                returnType: string,
              ),
            ],
          ),
          AstFlutterApi(
            name: 'Callbacks',
            methods: <Method>[
              Method(
                name: 'onEvent',
                location: ApiLocation.flutter,
                parameters: <Parameter>[Parameter(name: 'value', type: string)],
                returnType: const TypeDeclaration.voidDeclaration(),
              ),
            ],
          ),
        ],
        classes: <Class>[
          Class(
            name: 'Data',
            fields: <NamedType>[NamedType(name: 'value', type: string)],
          ),
        ],
        enums: <Enum>[
          Enum(
            name: 'MyEnum',
            members: <EnumMember>[EnumMember(name: 'one')],
          ),
        ],
      );
      const options = InternalDartOptions(
        ignoreLints: false,
        useFfi: true,
        useJni: true,
        ffiErrorClassName: 'GolubetsError',
        jniErrorClassName: 'GolubetsError',
        dartOut: 'lib/foo.g.dart',
      );
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(options, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
      final code = sink.toString();

      expect(code, isNot(contains("import 'dart:ffi'")));
      expect(code, isNot(contains("import 'dart:io'")));
      expect(code, isNot(contains("import 'package:ffi/ffi.dart'")));
      expect(code, isNot(contains("import 'package:jni/jni.dart'")));
      expect(code, isNot(contains("import 'package:objective_c/objective_c.dart'")));
      expect(code, isNot(contains('ffi_bridge')));
      expect(code, isNot(contains('jni_bridge')));
      expect(code, isNot(contains('toJni')));
      expect(code, isNot(contains('toFfi')));
      expect(
        code,
        contains(
          "import './foo.g.dart'\n"
          "    if (dart.library.ffi) './foo.native_interop.g.dart'\n"
          '    as golubets_native;',
        ),
      );
      expect(code, contains("import 'package:flutter/foundation.dart' show kIsWeb;"));
      expect(code, contains('if (!kIsWeb) {'));
      expect(code, isNot(contains('if (!kIsWeb && api != null) {')));
      expect(code, contains('golubets_native.golubets_set_up_Callbacks('));
      expect(
        code,
        contains(
          "import 'package:meta/meta.dart' show immutable, internal, protected, visibleForTesting;",
        ),
      );
      expect(
        code,
        contains("const String defaultInstanceName = '$defaultNativeInteropInstanceName';"),
      );
      expect(code, contains('@internal\nApiForNativeInterop? golubets_getInstance_Api({'));
      expect(code, contains('golubets_native.golubets_getInstance_Api(channelName: channelName)'));
      expect(
        code,
        contains(
          'static ApiForNativeInterop? getInstance({String channelName = defaultInstanceName}) =>',
        ),
      );
      expect(
        code,
        contains(
          r"No Api instance with ${messageChannelSuffix.isEmpty ? 'no ' : ''}instance name ",
        ),
      );
      expect(code, contains('@internal\nCallbacks golubets_register_Callbacks('));
      expect(code, contains('@internal\nvoid golubets_unregister_Callbacks(\n  Callbacks api, {'));
      expect(code, contains('@internal\nvoid golubets_set_up_Callbacks('));
      expect(code, contains('final class CallbacksRegistrar'));
      expect(code, isNot(contains('const CallbacksRegistrar._();')));
      expect(code, contains('  Callbacks register(\n    Callbacks api, {'));
      expect(code, contains('  void unregister(\n    Callbacks api, {'));
      expect(code, contains('golubets_native.golubets_register_Callbacks('));
      expect(code, contains('golubets_native.golubets_unregister_Callbacks('));
      expect(code, contains('static Callbacks implement(Callbacks api, {'));
      expect(code, contains('name: name.isEmpty ? defaultInstanceName : name,'));

      final nativeInteropSink = StringBuffer();
      generator.generateNativeInterop(
        options,
        root,
        nativeInteropSink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final nativeInteropCode = nativeInteropSink.toString();
      expect(nativeInteropCode, contains("import './foo.g.dart';"));
      expect(nativeInteropCode, isNot(contains('_defaultInstanceName')));
      expect(nativeInteropCode, contains('void _throwNoInstanceError(String channelName) {'));
      expect(
        nativeInteropCode,
        contains(
          'ApiForNativeInterop? golubets_getInstance_Api({\n'
          '  String channelName = defaultInstanceName,\n'
          '}) => _ApiForNativeInterop.getInstance(channelName: channelName);',
        ),
      );
      expect(nativeInteropCode, contains('extension GolubetsInternalDataNativeInterop on Data'));
      expect(
        nativeInteropCode,
        contains('extension GolubetsInternalMyEnumNativeInterop on MyEnum'),
      );
      expect(
        nativeInteropCode,
        contains('class _ApiForNativeInterop implements ApiForNativeInterop'),
      );
      expect(
        nativeInteropCode,
        contains(
          'static ApiForNativeInterop? getInstance({String channelName = defaultInstanceName}) {',
        ),
      );
      expect(nativeInteropCode, contains('_throwNoInstanceError(channelName);'));
      expect(
        nativeInteropCode,
        contains('return _ApiForNativeInterop._withRegistrar(jniApi: link);'),
      );
      expect(
        nativeInteropCode,
        contains('return _ApiForNativeInterop._withRegistrar(ffiApi: link);'),
      );
      expect(nativeInteropCode, contains('final class _CallbacksRegistrar'));
      expect(nativeInteropCode, contains('_CallbacksRegistrar(this.golubetsVar_dartApi);'));
      expect(nativeInteropCode, contains('golubetsVar_registeredHandles'));
      expect(nativeInteropCode, contains('golubetsVar_setUpInstances'));
      expect(nativeInteropCode, contains('Callbacks golubets_register_Callbacks('));
      expect(nativeInteropCode, contains('void golubets_unregister_Callbacks('));
      expect(nativeInteropCode, contains('registrar.registerInstance('));
      expect(nativeInteropCode, contains('registrar.unregisterInstance('));
      expect(nativeInteropCode, contains('ffi_bridge.CallbacksRegistrar.registerInstanceWithApi('));
      expect(
        nativeInteropCode,
        contains('ffi_bridge.CallbacksRegistrar.unregisterInstanceWithApi('),
      );
      expect(nativeInteropCode, contains('(removedHandle as JObject).release();'));
      expect(nativeInteropCode, contains('(removedHandle as ObjCObject).ref.release();'));
      expect(nativeInteropCode, contains('final Callbacks golubetsVar_dartApi;'));
      expect(nativeInteropCode, isNot(contains('if (dartApi != null)')));

      // Verify single-platform import isolation in generateNativeInterop.
      final jniOnlySink = StringBuffer();
      generator.generateNativeInterop(
        const InternalDartOptions(
          ignoreLints: false,
          useJni: true,
          jniErrorClassName: 'GolubetsError',
          dartOut: 'lib/foo.g.dart',
        ),
        root,
        jniOnlySink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final jniOnlyCode = jniOnlySink.toString();
      expect(jniOnlyCode, contains("import 'package:jni/jni.dart';"));
      expect(jniOnlyCode, contains("import './foo.g.jni.dart' as jni_bridge;"));
      expect(jniOnlyCode, contains('registrar.unregisterInstance('));
      expect(jniOnlyCode, isNot(contains('unregisterInstanceWithApi(')));
      expect(jniOnlyCode, isNot(contains('ObjCObject')));
      expect(jniOnlyCode, isNot(contains("import 'dart:ffi';")));
      expect(jniOnlyCode, isNot(contains("import 'package:ffi/ffi.dart';")));
      expect(jniOnlyCode, isNot(contains("import 'package:objective_c/objective_c.dart';")));
      expect(jniOnlyCode, isNot(contains('ffi_bridge')));

      final ffiOnlySink = StringBuffer();
      generator.generateNativeInterop(
        const InternalDartOptions(
          ignoreLints: false,
          useFfi: true,
          ffiErrorClassName: 'GolubetsError',
          dartOut: 'lib/foo.g.dart',
        ),
        root,
        ffiOnlySink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final ffiOnlyCode = ffiOnlySink.toString();
      expect(ffiOnlyCode, contains("import 'dart:ffi';"));
      expect(ffiOnlyCode, contains("import 'package:ffi/ffi.dart';"));
      expect(ffiOnlyCode, contains("import 'package:objective_c/objective_c.dart';"));
      expect(ffiOnlyCode, contains("import './foo.g.ffi.dart' as ffi_bridge;"));
      expect(ffiOnlyCode, contains('ffi_bridge.CallbacksRegistrar.unregisterInstanceWithApi('));
      expect(ffiOnlyCode, contains('(removedHandle as ObjCObject).ref.release();'));
      expect(ffiOnlyCode, isNot(contains('registrar.unregisterInstance(')));
      expect(ffiOnlyCode, isNot(contains("import 'package:jni/jni.dart';")));
      expect(ffiOnlyCode, isNot(contains('jni_bridge')));
    },
  );

  test('native interop JNI HostApi orders instance registrar methods before API methods', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'register',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'void', isNullable: false),
            ),
            Method(
              name: 'unregister',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'void', isNullable: false),
            ),
            Method(
              name: 'getGetInstance',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'String', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    const dartOptions = InternalDartOptions(
      ignoreLints: false,
      useJni: true,
      dartOut: 'lib/foo.g.dart',
    );
    final mainSink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(dartOptions, root, mainSink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final sink = StringBuffer();
    generator.generateNativeInterop(dartOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    // `register` and `unregister` each have two instance overloads declared
    // before the API methods. With no `getInstance(name)` on the registrar,
    // JNIgen's getter for `getGetInstance` keeps the plain name.
    expect(code, contains(r'_jniApi.register$2()'));
    expect(code, contains(r'_jniApi.unregister$2()'));
    expect(code, contains('_jniApi.getInstance;'));
    expect(code, isNot(contains(r'_jniApi.getInstance$1')));
    expect(code, contains('link = jni_bridge.ApiRegistrar.golubetsResolveInstance('));
    expect(code, contains('jni_bridge.ApiRegistrar.golubetsEngineKeyOf(link)'));
  });

  group('native interop engine keys', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'void', isNullable: false),
            ),
          ],
        ),
        AstFlutterApi(
          name: 'Callbacks',
          methods: <Method>[
            Method(
              name: 'onEvent',
              location: ApiLocation.flutter,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'void', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );

    String generateNativeInterop(InternalDartOptions options, Root root) {
      final sink = StringBuffer();
      const DartGenerator().generateNativeInterop(
        options,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      return sink.toString();
    }

    const jniOptions = InternalDartOptions(
      ignoreLints: false,
      useJni: true,
      jniErrorClassName: 'GolubetsError',
      dartOut: 'lib/foo.g.dart',
    );
    const ffiOptions = InternalDartOptions(
      ignoreLints: false,
      useFfi: true,
      ffiErrorClassName: 'GolubetsError',
      dartOut: 'lib/foo.g.dart',
    );

    test('emits engine affinity state once per file', () {
      final String code = generateNativeInterop(jniOptions, root);
      expect(code, contains("import 'dart:ui' show PlatformDispatcher;"));
      expect(
        'const int _golubetsNoEngineKey = -9223372036854775808;'.allMatches(code),
        hasLength(1),
      );
      expect('int? _golubetsEngineAffinity;'.allMatches(code), hasLength(1));
    });

    test('omits engine affinity state without APIs', () {
      final String code = generateNativeInterop(
        jniOptions,
        Root(
          apis: <Api>[],
          classes: <Class>[
            Class(
              name: 'Data',
              fields: <NamedType>[
                NamedType(
                  type: const TypeDeclaration(baseName: 'int', isNullable: true),
                  name: 'value',
                ),
              ],
            ),
          ],
          enums: <Enum>[],
        ),
      );
      expect(code, isNot(contains('dart:ui')));
      expect(code, isNot(contains('_golubetsNoEngineKey')));
      expect(code, isNot(contains('_golubetsEngineAffinity')));
    });

    test('JNI HostApi resolves by engine id and records affinity', () {
      final String code = generateNativeInterop(jniOptions, root);
      expect(
        code,
        contains(
          'final int? engineId = PlatformDispatcher.instance.engineId;\n'
          '      final JString jName = channelName.toJString();\n'
          '      final jni_bridge.ApiRegistrar? link;\n'
          '      try {\n'
          '        link = jni_bridge.ApiRegistrar.golubetsResolveInstance(\n'
          '          engineId ?? _golubetsNoEngineKey,\n'
          '          _golubetsEngineAffinity ?? _golubetsNoEngineKey,\n'
          '          jName,\n'
          '        );\n'
          '      } finally {\n'
          '        jName.release();\n'
          '      }\n'
          '      if (link == null) {\n'
          '        _throwNoInstanceError(channelName);\n'
          '      }\n'
          '      if (link != null && _golubetsEngineAffinity == null) {\n'
          '        final int linkEngineKey = jni_bridge.ApiRegistrar.golubetsEngineKeyOf(link);\n'
          '        if (linkEngineKey != _golubetsNoEngineKey && (engineId == null || linkEngineKey < 0)) {\n'
          '          _golubetsEngineAffinity = linkEngineKey;\n'
          '          _golubetsUpdateFlutterApiEngineAffinity();\n'
          '        }\n'
          '      }\n',
        ),
      );
      expect(code, isNot(contains('ApiRegistrar().getInstance(')));
    });

    test('FFI HostApi resolves by engine id and records affinity', () {
      final String code = generateNativeInterop(ffiOptions, root);
      expect(
        code,
        contains(
          'final ffi_bridge.ApiSetup? link = ffi_bridge.ApiSetup.golubetsResolveInstanceWithEngineId(\n'
          '        engineId ?? _golubetsNoEngineKey,\n'
          '        affinityKey: _golubetsEngineAffinity ?? _golubetsNoEngineKey,\n'
          '        name: NSString(channelName),\n'
          '      );\n'
          '      if (link == null) {\n'
          '        _throwNoInstanceError(channelName);\n'
          '      }\n',
        ),
      );
      expect(
        code,
        contains(
          '      if (link != null && _golubetsEngineAffinity == null) {\n'
          '        final int linkEngineKey = ffi_bridge.ApiSetup.golubetsEngineKeyOf(link);\n'
          '        if (linkEngineKey != _golubetsNoEngineKey && (engineId == null || linkEngineKey < 0)) {\n'
          '          _golubetsEngineAffinity = linkEngineKey;\n'
          '          _golubetsUpdateFlutterApiEngineAffinity();\n'
          '        }\n'
          '      }\n',
        ),
      );
      expect(code, isNot(contains('getInstanceWithName')));
    });

    test('FlutterApi registration passes engine keys to native', () {
      final String jniCode = generateNativeInterop(jniOptions, root);
      expect(
        jniCode,
        contains(
          'final int engineId = PlatformDispatcher.instance.engineId ?? _golubetsNoEngineKey;\n'
          '    final int affinityKey = _golubetsEngineAffinity ?? _golubetsNoEngineKey;\n',
        ),
      );
      expect(
        jniCode,
        contains(
          'final jni_bridge.CallbacksRegistrar registrar = jni_bridge.CallbacksRegistrar();\n'
          '      try {\n'
          '        registrar.registerInstance(impl, engineId, affinityKey, jName);\n'
          '      } catch (_) {\n'
          '        impl.release();\n'
          '        rethrow;\n'
          '      } finally {\n'
          '        registrar.release();\n'
          '        jName.release();\n'
          '      }\n',
        ),
      );

      final String ffiCode = generateNativeInterop(ffiOptions, root);
      expect(
        ffiCode,
        contains(
          'ffi_bridge.CallbacksRegistrar.registerInstanceWithApi(\n'
          '        impl,\n'
          '        engineId: engineId,\n'
          '        affinityKey: affinityKey,\n'
          '        name: NSString(name),\n'
          '      );',
        ),
      );
    });

    test('learning affinity re-sends FlutterApi registrations to native', () {
      final String jniCode = generateNativeInterop(jniOptions, root);
      expect(
        jniCode,
        contains(
          'void _golubetsUpdateFlutterApiEngineAffinity() {\n'
          '  _CallbacksRegistrar.golubetsVar_updateEngineAffinity();\n'
          '}',
        ),
      );
      expect(jniCode, contains('static void golubetsVar_updateEngineAffinity() {'));
      expect(
        jniCode,
        contains(
          'registrar.registerInstance(handle as jni_bridge.CallbacksBridge, engineId, affinityKey, jName);',
        ),
      );

      final String ffiCode = generateNativeInterop(ffiOptions, root);
      expect(ffiCode, contains('_golubetsUpdateFlutterApiEngineAffinity();'));
      expect(
        ffiCode,
        contains(
          'ffi_bridge.CallbacksRegistrar.registerInstanceWithApi(\n'
          '            handle as ffi_bridge.CallbacksBridge,\n'
          '            engineId: engineId,\n'
          '            affinityKey: affinityKey,\n'
          '            name: NSString(entry.key),\n'
          '          );',
        ),
      );
    });

    test('omits the FlutterApi affinity update without FlutterApis', () {
      final String code = generateNativeInterop(
        jniOptions,
        Root(
          apis: root.apis.whereType<AstHostApi>().toList(),
          classes: root.classes,
          enums: root.enums,
        ),
      );
      expect(code, contains('_golubetsEngineAffinity = linkEngineKey;'));
      expect(code, isNot(contains('_golubetsUpdateFlutterApiEngineAffinity')));
    });

    test('omits FlutterApi affinity state without HostApis', () {
      for (final options in <InternalDartOptions>[jniOptions, ffiOptions]) {
        final String code = generateNativeInterop(
          options,
          Root(
            apis: root.apis.whereType<AstFlutterApi>().toList(),
            classes: root.classes,
            enums: root.enums,
          ),
        );
        expect(code, contains('const int _golubetsNoEngineKey'));
        expect(code, contains('const int affinityKey = _golubetsNoEngineKey;'));
        expect(code, isNot(contains('_golubetsEngineAffinity')));
        expect(code, isNot(contains('golubetsVar_updateEngineAffinity')));
      }
    });

    test('FlutterApi re-registration keeps the setUp instance tracked', () {
      for (final options in <InternalDartOptions>[jniOptions, ffiOptions]) {
        final String code = generateNativeInterop(options, root);
        final int removeHandleStart = code.indexOf('static void golubetsVar_removeHandle(');
        final int registerStart = code.indexOf(
          'Callbacks golubetsVar_register({String name = defaultInstanceName}) {',
        );
        expect(removeHandleStart, isNonNegative);
        expect(registerStart, greaterThan(removeHandleStart));

        // Dedup in register only removes the native handle, so that
        // setUp(a) -> Registrar.register(a) -> setUp(null) still unregisters a.
        final String removeHandle = code.substring(removeHandleStart, registerStart);
        expect(removeHandle, isNot(contains('setUpInstances')));
        final String register = code.substring(registerStart);
        expect(
          register,
          startsWith(
            'Callbacks golubetsVar_register({String name = defaultInstanceName}) {\n'
            '    golubetsVar_removeHandle(golubetsVar_dartApi, name: name);\n',
          ),
        );

        // The public unregister path still clears the setUp slot.
        expect(
          code,
          contains(
            'static void golubetsVar_unregister(Callbacks api, {String name = defaultInstanceName}) {\n'
            '    if (identical(golubetsVar_setUpInstances[name], api)) {\n'
            '      golubetsVar_setUpInstances.remove(name);\n'
            '    }\n'
            '    golubetsVar_removeHandle(api, name: name);\n'
            '  }',
          ),
        );
      }
    });
  });

  test('native interop JNI FlutterApi registrar methods are not renamed by API methods', () {
    final root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Callbacks',
          methods: <Method>[
            Method(
              name: 'register',
              location: ApiLocation.flutter,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'void', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const DartGenerator().generateNativeInterop(
      const InternalDartOptions(ignoreLints: false, useJni: true, dartOut: 'lib/foo.g.dart'),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    // The registrar is a separate Kotlin class from the bridge interface, so
    // an API method named `register` does not rename its methods.
    expect(code, contains('registrar.registerInstance(impl, engineId, affinityKey'));
    expect(code, contains('registrar.unregisterInstance('));
  });

  test('native interop JNI FlutterApi prefixes internal registrar members to avoid collisions', () {
    final root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Callbacks',
          methods: <Method>[
            Method(
              name: 'register',
              location: ApiLocation.flutter,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'void', isNullable: false),
            ),
            Method(
              name: 'unregister',
              location: ApiLocation.flutter,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'void', isNullable: false),
            ),
            Method(
              name: 'dartApi',
              location: ApiLocation.flutter,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'void', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    const dartOptions = InternalDartOptions(
      ignoreLints: false,
      useJni: true,
      dartOut: 'lib/foo.g.dart',
    );
    final mainSink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(dartOptions, root, mainSink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final sink = StringBuffer();
    generator.generateNativeInterop(dartOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('Callbacks golubetsVar_register('));
    expect(code, contains('static void golubetsVar_unregister('));
    expect(code, contains('static void golubetsVar_setUp('));
    expect(code, contains('@override\n  void register()'));
    expect(code, contains('@override\n  void unregister()'));
    expect(code, contains('@override\n  void dartApi()'));
  });
}

/// Builds a root with a sealed class `Shape`, its subclasses `Circle` (one
/// field) and `EmptyShape` (no fields), and a host API that echoes `Shape`.
Root buildSealedClassRoot() {
  final shape = Class(name: 'Shape', fields: <NamedType>[], isSealed: true);
  final circle = Class(
    name: 'Circle',
    fields: <NamedType>[
      NamedType(
        name: 'radius',
        type: const TypeDeclaration(baseName: 'double', isNullable: false),
      ),
    ],
    superClassName: 'Shape',
    superClass: shape,
  );
  final emptyShape = Class(
    name: 'EmptyShape',
    fields: <NamedType>[],
    superClassName: 'Shape',
    superClass: shape,
  );
  shape.children.addAll(<Class>[circle, emptyShape]);
  final shapeType = TypeDeclaration(baseName: 'Shape', isNullable: false, associatedClass: shape);
  final nullableShapeType = TypeDeclaration(
    baseName: 'Shape',
    isNullable: true,
    associatedClass: shape,
  );
  return Root(
    apis: <Api>[
      AstHostApi(
        name: 'Api',
        methods: <Method>[
          Method(
            name: 'echoShape',
            location: ApiLocation.host,
            parameters: <Parameter>[Parameter(name: 'shape', type: shapeType)],
            returnType: shapeType,
          ),
          Method(
            name: 'echoNullableShape',
            location: ApiLocation.host,
            parameters: <Parameter>[Parameter(name: 'shape', type: nullableShapeType)],
            returnType: nullableShapeType,
          ),
        ],
      ),
    ],
    classes: <Class>[shape, circle, emptyShape],
    enums: <Enum>[],
  );
}
