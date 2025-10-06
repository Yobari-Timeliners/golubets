// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:golub/src/ast.dart';
import 'package:golub/src/kotlin/kotlin_generator.dart';
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Foobar ('));
    expect(code, contains('val field1: Long? = null'));
    expect(code, contains('fun fromList(pigeonVar_list: List<Any?>): Foobar'));
    expect(code, contains('fun toList(): List<Any?>'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum class Foobar(val raw: Int) {'));
    expect(code, contains('ONE(0)'));
    expect(code, contains('TWO(1)'));
  });

  test('gen class with enum', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Bar',
          fields: <NamedType>[
            NamedType(
              name: 'field1',
              type: TypeDeclaration(
                baseName: 'Foo',
                isNullable: false,
                associatedEnum: emptyEnum,
              ),
            ),
            NamedType(
              name: 'field2',
              type: const TypeDeclaration(
                baseName: 'String',
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum class Foo(val raw: Int) {'));
    expect(code, contains('data class Bar ('));
    expect(code, contains('val field1: Foo,'));
    expect(code, contains('val field2: String'));
    expect(code, contains('fun fromList(pigeonVar_list: List<Any?>): Bar'));
    expect(code, contains('Foo.ofRaw(it.toInt())'));
    expect(code, contains('val field1 = pigeonVar_list[0] as Foo'));
    expect(code, contains('val field2 = pigeonVar_list[1] as String\n'));
    expect(code, contains('fun toList(): List<Any?>'));
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
                    isNullable: false,
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum class Foo(val raw: Int) {'));
    expect(code, contains('Foo.ofRaw(it.toInt())'));
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
                  name: 'input',
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('interface Api'));
    expect(code, contains('fun doSomething(input: Input): Output'));
    expect(
      code,
      contains('''
    @JvmOverloads
    fun setUp(binaryMessenger: BinaryMessenger, api: Api?, messageChannelSuffix: String = "") {
    '''),
    );
    expect(code, contains('channel.setMessageHandler'));
    expect(
      code,
      contains('''
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val inputArg = args[0] as Input
            val wrapped: List<Any?> = try {
              listOf(api.doSomething(inputArg))
            } catch (exception: Throwable) {
              PigeonUtils.wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
    '''),
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
              type: const TypeDeclaration(baseName: 'bool', isNullable: false),
              name: 'aBool',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'int', isNullable: false),
              name: 'aInt',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'double',
                isNullable: false,
              ),
              name: 'aDouble',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'String',
                isNullable: false,
              ),
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
                isNullable: false,
              ),
              name: 'aInt32List',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Int64List',
                isNullable: false,
              ),
              name: 'aInt64List',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Float64List',
                isNullable: false,
              ),
              name: 'aFloat64List',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'bool', isNullable: true),
              name: 'aNullableBool',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'int', isNullable: true),
              name: 'aNullableInt',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'double', isNullable: true),
              name: 'aNullableDouble',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'aNullableString',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Uint8List',
                isNullable: true,
              ),
              name: 'aNullableUint8List',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Int32List',
                isNullable: true,
              ),
              name: 'aNullableInt32List',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Int64List',
                isNullable: true,
              ),
              name: 'aNullableInt64List',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Float64List',
                isNullable: true,
              ),
              name: 'aNullableFloat64List',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );

    final StringBuffer sink = StringBuffer();

    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('val aBool: Boolean'));
    expect(code, contains('val aInt: Long'));
    expect(code, contains('val aDouble: Double'));
    expect(code, contains('val aString: String'));
    expect(code, contains('val aUint8List: ByteArray'));
    expect(code, contains('val aInt32List: IntArray'));
    expect(code, contains('val aInt64List: LongArray'));
    expect(code, contains('val aFloat64List: DoubleArray'));
    expect(code, contains('val aNullableBool: Boolean? = null'));
    expect(code, contains('val aNullableInt: Long? = null'));
    expect(code, contains('val aNullableDouble: Double? = null'));
    expect(code, contains('val aNullableString: String? = null'));
    expect(code, contains('val aNullableUint8List: ByteArray? = null'));
    expect(code, contains('val aNullableInt32List: IntArray? = null'));
    expect(code, contains('val aNullableInt64List: LongArray? = null'));
    expect(code, contains('val aNullableFloat64List: DoubleArray? = null'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
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
        'class Api(private val binaryMessenger: BinaryMessenger, private val messageChannelSuffix: String = "")',
      ),
    );
    expect(code, matches('fun doSomething.*Input.*Output'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(matches('.*doSomething(.*) ->')));
    expect(code, matches('doSomething(.*)'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('callback: (Result<Unit>) -> Unit'));
    expect(code, contains('callback(Result.success(Unit))'));
    // Lines should not end in semicolons.
    expect(code, isNot(contains(RegExp(r';\n'))));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun doSomething(): Output'));
    expect(code, contains('listOf(api.doSomething())'));
    expect(code, contains('wrapError(exception)'));
    expect(code, contains('reply(wrapped)'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains('fun doSomething(callback: (Result<Output>) -> Unit)'),
    );
    expect(code, contains('channel.send(null)'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Foobar'));
    expect(code, contains('val field1: List<Any?>? = null'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Foobar'));
    expect(code, contains('val field1: Map<Any, Any?>? = null'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Outer'));
    expect(code, contains('data class Nested'));
    expect(code, contains('val nested: Nested? = null'));
    expect(code, contains('fun fromList(pigeonVar_list: List<Any?>): Outer'));
    expect(code, contains('val nested = pigeonVar_list[0] as Nested?'));
    expect(code, contains('fun toList(): List<Any?>'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('interface Api'));
    expect(code, contains('api.doSomething(argArg) {'));
    expect(code, contains('reply.reply(PigeonUtils.wrapResult(data))'));
  });

  test('gen one modern async Host Api', () {
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('interface Api'));
    expect(
      code,
      contains('suspend fun doSomething(arg: Input): Output'),
    );
    expect(code, contains('coroutineScope.launch {'));
    expect(code, contains('coroutineScope: CoroutineScope'));
    expect(code, contains('api.doSomething(argArg)'));
    expect(code, contains('reply.reply(wrapped)'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, matches('fun doSomething.*Input.*callback.*Output.*Unit'));
  });

  test('gen one enum class', () {
    final Enum anEnum = Enum(
      name: 'SampleEnum',
      members: <EnumMember>[
        EnumMember(name: 'sampleVersion'),
        EnumMember(name: 'sampleTest'),
      ],
    );
    final Class classDefinition = Class(
      name: 'EnumClass',
      fields: <NamedType>[
        NamedType(
          type: TypeDeclaration(
            baseName: 'SampleEnum',
            associatedEnum: emptyEnum,
            isNullable: true,
          ),
          name: 'sampleEnum',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[anEnum],
    );
    final StringBuffer sink = StringBuffer();
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum class SampleEnum(val raw: Int)'));
    expect(code, contains('SAMPLE_VERSION(0)'));
    expect(code, contains('SAMPLE_TEST(1)'));
  });

  Iterable<String> makeIterable(String string) sync* {
    yield string;
  }

  test('header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    final InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      copyrightHeader: makeIterable('hello world'),
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, startsWith('// hello world'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Foobar'));
    expect(code, contains('val field1: List<Long?>'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Foobar'));
    expect(code, contains('val field1: Map<String?, String?>'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun doit(arg: List<Long?>'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun doit(argArg: List<Long?>'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun doit(): List<Long?>'));
    expect(code, contains('listOf(api.doit())'));
    expect(code, contains('reply.reply(wrapped)'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun doit(callback: (Result<List<Long?>>) -> Unit)'));
    expect(code, contains('val output = it[0] as List<Long?>'));
    expect(code, contains('callback(Result.success(output))'));
  });

  test('generic class with single type parameter', () {
    final Class classDefinition = Class(
      name: 'Wrapper',
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
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Wrapper<T>'));
    expect(code, contains('val value: T'));
    expect(code, contains('internal val tType: KType'));
    expect(
      code,
      contains(
        'inline fun <reified T> fromList(pigeonVar_list: List<Any?>): Wrapper<T>',
      ),
    );
    expect(code, contains('fun toList(): List<Any?>'));
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
          type: const TypeDeclaration(
            baseName: 'T',
            isNullable: false,
          ),
          name: 'first',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'U',
            isNullable: true,
          ),
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Pair<T, U>'));
    expect(code, contains('val first: T'));
    expect(code, contains('val second: U? = null'));
    expect(code, contains('internal val tType: KType'));
    expect(code, contains('internal val uType: KType'));
    expect(
      code,
      contains(
        'fun <reified T, reified U> fromList(pigeonVar_list: List<Any?>): Pair<T, U>',
      ),
    );
    expect(code, contains('fun toList(): List<Any?>'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Container<T>'));
    expect(code, contains('val data: List<Map<String, T?>>'));
    expect(code, contains('internal val tType: KType'));
    expect(
      code,
      contains(
        'fun <reified T> fromList(pigeonVar_list: List<Any?>): Container<T>',
      ),
    );
    expect(code, contains('fun toList(): List<Any?>'));
  });

  test('generic class with generic superclass', () {
    final Class superClass = Class(
      name: 'BaseContainer',
      typeArguments: <TypeDeclaration>[
        const TypeDeclaration(baseName: 'T', isNullable: false),
      ],
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'T',
            isNullable: false,
          ),
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
          type: const TypeDeclaration(
            baseName: 'int',
            isNullable: false,
          ),
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class BaseContainer<T>'));
    expect(code, contains('data class SpecialList<T>'));
    expect(code, contains('val capacity: Long'));
    expect(code, contains('internal val tType: KType'));
    expect(
      code,
      contains(
        'fun <reified T> fromList(pigeonVar_list: List<Any?>): SpecialList<T>',
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
          type: const TypeDeclaration(
            baseName: 'T',
            isNullable: true,
          ),
          name: 'success',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'E',
            isNullable: true,
          ),
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Result<T, E>'));
    expect(code, contains('val success: T? = null'));
    expect(code, contains('val error: E? = null'));
    expect(code, contains('internal val tType: KType'));
    expect(code, contains('internal val eType: KType'));
    expect(
      code,
      contains(
        'fun <reified T, reified E> fromList(pigeonVar_list: List<Any?>): Result<T, E>',
      ),
    );
    expect(code, contains('fun toList(): List<Any?>'));
  });

  test('generic class with Map key constraints', () {
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class KeyValueStore<K, V>'));
    expect(code, contains('val store: Map<K, V>'));
    expect(code, contains('internal val kType: KType'));
    expect(code, contains('internal val vType: KType'));
    expect(
      code,
      contains(
        'fun <reified K, reified V> fromList(pigeonVar_list: List<Any?>): KeyValueStore<K, V>',
      ),
    );
    expect(code, contains('fun toList(): List<Any?>'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun add(x: Long, y: Long): Long'));
    expect(code, contains('val args = message as List<Any?>'));
    expect(code, contains('listOf(api.add(xArg, yArg))'));
    expect(code, contains('reply.reply(wrapped)'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('val channel = BasicMessageChannel'));
    expect(code, contains('callback(Result.success(output))'));
    expect(
      code,
      contains(
        'fun add(xArg: Long, yArg: Long, callback: (Result<Long>) -> Unit)',
      ),
    );
    expect(code, contains('channel.send(listOf(xArg, yArg)) {'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun doit(): Long?'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun doit(callback: (Result<Long?>) -> Unit'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('val fooArg = args[0]'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains('fun doit(fooArg: Long?, callback: (Result<Unit>) -> Unit)'),
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('val input: String\n'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    for (final String comment in comments) {
      // This regex finds the comment only between the open and close comment block
      expect(
        RegExp(
          r'(?<=\/\*\*.*?)' + comment + r'(?=.*?\*\/)',
          dotAll: true,
        ).hasMatch(code),
        true,
      );
    }
    expect(code, isNot(contains('*//')));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains(' : StandardMessageCodec() '));
  });

  test('creates api error class for custom errors', () {
    final Method method = Method(
      name: 'doSomething',
      location: ApiLocation.host,
      returnType: const TypeDeclaration.voidDeclaration(),
      parameters: <Parameter>[],
    );
    final AstHostApi api = AstHostApi(
      name: 'SomeApi',
      methods: <Method>[method],
    );
    final Root root = Root(
      apis: <Api>[api],
      classes: <Class>[],
      enums: <Enum>[],
      containsHostApi: true,
    );
    final StringBuffer sink = StringBuffer();
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      errorClassName: 'SomeError',
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class SomeError'));
    expect(code, contains('if (exception is SomeError)'));
    expect(code, contains('exception.code,'));
    expect(code, contains('exception.message,'));
    expect(code, contains('exception.details'));
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
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
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
        'return FlutterError("channel-error",  "Unable to establish connection on channel: \'\$channelName\'.", "")',
      ),
    );
    expect(
      code,
      contains(
        'callback(Result.failure(PigeonUtils.createConnectionError(channelName)))',
      ),
    );
  });

  test('gen host uses default error class', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'method',
              location: ApiLocation.host,
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
    );
    final StringBuffer sink = StringBuffer();
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('FlutterError'));
  });

  test('gen flutter uses default error class', () {
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
    );
    final StringBuffer sink = StringBuffer();
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('FlutterError'));
  });

  test('gen host uses error class', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'method',
              location: ApiLocation.host,
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
    );
    final StringBuffer sink = StringBuffer();
    const String errorClassName = 'FooError';
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      errorClassName: errorClassName,
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains(errorClassName));
    expect(code, isNot(contains('FlutterError')));
  });

  test('gen flutter uses error class', () {
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
    );
    final StringBuffer sink = StringBuffer();
    const String errorClassName = 'FooError';
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      errorClassName: errorClassName,
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains(errorClassName));
    expect(code, isNot(contains('FlutterError')));
  });

  test('do not generate duplicated entries in writeValue', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'FooBar',
          methods: <Method>[
            Method(
              name: 'fooBar',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'bar',
                  type: const TypeDeclaration(
                    baseName: 'Bar',
                    isNullable: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Foo',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'int', isNullable: false),
              name: 'foo',
            ),
          ],
        ),
        Class(
          name: 'Bar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'Foo', isNullable: false),
              name: 'foo',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'Foo', isNullable: true),
              name: 'foo2',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );

    final StringBuffer sink = StringBuffer();
    const String errorClassName = 'FooError';
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      errorClassName: errorClassName,
      kotlinOut: '',
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );

    final String code = sink.toString();

    // Extract override fun writeValue block
    final int blockStart = code.indexOf('override fun writeValue');
    expect(blockStart, isNot(-1));
    final int blockEnd = code.indexOf('super.writeValue', blockStart);
    expect(blockEnd, isNot(-1));
    final String writeValueBlock = code.substring(blockStart, blockEnd);

    // Count the occurrence of 'is Foo' in the block
    int count = 0;
    int index = 0;
    while (index != -1) {
      index = writeValueBlock.indexOf('is Foo', index);
      if (index != -1) {
        count++;
        index += 'is Foo'.length;
      }
    }

    // There should be only one occurrence of 'is Foo' in the block
    expect(count, 1);
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
    const KotlinGenerator generator = KotlinGenerator();
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
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
      contains('sealed class PlatformEvent'),
    );
    expect(
      code,
      contains('data class IntEvent'),
    );
    expect(code, contains(': PlatformEvent'));
    expect(
      code,
      contains('data class ClassEvent'),
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
    const KotlinGenerator generator = KotlinGenerator();
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('sealed class Result<T>'));
    expect(code, contains('data class Success<T>'));
    expect(code, contains('data class Failure<T>'));
    expect(code, contains(': Result<T>'));
    expect(code, contains('val value: T'));
    expect(code, contains('val error: String'));
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
    const KotlinGenerator generator = KotlinGenerator();
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('sealed class Either<L, R>'));
    expect(code, contains('data class Left<L, R>'));
    expect(code, contains('data class Right<L, R>'));
    expect(code, contains(': Either<L, R>'));
  });

  test('sealed class with generic constraints for collections', () {
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
    const KotlinGenerator generator = KotlinGenerator();
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('sealed class Container<K, V>'));
    expect(code, contains('data class MapContainer<K, V>'));
    expect(code, contains('data class ListContainer<K, V>'));
    expect(code, contains('val data: Map<K, V>'));
    expect(code, contains('val items: List<V>'));
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
    const KotlinGenerator generator = KotlinGenerator();
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('sealed class Response<T>'));
    expect(code, contains('data class DataResponse<T>'));
    expect(code, contains('data class ErrorResponse<T>'));
    expect(code, contains('val items: List<Map<String, T?>>'));
    expect(code, contains('val code: Long'));
    expect(code, contains('val message: String'));
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
    const KotlinGenerator generator = KotlinGenerator();
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
    );
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();

    expect(code, contains('class EmptyClass'));
    expect(code, isNot(contains('data class EmptyClass')));
  });

  test('nested sealed class', () {
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
          name: 'Int',
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
          name: 'Class',
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
    const KotlinGenerator generator = KotlinGenerator();
    const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
      kotlinOut: '',
      nestSealedClasses: true,
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
      contains('sealed class PlatformEvent'),
    );
    expect(
      code,
      contains('is PlatformEvent.Int'),
    );
    expect(
      code,
      contains('is PlatformEvent.Class'),
    );
    expect(
      code,
      contains('PlatformEvent.Int.fromList'),
    );
    expect(
      code,
      contains('PlatformEvent.Class.fromList'),
    );
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
      const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
        kotlinOut: '',
      );
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        kotlinOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('data class Foobar'));
      expect(code, contains('val field1: String = "hello world"'));
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
      const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
        kotlinOut: '',
      );
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        kotlinOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('data class Foobar'));
      expect(code, contains('val field1: Long = 42L'));
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
      const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
        kotlinOut: '',
      );
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        kotlinOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('data class Foobar'));
      expect(code, contains('val field1: Double = 42.0'));
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
      const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
        kotlinOut: '',
      );
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        kotlinOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('data class Foobar'));
      expect(code, contains('val field1: Double = 3.14'));
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
      const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
        kotlinOut: '',
      );
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        kotlinOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('data class Foobar'));
      expect(code, contains('val field1: Boolean = true'));
      expect(code, contains('val field2: Boolean = false'));
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
      const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
        kotlinOut: '',
      );
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        kotlinOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('data class Foobar'));
      expect(code, contains('val field1: List<Long> = listOf<Long>()'));
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
      const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
        kotlinOut: '',
      );
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        kotlinOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('data class Foobar'));
      expect(code, contains('val field1: List<Long> = listOf('));
      expect(code, contains('1L,'));
      expect(code, contains('2L,'));
      expect(code, contains('3L'));
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
      const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
        kotlinOut: '',
      );
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        kotlinOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('data class Foobar'));
      expect(
        code,
        contains('val field1: Map<String, Long> = mapOf<String, Long>()'),
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
      const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
        kotlinOut: '',
      );
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        kotlinOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('data class Foobar'));
      expect(code, contains('val field1: Map<String, Long> = mapOf('));
      expect(code, contains('"key1" to 100L,'));
      expect(code, contains('"key2" to 200L'));
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
      const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
        kotlinOut: '',
      );
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        kotlinOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('data class Foobar'));
      expect(code, contains('val field1: TestEnum = TestEnum.FIRST_VALUE'));
      expect(code, contains('enum class TestEnum(val raw: Int)'));
      expect(code, contains('FIRST_VALUE(0)'));
      expect(code, contains('SECOND_VALUE(1)'));
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
      const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
        kotlinOut: '',
      );
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        kotlinOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('data class Foobar'));
      expect(code, contains('val field1: InnerClass = InnerClass('));
      expect(code, contains('42L'));
      expect(code, contains('data class InnerClass'));
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
      const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
        kotlinOut: '',
      );
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        kotlinOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('data class Foobar'));
      expect(code, contains('val field1: InnerClass = InnerClass()'));
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
      const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
        kotlinOut: '',
      );
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        kotlinOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('data class Foobar'));
      expect(code, contains('val field1: InnerClass = InnerClass('));
      expect(code, contains('x = 10L,'));
      expect(code, contains('y = 20L'));
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
      const InternalKotlinOptions kotlinOptions = InternalKotlinOptions(
        kotlinOut: '',
      );
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        kotlinOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('data class Foobar'));
      expect(code, contains('val field1: List<List<String>> = listOf('));
      expect(code, contains('listOf('));
      expect(code, contains('"a",'));
      expect(code, contains('"b"'));
      expect(code, contains('"c"'));
    });
  });
}
