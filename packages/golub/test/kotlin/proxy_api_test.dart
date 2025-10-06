// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:golub/src/ast.dart';
import 'package:golub/src/kotlin/kotlin_generator.dart';
import 'package:test/test.dart';

const String DEFAULT_PACKAGE_NAME = 'test_package';

void main() {
  group('ProxyApi', () {
    test('one api', () {
      final Root root = Root(
        apis: <Api>[
          AstProxyApi(
            name: 'Api',
            kotlinOptions: const KotlinProxyApiOptions(
              fullClassName: 'my.library.Api',
            ),
            constructors: <Constructor>[
              Constructor(
                name: 'name',
                parameters: <Parameter>[
                  Parameter(
                    type: const TypeDeclaration(
                      baseName: 'Input',
                      isNullable: false,
                    ),
                    name: 'input',
                  ),
                ],
              ),
            ],
            fields: <ApiField>[
              ApiField(
                name: 'someField',
                type: const TypeDeclaration(baseName: 'int', isNullable: false),
              ),
            ],
            methods: <Method>[
              Method(
                name: 'doSomething',
                location: ApiLocation.host,
                parameters: <Parameter>[
                  Parameter(
                    type: const TypeDeclaration(
                      baseName: 'Input',
                      isNullable: false,
                    ),
                    name: 'input',
                  ),
                ],
                returnType: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: false,
                ),
              ),
              Method(
                name: 'doSomethingElse',
                location: ApiLocation.flutter,
                isRequired: false,
                parameters: <Parameter>[
                  Parameter(
                    type: const TypeDeclaration(
                      baseName: 'Input',
                      isNullable: false,
                    ),
                    name: 'input',
                  ),
                ],
                returnType: const TypeDeclaration(
                  baseName: 'String',
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
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        const InternalKotlinOptions(
          fileSpecificClassNameComponent: 'MyFile',
          kotlinOut: '',
        ),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      final String collapsedCode = _collapseNewlineAndIndentation(code);

      // Instance Manager
      expect(code, contains(r'class MyFileGolubInstanceManager'));
      expect(code, contains(r'class MyFileGolubInstanceManagerApi'));

      // API registrar
      expect(
        code,
        contains(
          'abstract class MyFileGolubProxyApiRegistrar(val binaryMessenger: BinaryMessenger)',
        ),
      );

      // Codec
      expect(
        code,
        contains(
          'private class MyFileGolubProxyApiBaseCodec(val registrar: MyFileGolubProxyApiRegistrar) : MyFileGolubCodec()',
        ),
      );

      // Proxy API class
      expect(
        code,
        contains(
          r'abstract class GolubApiApi(open val golubRegistrar: MyFileGolubProxyApiRegistrar)',
        ),
      );

      // Constructors
      expect(
        collapsedCode,
        contains(r'abstract fun name(someField: Long, input: Input)'),
      );
      expect(
        collapsedCode,
        contains(
          r'fun golub_newInstance(golub_instanceArg: my.library.Api, callback: (Result<Unit>) -> Unit)',
        ),
      );

      // Field
      expect(
        code,
        contains(
          'abstract fun someField(golub_instance: my.library.Api): Long',
        ),
      );

      // Dart -> Host method
      expect(
        collapsedCode,
        contains('api.doSomething(golub_instanceArg, inputArg)'),
      );

      // Host -> Dart method
      expect(
        code,
        contains(
          r'fun setUpMessageHandlers(binaryMessenger: BinaryMessenger, api: GolubApiApi?)',
        ),
      );
      expect(
        code,
        contains(
          'fun doSomethingElse(golub_instanceArg: my.library.Api, inputArg: Input, callback: (Result<String>) -> Unit)',
        ),
      );
    });

    group('inheritance', () {
      test('extends', () {
        final AstProxyApi api2 = AstProxyApi(
          name: 'Api2',
          constructors: <Constructor>[],
          fields: <ApiField>[],
          methods: <Method>[],
        );
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[],
              superClass: TypeDeclaration(
                baseName: api2.name,
                isNullable: false,
                associatedProxyApi: api2,
              ),
            ),
            api2,
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const InternalKotlinOptions(kotlinOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          collapsedCode,
          contains('fun golub_getGolubApiApi2(): GolubApiApi2'),
        );
      });

      test('implements', () {
        final AstProxyApi api2 = AstProxyApi(
          name: 'Api2',
          constructors: <Constructor>[],
          fields: <ApiField>[],
          methods: <Method>[],
        );
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[],
              interfaces: <TypeDeclaration>{
                TypeDeclaration(
                  baseName: api2.name,
                  isNullable: false,
                  associatedProxyApi: api2,
                ),
              },
            ),
            api2,
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const InternalKotlinOptions(kotlinOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(code, contains('fun golub_getGolubApiApi2(): GolubApiApi2'));
      });

      test('implements 2 ProxyApis', () {
        final AstProxyApi api2 = AstProxyApi(
          name: 'Api2',
          constructors: <Constructor>[],
          fields: <ApiField>[],
          methods: <Method>[],
        );
        final AstProxyApi api3 = AstProxyApi(
          name: 'Api3',
          constructors: <Constructor>[],
          fields: <ApiField>[],
          methods: <Method>[],
        );
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[],
              interfaces: <TypeDeclaration>{
                TypeDeclaration(
                  baseName: api2.name,
                  isNullable: false,
                  associatedProxyApi: api2,
                ),
                TypeDeclaration(
                  baseName: api3.name,
                  isNullable: false,
                  associatedProxyApi: api3,
                ),
              },
            ),
            api2,
            api3,
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const InternalKotlinOptions(kotlinOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(code, contains('fun golub_getGolubApiApi2(): GolubApiApi2'));
        expect(code, contains('fun golub_getGolubApiApi3(): GolubApiApi3'));
      });
    });

    group('Constructors', () {
      test('empty name and no params constructor', () {
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[
                Constructor(name: '', parameters: <Parameter>[]),
              ],
              fields: <ApiField>[],
              methods: <Method>[],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const InternalKotlinOptions(kotlinOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          code,
          contains(
            'abstract class GolubApiApi(open val golubRegistrar: GolubProxyApiRegistrar) ',
          ),
        );
        expect(
          collapsedCode,
          contains('abstract fun golub_defaultConstructor(): Api'),
        );
        expect(
          collapsedCode,
          contains(
            r'val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.bayori.golub.test_package.Api.golub_defaultConstructor"',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'api.golubRegistrar.instanceManager.addDartCreatedInstance(api.golub_defaultConstructor(',
          ),
        );
      });

      test('multiple params constructor', () {
        final Enum anEnum = Enum(
          name: 'AnEnum',
          members: <EnumMember>[EnumMember(name: 'one')],
        );
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[
                Constructor(
                  name: 'name',
                  parameters: <Parameter>[
                    Parameter(
                      type: const TypeDeclaration(
                        isNullable: false,
                        baseName: 'int',
                      ),
                      name: 'validType',
                    ),
                    Parameter(
                      type: TypeDeclaration(
                        isNullable: false,
                        baseName: 'AnEnum',
                        associatedEnum: anEnum,
                      ),
                      name: 'enumType',
                    ),
                    Parameter(
                      type: const TypeDeclaration(
                        isNullable: false,
                        baseName: 'Api2',
                      ),
                      name: 'proxyApiType',
                    ),
                    Parameter(
                      type: const TypeDeclaration(
                        isNullable: true,
                        baseName: 'int',
                      ),
                      name: 'nullableValidType',
                    ),
                    Parameter(
                      type: TypeDeclaration(
                        isNullable: true,
                        baseName: 'AnEnum',
                        associatedEnum: anEnum,
                      ),
                      name: 'nullableEnumType',
                    ),
                    Parameter(
                      type: const TypeDeclaration(
                        isNullable: true,
                        baseName: 'Api2',
                      ),
                      name: 'nullableProxyApiType',
                    ),
                  ],
                ),
              ],
              fields: <ApiField>[],
              methods: <Method>[],
            ),
            AstProxyApi(
              name: 'Api2',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[anEnum],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const InternalKotlinOptions(kotlinOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          code,
          contains(
            'abstract class GolubApiApi(open val golubRegistrar: GolubProxyApiRegistrar) ',
          ),
        );
        expect(
          collapsedCode,
          contains(
            'abstract fun name(validType: Long, enumType: AnEnum, '
            'proxyApiType: Api2, nullableValidType: Long?, '
            'nullableEnumType: AnEnum?, nullableProxyApiType: Api2?): Api',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'api.golubRegistrar.instanceManager.addDartCreatedInstance(api.name('
            r'validTypeArg,enumTypeArg,proxyApiTypeArg,nullableValidTypeArg,'
            r'nullableEnumTypeArg,nullableProxyApiTypeArg), golub_identifierArg)',
          ),
        );
      });

      test('host platform constructor callback method', () {
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[
                Method(
                  name: 'aCallbackMethod',
                  returnType: const TypeDeclaration.voidDeclaration(),
                  parameters: <Parameter>[],
                  location: ApiLocation.flutter,
                ),
              ],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const InternalKotlinOptions(
            errorClassName: 'TestError',
            kotlinOut: '',
          ),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);

        expect(
          collapsedCode,
          contains(
            'if (golubRegistrar.instanceManager.containsInstance(golub_instanceArg)) { callback(Result.success(Unit))',
          ),
        );
      });

      test(
        'host platform constructor calls new instance error for required callbacks',
        () {
          final Root root = Root(
            apis: <Api>[
              AstProxyApi(
                name: 'Api',
                constructors: <Constructor>[],
                fields: <ApiField>[],
                methods: <Method>[
                  Method(
                    name: 'aCallbackMethod',
                    returnType: const TypeDeclaration.voidDeclaration(),
                    parameters: <Parameter>[],
                    location: ApiLocation.flutter,
                  ),
                ],
              ),
            ],
            classes: <Class>[],
            enums: <Enum>[],
          );
          final StringBuffer sink = StringBuffer();
          const KotlinGenerator generator = KotlinGenerator();
          generator.generate(
            const InternalKotlinOptions(
              errorClassName: 'TestError',
              kotlinOut: '',
            ),
            root,
            sink,
            dartPackageName: DEFAULT_PACKAGE_NAME,
          );
          final String code = sink.toString();
          final String collapsedCode = _collapseNewlineAndIndentation(code);

          expect(
            collapsedCode,
            contains(r'Result.failure( TestError("new-instance-error"'),
          );
        },
      );
    });

    group('Fields', () {
      test('constructor with fields', () {
        final Enum anEnum = Enum(
          name: 'AnEnum',
          members: <EnumMember>[EnumMember(name: 'one')],
        );
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[
                Constructor(name: 'name', parameters: <Parameter>[]),
              ],
              fields: <ApiField>[
                ApiField(
                  type: const TypeDeclaration(
                    isNullable: false,
                    baseName: 'int',
                  ),
                  name: 'validType',
                ),
                ApiField(
                  type: TypeDeclaration(
                    isNullable: false,
                    baseName: 'AnEnum',
                    associatedEnum: anEnum,
                  ),
                  name: 'enumType',
                ),
                ApiField(
                  type: const TypeDeclaration(
                    isNullable: false,
                    baseName: 'Api2',
                  ),
                  name: 'proxyApiType',
                ),
                ApiField(
                  type: const TypeDeclaration(
                    isNullable: true,
                    baseName: 'int',
                  ),
                  name: 'nullableValidType',
                ),
                ApiField(
                  type: TypeDeclaration(
                    isNullable: true,
                    baseName: 'AnEnum',
                    associatedEnum: anEnum,
                  ),
                  name: 'nullableEnumType',
                ),
                ApiField(
                  type: const TypeDeclaration(
                    isNullable: true,
                    baseName: 'Api2',
                  ),
                  name: 'nullableProxyApiType',
                ),
              ],
              methods: <Method>[],
            ),
            AstProxyApi(
              name: 'Api2',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[anEnum],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const InternalKotlinOptions(kotlinOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          collapsedCode,
          contains(
            'abstract fun name(validType: Long, enumType: AnEnum, '
            'proxyApiType: Api2, nullableValidType: Long?, '
            'nullableEnumType: AnEnum?, nullableProxyApiType: Api2?): Api',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'api.golubRegistrar.instanceManager.addDartCreatedInstance(api.name('
            r'validTypeArg,enumTypeArg,proxyApiTypeArg,nullableValidTypeArg,'
            r'nullableEnumTypeArg,nullableProxyApiTypeArg), golub_identifierArg)',
          ),
        );
        expect(
          collapsedCode,
          contains(
            'channel.send(listOf(golub_identifierArg, validTypeArg, '
            'enumTypeArg, proxyApiTypeArg, nullableValidTypeArg, '
            'nullableEnumTypeArg, nullableProxyApiTypeArg))',
          ),
        );
        expect(
          code,
          contains(r'abstract fun validType(golub_instance: Api): Long'),
        );
        expect(
          code,
          contains(r'abstract fun enumType(golub_instance: Api): AnEnum'),
        );
        expect(
          code,
          contains(r'abstract fun proxyApiType(golub_instance: Api): Api2'),
        );
        expect(
          code,
          contains(
            r'abstract fun nullableValidType(golub_instance: Api): Long?',
          ),
        );
        expect(
          code,
          contains(
            r'abstract fun nullableEnumType(golub_instance: Api): AnEnum?',
          ),
        );
        expect(
          code,
          contains(
            r'abstract fun nullableProxyApiType(golub_instance: Api): Api2?',
          ),
        );
      });

      test('attached field', () {
        final AstProxyApi api2 = AstProxyApi(
          name: 'Api2',
          constructors: <Constructor>[],
          fields: <ApiField>[],
          methods: <Method>[],
        );
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <ApiField>[
                ApiField(
                  name: 'aField',
                  isAttached: true,
                  type: TypeDeclaration(
                    baseName: 'Api2',
                    isNullable: false,
                    associatedProxyApi: api2,
                  ),
                ),
              ],
              methods: <Method>[],
            ),
            api2,
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const InternalKotlinOptions(kotlinOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(
          code,
          contains(r'abstract fun aField(golub_instance: Api): Api2'),
        );
        expect(
          code,
          contains(
            r'api.golubRegistrar.instanceManager.addDartCreatedInstance(api.aField(golub_instanceArg), golub_identifierArg)',
          ),
        );
      });

      test('static attached field', () {
        final AstProxyApi api2 = AstProxyApi(
          name: 'Api2',
          constructors: <Constructor>[],
          fields: <ApiField>[],
          methods: <Method>[],
        );
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <ApiField>[
                ApiField(
                  name: 'aField',
                  isStatic: true,
                  isAttached: true,
                  type: TypeDeclaration(
                    baseName: 'Api2',
                    isNullable: false,
                    associatedProxyApi: api2,
                  ),
                ),
              ],
              methods: <Method>[],
            ),
            api2,
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const InternalKotlinOptions(kotlinOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(code, contains(r'abstract fun aField(): Api2'));
        expect(
          code,
          contains(
            r'api.golubRegistrar.instanceManager.addDartCreatedInstance(api.aField(), golub_identifierArg)',
          ),
        );
      });
    });

    group('Host methods', () {
      test('multiple params method', () {
        final Enum anEnum = Enum(
          name: 'AnEnum',
          members: <EnumMember>[EnumMember(name: 'one')],
        );
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[
                Method(
                  name: 'doSomething',
                  location: ApiLocation.host,
                  parameters: <Parameter>[
                    Parameter(
                      type: const TypeDeclaration(
                        isNullable: false,
                        baseName: 'int',
                      ),
                      name: 'validType',
                    ),
                    Parameter(
                      type: TypeDeclaration(
                        isNullable: false,
                        baseName: 'AnEnum',
                        associatedEnum: anEnum,
                      ),
                      name: 'enumType',
                    ),
                    Parameter(
                      type: const TypeDeclaration(
                        isNullable: false,
                        baseName: 'Api2',
                      ),
                      name: 'proxyApiType',
                    ),
                    Parameter(
                      type: const TypeDeclaration(
                        isNullable: true,
                        baseName: 'int',
                      ),
                      name: 'nullableValidType',
                    ),
                    Parameter(
                      type: TypeDeclaration(
                        isNullable: true,
                        baseName: 'AnEnum',
                        associatedEnum: anEnum,
                      ),
                      name: 'nullableEnumType',
                    ),
                    Parameter(
                      type: const TypeDeclaration(
                        isNullable: true,
                        baseName: 'Api2',
                      ),
                      name: 'nullableProxyApiType',
                    ),
                  ],
                  returnType: const TypeDeclaration.voidDeclaration(),
                ),
              ],
            ),
            AstProxyApi(
              name: 'Api2',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[anEnum],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const InternalKotlinOptions(kotlinOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          collapsedCode,
          contains(
            'abstract fun doSomething(golub_instance: Api, validType: Long, '
            'enumType: AnEnum, proxyApiType: Api2, nullableValidType: Long?, '
            'nullableEnumType: AnEnum?, nullableProxyApiType: Api2?)',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'api.doSomething(golub_instanceArg, validTypeArg, enumTypeArg, '
            r'proxyApiTypeArg, nullableValidTypeArg, nullableEnumTypeArg, '
            r'nullableProxyApiTypeArg)',
          ),
        );
      });

      test('static method', () {
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[
                Method(
                  name: 'doSomething',
                  location: ApiLocation.host,
                  isStatic: true,
                  parameters: <Parameter>[],
                  returnType: const TypeDeclaration.voidDeclaration(),
                ),
              ],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const InternalKotlinOptions(kotlinOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(collapsedCode, contains('abstract fun doSomething()'));
        expect(collapsedCode, contains(r'api.doSomething()'));
      });
    });

    group('Flutter methods', () {
      test('multiple params flutter method', () {
        final Enum anEnum = Enum(
          name: 'AnEnum',
          members: <EnumMember>[EnumMember(name: 'one')],
        );
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[
                Method(
                  name: 'doSomething',
                  location: ApiLocation.flutter,
                  parameters: <Parameter>[
                    Parameter(
                      type: const TypeDeclaration(
                        isNullable: false,
                        baseName: 'int',
                      ),
                      name: 'validType',
                    ),
                    Parameter(
                      type: TypeDeclaration(
                        isNullable: false,
                        baseName: 'AnEnum',
                        associatedEnum: anEnum,
                      ),
                      name: 'enumType',
                    ),
                    Parameter(
                      type: const TypeDeclaration(
                        isNullable: false,
                        baseName: 'Api2',
                      ),
                      name: 'proxyApiType',
                    ),
                    Parameter(
                      type: const TypeDeclaration(
                        isNullable: true,
                        baseName: 'int',
                      ),
                      name: 'nullableValidType',
                    ),
                    Parameter(
                      type: TypeDeclaration(
                        isNullable: true,
                        baseName: 'AnEnum',
                        associatedEnum: anEnum,
                      ),
                      name: 'nullableEnumType',
                    ),
                    Parameter(
                      type: const TypeDeclaration(
                        isNullable: true,
                        baseName: 'Api2',
                      ),
                      name: 'nullableProxyApiType',
                    ),
                  ],
                  returnType: const TypeDeclaration.voidDeclaration(),
                ),
              ],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[anEnum],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const InternalKotlinOptions(kotlinOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          collapsedCode,
          contains(
            'fun doSomething(golub_instanceArg: Api, validTypeArg: Long, '
            'enumTypeArg: AnEnum, proxyApiTypeArg: Api2, nullableValidTypeArg: Long?, '
            'nullableEnumTypeArg: AnEnum?, nullableProxyApiTypeArg: Api2?, '
            'callback: (Result<Unit>) -> Unit)',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'channel.send(listOf(golub_instanceArg, validTypeArg, enumTypeArg, '
            r'proxyApiTypeArg, nullableValidTypeArg, nullableEnumTypeArg, '
            r'nullableProxyApiTypeArg))',
          ),
        );
      });
    });

    group('InstanceManager', () {
      test(
        'InstanceManager passes runnable field and not a new runnable instance',
        () {
          final Root root = Root(
            apis: <Api>[
              AstProxyApi(
                name: 'Api',
                constructors: <Constructor>[],
                fields: <ApiField>[],
                methods: <Method>[],
              ),
            ],
            classes: <Class>[],
            enums: <Enum>[],
          );
          final StringBuffer sink = StringBuffer();
          const KotlinGenerator generator = KotlinGenerator();
          generator.generate(
            const InternalKotlinOptions(kotlinOut: ''),
            root,
            sink,
            dartPackageName: DEFAULT_PACKAGE_NAME,
          );
          final String code = sink.toString();
          final String collapsedCode = _collapseNewlineAndIndentation(code);

          expect(
            code,
            contains(
              'handler.removeCallbacks(releaseAllFinalizedInstancesRunnable)',
            ),
          );
          expect(
            code,
            contains(
              'handler.postDelayed(releaseAllFinalizedInstancesRunnable',
            ),
          );

          expect(
            collapsedCode,
            contains(
              'private val releaseAllFinalizedInstancesRunnable = Runnable { this.releaseAllFinalizedInstances() }',
            ),
          );
          expect(
            'this.releaseAllFinalizedInstances()'.allMatches(code).length,
            1,
          );
        },
      );
    });
  });
}

/// Replaces a new line and the indentation with a single white space
///
/// This
///
/// ```dart
/// void method(
///   int param1,
///   int param2,
/// )
/// ```
///
/// converts to
///
/// ```dart
/// void method( int param1, int param2, )
/// ```
String _collapseNewlineAndIndentation(String string) {
  final StringBuffer result = StringBuffer();
  for (final String line in string.split('\n')) {
    result.write('${line.trimLeft()} ');
  }
  return result.toString().trim();
}
