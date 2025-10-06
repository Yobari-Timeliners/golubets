// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:golub/src/ast.dart';
import 'package:golub/src/swift/swift_generator.dart';
import 'package:test/test.dart';

const String DEFAULT_PACKAGE_NAME = 'test_package';

void main() {
  group('ProxyApi', () {
    test('one api', () {
      final Root root = Root(
        apis: <Api>[
          AstProxyApi(
            name: 'Api',
            swiftOptions: const SwiftProxyApiOptions(
              name: 'MyLibraryApi',
              import: 'MyLibrary',
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
      const SwiftGenerator generator = SwiftGenerator();
      generator.generate(
        const InternalSwiftOptions(
          fileSpecificClassNameComponent: 'MyFile',
          swiftOut: '',
        ),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      final String collapsedCode = _collapseNewlineAndIndentation(code);

      // import
      expect(code, contains('import MyLibrary'));

      // Instance Manager
      expect(code, contains(r'final class MyFileGolubInstanceManager'));
      expect(code, contains(r'private class MyFileGolubInstanceManagerApi'));

      // ProxyApi Delegate
      expect(code, contains(r'protocol MyFileGolubProxyApiDelegate'));
      expect(
        collapsedCode,
        contains(
          r'func golubApiApi(_ registrar: MyFileGolubProxyApiRegistrar) -> GolubApiApi',
        ),
      );

      // API registrar
      expect(code, contains('open class MyFileGolubProxyApiRegistrar'));

      // ReaderWriter
      expect(
        code,
        contains(
          'private class MyFileGolubInternalProxyApiCodecReaderWriter: FlutterStandardReaderWriter',
        ),
      );

      // Delegate and class
      expect(code, contains('protocol GolubApiDelegateApi'));
      expect(code, contains('protocol GolubApiProtocolApi'));
      expect(code, contains(r'class GolubApiApi: GolubApiProtocolApi'));

      // Constructors
      expect(
        collapsedCode,
        contains(
          r'func name(golubApi: GolubApiApi, someField: Int64, input: Input) throws -> MyLibraryApi',
        ),
      );
      expect(
        collapsedCode,
        contains(
          r'func golubNewInstance(golubInstance: MyLibraryApi, completion: @escaping (Result<Void, GolubError>) -> Void) ',
        ),
      );

      // Field
      expect(
        code,
        contains(
          'func someField(golubApi: GolubApiApi, golubInstance: MyLibraryApi) throws -> Int64',
        ),
      );

      // Dart -> Host method
      expect(
        collapsedCode,
        contains(
          'func doSomething(golubApi: GolubApiApi, golubInstance: MyLibraryApi, input: Input) throws -> String',
        ),
      );

      // Host -> Dart method
      expect(
        code,
        contains(
          r'static func setUpMessageHandlers(binaryMessenger: FlutterBinaryMessenger, api: GolubApiApi?)',
        ),
      );
      expect(
        code,
        contains(
          'func doSomethingElse(golubInstance golubInstanceArg: MyLibraryApi, input inputArg: Input, completion: @escaping (Result<String, GolubError>) -> Void)',
        ),
      );
    });

    group('imports', () {
      test('add check if every class does not support iOS', () {
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              swiftOptions: const SwiftProxyApiOptions(
                import: 'MyImport',
                supportsIos: false,
              ),
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();

        expect(code, contains('#if !os(iOS)\nimport MyImport\n#endif'));
      });

      test('add check if every class does not support macOS', () {
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              swiftOptions: const SwiftProxyApiOptions(
                import: 'MyImport',
                supportsMacos: false,
              ),
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();

        expect(code, contains('#if !os(macOS)\nimport MyImport\n#endif'));
      });

      test('add check if for multiple unsupported platforms', () {
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              swiftOptions: const SwiftProxyApiOptions(
                import: 'MyImport',
                supportsIos: false,
                supportsMacos: false,
              ),
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();

        expect(
          code,
          contains('#if !os(iOS) || !os(macOS)\nimport MyImport\n#endif'),
        );
      });

      test('do not add check if at least one class is supported', () {
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              swiftOptions: const SwiftProxyApiOptions(
                import: 'MyImport',
                supportsIos: false,
              ),
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[],
            ),
            AstProxyApi(
              name: 'Api2',
              swiftOptions: const SwiftProxyApiOptions(import: 'MyImport'),
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();

        expect(code, isNot(contains('#if !os(iOS)\nimport MyImport')));
      });
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
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(code, contains('var golubApiApi2: GolubApiApi2'));
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
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(code, contains('var golubApiApi2: GolubApiApi2'));
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
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(code, contains('var golubApiApi2: GolubApiApi2'));
        expect(code, contains('var golubApiApi3: GolubApiApi3'));
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
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(code, contains('class GolubApiApi: GolubApiProtocolApi '));
        expect(
          collapsedCode,
          contains(
            'func golubDefaultConstructor(golubApi: GolubApiApi) throws -> Api',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'let golubDefaultConstructorChannel = FlutterBasicMessageChannel(name: "dev.bayori.golub.test_package.Api.golub_defaultConstructor", binaryMessenger: binaryMessenger, codec: codec)',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'api.golubRegistrar.instanceManager.addDartCreatedInstance(',
          ),
        );
      });

      test('named constructor', () {
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[
                Constructor(
                  name: 'myConstructorName',
                  parameters: <Parameter>[],
                ),
              ],
              fields: <ApiField>[],
              methods: <Method>[],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          collapsedCode,
          contains(
            'func myConstructorName(golubApi: GolubApiApi) throws -> Api',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'let myConstructorNameChannel = FlutterBasicMessageChannel(name: "dev.bayori.golub.test_package.Api.myConstructorName", binaryMessenger: binaryMessenger, codec: codec)',
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
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(code, contains('class GolubApiApi: GolubApiProtocolApi '));
        expect(
          collapsedCode,
          contains(
            'func name(golubApi: GolubApiApi, validType: Int64, enumType: AnEnum, proxyApiType: Api2, nullableValidType: Int64?, nullableEnumType: AnEnum?, nullableProxyApiType: Api2?) throws -> Api',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'api.golubRegistrar.instanceManager.addDartCreatedInstance( '
            r'try api.golubDelegate.name(golubApi: api, validType: validTypeArg, enumType: enumTypeArg, proxyApiType: '
            r'proxyApiTypeArg, nullableValidType: nullableValidTypeArg, nullableEnumType: nullableEnumTypeArg, '
            r'nullableProxyApiType: nullableProxyApiTypeArg)',
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
          const SwiftGenerator generator = SwiftGenerator();
          generator.generate(
            const InternalSwiftOptions(
              errorClassName: 'TestError',
              swiftOut: '',
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
              r'completion( .failure( TestError( code: "new-instance-error"',
            ),
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
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          collapsedCode,
          contains(
            'func name(golubApi: '
            'GolubApiApi, validType: Int64, enumType: AnEnum, proxyApiType: Api2, nullableValidType: Int64?, nullableEnumType: AnEnum?, '
            'nullableProxyApiType: Api2?) throws -> Api func validType(golubApi: GolubApiApi, golubInstance: Api) throws -> Int64 ',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'api.golubRegistrar.instanceManager.addDartCreatedInstance( try api.golubDelegate.name(golubApi: api, '
            r'validType: validTypeArg, enumType: enumTypeArg, proxyApiType: proxyApiTypeArg, nullableValidType: nullableValidTypeArg, '
            r'nullableEnumType: nullableEnumTypeArg, nullableProxyApiType: nullableProxyApiTypeArg)',
          ),
        );
        expect(
          collapsedCode,
          contains(
            'channel.sendMessage([golubIdentifierArg, validTypeArg, enumTypeArg, '
            'proxyApiTypeArg, nullableValidTypeArg, nullableEnumTypeArg, nullableProxyApiTypeArg] as [Any?])',
          ),
        );
        expect(
          code,
          contains(
            r'func validType(golubApi: GolubApiApi, golubInstance: Api) throws -> Int64',
          ),
        );
        expect(
          code,
          contains(
            r'func enumType(golubApi: GolubApiApi, golubInstance: Api) throws -> AnEnum',
          ),
        );
        expect(
          code,
          contains(
            r'func proxyApiType(golubApi: GolubApiApi, golubInstance: Api) throws -> Api2',
          ),
        );
        expect(
          code,
          contains(
            r'func nullableValidType(golubApi: GolubApiApi, golubInstance: Api) throws -> Int64?',
          ),
        );
        expect(
          code,
          contains(
            r'func nullableEnumType(golubApi: GolubApiApi, golubInstance: Api) throws -> AnEnum?',
          ),
        );
        expect(
          code,
          contains(
            r'func nullableProxyApiType(golubApi: GolubApiApi, golubInstance: Api) throws -> Api2?',
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
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(
          code,
          contains(
            r'func aField(golubApi: GolubApiApi, golubInstance: Api) throws -> Api2',
          ),
        );
        expect(
          code,
          contains(
            r'api.golubRegistrar.instanceManager.addDartCreatedInstance(try api.golubDelegate.aField(golubApi: api, golubInstance: golubInstanceArg), withIdentifier: golubIdentifierArg)',
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
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(
          code,
          contains(r'func aField(golubApi: GolubApiApi) throws -> Api2'),
        );
        expect(
          code,
          contains(
            r'api.golubRegistrar.instanceManager.addDartCreatedInstance(try api.golubDelegate.aField(golubApi: api), withIdentifier: golubIdentifierArg)',
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
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          collapsedCode,
          contains(
            'func doSomething(golubApi: '
            'GolubApiApi, golubInstance: Api, validType: Int64, enumType: AnEnum, proxyApiType: Api2, nullableValidType: Int64?, '
            'nullableEnumType: AnEnum?, nullableProxyApiType: Api2?) throws',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'try api.golubDelegate.doSomething(golubApi: '
            r'api, golubInstance: golubInstanceArg, validType: validTypeArg, enumType: enumTypeArg, proxyApiType: '
            r'proxyApiTypeArg, nullableValidType: nullableValidTypeArg, nullableEnumType: nullableEnumTypeArg, nullableProxyApiType: '
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
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          collapsedCode,
          contains('func doSomething(golubApi: GolubApiApi) throws'),
        );
        expect(
          collapsedCode,
          contains(r'try api.golubDelegate.doSomething(golubApi: api)'),
        );
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
        const SwiftGenerator generator = SwiftGenerator();
        generator.generate(
          const InternalSwiftOptions(swiftOut: ''),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          collapsedCode,
          contains(
            'func doSomething(golubInstance golubInstanceArg: Api, validType validTypeArg: Int64, enumType '
            'enumTypeArg: AnEnum, proxyApiType proxyApiTypeArg: Api2, nullableValidType nullableValidTypeArg: Int64?, nullableEnumType '
            'nullableEnumTypeArg: AnEnum?, nullableProxyApiType nullableProxyApiTypeArg: Api2?, '
            'completion: @escaping (Result<Void, GolubError>) -> Void)',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'channel.sendMessage([golubInstanceArg, validTypeArg, '
            r'enumTypeArg, proxyApiTypeArg, nullableValidTypeArg, '
            r'nullableEnumTypeArg, nullableProxyApiTypeArg] as [Any?])',
          ),
        );
      });
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
