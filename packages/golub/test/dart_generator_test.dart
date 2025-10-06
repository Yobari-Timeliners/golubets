// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Directory, File;

import 'package:golub/src/ast.dart';
import 'package:golub/src/dart/dart_generator.dart';
import 'package:golub/src/generator_tools.dart';
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
    final Class classDefinition = Class(
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
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('  dataType1? field1;'));
  });

  test('gen one enum', () {
    final Enum anEnum = Enum(
      name: 'Foobar',
      members: <EnumMember>[EnumMember(name: 'one'), EnumMember(name: 'two')],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[],
      enums: <Enum>[anEnum],
    );
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum Foobar'));
    expect(code, contains('  one,'));
    expect(code, contains('  two,'));
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, contains('Future<Output> doSomething(Input input)'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, contains('Future<int> add(int x, int y)'));
    expect(
      code,
      contains(
        'golubVar_sendFuture = golubVar_channel.send(<Object?>[x, y])',
      ),
    );
    expect(code, contains('await golubVar_sendFuture'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, contains('int add(int x, int y)'));
    expect(
      code,
      contains('final List<Object?> args = (message as List<Object?>?)!'),
    );
    expect(code, contains('final int? arg_x = (args[0] as int?)'));
    expect(code, contains('final int? arg_y = (args[1] as int?)'));
    expect(code, contains('final int output = api.add(arg_x!, arg_y!)'));
  });

  test('nested class', () {
    final Root root = Root(
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('nested,'));
    expect(code, contains('nested: result[0] as Input?'));
  });

  test('nested non-nullable class', () {
    final Root root = Root(
      apis: <Api>[],
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('nested,'));
    expect(code, contains('nested: result[0]! as Input'));
  });

  test('flutterApi', () {
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('abstract class Api'));
    expect(code, contains('static void setUp(Api'));
    expect(code, contains('Output doSomething(Input input)'));
  });

  test('host void', () {
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Future<void> doSomething'));
    expect(code, contains('return;'));
  });

  test('flutter void return', () {
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    // The next line verifies that we're not setting a variable to the value of "doSomething", but
    // ignores the line where we assert the value of the argument isn't null, since on that line
    // we mention "doSomething" in the assertion message.
    expect(code, isNot(matches('[^!]=.*doSomething')));
    expect(code, contains('doSomething('));
  });

  test('flutter void argument', () {
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, matches('output.*=.*doSomething[(][)]'));
    expect(code, contains('Output doSomething();'));
  });

  test('flutter enum argument with enum class', () {
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
              type: TypeDeclaration(
                baseName: 'Enum',
                isNullable: true,
                associatedEnum: emptyEnum,
              ),
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('return value == null ? null : Enum.values[value];'));
    expect(code, contains('writeValue(buffer, value.index);'));
    expect(
      code,
      contains('final EnumClass? arg_enumClass = (args[0] as EnumClass?);'),
    );
    expect(code, contains('EnumClass doSomething(EnumClass enumClass);'));
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum Foo {'));
    expect(code, contains('Future<void> bar(Foo? foo) async'));
    expect(
      code,
      contains('golubVar_sendFuture = golubVar_channel.send(<Object?>[foo])'),
    );
    expect(code, contains('await golubVar_sendFuture'));
  });

  test('flutter non-nullable enum argument with enum class', () {
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
              type: TypeDeclaration(
                baseName: 'Enum',
                isNullable: false,
                associatedEnum: emptyEnum,
              ),
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('writeValue(buffer, value.index)'));
    expect(code, contains('return value == null ? null : Enum.values[value];'));
    expect(code, contains('enum1: result[0]! as Enum,'));
  });

  test('host void argument', () {
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      matches('golubVar_sendFuture = golubVar_channel.send[(]null[)]'),
    );
  });

  test('mock Dart handler', () {
    final Root root = Root(
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
    final StringBuffer mainCodeSink = StringBuffer();
    final StringBuffer testCodeSink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      mainCodeSink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String mainCode = mainCodeSink.toString();
    expect(mainCode, isNot(contains(r"import 'fo\'o.dart';")));
    expect(mainCode, contains('class Api {'));
    expect(mainCode, isNot(contains('abstract class ApiMock')));
    expect(mainCode, isNot(contains('.ApiMock.doSomething')));
    expect(mainCode, isNot(contains("'${Keys.result}': output")));
    expect(mainCode, isNot(contains('return <Object>[];')));

    const DartGenerator testGenerator = DartGenerator();
    testGenerator.generateTest(
      const InternalDartOptions(dartOut: "fo'o.dart", testOut: 'test.dart'),
      root,
      testCodeSink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
      dartOutputPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String testCode = testCodeSink.toString();
    expect(testCode, contains(r"import 'fo\'o.dart';"));
    expect(testCode, isNot(contains('class Api {')));
    expect(testCode, contains('abstract class ApiMock'));
    expect(testCode, isNot(contains('.ApiMock.doSomething')));
    expect(testCode, contains('output'));
    expect(testCode, contains('return <Object?>[output];'));
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('abstract class Api'));
    expect(code, contains('Future<Output> doSomething(Input input);'));
    expect(
      code,
      contains('final Output output = await api.doSomething(arg_input!);'),
    );
  });

  test('gen one async Flutter Api with void return', () {
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(matches('=.s*doSomething')));
    expect(code, contains('await api.doSomething('));
    expect(code, isNot(contains('._toMap()')));
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, matches('Output.*doSomething.*Input'));
  });

  test('async host void argument', () {
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, matches('golubVar_channel.send[(]null[)]'));
  });

  Iterable<String> makeIterable(String string) sync* {
    yield string;
  }

  test('header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();

    const DartGenerator generator = DartGenerator();
    generator.generate(
      InternalDartOptions(copyrightHeader: makeIterable('hello world')),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, startsWith('// hello world'));
  });

  test('generics', () {
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('  List<int?>? field1;'));
  });

  test('map generics', () {
    final Class classDefinition = Class(
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
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('  Map<String?, int?>? field1;'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('doit(List<int?> arg'));
  });

  test('flutter generics argument with void return', () {
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('doit(List<int?> arg'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Future<List<int?>> doit('));
    expect(
      code,
      contains(
        'return (golubVar_replyList[0] as List<Object?>?)!.cast<int?>();',
      ),
    );
  });

  test('flutter generics argument non void return', () {
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('List<int?> doit('));
    expect(
      code,
      contains(
        'final List<int?>? arg_foo = (args[0] as List<Object?>?)?.cast<int?>()',
      ),
    );
    expect(code, contains('final List<int?> output = api.doit(arg_foo!)'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Future<int?> doit()'));
    expect(code, contains('return (golubVar_replyList[0] as int?);'));
  });

  test('return nullable collection host', () {
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Future<List<int?>?> doit()'));
    expect(
      code,
      contains(
        'return (golubVar_replyList[0] as List<Object?>?)?.cast<int?>();',
      ),
    );
  });

  test('return nullable async host', () {
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
              asynchronousType: AsynchronousType.callback,
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Future<int?> doit()'));
    expect(code, contains('return (golubVar_replyList[0] as int?);'));
  });

  test('return nullable flutter', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.flutter,
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('int? doit();'));
    expect(code, contains('final int? output = api.doit();'));
  });

  test('return nullable async flutter', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: true,
              ),
              parameters: <Parameter>[],
              asynchronousType: AsynchronousType.callback,
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Future<int?> doit();'));
    expect(code, contains('final int? output = await api.doit();'));
  });

  test('platform error for return nil on nonnull', () {
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
                isNullable: false,
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains('Host platform returned null value for non-null return value.'),
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Future<void> doit(int? foo) async {'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('void doit(int? foo);'));
  });

  test('named argument flutter', () {
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
                    isNullable: false,
                  ),
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('void doit({required int foo});'));
    expect(code, contains('api.doit(foo: arg_foo!)'));
  });

  test('uses output package name for imports', () {
    const String overriddenPackageName = 'custom_name';
    const String outputPackageName = 'some_output_package';
    assert(outputPackageName != DEFAULT_PACKAGE_NAME);
    final Directory tempDir = Directory.systemTemp.createTempSync('golub');
    try {
      final Directory foo = Directory(path.join(tempDir.path, 'lib', 'foo'));
      foo.createSync(recursive: true);
      final File pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
name: foobar
''');
      final Root root = Root(
        classes: <Class>[],
        apis: <Api>[],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const DartGenerator testGenerator = DartGenerator();
      testGenerator.generateTest(
        InternalDartOptions(
          dartOut: path.join(foo.path, 'bar.dart'),
          testOut: path.join(tempDir.path, 'test', 'bar_test.dart'),
        ),
        root,
        sink,
        dartPackageName: overriddenPackageName,
        dartOutputPackageName: outputPackageName,
      );
      final String code = sink.toString();
      expect(
        code,
        contains("import 'package:$outputPackageName/foo/bar.dart';"),
      );
    } finally {
      tempDir.deleteSync(recursive: true);
    }
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
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
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('extends StandardMessageCodec'));
  });

  test('host test code handles enums', () {
    final Root root = Root(
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
    final StringBuffer sink = StringBuffer();

    const DartGenerator testGenerator = DartGenerator();
    testGenerator.generateTest(
      const InternalDartOptions(dartOut: 'code.dart', testOut: 'test.dart'),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
      dartOutputPackageName: DEFAULT_PACKAGE_NAME,
    );

    final String testCode = sink.toString();
    expect(testCode, contains('final Enum? arg_anEnum = (args[0] as Enum?);'));
    expect(
      testCode,
      contains('return value == null ? null : Enum.values[value];'),
    );
    expect(testCode, contains('writeValue(buffer, value.index);'));
  });

  test('connection error contains channel name', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'method',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(
                baseName: 'Output',
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
      containsHostApi: true,
    );
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains('throw _createConnectionError(golubVar_channelName);'),
    );
    expect(
      code,
      contains(
        '\'Unable to establish connection on channel: "\$channelName".\'',
      ),
    );
  });

  test('generate wrapResponse if is generating tests', () {
    final Root root = Root(
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

    final StringBuffer mainCodeSink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(testOut: 'test.dart'),
      root,
      mainCodeSink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String mainCode = mainCodeSink.toString();
    expect(mainCode, contains('List<Object?> wrapResponse('));
  });

  test('writes custom int codec without custom types', () {
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('if (value is int) {'));
    expect(code, contains('buffer.putUint8(4);'));
    expect(code, contains('buffer.putInt64(value);'));
  });

  test('sealed class', () {
    final Class superClass = Class(
      name: 'PlatformEvent',
      isSealed: true,
      fields: const <NamedType>[],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        superClass,
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
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains('sealed class PlatformEvent'),
    );
    expect(
      code,
      contains('class IntEvent extends PlatformEvent'),
    );
    expect(
      code,
      contains('class ClassEvent extends PlatformEvent'),
    );
    expect(
      code,
      contains('result[0]! as int'),
    );
    expect(
      code,
      contains('result[0] as Input?'),
    );
  });

  test('empty class', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'EmptyClass',
          fields: <NamedType>[],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();

    expect(code, contains('static EmptyClass decode(Object _)'));
    expect(code, isNot(contains('result as List<Object?>')));
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
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains("this.field1 = 'hello world'"));
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
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = 42'));
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
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = 42'));
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
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = 3.14'));
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
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = true'));
      expect(code, contains('this.field2 = false'));
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
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const <int>[]'));
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
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const <int>['));
      expect(code, contains('1,'));
      expect(code, contains('2,'));
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
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(
        code,
        contains('this.field1 = const <String, int>{}'),
      );
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
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const <String, int>{'));
      expect(code, contains("'key1': 100,"));
      expect(code, contains("'key2': 200"));
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
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = TestEnum.firstValue'));
      expect(code, contains('enum TestEnum {'));
      expect(code, contains('firstValue,'));
      expect(code, contains('secondValue,'));
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
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const InnerClass('));
      expect(code, contains('42'));
      expect(code, contains('class InnerClass'));
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
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const InnerClass()'));
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
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const InnerClass('));
      expect(code, contains('x: 10,'));
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
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const InternalDartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('class Foobar'));
      expect(code, contains('this.field1 = const <List<String>>['));
      expect(code, contains('const <String>['));
      expect(code, contains("'a',"));
      expect(code, contains("'b'"));
      expect(code, contains("'c'"));
    });
  });
}
