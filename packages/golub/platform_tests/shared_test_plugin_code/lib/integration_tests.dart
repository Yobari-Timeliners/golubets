// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'event_test_types.dart';
import 'generated.dart';
import 'src/generated/generics_tests.gen.dart';
import 'src/generated/kotlin_nested_sealed_tests.gen.dart';
import 'test_types.dart';

/// Possible host languages that test can target.
enum TargetGenerator {
  /// The Windows C++ generator.
  cpp,

  /// The Linux GObject generator.
  gobject,

  /// The Android Java generator.
  java,

  /// The Android Kotlin generator.
  kotlin,

  /// The iOS Objective-C generator.
  objc,

  /// The iOS or macOS Swift generator.
  swift,
}

/// Host languages that support generating Proxy APIs.
const Set<TargetGenerator> proxyApiSupportedLanguages = <TargetGenerator>{
  TargetGenerator.kotlin,
  TargetGenerator.swift,
};

/// Sets up and runs the integration tests.
void runPigeonIntegrationTests(TargetGenerator targetGenerator) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Host sync API tests', () {
    testWidgets('basic void->void call works', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(api.noop(), completes);
    });

    testWidgets('all datatypes serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllTypes echoObject = await api.echoAllTypes(genericAllTypes);
      expect(echoObject, genericAllTypes);
    });

    testWidgets('all nullable datatypes serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypes? echoObject = await api.echoAllNullableTypes(
        recursiveAllNullableTypes,
      );

      expect(echoObject, recursiveAllNullableTypes);
    });

    testWidgets('all null datatypes serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypes allTypesNull = AllNullableTypes();

      final AllNullableTypes? echoNullFilledClass = await api
          .echoAllNullableTypes(allTypesNull);
      expect(allTypesNull, echoNullFilledClass);
    });

    testWidgets(
      'Classes with list of null serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypes listTypes = AllNullableTypes(
          list: <String?>['String', null],
        );

        final AllNullableTypes? echoNullFilledClass = await api
            .echoAllNullableTypes(listTypes);

        expect(listTypes, echoNullFilledClass);
      },
    );

    testWidgets(
      'Classes with map of null serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypes listTypes = AllNullableTypes(
          map: <String?, String?>{'String': 'string', 'null': null},
        );

        final AllNullableTypes? echoNullFilledClass = await api
            .echoAllNullableTypes(listTypes);

        expect(listTypes, echoNullFilledClass);
      },
    );

    testWidgets(
      'all nullable datatypes without recursion serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypesWithoutRecursion? echoObject = await api
            .echoAllNullableTypesWithoutRecursion(
              genericAllNullableTypesWithoutRecursion,
            );

        expect(echoObject, genericAllNullableTypesWithoutRecursion);
      },
    );

    testWidgets(
      'all null datatypes without recursion serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypesWithoutRecursion allTypesNull =
            AllNullableTypesWithoutRecursion();

        final AllNullableTypesWithoutRecursion? echoNullFilledClass = await api
            .echoAllNullableTypesWithoutRecursion(allTypesNull);
        expect(allTypesNull, echoNullFilledClass);
      },
    );

    testWidgets(
      'Classes without recursion with list of null serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypesWithoutRecursion listTypes =
            AllNullableTypesWithoutRecursion(list: <String?>['String', null]);

        final AllNullableTypesWithoutRecursion? echoNullFilledClass = await api
            .echoAllNullableTypesWithoutRecursion(listTypes);

        expect(listTypes, echoNullFilledClass);
      },
    );

    testWidgets(
      'Classes without recursion with map of null serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypesWithoutRecursion listTypes =
            AllNullableTypesWithoutRecursion(
              map: <String?, String?>{'String': 'string', 'null': null},
            );

        final AllNullableTypesWithoutRecursion? echoNullFilledClass = await api
            .echoAllNullableTypesWithoutRecursion(listTypes);

        expect(listTypes, echoNullFilledClass);
      },
    );

    testWidgets('errors are returned correctly', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(() async {
        await api.throwError();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('errors are returned from void methods correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(() async {
        await api.throwErrorFromVoid();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('flutter errors are returned correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(
        () => api.throwFlutterError(),
        throwsA(
          (dynamic e) =>
              e is PlatformException &&
              e.code == 'code' &&
              e.message == 'message' &&
              e.details == 'details',
        ),
      );
    });

    testWidgets('nested objects can be sent correctly', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final AllClassesWrapper classWrapper = classWrapperMaker();
      final String? receivedString = await api.extractNestedNullableString(
        classWrapper,
      );
      expect(receivedString, classWrapper.allNullableTypes.aNullableString);
    });

    testWidgets('nested objects can be received correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const String sentString = 'Some string';
      final AllClassesWrapper receivedObject = await api
          .createNestedNullableString(sentString);
      expect(receivedObject.allNullableTypes.aNullableString, sentString);
    });

    testWidgets('nested classes can serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final AllClassesWrapper classWrapper = classWrapperMaker();

      final AllClassesWrapper receivedClassWrapper = await api.echoClassWrapper(
        classWrapper,
      );
      expect(classWrapper, receivedClassWrapper);
    });

    testWidgets('nested null classes can serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final AllClassesWrapper classWrapper = classWrapperMaker();

      classWrapper.allTypes = null;

      final AllClassesWrapper receivedClassWrapper = await api.echoClassWrapper(
        classWrapper,
      );
      expect(classWrapper, receivedClassWrapper);
    });

    testWidgets(
      'Arguments of multiple types serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        const String aNullableString = 'this is a String';
        const bool aNullableBool = false;
        const int aNullableInt = regularInt;

        final AllNullableTypes echoObject = await api.sendMultipleNullableTypes(
          aNullableBool,
          aNullableInt,
          aNullableString,
        );
        expect(echoObject.aNullableInt, aNullableInt);
        expect(echoObject.aNullableBool, aNullableBool);
        expect(echoObject.aNullableString, aNullableString);
      },
    );

    testWidgets(
      'Arguments of multiple null types serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypes echoNullFilledClass = await api
            .sendMultipleNullableTypes(null, null, null);
        expect(echoNullFilledClass.aNullableInt, null);
        expect(echoNullFilledClass.aNullableBool, null);
        expect(echoNullFilledClass.aNullableString, null);
      },
    );

    testWidgets(
      'Arguments of multiple types serialize and deserialize correctly (WithoutRecursion)',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        const String aNullableString = 'this is a String';
        const bool aNullableBool = false;
        const int aNullableInt = regularInt;

        final AllNullableTypesWithoutRecursion echoObject = await api
            .sendMultipleNullableTypesWithoutRecursion(
              aNullableBool,
              aNullableInt,
              aNullableString,
            );
        expect(echoObject.aNullableInt, aNullableInt);
        expect(echoObject.aNullableBool, aNullableBool);
        expect(echoObject.aNullableString, aNullableString);
      },
    );

    testWidgets(
      'Arguments of multiple null types serialize and deserialize correctly (WithoutRecursion)',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypesWithoutRecursion echoNullFilledClass = await api
            .sendMultipleNullableTypesWithoutRecursion(null, null, null);
        expect(echoNullFilledClass.aNullableInt, null);
        expect(echoNullFilledClass.aNullableBool, null);
        expect(echoNullFilledClass.aNullableString, null);
      },
    );

    testWidgets('Int serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const int sentInt = regularInt;
      final int receivedInt = await api.echoInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Int64 serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = biggerThanBigInt;
      final int receivedInt = await api.echoInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Doubles serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const double sentDouble = 2.0694;
      final double receivedDouble = await api.echoDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('booleans serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      for (final bool sentBool in <bool>[true, false]) {
        final bool receivedBool = await api.echoBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('strings serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const String sentString = 'default';
      final String receivedString = await api.echoString(sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Uint8List serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final List<int> data = <int>[
        102,
        111,
        114,
        116,
        121,
        45,
        116,
        119,
        111,
        0,
      ];
      final Uint8List sentUint8List = Uint8List.fromList(data);
      final Uint8List receivedUint8List = await api.echoUint8List(
        sentUint8List,
      );
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const Object sentString = "I'm a computer";
      final Object receivedString = await api.echoObject(sentString);
      expect(receivedString, sentString);

      // Echo a second type as well to ensure the handling is generic.
      const Object sentInt = regularInt;
      final Object receivedInt = await api.echoObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?> echoObject = await api.echoList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('enum lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum?> echoObject = await api.echoEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('class lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?> echoObject = await api.echoClassList(
        allNullableTypesList,
      );
      for (final (int index, AllNullableTypes? value) in echoObject.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets('NonNull enum lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum> echoObject = await api.echoNonNullEnumList(
        nonNullEnumList,
      );
      expect(listEquals(echoObject, nonNullEnumList), true);
    });

    testWidgets('NonNull class lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes> echoObject = await api.echoNonNullClassList(
        nonNullAllNullableTypesList,
      );
      for (final (int index, AllNullableTypes value) in echoObject.indexed) {
        expect(value, nonNullAllNullableTypesList[index]);
      }
    });

    testWidgets('maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<Object?, Object?> echoObject = await api.echoMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String?, String?> echoObject = await api.echoStringMap(
        stringMap,
      );
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, int?> echoObject = await api.echoIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('enum maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?> echoObject = await api.echoEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('class maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?> echoObject = await api.echoClassMap(
        allNullableTypesMap,
      );
      for (final MapEntry<int?, AllNullableTypes?> entry
          in echoObject.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('NonNull string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String, String> echoObject = await api.echoNonNullStringMap(
        nonNullStringMap,
      );
      expect(mapEquals(echoObject, nonNullStringMap), true);
    });

    testWidgets('NonNull int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int, int> echoObject = await api.echoNonNullIntMap(
        nonNullIntMap,
      );
      expect(mapEquals(echoObject, nonNullIntMap), true);
    });

    testWidgets('NonNull enum maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum, AnEnum> echoObject = await api.echoNonNullEnumMap(
        nonNullEnumMap,
      );
      expect(mapEquals(echoObject, nonNullEnumMap), true);
    });

    testWidgets('NonNull class maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int, AllNullableTypes> echoObject = await api
          .echoNonNullClassMap(nonNullAllNullableTypesMap);
      for (final MapEntry<int, AllNullableTypes> entry in echoObject.entries) {
        expect(entry.value, nonNullAllNullableTypesMap[entry.key]);
      }
    });

    testWidgets('enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.two;
      final AnEnum receivedEnum = await api.echoEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    testWidgets('enums serialize and deserialize correctly (again)', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum receivedEnum = await api.echoAnotherEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    testWidgets('multi word enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fortyTwo;
      final AnEnum receivedEnum = await api.echoEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    testWidgets('required named parameter', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      // This number corresponds with the default value of this method.
      const int sentInt = regularInt;
      final int receivedInt = await api.echoRequiredInt(anInt: sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('optional default parameter no arg', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      // This number corresponds with the default value of this method.
      const double sentDouble = 3.14;
      final double receivedDouble = await api.echoOptionalDefaultDouble();
      expect(receivedDouble, sentDouble);
    });

    testWidgets('optional default parameter with arg', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const double sentDouble = 3.15;
      final double receivedDouble = await api.echoOptionalDefaultDouble(
        sentDouble,
      );
      expect(receivedDouble, sentDouble);
    });

    testWidgets('named default parameter no arg', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      // This string corresponds with the default value of this method.
      const String sentString = 'default';
      final String receivedString = await api.echoNamedDefaultString();
      expect(receivedString, sentString);
    });

    testWidgets('named default parameter with arg', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      // This string corresponds with the default value of this method.
      const String sentString = 'notDefault';
      final String receivedString = await api.echoNamedDefaultString(
        aString: sentString,
      );
      expect(receivedString, sentString);
    });

    testWidgets('Nullable Int serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = regularInt;
      final int? receivedInt = await api.echoNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Nullable Int64 serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = biggerThanBigInt;
      final int? receivedInt = await api.echoNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Null Ints serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final int? receivedNullInt = await api.echoNullableInt(null);
      expect(receivedNullInt, null);
    });

    testWidgets('Nullable Doubles serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const double sentDouble = 2.0694;
      final double? receivedDouble = await api.echoNullableDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('Null Doubles serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final double? receivedNullDouble = await api.echoNullableDouble(null);
      expect(receivedNullDouble, null);
    });

    testWidgets('Nullable booleans serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      for (final bool? sentBool in <bool?>[true, false]) {
        final bool? receivedBool = await api.echoNullableBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('Null booleans serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const bool? sentBool = null;
      final bool? receivedBool = await api.echoNullableBool(sentBool);
      expect(receivedBool, sentBool);
    });

    testWidgets('Nullable strings serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const String sentString = "I'm a computer";
      final String? receivedString = await api.echoNullableString(sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Null strings serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final String? receivedNullString = await api.echoNullableString(null);
      expect(receivedNullString, null);
    });

    testWidgets('Nullable Uint8List serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final List<int> data = <int>[
        102,
        111,
        114,
        116,
        121,
        45,
        116,
        119,
        111,
        0,
      ];
      final Uint8List sentUint8List = Uint8List.fromList(data);
      final Uint8List? receivedUint8List = await api.echoNullableUint8List(
        sentUint8List,
      );
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('Null Uint8List serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Uint8List? receivedNullUint8List = await api.echoNullableUint8List(
        null,
      );
      expect(receivedNullUint8List, null);
    });

    testWidgets(
      'generic nullable Objects serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        const Object sentString = "I'm a computer";
        final Object? receivedString = await api.echoNullableObject(sentString);
        expect(receivedString, sentString);

        // Echo a second type as well to ensure the handling is generic.
        const Object sentInt = regularInt;
        final Object? receivedInt = await api.echoNullableObject(sentInt);
        expect(receivedInt, sentInt);
      },
    );

    testWidgets('Null generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Object? receivedNullObject = await api.echoNullableObject(null);
      expect(receivedNullObject, null);
    });

    testWidgets('nullable lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.echoNullableList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('nullable enum lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum?>? echoObject = await api.echoNullableEnumList(
        enumList,
      );
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('nullable lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?>? echoObject = await api
          .echoNullableClassList(allNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject!.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets(
      'nullable NonNull enum lists serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final List<AnEnum?>? echoObject = await api.echoNullableNonNullEnumList(
          nonNullEnumList,
        );
        expect(listEquals(echoObject, nonNullEnumList), true);
      },
    );

    testWidgets('nullable NonNull lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?>? echoObject = await api
          .echoNullableClassList(nonNullAllNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject!.indexed) {
        expect(value, nonNullAllNullableTypesList[index]);
      }
    });

    testWidgets('nullable maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<Object?, Object?>? echoObject = await api.echoNullableMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('nullable string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String?, String?>? echoObject = await api.echoNullableStringMap(
        stringMap,
      );
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('nullable int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, int?>? echoObject = await api.echoNullableIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('nullable enum maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?>? echoObject = await api.echoNullableEnumMap(
        enumMap,
      );
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('nullable class maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?>? echoObject = await api
          .echoNullableClassMap(allNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry
          in echoObject!.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets(
      'nullable NonNull string maps serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        final Map<String?, String?>? echoObject = await api
            .echoNullableNonNullStringMap(nonNullStringMap);
        expect(mapEquals(echoObject, nonNullStringMap), true);
      },
    );

    testWidgets(
      'nullable NonNull int maps serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        final Map<int?, int?>? echoObject = await api.echoNullableNonNullIntMap(
          nonNullIntMap,
        );
        expect(mapEquals(echoObject, nonNullIntMap), true);
      },
    );

    testWidgets(
      'nullable NonNull enum maps serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        final Map<AnEnum?, AnEnum?>? echoObject = await api
            .echoNullableNonNullEnumMap(nonNullEnumMap);
        expect(mapEquals(echoObject, nonNullEnumMap), true);
      },
    );

    testWidgets(
      'nullable NonNull class maps serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        final Map<int?, AllNullableTypes?>? echoObject = await api
            .echoNullableNonNullClassMap(nonNullAllNullableTypesMap);
        for (final MapEntry<int?, AllNullableTypes?> entry
            in echoObject!.entries) {
          expect(entry.value, nonNullAllNullableTypesMap[entry.key]);
        }
      },
    );

    testWidgets('nullable enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum? echoEnum = await api.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly (again)', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum? echoEnum = await api.echoAnotherNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets(
      'multi word nullable enums serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        const AnEnum sentEnum = AnEnum.fourHundredTwentyTwo;
        final AnEnum? echoEnum = await api.echoNullableEnum(sentEnum);
        expect(echoEnum, sentEnum);
      },
    );

    testWidgets('null lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.echoNullableList(null);
      expect(listEquals(echoObject, null), true);
    });

    testWidgets('null maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<Object?, Object?>? echoObject = await api.echoNullableMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<String?, String?>? echoObject = await api.echoNullableStringMap(
        null,
      );
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<int?, int?>? echoObject = await api.echoNullableIntMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum? sentEnum = null;
      final AnEnum? echoEnum = await api.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null enums serialize and deserialize correctly (again)', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum? sentEnum = null;
      final AnotherEnum? echoEnum = await api.echoAnotherNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null classes serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypes? echoObject = await api.echoAllNullableTypes(null);

      expect(echoObject, isNull);
    });

    testWidgets('optional nullable parameter', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = regularInt;
      final int? receivedInt = await api.echoOptionalNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Null optional nullable parameter', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final int? receivedNullInt = await api.echoOptionalNullableInt();
      expect(receivedNullInt, null);
    });

    testWidgets('named nullable parameter', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const String sentString = "I'm a computer";
      final String? receivedString = await api.echoNamedNullableString(
        aNullableString: sentString,
      );
      expect(receivedString, sentString);
    });

    testWidgets('Null named nullable parameter', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final String? receivedNullString = await api.echoNamedNullableString();
      expect(receivedNullString, null);
    });

    const List<TargetGenerator> defaultValuesSupportedTargets =
        <TargetGenerator>[
          TargetGenerator.kotlin,
          TargetGenerator.swift,
        ];

    testWidgets(
      'createAllTypesWithDefaults returns object with correct default values',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllTypesWithDefaults createdObject =
            await api.createAllTypesWithDefaults();

        // Verify basic field defaults
        expect(createdObject.aBool, false);
        expect(createdObject.anInt, 0);
        expect(createdObject.anInt64, 0);
        expect(createdObject.aDouble, 0.0);
        expect(createdObject.aString, '');
        expect(createdObject.anObject, 0);
        expect(createdObject.anEnum, AnEnum.one);
        expect(createdObject.anotherEnum, AnotherEnum.justInCase);

        // The collection fields should have predefined default values
        expect(createdObject.list.length, 7);
        expect(createdObject.list[0], 1);
        expect(createdObject.list[1], 'string');
        expect(createdObject.list[2], 3.0);
        expect(createdObject.list[3], true);
        expect(createdObject.list[4], AnEnum.fortyTwo);

        expect(createdObject.stringList.length, 2);
        expect(createdObject.stringList[0], 'hello');
        expect(createdObject.stringList[1], 'world');

        expect(createdObject.intList.length, 3);
        expect(createdObject.intList[0], 1);
        expect(createdObject.intList[1], 2);
        expect(createdObject.intList[2], 3);

        expect(createdObject.doubleList.length, 7);
        expect(createdObject.doubleList[0], 1.0);
        expect(createdObject.doubleList[1], 2.0);
        expect(createdObject.doubleList[2], 3.0);
        expect(createdObject.doubleList[3], 5.0);
        expect(createdObject.doubleList[4], 10.0);
        expect(createdObject.doubleList[5], 20.0);
        expect(createdObject.doubleList[6], 3.0);

        expect(createdObject.boolList.length, 3);
        expect(createdObject.boolList[0], true);
        expect(createdObject.boolList[1], false);
        expect(createdObject.boolList[2], true);

        expect(createdObject.enumList.length, 5);
        expect(createdObject.enumList[0], AnEnum.one);
        expect(createdObject.enumList[1], AnEnum.two);
        expect(createdObject.enumList[2], AnEnum.three);
        expect(createdObject.enumList[3], AnEnum.fortyTwo);
        expect(createdObject.enumList[4], AnEnum.fourHundredTwentyTwo);

        expect(createdObject.objectList.length, 7);
        expect(createdObject.objectList[0], 1);
        expect(createdObject.objectList[1], 'string');
        expect(createdObject.objectList[2], 3.0);
        expect(createdObject.objectList[3], true);
        expect(createdObject.objectList[4], AnEnum.fortyTwo);

        expect(createdObject.listList.length, 8);
        expect(createdObject.mapList.length, 7);
        expect(createdObject.map.length, 7);
        expect(createdObject.stringMap.length, 3);
        expect(createdObject.intMap.length, 3);
        expect(createdObject.enumMap.length, 3);
        expect(createdObject.objectMap.length, 7);
        expect(createdObject.listMap.length, 7);
        expect(createdObject.mapMap.length, 7);

        // Verify some key map contents
        expect(createdObject.stringMap['hello'], 'world');
        expect(createdObject.stringMap['lorem'], 'ipsum');
        expect(createdObject.stringMap['golub'], 'rocks');

        expect(createdObject.intMap[1], 2);
        expect(createdObject.intMap[3], 4);
        expect(createdObject.intMap[5], 6);

        expect(createdObject.enumMap[AnEnum.one], AnEnum.two);
        expect(createdObject.enumMap[AnEnum.three], AnEnum.fortyTwo);
        expect(createdObject.enumMap[AnEnum.fourHundredTwentyTwo], AnEnum.one);

        // Verify objectMap contains the expected keys
        expect(createdObject.objectMap[1], 'hello');
        expect(createdObject.objectMap['world'], 2.0);
        expect(createdObject.objectMap[AnEnum.one], 'hello');
        expect(createdObject.objectMap['worldEnum'], AnEnum.two);

        // But the nested ImmutableAllTypes should have predefined values
        final ImmutableAllTypes immutable = createdObject.allTypes;

        // Verify immutable basic fields
        expect(immutable.aBool, false);
        expect(immutable.anInt, 0);
        expect(immutable.anInt64, 0);
        expect(immutable.aDouble, 0);
        expect(immutable.anEnum, AnEnum.one);
        expect(immutable.anotherEnum, AnotherEnum.justInCase);
        expect(immutable.aString, 'some string');
        expect(immutable.anObject, 0);

        // Verify predefined list values
        expect(immutable.list.length, 7);
        expect(immutable.list[0], 1);
        expect(immutable.list[1], 'string');
        expect(immutable.list[2], 3.0);
        expect(immutable.list[3], true);
        expect(immutable.list[4], AnEnum.fortyTwo);
        expect(immutable.list[5], isA<List<Object?>>());
        expect(immutable.list[6], <String, String>{'hello': 'world'});

        expect(immutable.stringList.length, 2);
        expect(immutable.stringList[0], 'hello');
        expect(immutable.stringList[1], 'world');

        expect(immutable.intList.length, 3);
        expect(immutable.intList[0], 1);
        expect(immutable.intList[1], 2);
        expect(immutable.intList[2], 3);

        expect(immutable.doubleList.length, 7);
        expect(immutable.doubleList[0], 1.0);
        expect(immutable.doubleList[1], 2.0);
        expect(immutable.doubleList[2], 3.0);
        expect(immutable.doubleList[3], 5);
        expect(immutable.doubleList[4], 10);
        expect(immutable.doubleList[5], 20.0);
        expect(immutable.doubleList[6], 3);

        expect(immutable.boolList.length, 3);
        expect(immutable.boolList[0], true);
        expect(immutable.boolList[1], false);
        expect(immutable.boolList[2], true);

        expect(immutable.enumList.length, 5);
        expect(immutable.enumList[0], AnEnum.one);
        expect(immutable.enumList[1], AnEnum.two);
        expect(immutable.enumList[2], AnEnum.three);
        expect(immutable.enumList[3], AnEnum.fortyTwo);
        expect(immutable.enumList[4], AnEnum.fourHundredTwentyTwo);

        expect(immutable.objectList.length, 7);
        expect(immutable.objectList[0], 1);
        expect(immutable.objectList[1], 'string');
        expect(immutable.objectList[2], 3.0);
        expect(immutable.objectList[3], true);
        expect(immutable.objectList[4], AnEnum.fortyTwo);
        expect(immutable.objectList[5], isA<List<Object?>>());
        expect(immutable.objectList[6], <String, String>{'hello': 'world'});

        // Verify predefined map values
        expect(immutable.stringMap.length, 3);
        expect(immutable.stringMap['hello'], 'world');
        expect(immutable.stringMap['lorem'], 'ipsum');
        expect(immutable.stringMap['golub'], 'rocks');

        expect(immutable.intMap.length, 3);
        expect(immutable.intMap[1], 2);
        expect(immutable.intMap[3], 4);
        expect(immutable.intMap[5], 6);

        expect(immutable.enumMap.length, 3);
        expect(immutable.enumMap[AnEnum.one], AnEnum.two);
        expect(immutable.enumMap[AnEnum.three], AnEnum.fortyTwo);
        expect(immutable.enumMap[AnEnum.fourHundredTwentyTwo], AnEnum.one);

        expect(immutable.objectMap.length, 7);
        expect(immutable.objectMap[1], 'hello');
        expect(immutable.objectMap['world'], 2.0);
        expect(immutable.objectMap[AnEnum.one], 'hello');
        expect(immutable.objectMap['worldEnum'], AnEnum.two);
        expect(immutable.objectMap['list'], <int>[1, 2, 3]);
        expect(immutable.objectMap['map'], <String, String>{'hello': 'world'});
        expect(immutable.objectMap['doubleMap'], <int, num>{
          1: 1,
          2: 0,
          3: 3.0,
        });

        expect(immutable.listMap.length, 7);
        expect(immutable.listMap[1], <int>[1, 2, 3]);
        expect(immutable.listMap[2], <String>['hello', 'world']);
        expect(immutable.listMap[3], <bool>[true, false, true]);
        expect(immutable.listMap[4], <AnEnum>[
          AnEnum.one,
          AnEnum.two,
          AnEnum.three,
        ]);
        expect(immutable.listMap[5], <List<Object?>>[
          <Object?>[],
          <Object?>[1, 2, 3],
        ]);
        expect(immutable.listMap[6], <Map<String, String>>[
          <String, String>{'hello': 'world'},
          <String, String>{'lorem': 'ipsum'},
        ]);
        expect(immutable.listMap[7], <num>[2, 3.0, 5, 10, 20.0, 3]);

        expect(immutable.mapMap.length, 7);
        expect(immutable.mapMap[1], <int, String>{1: 'hello', 2: 'world'});
        expect(immutable.mapMap[2], <String, int>{'hello': 1, 'world': 2});
        expect(immutable.mapMap[3], <AnEnum, String>{
          AnEnum.one: 'hello',
          AnEnum.two: 'world',
        });
        expect(immutable.mapMap[4], <String, AnEnum>{
          'hello': AnEnum.one,
          'world': AnEnum.two,
        });
        expect(immutable.mapMap[5], <int, List<Object>>{
          1: <int>[1, 2, 3],
          2: <String>['hello', 'world'],
        });
        expect(immutable.mapMap[6], <String, Map<String, String>>{
          'hello': <String, String>{'hello': 'world'},
          'lorem': <String, String>{'lorem': 'ipsum'},
        });
        expect(immutable.mapMap[7], <AnEnum, Map<String, num>>{
          AnEnum.one: <String, num>{'hello': 0.0, 'world': 1},
        });
      },
      skip: !defaultValuesSupportedTargets.contains(targetGenerator),
    );

    testWidgets(
      'echoAllTypesWithDefaults preserves default values across platforms',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        // Test that our test data with defaults roundtrips correctly
        final AllTypesWithDefaults echoedObject = await api
            .echoAllTypesWithDefaults(allTypesWithDefaults);
        expect(echoedObject, allTypesWithDefaults);
      },
      skip: !defaultValuesSupportedTargets.contains(targetGenerator),
    );

    testWidgets(
      'default values are correctly generated in target platform',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        // Create object with defaults on the platform side
        final AllTypesWithDefaults platformDefaults =
            await api.createAllTypesWithDefaults();

        // Echo it back to ensure serialization works
        final AllTypesWithDefaults echoedDefaults = await api
            .echoAllTypesWithDefaults(platformDefaults);

        // Should be equal to themselves
        expect(echoedDefaults, platformDefaults);

        // Should match our local defaults
        expect(platformDefaults.aBool, allTypesWithDefaults.aBool);
        expect(platformDefaults.anInt, allTypesWithDefaults.anInt);
        expect(platformDefaults.anInt64, allTypesWithDefaults.anInt64);
        expect(platformDefaults.aDouble, allTypesWithDefaults.aDouble);
        expect(platformDefaults.aString, allTypesWithDefaults.aString);
        expect(platformDefaults.anObject, allTypesWithDefaults.anObject);
        expect(platformDefaults.anEnum, allTypesWithDefaults.anEnum);
        expect(platformDefaults.anotherEnum, allTypesWithDefaults.anotherEnum);

        // Verify the nested ImmutableAllTypes matches
        expect(
          platformDefaults.allTypes.aBool,
          allTypesWithDefaults.allTypes.aBool,
        );
        expect(
          platformDefaults.allTypes.aString,
          allTypesWithDefaults.allTypes.aString,
        );
        expect(
          platformDefaults.allTypes.stringList.length,
          allTypesWithDefaults.allTypes.stringList.length,
        );
        expect(
          platformDefaults.allTypes.stringMap.length,
          allTypesWithDefaults.allTypes.stringMap.length,
        );
      },
      skip: !defaultValuesSupportedTargets.contains(targetGenerator),
    );
  });

  group('Host async API tests', () {
    testWidgets('basic void->void call works', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(api.noopAsync(), completes);
    });

    testWidgets('async errors are returned from non void methods correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(() async {
        await api.throwAsyncError();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('async errors are returned from void methods correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(() async {
        await api.throwAsyncErrorFromVoid();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets(
      'async flutter errors are returned from non void methods correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        expect(
          () => api.throwAsyncFlutterError(),
          throwsA(
            (dynamic e) =>
                e is PlatformException &&
                e.code == 'code' &&
                e.message == 'message' &&
                e.details == 'details',
          ),
        );
      },
    );

    testWidgets('all datatypes async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllTypes echoObject = await api.echoAsyncAllTypes(genericAllTypes);

      expect(echoObject, genericAllTypes);
    });

    testWidgets(
      'all nullable async datatypes serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypes? echoObject = await api
            .echoAsyncNullableAllNullableTypes(recursiveAllNullableTypes);

        expect(echoObject, recursiveAllNullableTypes);
      },
    );

    testWidgets(
      'all null datatypes async serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypes allTypesNull = AllNullableTypes();

        final AllNullableTypes? echoNullFilledClass = await api
            .echoAsyncNullableAllNullableTypes(allTypesNull);
        expect(echoNullFilledClass, allTypesNull);
      },
    );

    testWidgets(
      'all nullable async datatypes without recursion serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypesWithoutRecursion? echoObject = await api
            .echoAsyncNullableAllNullableTypesWithoutRecursion(
              genericAllNullableTypesWithoutRecursion,
            );

        expect(echoObject, genericAllNullableTypesWithoutRecursion);
      },
    );

    testWidgets(
      'all null datatypes without recursion async serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypesWithoutRecursion allTypesNull =
            AllNullableTypesWithoutRecursion();

        final AllNullableTypesWithoutRecursion? echoNullFilledClass = await api
            .echoAsyncNullableAllNullableTypesWithoutRecursion(allTypesNull);
        expect(echoNullFilledClass, allTypesNull);
      },
    );

    testWidgets('Int async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = regularInt;
      final int receivedInt = await api.echoAsyncInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Int64 async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = biggerThanBigInt;
      final int receivedInt = await api.echoAsyncInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Doubles async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const double sentDouble = 2.0694;
      final double receivedDouble = await api.echoAsyncDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('booleans async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      for (final bool sentBool in <bool>[true, false]) {
        final bool receivedBool = await api.echoAsyncBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('strings async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const String sentObject = 'Hello, asynchronously!';

      final String echoObject = await api.echoAsyncString(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('Uint8List async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final List<int> data = <int>[
        102,
        111,
        114,
        116,
        121,
        45,
        116,
        119,
        111,
        0,
      ];
      final Uint8List sentUint8List = Uint8List.fromList(data);
      final Uint8List receivedUint8List = await api.echoAsyncUint8List(
        sentUint8List,
      );
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('generic Objects async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const Object sentString = "I'm a computer";
      final Object receivedString = await api.echoAsyncObject(sentString);
      expect(receivedString, sentString);

      // Echo a second type as well to ensure the handling is generic.
      const Object sentInt = regularInt;
      final Object receivedInt = await api.echoAsyncObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?> echoObject = await api.echoAsyncList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('enum lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum?> echoObject = await api.echoAsyncEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('class lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?> echoObject = await api.echoAsyncClassList(
        allNullableTypesList,
      );
      for (final (int index, AllNullableTypes? value) in echoObject.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets('maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<Object?, Object?> echoObject = await api.echoAsyncMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String?, String?> echoObject = await api.echoAsyncStringMap(
        stringMap,
      );
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, int?> echoObject = await api.echoAsyncIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('enum maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?> echoObject = await api.echoAsyncEnumMap(
        enumMap,
      );
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('class maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?> echoObject = await api
          .echoAsyncClassMap(allNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry
          in echoObject.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum echoEnum = await api.echoAsyncEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('enums serialize and deserialize correctly (again)', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum echoEnum = await api.echoAnotherAsyncEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('multi word enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fourHundredTwentyTwo;
      final AnEnum echoEnum = await api.echoAsyncEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable Int async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = regularInt;
      final int? receivedInt = await api.echoAsyncNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('nullable Int64 async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = biggerThanBigInt;
      final int? receivedInt = await api.echoAsyncNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('nullable Doubles async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const double sentDouble = 2.0694;
      final double? receivedDouble = await api.echoAsyncNullableDouble(
        sentDouble,
      );
      expect(receivedDouble, sentDouble);
    });

    testWidgets('nullable booleans async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      for (final bool sentBool in <bool>[true, false]) {
        final bool? receivedBool = await api.echoAsyncNullableBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('nullable strings async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const String sentObject = 'Hello, asynchronously!';

      final String? echoObject = await api.echoAsyncNullableString(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets(
      'nullable Uint8List async serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        final List<int> data = <int>[
          102,
          111,
          114,
          116,
          121,
          45,
          116,
          119,
          111,
          0,
        ];
        final Uint8List sentUint8List = Uint8List.fromList(data);
        final Uint8List? receivedUint8List = await api
            .echoAsyncNullableUint8List(sentUint8List);
        expect(receivedUint8List, sentUint8List);
      },
    );

    testWidgets(
      'nullable generic Objects async serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        const Object sentString = "I'm a computer";
        final Object? receivedString = await api.echoAsyncNullableObject(
          sentString,
        );
        expect(receivedString, sentString);

        // Echo a second type as well to ensure the handling is generic.
        const Object sentInt = regularInt;
        final Object? receivedInt = await api.echoAsyncNullableObject(sentInt);
        expect(receivedInt, sentInt);
      },
    );

    testWidgets('nullable lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.echoAsyncNullableList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('nullable enum lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum?>? echoObject = await api.echoAsyncNullableEnumList(
        enumList,
      );
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('nullable class lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?>? echoObject = await api
          .echoAsyncNullableClassList(allNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject!.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets('nullable maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<Object?, Object?>? echoObject = await api.echoAsyncNullableMap(
        map,
      );
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('nullable string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String?, String?>? echoObject = await api
          .echoAsyncNullableStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('nullable int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, int?>? echoObject = await api.echoAsyncNullableIntMap(
        intMap,
      );
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('nullable enum maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?>? echoObject = await api
          .echoAsyncNullableEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('nullable class maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?>? echoObject = await api
          .echoAsyncNullableClassMap(allNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry
          in echoObject!.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('nullable enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum? echoEnum = await api.echoAsyncNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly (again)', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum? echoEnum = await api.echoAnotherAsyncNullableEnum(
        sentEnum,
      );
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fortyTwo;
      final AnEnum? echoEnum = await api.echoAsyncNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null Ints async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final int? receivedInt = await api.echoAsyncNullableInt(null);
      expect(receivedInt, null);
    });

    testWidgets('null Doubles async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final double? receivedDouble = await api.echoAsyncNullableDouble(null);
      expect(receivedDouble, null);
    });

    testWidgets('null booleans async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final bool? receivedBool = await api.echoAsyncNullableBool(null);
      expect(receivedBool, null);
    });

    testWidgets('null strings async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final String? echoObject = await api.echoAsyncNullableString(null);
      expect(echoObject, null);
    });

    testWidgets('null Uint8List async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Uint8List? receivedUint8List = await api.echoAsyncNullableUint8List(
        null,
      );
      expect(receivedUint8List, null);
    });

    testWidgets(
      'null generic Objects async serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        final Object? receivedString = await api.echoAsyncNullableObject(null);
        expect(receivedString, null);
      },
    );

    testWidgets('null lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.echoAsyncNullableList(null);
      expect(listEquals(echoObject, null), true);
    });

    testWidgets('null maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<Object?, Object?>? echoObject = await api.echoAsyncNullableMap(
        null,
      );
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<String?, String?>? echoObject = await api
          .echoAsyncNullableStringMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<int?, int?>? echoObject = await api.echoAsyncNullableIntMap(
        null,
      );
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum? sentEnum = null;
      final AnEnum? echoEnum = await api.echoAsyncNullableEnum(null);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum? sentEnum = null;
      final AnotherEnum? echoEnum = await api.echoAnotherAsyncNullableEnum(
        null,
      );
      expect(echoEnum, sentEnum);
    });

    const List<TargetGenerator> modernAsyncSupportedTargets = <TargetGenerator>[
      TargetGenerator.kotlin,
      TargetGenerator.swift,
    ];

    testWidgets(
      'all nullable async datatypes serialize and deserialize correctly using `await`-style',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypes? echoObject = await api
            .echoModernAsyncNullableAllNullableTypes(recursiveAllNullableTypes);

        expect(echoObject, recursiveAllNullableTypes);
      },
      skip: !modernAsyncSupportedTargets.contains(targetGenerator),
    );

    testWidgets(
      'all datatypes async serialize and deserialize correctly using `await`-style',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllTypes echoObject = await api.echoModernAsyncAllTypes(
          genericAllTypes,
        );

        expect(echoObject, genericAllTypes);
      },
      skip: !modernAsyncSupportedTargets.contains(targetGenerator),
    );

    testWidgets(
      'all datatypes async serialize and deserialize correctly using `await`-style and does not throw',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllTypes echoObject = await api
            .echoModernAsyncAllTypesAndNotThrow(genericAllTypes);

        expect(echoObject, genericAllTypes);
      },
      skip: !modernAsyncSupportedTargets.contains(targetGenerator),
    );

    testWidgets(
      'all datatypes async serialize correctly using `await`-style and throws',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        await expectLater(
          () => api.echoModernAsyncAllTypesAndThrow(genericAllTypes),
          throwsA(isA<PlatformException>()),
        );
      },
      skip: !modernAsyncSupportedTargets.contains(targetGenerator),
    );

    testWidgets(
      'all null datatypes async serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypes allTypesNull = AllNullableTypes();

        final AllNullableTypes? echoNullFilledClass = await api
            .echoAsyncNullableAllNullableTypes(allTypesNull);
        expect(echoNullFilledClass, allTypesNull);
      },
    );

    testWidgets(
      'all null datatypes async serialize and deserialize correctly using `await`-style',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypes allTypesNull = AllNullableTypes();

        final AllNullableTypes? echoNullFilledClass = await api
            .echoModernAsyncNullableAllNullableTypes(allTypesNull);
        expect(echoNullFilledClass, allTypesNull);
      },
      skip: !modernAsyncSupportedTargets.contains(targetGenerator),
    );
  });

  group('Host API with suffix', () {
    testWidgets('echo string succeeds with suffix with multiple instances', (
      _,
    ) async {
      final HostSmallApi apiWithSuffixOne = HostSmallApi(
        messageChannelSuffix: 'suffixOne',
      );
      final HostSmallApi apiWithSuffixTwo = HostSmallApi(
        messageChannelSuffix: 'suffixTwo',
      );
      const String sentString = "I'm a computer";
      final String echoStringOne = await apiWithSuffixOne.echo(sentString);
      final String echoStringTwo = await apiWithSuffixTwo.echo(sentString);
      expect(sentString, echoStringOne);
      expect(sentString, echoStringTwo);
    });

    testWidgets('multiple instances will have different method channel names', (
      _,
    ) async {
      // The only way to get the channel name back is to throw an exception.
      // These APIs have no corresponding APIs on the host platforms.
      final HostSmallApi apiWithSuffixOne = HostSmallApi(
        messageChannelSuffix: 'suffixWithNoHost',
      );
      final HostSmallApi apiWithSuffixTwo = HostSmallApi(
        messageChannelSuffix: 'suffixWithoutHost',
      );
      const String sentString = "I'm a computer";
      try {
        await apiWithSuffixOne.echo(sentString);
      } on PlatformException catch (e) {
        expect(e.message, contains('suffixWithNoHost'));
      }
      try {
        await apiWithSuffixTwo.echo(sentString);
      } on PlatformException catch (e) {
        expect(e.message, contains('suffixWithoutHost'));
      }
    });
  });

  // These tests rely on the async Dart->host calls to work correctly, since
  // the host->Dart call is wrapped in a driving Dart->host call, so any test
  // added to this group should have coverage of the relevant arguments and
  // return value in the "Host async API tests" group.
  group('Flutter API tests', () {
    setUp(() {
      FlutterIntegrationCoreApi.setUp(_FlutterApiTestImplementation());
    });

    testWidgets('basic void->void call works', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(api.callFlutterNoop(), completes);
    });

    testWidgets('errors are returned from non void methods correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(() async {
        await api.callFlutterThrowError();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('errors are returned from void methods correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(() async {
        await api.callFlutterThrowErrorFromVoid();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('all datatypes serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllTypes echoObject = await api.callFlutterEchoAllTypes(
        genericAllTypes,
      );

      expect(echoObject, genericAllTypes);
    });

    testWidgets(
      'Arguments of multiple types serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        const String aNullableString = 'this is a String';
        const bool aNullableBool = false;
        const int aNullableInt = regularInt;

        final AllNullableTypes compositeObject = await api
            .callFlutterSendMultipleNullableTypes(
              aNullableBool,
              aNullableInt,
              aNullableString,
            );
        expect(compositeObject.aNullableInt, aNullableInt);
        expect(compositeObject.aNullableBool, aNullableBool);
        expect(compositeObject.aNullableString, aNullableString);
      },
    );

    testWidgets(
      'Arguments of multiple null types serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypes compositeObject = await api
            .callFlutterSendMultipleNullableTypes(null, null, null);
        expect(compositeObject.aNullableInt, null);
        expect(compositeObject.aNullableBool, null);
        expect(compositeObject.aNullableString, null);
      },
    );

    testWidgets(
      'Arguments of multiple types serialize and deserialize correctly (WithoutRecursion)',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        const String aNullableString = 'this is a String';
        const bool aNullableBool = false;
        const int aNullableInt = regularInt;

        final AllNullableTypesWithoutRecursion compositeObject = await api
            .callFlutterSendMultipleNullableTypesWithoutRecursion(
              aNullableBool,
              aNullableInt,
              aNullableString,
            );
        expect(compositeObject.aNullableInt, aNullableInt);
        expect(compositeObject.aNullableBool, aNullableBool);
        expect(compositeObject.aNullableString, aNullableString);
      },
    );

    testWidgets(
      'Arguments of multiple null types serialize and deserialize correctly (WithoutRecursion)',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final AllNullableTypesWithoutRecursion compositeObject = await api
            .callFlutterSendMultipleNullableTypesWithoutRecursion(
              null,
              null,
              null,
            );
        expect(compositeObject.aNullableInt, null);
        expect(compositeObject.aNullableBool, null);
        expect(compositeObject.aNullableString, null);
      },
    );

    testWidgets('booleans serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      for (final bool sentObject in <bool>[true, false]) {
        final bool echoObject = await api.callFlutterEchoBool(sentObject);
        expect(echoObject, sentObject);
      }
    });

    testWidgets('ints serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentObject = regularInt;
      final int echoObject = await api.callFlutterEchoInt(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('doubles serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const double sentObject = 2.0694;
      final double echoObject = await api.callFlutterEchoDouble(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('strings serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const String sentObject = 'Hello Dart!';
      final String echoObject = await api.callFlutterEchoString(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('Uint8Lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<int> data = <int>[
        102,
        111,
        114,
        116,
        121,
        45,
        116,
        119,
        111,
        0,
      ];
      final Uint8List sentObject = Uint8List.fromList(data);
      final Uint8List echoObject = await api.callFlutterEchoUint8List(
        sentObject,
      );
      expect(echoObject, sentObject);
    });

    testWidgets('lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?> echoObject = await api.callFlutterEchoList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('enum lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum?> echoObject = await api.callFlutterEchoEnumList(
        enumList,
      );
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('class lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?> echoObject = await api
          .callFlutterEchoClassList(allNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets('NonNull enum lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum> echoObject = await api.callFlutterEchoNonNullEnumList(
        nonNullEnumList,
      );
      expect(listEquals(echoObject, nonNullEnumList), true);
    });

    testWidgets('NonNull class lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes> echoObject = await api
          .callFlutterEchoNonNullClassList(nonNullAllNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject.indexed) {
        expect(value, nonNullAllNullableTypesList[index]);
      }
    });

    testWidgets('maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<Object?, Object?> echoObject = await api.callFlutterEchoMap(
        map,
      );
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String?, String?> echoObject = await api
          .callFlutterEchoStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, int?> echoObject = await api.callFlutterEchoIntMap(
        intMap,
      );
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('enum maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?> echoObject = await api.callFlutterEchoEnumMap(
        enumMap,
      );
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('class maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?> echoObject = await api
          .callFlutterEchoClassMap(allNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry
          in echoObject.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('NonNull string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String, String> echoObject = await api
          .callFlutterEchoNonNullStringMap(nonNullStringMap);
      expect(mapEquals(echoObject, nonNullStringMap), true);
    });

    testWidgets('NonNull int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int, int> echoObject = await api.callFlutterEchoNonNullIntMap(
        nonNullIntMap,
      );
      expect(mapEquals(echoObject, nonNullIntMap), true);
    });

    testWidgets('NonNull enum maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum, AnEnum> echoObject = await api
          .callFlutterEchoNonNullEnumMap(nonNullEnumMap);
      expect(mapEquals(echoObject, nonNullEnumMap), true);
    });

    testWidgets('NonNull class maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int, AllNullableTypes> echoObject = await api
          .callFlutterEchoNonNullClassMap(nonNullAllNullableTypesMap);
      for (final MapEntry<int, AllNullableTypes> entry in echoObject.entries) {
        expect(entry.value, nonNullAllNullableTypesMap[entry.key]);
      }
    });

    testWidgets('enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum echoEnum = await api.callFlutterEchoEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('enums serialize and deserialize correctly (again)', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum echoEnum = await api.callFlutterEchoAnotherEnum(
        sentEnum,
      );
      expect(echoEnum, sentEnum);
    });

    testWidgets('multi word enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fortyTwo;
      final AnEnum echoEnum = await api.callFlutterEchoEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable booleans serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      for (final bool? sentObject in <bool?>[true, false]) {
        final bool? echoObject = await api.callFlutterEchoNullableBool(
          sentObject,
        );
        expect(echoObject, sentObject);
      }
    });

    testWidgets('null booleans serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const bool? sentObject = null;
      final bool? echoObject = await api.callFlutterEchoNullableBool(
        sentObject,
      );
      expect(echoObject, sentObject);
    });

    testWidgets('nullable ints serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentObject = regularInt;
      final int? echoObject = await api.callFlutterEchoNullableInt(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('nullable big ints serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentObject = biggerThanBigInt;
      final int? echoObject = await api.callFlutterEchoNullableInt(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('null ints serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final int? echoObject = await api.callFlutterEchoNullableInt(null);
      expect(echoObject, null);
    });

    testWidgets('nullable doubles serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const double sentObject = 2.0694;
      final double? echoObject = await api.callFlutterEchoNullableDouble(
        sentObject,
      );
      expect(echoObject, sentObject);
    });

    testWidgets('null doubles serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final double? echoObject = await api.callFlutterEchoNullableDouble(null);
      expect(echoObject, null);
    });

    testWidgets('nullable strings serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const String sentObject = "I'm a computer";
      final String? echoObject = await api.callFlutterEchoNullableString(
        sentObject,
      );
      expect(echoObject, sentObject);
    });

    testWidgets('null strings serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final String? echoObject = await api.callFlutterEchoNullableString(null);
      expect(echoObject, null);
    });

    testWidgets('nullable Uint8Lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final List<int> data = <int>[
        102,
        111,
        114,
        116,
        121,
        45,
        116,
        119,
        111,
        0,
      ];
      final Uint8List sentObject = Uint8List.fromList(data);
      final Uint8List? echoObject = await api.callFlutterEchoNullableUint8List(
        sentObject,
      );
      expect(echoObject, sentObject);
    });

    testWidgets('null Uint8Lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Uint8List? echoObject = await api.callFlutterEchoNullableUint8List(
        null,
      );
      expect(echoObject, null);
    });

    testWidgets('nullable lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.callFlutterEchoNullableList(
        list,
      );
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('nullable enum lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum?>? echoObject = await api
          .callFlutterEchoNullableEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('nullable class lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?>? echoObject = await api
          .callFlutterEchoNullableClassList(allNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject!.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets(
      'nullable NonNull enum lists serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final List<AnEnum?>? echoObject = await api
            .callFlutterEchoNullableNonNullEnumList(nonNullEnumList);
        expect(listEquals(echoObject, nonNullEnumList), true);
      },
    );

    testWidgets(
      'nullable NonNull class lists serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        final List<AllNullableTypes?>? echoObject = await api
            .callFlutterEchoNullableNonNullClassList(
              nonNullAllNullableTypesList,
            );
        for (final (int index, AllNullableTypes? value)
            in echoObject!.indexed) {
          expect(value, nonNullAllNullableTypesList[index]);
        }
      },
    );

    testWidgets('null lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.callFlutterEchoNullableList(
        null,
      );
      expect(listEquals(echoObject, null), true);
    });

    testWidgets('nullable maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<Object?, Object?>? echoObject = await api
          .callFlutterEchoNullableMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('null maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<Object?, Object?>? echoObject = await api
          .callFlutterEchoNullableMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('nullable string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String?, String?>? echoObject = await api
          .callFlutterEchoNullableStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('nullable int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, int?>? echoObject = await api
          .callFlutterEchoNullableIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('nullable enum maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?>? echoObject = await api
          .callFlutterEchoNullableEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('nullable class maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?>? echoObject = await api
          .callFlutterEchoNullableClassMap(allNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry
          in echoObject!.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets(
      'nullable NonNull string maps serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        final Map<String?, String?>? echoObject = await api
            .callFlutterEchoNullableNonNullStringMap(nonNullStringMap);
        expect(mapEquals(echoObject, nonNullStringMap), true);
      },
    );

    testWidgets(
      'nullable NonNull int maps serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        final Map<int?, int?>? echoObject = await api
            .callFlutterEchoNullableNonNullIntMap(nonNullIntMap);
        expect(mapEquals(echoObject, nonNullIntMap), true);
      },
    );

    testWidgets(
      'nullable NonNull enum maps serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        final Map<AnEnum?, AnEnum?>? echoObject = await api
            .callFlutterEchoNullableNonNullEnumMap(nonNullEnumMap);
        expect(mapEquals(echoObject, nonNullEnumMap), true);
      },
    );

    testWidgets(
      'nullable NonNull class maps serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();
        final Map<int?, AllNullableTypes?>? echoObject = await api
            .callFlutterEchoNullableNonNullClassMap(nonNullAllNullableTypesMap);
        for (final MapEntry<int?, AllNullableTypes?> entry
            in echoObject!.entries) {
          expect(entry.value, nonNullAllNullableTypesMap[entry.key]);
        }
      },
    );

    testWidgets('null maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<int?, int?>? echoObject = await api
          .callFlutterEchoNullableIntMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('nullable enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum? echoEnum = await api.callFlutterEchoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly (again)', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum? echoEnum = await api
          .callFlutterEchoAnotherNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets(
      'multi word nullable enums serialize and deserialize correctly',
      (WidgetTester _) async {
        final HostIntegrationCoreApi api = HostIntegrationCoreApi();

        const AnEnum sentEnum = AnEnum.fourHundredTwentyTwo;
        final AnEnum? echoEnum = await api.callFlutterEchoNullableEnum(
          sentEnum,
        );
        expect(echoEnum, sentEnum);
      },
    );

    testWidgets('null enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum? sentEnum = null;
      final AnEnum? echoEnum = await api.callFlutterEchoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null enums serialize and deserialize correctly (again)', (
      WidgetTester _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum? sentEnum = null;
      final AnotherEnum? echoEnum = await api
          .callFlutterEchoAnotherNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });
  });

  group('Proxy API Tests', () {
    if (!proxyApiSupportedLanguages.contains(targetGenerator)) {
      return;
    }

    testWidgets('named constructor', (_) async {
      final ProxyApiTestClass instance = ProxyApiTestClass.namedConstructor(
        aBool: true,
        anInt: 0,
        aDouble: 0.0,
        aString: '',
        aUint8List: Uint8List(0),
        aList: const <Object?>[],
        aMap: const <String?, Object?>{},
        anEnum: ProxyApiTestEnum.one,
        aProxyApi: ProxyApiSuperClass(),
        flutterEchoBool: (ProxyApiTestClass instance, bool aBool) => true,
        flutterEchoInt: (_, __) => 3,
        flutterEchoDouble: (_, __) => 1.0,
        flutterEchoString: (_, __) => '',
        flutterEchoUint8List: (_, __) => Uint8List(0),
        flutterEchoList: (_, __) => <Object?>[],
        flutterEchoProxyApiList: (_, __) => <ProxyApiTestClass?>[],
        flutterEchoMap: (_, __) => <String?, Object?>{},
        flutterEchoEnum: (_, __) => ProxyApiTestEnum.one,
        flutterEchoProxyApi: (_, __) => ProxyApiSuperClass(),
        flutterEchoAsyncString: (_, __) async => '',
        flutterEchoProxyApiMap: (_, __) => <String?, ProxyApiTestClass?>{},
      );
      // Ensure no error calling method on instance.
      await instance.noop();
    });

    testWidgets('noop', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(api.noop(), completes);
    });

    testWidgets('throwError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(
        () => api.throwError(),
        throwsA(isA<PlatformException>()),
      );
    });

    testWidgets('throwErrorFromVoid', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(
        () => api.throwErrorFromVoid(),
        throwsA(isA<PlatformException>()),
      );
    });

    testWidgets('throwFlutterError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(
        () => api.throwFlutterError(),
        throwsA((dynamic e) {
          return e is PlatformException &&
              e.code == 'code' &&
              e.message == 'message' &&
              e.details == 'details';
        }),
      );
    });

    testWidgets('echoInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const int value = 0;
      expect(await api.echoInt(value), value);
    });

    testWidgets('echoDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const double value = 0.0;
      expect(await api.echoDouble(value), value);
    });

    testWidgets('echoBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const bool value = true;
      expect(await api.echoBool(value), value);
    });

    testWidgets('echoString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const String value = 'string';
      expect(await api.echoString(value), value);
    });

    testWidgets('echoUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final Uint8List value = Uint8List(0);
      expect(await api.echoUint8List(value), value);
    });

    testWidgets('echoObject', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const Object value = 'apples';
      expect(await api.echoObject(value), value);
    });

    testWidgets('echoList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const List<Object?> value = <int>[1, 2];
      expect(await api.echoList(value), value);
    });

    testWidgets('echoProxyApiList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final List<ProxyApiTestClass> value = <ProxyApiTestClass>[
        _createGenericProxyApiTestClass(),
        _createGenericProxyApiTestClass(),
      ];
      expect(await api.echoProxyApiList(value), value);
    });

    testWidgets('echoMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const Map<String?, Object?> value = <String?, Object?>{'apple': 'pie'};
      expect(await api.echoMap(value), value);
    });

    testWidgets('echoProxyApiMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final Map<String, ProxyApiTestClass> value = <String, ProxyApiTestClass>{
        '42': _createGenericProxyApiTestClass(),
      };
      expect(await api.echoProxyApiMap(value), value);
    });

    testWidgets('echoEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const ProxyApiTestEnum value = ProxyApiTestEnum.three;
      expect(await api.echoEnum(value), value);
    });

    testWidgets('echoProxyApi', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final ProxyApiSuperClass value = ProxyApiSuperClass();
      expect(await api.echoProxyApi(value), value);
    });

    testWidgets('echoNullableInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableInt(null), null);
      expect(await api.echoNullableInt(1), 1);
    });

    testWidgets('echoNullableDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableDouble(null), null);
      expect(await api.echoNullableDouble(1.0), 1.0);
    });

    testWidgets('echoNullableBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableBool(null), null);
      expect(await api.echoNullableBool(false), false);
    });

    testWidgets('echoNullableString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableString(null), null);
      expect(await api.echoNullableString('aString'), 'aString');
    });

    testWidgets('echoNullableUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableUint8List(null), null);
      expect(await api.echoNullableUint8List(Uint8List(0)), Uint8List(0));
    });

    testWidgets('echoNullableObject', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableObject(null), null);
      expect(await api.echoNullableObject('aString'), 'aString');
    });

    testWidgets('echoNullableList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableList(null), null);
      expect(await api.echoNullableList(<int>[1]), <int>[1]);
    });

    testWidgets('echoNullableMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableMap(null), null);
      expect(
        await api.echoNullableMap(<String, int>{'value': 1}),
        <String, int>{'value': 1},
      );
    });

    testWidgets('echoNullableEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableEnum(null), null);
      expect(
        await api.echoNullableEnum(ProxyApiTestEnum.one),
        ProxyApiTestEnum.one,
      );
    });

    testWidgets('echoNullableProxyApi', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableProxyApi(null), null);

      final ProxyApiSuperClass proxyApi = ProxyApiSuperClass();
      expect(await api.echoNullableProxyApi(proxyApi), proxyApi);
    });

    testWidgets('noopAsync', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      await expectLater(api.noopAsync(), completes);
    });

    testWidgets('echoAsyncInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const int value = 0;
      expect(await api.echoAsyncInt(value), value);
    });

    testWidgets('echoAsyncDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const double value = 0.0;
      expect(await api.echoAsyncDouble(value), value);
    });

    testWidgets('echoAsyncBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const bool value = false;
      expect(await api.echoAsyncBool(value), value);
    });

    testWidgets('echoAsyncString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const String value = 'ping';
      expect(await api.echoAsyncString(value), value);
    });

    testWidgets('echoAsyncUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final Uint8List value = Uint8List(0);
      expect(await api.echoAsyncUint8List(value), value);
    });

    testWidgets('echoAsyncObject', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const Object value = 0;
      expect(await api.echoAsyncObject(value), value);
    });

    testWidgets('echoAsyncList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const List<Object?> value = <Object?>['apple', 'pie'];
      expect(await api.echoAsyncList(value), value);
    });

    testWidgets('echoAsyncMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final Map<String?, Object?> value = <String?, Object?>{
        'something': ProxyApiSuperClass(),
      };
      expect(await api.echoAsyncMap(value), value);
    });

    testWidgets('echoAsyncEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const ProxyApiTestEnum value = ProxyApiTestEnum.two;
      expect(await api.echoAsyncEnum(value), value);
    });

    testWidgets('throwAsyncError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(
        () => api.throwAsyncError(),
        throwsA(isA<PlatformException>()),
      );
    });

    testWidgets('throwAsyncErrorFromVoid', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(
        () => api.throwAsyncErrorFromVoid(),
        throwsA(isA<PlatformException>()),
      );
    });

    testWidgets('throwAsyncFlutterError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(
        () => api.throwAsyncFlutterError(),
        throwsA((dynamic e) {
          return e is PlatformException &&
              e.code == 'code' &&
              e.message == 'message' &&
              e.details == 'details';
        }),
      );
    });

    testWidgets('echoAsyncNullableInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableInt(null), null);
      expect(await api.echoAsyncNullableInt(1), 1);
    });

    testWidgets('echoAsyncNullableDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableDouble(null), null);
      expect(await api.echoAsyncNullableDouble(2.0), 2.0);
    });

    testWidgets('echoAsyncNullableBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableBool(null), null);
      expect(await api.echoAsyncNullableBool(true), true);
    });

    testWidgets('echoAsyncNullableString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableString(null), null);
      expect(await api.echoAsyncNullableString('aString'), 'aString');
    });

    testWidgets('echoAsyncNullableUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableUint8List(null), null);
      expect(await api.echoAsyncNullableUint8List(Uint8List(0)), Uint8List(0));
    });

    testWidgets('echoAsyncNullableObject', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableObject(null), null);
      expect(await api.echoAsyncNullableObject(1), 1);
    });

    testWidgets('echoAsyncNullableList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableList(null), null);
      expect(await api.echoAsyncNullableList(<int>[1]), <int>[1]);
    });

    testWidgets('echoAsyncNullableMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableMap(null), null);
      expect(
        await api.echoAsyncNullableMap(<String, int>{'banana': 1}),
        <String, int>{'banana': 1},
      );
    });

    testWidgets('echoAsyncNullableEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableEnum(null), null);
      expect(
        await api.echoAsyncNullableEnum(ProxyApiTestEnum.one),
        ProxyApiTestEnum.one,
      );
    });

    testWidgets('staticNoop', (_) async {
      await expectLater(ProxyApiTestClass.staticNoop(), completes);
    });

    testWidgets('echoStaticString', (_) async {
      const String value = 'static string';
      expect(await ProxyApiTestClass.echoStaticString(value), value);
    });

    testWidgets('staticAsyncNoop', (_) async {
      await expectLater(ProxyApiTestClass.staticAsyncNoop(), completes);
    });

    testWidgets('callFlutterNoop', (_) async {
      bool called = false;
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterNoop: (ProxyApiTestClass instance) async {
          called = true;
        },
      );

      await api.callFlutterNoop();
      expect(called, isTrue);
    });

    testWidgets('callFlutterThrowError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterThrowError: (_) {
          throw FlutterError('this is an error');
        },
      );

      await expectLater(
        api.callFlutterThrowError(),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException exception) => exception.message,
            'message',
            equals('this is an error'),
          ),
        ),
      );
    });

    testWidgets('callFlutterThrowErrorFromVoid', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterThrowErrorFromVoid: (_) {
          throw FlutterError('this is an error');
        },
      );

      await expectLater(
        api.callFlutterThrowErrorFromVoid(),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException exception) => exception.message,
            'message',
            equals('this is an error'),
          ),
        ),
      );
    });

    testWidgets('callFlutterEchoBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoBool: (_, bool aBool) => aBool,
      );

      const bool value = true;
      expect(await api.callFlutterEchoBool(value), value);
    });

    testWidgets('callFlutterEchoInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoInt: (_, int anInt) => anInt,
      );

      const int value = 0;
      expect(await api.callFlutterEchoInt(value), value);
    });

    testWidgets('callFlutterEchoDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoDouble: (_, double aDouble) => aDouble,
      );

      const double value = 0.0;
      expect(await api.callFlutterEchoDouble(value), value);
    });

    testWidgets('callFlutterEchoString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoString: (_, String aString) => aString,
      );

      const String value = 'a string';
      expect(await api.callFlutterEchoString(value), value);
    });

    testWidgets('callFlutterEchoUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoUint8List: (_, Uint8List aUint8List) => aUint8List,
      );

      final Uint8List value = Uint8List(0);
      expect(await api.callFlutterEchoUint8List(value), value);
    });

    testWidgets('callFlutterEchoList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoList: (_, List<Object?> aList) => aList,
      );

      final List<Object?> value = <Object?>[0, 0.0, true, ProxyApiSuperClass()];
      expect(await api.callFlutterEchoList(value), value);
    });

    testWidgets('callFlutterEchoProxyApiList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoProxyApiList: (_, List<ProxyApiTestClass?> aList) => aList,
      );

      final List<ProxyApiTestClass?> value = <ProxyApiTestClass>[
        _createGenericProxyApiTestClass(),
      ];
      expect(await api.callFlutterEchoProxyApiList(value), value);
    });

    testWidgets('callFlutterEchoMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoMap: (_, Map<String?, Object?> aMap) => aMap,
      );

      final Map<String?, Object?> value = <String?, Object?>{'a String': 4};
      expect(await api.callFlutterEchoMap(value), value);
    });

    testWidgets('callFlutterEchoProxyApiMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoProxyApiMap:
            (_, Map<String?, ProxyApiTestClass?> aMap) => aMap,
      );

      final Map<String?, ProxyApiTestClass?> value =
          <String?, ProxyApiTestClass?>{
            'a String': _createGenericProxyApiTestClass(),
          };
      expect(await api.callFlutterEchoProxyApiMap(value), value);
    });

    testWidgets('callFlutterEchoEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoEnum: (_, ProxyApiTestEnum anEnum) => anEnum,
      );

      const ProxyApiTestEnum value = ProxyApiTestEnum.three;
      expect(await api.callFlutterEchoEnum(value), value);
    });

    testWidgets('callFlutterEchoProxyApi', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoProxyApi: (_, ProxyApiSuperClass aProxyApi) => aProxyApi,
      );

      final ProxyApiSuperClass value = ProxyApiSuperClass();
      expect(await api.callFlutterEchoProxyApi(value), value);
    });

    testWidgets('callFlutterEchoNullableBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableBool: (_, bool? aBool) => aBool,
      );
      expect(await api.callFlutterEchoNullableBool(null), null);
      expect(await api.callFlutterEchoNullableBool(true), true);
    });

    testWidgets('callFlutterEchoNullableInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableInt: (_, int? anInt) => anInt,
      );
      expect(await api.callFlutterEchoNullableInt(null), null);
      expect(await api.callFlutterEchoNullableInt(1), 1);
    });

    testWidgets('callFlutterEchoNullableDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableDouble: (_, double? aDouble) => aDouble,
      );
      expect(await api.callFlutterEchoNullableDouble(null), null);
      expect(await api.callFlutterEchoNullableDouble(1.0), 1.0);
    });

    testWidgets('callFlutterEchoNullableString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableString: (_, String? aString) => aString,
      );
      expect(await api.callFlutterEchoNullableString(null), null);
      expect(await api.callFlutterEchoNullableString('aString'), 'aString');
    });

    testWidgets('callFlutterEchoNullableUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableUint8List: (_, Uint8List? aUint8List) => aUint8List,
      );
      expect(await api.callFlutterEchoNullableUint8List(null), null);
      expect(
        await api.callFlutterEchoNullableUint8List(Uint8List(0)),
        Uint8List(0),
      );
    });

    testWidgets('callFlutterEchoNullableList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableList: (_, List<Object?>? aList) => aList,
      );
      expect(await api.callFlutterEchoNullableList(null), null);
      expect(await api.callFlutterEchoNullableList(<int>[0]), <int>[0]);
    });

    testWidgets('callFlutterEchoNullableMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableMap: (_, Map<String?, Object?>? aMap) => aMap,
      );
      expect(await api.callFlutterEchoNullableMap(null), null);
      expect(
        await api.callFlutterEchoNullableMap(<String, int>{'str': 0}),
        <String, int>{'str': 0},
      );
    });

    testWidgets('callFlutterEchoNullableEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableEnum: (_, ProxyApiTestEnum? anEnum) => anEnum,
      );
      expect(await api.callFlutterEchoNullableEnum(null), null);
      expect(
        await api.callFlutterEchoNullableEnum(ProxyApiTestEnum.two),
        ProxyApiTestEnum.two,
      );
    });

    testWidgets('callFlutterEchoNullableProxyApi', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableProxyApi:
            (_, ProxyApiSuperClass? aProxyApi) => aProxyApi,
      );

      expect(await api.callFlutterEchoNullableProxyApi(null), null);

      final ProxyApiSuperClass proxyApi = ProxyApiSuperClass();
      expect(await api.callFlutterEchoNullableProxyApi(proxyApi), proxyApi);
    });

    testWidgets('callFlutterNoopAsync', (_) async {
      bool called = false;
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterNoopAsync: (ProxyApiTestClass instance) async {
          called = true;
        },
      );

      await api.callFlutterNoopAsync();
      expect(called, isTrue);
    });

    testWidgets('callFlutterEchoAsyncString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoAsyncString: (_, String aString) async => aString,
      );

      const String value = 'a string';
      expect(await api.callFlutterEchoAsyncString(value), value);
    });
  });

  group('Flutter API with suffix', () {
    setUp(() {
      FlutterSmallApi.setUp(
        _SmallFlutterApi(),
        messageChannelSuffix: 'suffixOne',
      );
      FlutterSmallApi.setUp(
        _SmallFlutterApi(),
        messageChannelSuffix: 'suffixTwo',
      );
    });

    testWidgets('echo string succeeds with suffix with multiple instances', (
      _,
    ) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const String sentObject = "I'm a computer";
      final String echoObject = await api.callFlutterSmallApiEchoString(
        sentObject,
      );
      expect(echoObject, sentObject);
    });
  });

  testWidgets('Unused data class still generate', (_) async {
    final UnusedClass unused = UnusedClass();
    expect(unused, unused);
  });

  /// Task queues

  testWidgets('non-task-queue handlers run on a the main thread', (_) async {
    final HostIntegrationCoreApi api = HostIntegrationCoreApi();
    expect(await api.defaultIsMainThread(), true);
  });

  testWidgets('task queue handlers run on a background thread', (_) async {
    final HostIntegrationCoreApi api = HostIntegrationCoreApi();
    // Currently only Android and iOS have task queue support. See
    // https://github.com/flutter/flutter/issues/93945
    // Rather than skip the test, this changes the expectation, so that there
    // is test coverage of the code path, even though the actual backgrounding
    // doesn't happen. This is especially important for macOS, which may need to
    // share generated code with iOS, falling back to the main thread since
    // background is not supported.
    final bool taskQueuesSupported =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    expect(await api.taskQueueIsBackgroundThread(), taskQueuesSupported);
  });

  /// Event channels

  const List<TargetGenerator> eventChannelSupported = <TargetGenerator>[
    TargetGenerator.kotlin,
    TargetGenerator.swift,
  ];

  testWidgets(
    'event channel sends continuous ints',
    (_) async {
      final Stream<int> events = streamInts();
      final List<int> listEvents = await events.toList();
      for (final int value in listEvents) {
        expect(listEvents[value], value);
      }
    },
    skip: !eventChannelSupported.contains(targetGenerator),
  );

  testWidgets(
    'event channel handles extended sealed classes',
    (_) async {
      final Completer<void> completer = Completer<void>();
      int count = 0;
      final Stream<PlatformEvent> events = streamEvents();
      events.listen((PlatformEvent event) {
        switch (event) {
          case IntEvent():
            expect(event.value, 1);
            expect(count, 0);
            count++;
          case StringEvent():
            expect(event.value, 'string');
            expect(count, 1);
            count++;
          case BoolEvent():
            expect(event.value, false);
            expect(count, 2);
            count++;
          case DoubleEvent():
            expect(event.value, 3.14);
            expect(count, 3);
            count++;
          case ObjectsEvent():
            expect(event.value, true);
            expect(count, 4);
            count++;
          case EnumEvent():
            expect(event.value, EventEnum.fortyTwo);
            expect(count, 5);
            count++;
          case ClassEvent():
            expect(event.value.aNullableInt, 0);
            expect(count, 6);
            count++;
          case EmptyEvent():
            expect(count, 7);
            completer.complete();
        }
      });
      await completer.future;
    },
    skip: !eventChannelSupported.contains(targetGenerator),
  );

  testWidgets(
    'event channels handle multiple instances',
    (_) async {
      final Completer<void> completer1 = Completer<void>();
      final Completer<void> completer2 = Completer<void>();
      final Stream<int> events1 = streamConsistentNumbers(instanceName: '1');
      final Stream<int> events2 = streamConsistentNumbers(instanceName: '2');

      events1
          .listen((int event) {
            expect(event, 1);
          })
          .onDone(() => completer1.complete());

      events2
          .listen((int event) {
            expect(event, 2);
          })
          .onDone(() => completer2.complete());

      await completer1.future;
      await completer2.future;
    },
    skip: !eventChannelSupported.contains(targetGenerator),
  );

  testWidgets(
    'sealed subclasses serialize and deserialize correctly',
    (WidgetTester _) async {
      final List<PlatformEvent> events = <PlatformEvent>[
        IntEvent(value: regularInt),
        IntEvent(value: biggerThanBigInt),
        DoubleEvent(value: 2.0694),
        BoolEvent(value: true),
        BoolEvent(value: false),
        StringEvent(value: 'default'),
        ObjectsEvent(value: true),
        EnumEvent(value: EventEnum.fortyTwo),
        ClassEvent(value: genericEventAllNullableTypesWithoutRecursion),
        EmptyEvent(),
      ];

      final SealedClassApi api = SealedClassApi();

      for (final PlatformEvent sentEvent in events) {
        final PlatformEvent receivedEvent = await api.echo(sentEvent);
        expect(receivedEvent, equals(sentEvent));
      }
    },
    skip: !eventChannelSupported.contains(targetGenerator),
  );

  test(
    'nested kotlin sealed classes serialize and deserialize correctly',
    () async {
      final KotlinNestedSealedApi api = KotlinNestedSealedApi();

      final List<SomeState> states = <SomeState>[
        Loading(progress: 42),
        Success(data: 'ok'),
        Error(code: 7),
      ];

      for (final SomeState sentState in states) {
        final SomeState receivedState = await api.echo(sentState);
        expect(receivedState, equals(sentState));
      }
    },
    skip: targetGenerator != TargetGenerator.kotlin,
  );

  const List<TargetGenerator> targetSupportsGenerics = <TargetGenerator>[
    TargetGenerator.kotlin,
    TargetGenerator.swift,
  ];

  // Generic API tests
  group(
    'Host Generic API tests',
    skip: !targetSupportsGenerics.contains(targetGenerator),
    () {
      final HostGenericApi api = HostGenericApi();

      testWidgets('generic container int echo works', (WidgetTester _) async {
        const GenericContainer<int> input = GenericContainer<int>(
          value: 42,
          values: <int>[1, 2, 3],
        );

        final GenericContainer<int> result = await api.echoGenericInt(input);
        expect(result.value, equals(input.value));
        expect(result.values, equals(input.values));
      });

      testWidgets('generic container string echo works', (
        WidgetTester _,
      ) async {
        const GenericContainer<String> input = GenericContainer<String>(
          value: 'test',
          values: <String>['a', 'b', 'c'],
        );
        final GenericContainer<String> result = await api.echoGenericString(
          input,
        );
        expect(result.value, equals(input.value));
        expect(result.values, equals(input.values));
      });

      testWidgets('generic container double echo works', (
        WidgetTester _,
      ) async {
        const GenericContainer<double> input = GenericContainer<double>(
          value: 3.14,
          values: <double>[1.0, 2.0, 3.0],
        );
        final GenericContainer<double> result = await api.echoGenericDouble(
          input,
        );
        expect(result.value, equals(input.value));
        expect(result.values, equals(input.values));
      });

      testWidgets('generic container bool echo works', (WidgetTester _) async {
        const GenericContainer<bool> input = GenericContainer<bool>(
          value: true,
          values: <bool>[true, false, true],
        );
        final GenericContainer<bool> result = await api.echoGenericBool(input);
        expect(result.value, equals(input.value));
        expect(result.values, equals(input.values));
      });

      testWidgets('generic container enum echo works', (WidgetTester _) async {
        const GenericContainer<GenericsAnEnum> input =
            GenericContainer<GenericsAnEnum>(
              value: GenericsAnEnum.fortyTwo,
              values: <GenericsAnEnum>[
                GenericsAnEnum.one,
                GenericsAnEnum.two,
                GenericsAnEnum.three,
              ],
            );
        final GenericContainer<GenericsAnEnum> result = await api
            .echoGenericEnum(
              input,
            );
        expect(result.value, equals(input.value));
        expect(result.values, equals(input.values));
      });

      testWidgets('generic container nullable int echo works', (
        WidgetTester _,
      ) async {
        const GenericContainer<int?> input = GenericContainer<int?>(
          value: 42,
          values: <int?>[1, null, 3],
        );
        final GenericContainer<int?> result = await api.echoGenericNullableInt(
          input,
        );
        expect(result.value, equals(input.value));
        expect(result.values, equals(input.values));
      });

      testWidgets('generic container nullable string echo works', (
        WidgetTester _,
      ) async {
        const GenericContainer<String?> input = GenericContainer<String?>(
          value: 'test',
          values: <String?>['a', null, 'c'],
        );
        final GenericContainer<String?> result = await api
            .echoGenericNullableString(input);
        expect(result.value, equals(input.value));
        expect(result.values, equals(input.values));
      });

      testWidgets('generic pair string-int echo works', (WidgetTester _) async {
        const GenericPair<String, int> input = GenericPair<String, int>(
          first: 'hello',
          second: 42,
          map: <String, int>{'key1': 1, 'key2': 2},
        );
        final GenericPair<String, int> result = await api
            .echoGenericPairStringInt(input);
        expect(result.first, equals(input.first));
        expect(result.second, equals(input.second));
        expect(result.map, equals(input.map));
      });

      testWidgets('generic pair int-string echo works', (WidgetTester _) async {
        const GenericPair<int, String> input = GenericPair<int, String>(
          first: 42,
          second: 'hello',
          map: <int, String>{1: 'one', 2: 'two'},
        );
        final GenericPair<int, String> result = await api
            .echoGenericPairIntString(input);
        expect(result.first, equals(input.first));
        expect(result.second, equals(input.second));
        expect(result.map, equals(input.map));
      });

      testWidgets('generic pair double-bool echo works', (
        WidgetTester _,
      ) async {
        final GenericPair<double, bool> input = GenericPair<double, bool>(
          first: 3.14,
          second: true,
          map: <double, bool>{1.0: true, 2.0: false},
        );
        final GenericPair<double, bool> result = await api
            .echoGenericPairDoubleBool(input);
        expect(result.first, equals(input.first));
        expect(result.second, equals(input.second));
        expect(result.map, equals(input.map));
      });

      testWidgets('nested generic string-int-double echo works', (
        WidgetTester _,
      ) async {
        const NestedGeneric<String, int, double> input =
            NestedGeneric<String, int, double>(
              container: GenericContainer<String>(
                value: 'test',
                values: <String>['a', 'b'],
              ),
              pairs: <GenericPair<int, double>>[
                GenericPair<int, double>(
                  first: 1,
                  second: 1.0,
                  map: <int, double>{1: 1.0, 2: 2.0},
                ),
              ],
              nestedMap: <String, GenericContainer<int>>{
                'key': GenericContainer<int>(
                  value: 42,
                  values: <int>[1, 2, 3],
                ),
              },
              listOfMaps: <Map<int, double>>[
                <int, double>{1: 1.0, 2: 2.0},
              ],
            );
        final NestedGeneric<String, int, double> result = await api
            .echoNestedGenericStringIntDouble(input);
        expect(result.container.value, equals(input.container.value));
        expect(result.container.values, equals(input.container.values));
        expect(result.pairs.length, equals(input.pairs.length));
        expect(result.nestedMap.length, equals(input.nestedMap.length));
        expect(result.listOfMaps.length, equals(input.listOfMaps.length));
      });

      testWidgets('generic list container echo works', (WidgetTester _) async {
        final List<GenericContainer<int>> input = <GenericContainer<int>>[
          const GenericContainer<int>(value: 1, values: <int>[1, 2]),
          const GenericContainer<int>(value: 2, values: <int>[3, 4]),
        ];
        final List<GenericContainer<int>> result = await api
            .echoListGenericContainer(input);
        expect(result.length, equals(input.length));
        for (int i = 0; i < result.length; i++) {
          expect(result[i].value, equals(input[i].value));
          expect(result[i].values, equals(input[i].values));
        }
      });

      testWidgets('generic list pair echo works', (WidgetTester _) async {
        final List<GenericPair<String, int>> input = <GenericPair<String, int>>[
          const GenericPair<String, int>(
            first: 'a',
            second: 1,
            map: <String, int>{'x': 1},
          ),
          const GenericPair<String, int>(
            first: 'b',
            second: 2,
            map: <String, int>{'y': 2},
          ),
        ];
        final List<GenericPair<String, int>> result = await api
            .echoListGenericPair(input);
        expect(result.length, equals(input.length));
        for (int i = 0; i < result.length; i++) {
          expect(result[i].first, equals(input[i].first));
          expect(result[i].second, equals(input[i].second));
          expect(result[i].map, equals(input[i].map));
        }
      });

      testWidgets('generic map container echo works', (WidgetTester _) async {
        final Map<String, GenericContainer<int>>
        input = <String, GenericContainer<int>>{
          'key1': const GenericContainer<int>(value: 1, values: <int>[1, 2]),
          'key2': const GenericContainer<int>(value: 2, values: <int>[3, 4]),
        };
        final Map<String, GenericContainer<int>> result = await api
            .echoMapGenericContainer(input);
        expect(result.length, equals(input.length));
        for (final String key in input.keys) {
          expect(result[key]?.value, equals(input[key]?.value));
          expect(result[key]?.values, equals(input[key]?.values));
        }
      });

      testWidgets('generic map pair echo works', (WidgetTester _) async {
        final Map<int, GenericPair<String, double>> input =
            <int, GenericPair<String, double>>{
              1: const GenericPair<String, double>(
                first: 'a',
                second: 1.0,
                map: <String, double>{'x': 1.0},
              ),
              2: const GenericPair<String, double>(
                first: 'b',
                second: 2.0,
                map: <String, double>{'y': 2.0},
              ),
            };
        final Map<int, GenericPair<String, double>> result = await api
            .echoMapGenericPair(input);
        expect(result.length, equals(input.length));
        for (final int key in input.keys) {
          expect(result[key]?.first, equals(input[key]?.first));
          expect(result[key]?.second, equals(input[key]?.second));
          expect(result[key]?.map, equals(input[key]?.map));
        }
      });

      testWidgets('async generic int echo works', (WidgetTester _) async {
        const GenericContainer<int> input = GenericContainer<int>(
          value: 42,
          values: <int>[1, 2, 3],
        );
        final GenericContainer<int> result = await api.echoAsyncGenericInt(
          input,
        );
        expect(result.value, equals(input.value));
        expect(result.values, equals(input.values));
      });

      testWidgets('async nested generic echo works', (WidgetTester _) async {
        const NestedGeneric<String, int, double> input =
            NestedGeneric<String, int, double>(
              container: GenericContainer<String>(
                value: 'test',
                values: <String>['a'],
              ),
              pairs: <GenericPair<int, double>>[
                GenericPair<int, double>(
                  first: 1,
                  second: 1.0,
                  map: <int, double>{1: 1.0},
                ),
              ],
              nestedMap: <String, GenericContainer<int>>{
                'key': GenericContainer<int>(value: 42, values: <int>[1]),
              },
              listOfMaps: <Map<int, double>>[
                <int, double>{1: 1.0},
              ],
            );
        final NestedGeneric<String, int, double> result = await api
            .echoAsyncNestedGeneric(input);
        expect(result.container.value, equals(input.container.value));
      });

      testWidgets('either generic container echo works', (
        WidgetTester _,
      ) async {
        const Either<GenericContainer<int>, GenericContainer<String>> input =
            Left<GenericContainer<int>, GenericContainer<String>>(
              value: GenericContainer<int>(value: 42, values: <int>[1, 2, 3]),
            );
        final Either<GenericContainer<int>, GenericContainer<String>> result =
            await api.echoEitherGenericIntOrString(input);
        expect(
          result,
          isA<Left<GenericContainer<int>, GenericContainer<String>>>(),
        );
        final Left<GenericContainer<int>, GenericContainer<String>> leftResult =
            result as Left<GenericContainer<int>, GenericContainer<String>>;
        expect(leftResult.value.value, equals(42));
        expect(leftResult.value.values, equals(<int>[1, 2, 3]));
      });

      testWidgets('either generic pair echo works', (WidgetTester _) async {
        const Either<GenericPair<String, int>, GenericPair<int, String>> input =
            Right<GenericPair<String, int>, GenericPair<int, String>>(
              value: GenericPair<int, String>(
                first: 42,
                second: 'test',
                map: <int, String>{1: 'one'},
              ),
            );
        final Either<GenericPair<String, int>, GenericPair<int, String>>
        result = await api.echoEitherGenericPairStringIntOrIntString(input);
        expect(
          result,
          isA<Right<GenericPair<String, int>, GenericPair<int, String>>>(),
        );
        final Right<GenericPair<String, int>, GenericPair<int, String>>
        rightResult =
            result as Right<GenericPair<String, int>, GenericPair<int, String>>;
        expect(rightResult.value.first, equals(42));
        expect(rightResult.value.second, equals('test'));
      });

      // GenericsAllNullableTypesTyped tests
      testWidgets('typed nullable string-int-double echo works', (
        WidgetTester _,
      ) async {
        final GenericsAllNullableTypesTyped<String, int, double> input =
            GenericsAllNullableTypesTyped<String, int, double>(
              aNullableInt: 42,
              aNullableInt64: 64,
              aNullableDouble: 3.14,
              aNullableByteArray: Uint8List.fromList(<int>[
                1,
                2,
                3,
              ]),
              aNullable4ByteArray: Int32List.fromList(<int>[
                4,
                5,
                6,
              ]),
              aNullable8ByteArray: Int64List.fromList(<int>[
                7,
                8,
                9,
              ]),
              aNullableFloatArray: Float64List.fromList(<double>[
                1.1,
                2.2,
                3.3,
              ]),
              aNullableEnum: GenericsAnEnum.fortyTwo,
              anotherNullableEnum: GenericsAnotherEnum.justInCase,
              aNullableString: 'test',
              aNullableObject: 'object',
              stringList: <String?>['a', null, 'c'],
              intList: <double?>[1.0, null, 3.0],
              doubleList: <int?>[1, null, 3],
              boolList: <String?>[null, 'b'],
              enumList: <double?>[4.0, 5.0],
              objectList: <int?>[6, 7],
              listList: <List<int?>?>[
                <int?>[1, 2],
              ],
              mapList: <Map<String?, double?>?>[
                <String?, double?>{'k': 1.0},
              ],
              recursiveClassList: <GenericsAllNullableTypes?>[
                null,
              ],
              map: <String?, String?>{'key': 'value'},
              stringMap: <String?, String?>{'s1': 's2'},
              intMap: <double?, int?>{1.0: 10},
              enumMap: <GenericsAnEnum?, GenericsAnEnum?>{
                GenericsAnEnum.one: GenericsAnEnum.two,
              },
              objectMap: <Object?, Object?>{'obj': 'val'},
              listMap: <int?, List<int?>?>{
                1: <int?>[1, 2],
              },
              mapMap: <int?, Map<int?, int?>?>{
                1: <int?, int?>{2: 3},
              },
              recursiveClassMap: <int?, GenericsAllNullableTypes?>{
                1: null,
              },
            );
        final GenericsAllNullableTypesTyped<String, int, double> result =
            await api.echoTypedNullableStringIntDouble(input);
        expect(result.aNullableBool, equals(input.aNullableBool));
        expect(result.aNullableString, equals(input.aNullableString));
        expect(result.aNullableInt, equals(input.aNullableInt));
        expect(result.aNullableDouble, equals(input.aNullableDouble));
      });

      testWidgets('typed nullable int-string-bool echo works', (
        WidgetTester _,
      ) async {
        final GenericsAllNullableTypesTyped<int, String, bool> input =
            GenericsAllNullableTypesTyped<int, String, bool>();
        final GenericsAllNullableTypesTyped<int, String, bool> result =
            await api.echoTypedNullableIntStringBool(input);
        expect(result.aNullableBool, isNull);
        expect(result.aNullableString, isNull);
        expect(result.aNullableInt, isNull);
        expect(result.aNullableDouble, isNull);
      });

      testWidgets('typed nullable enum-double-string echo works', (
        WidgetTester _,
      ) async {
        final GenericsAllNullableTypesTyped<GenericsAnEnum, double, String>
        input = GenericsAllNullableTypesTyped<GenericsAnEnum, double, String>(
          aNullableBool: false,
          aNullableInt: 100,
          aNullableInt64: 200,
          aNullableDouble: 2.71,
          aNullableByteArray: Uint8List.fromList(<int>[
            9,
            8,
            7,
          ]),
          aNullable4ByteArray: Int32List.fromList(<int>[
            6,
            5,
            4,
          ]),
          aNullable8ByteArray: Int64List.fromList(<int>[
            3,
            2,
            1,
          ]),
          aNullableFloatArray: Float64List.fromList(<double>[
            4.4,
            5.5,
          ]),
          aNullableEnum: GenericsAnEnum.three,
          anotherNullableEnum: GenericsAnotherEnum.justInCase,
          aNullableString: 'enum-test',
          aNullableObject: 42,
          list: <GenericsAnEnum?>[GenericsAnEnum.one],
          intList: <String?>[null, 'test'],
          doubleList: <double?>[9.9, 8.8],
          boolList: <GenericsAnEnum?>[GenericsAnEnum.two],
          enumList: <String?>['x', 'y'],
          objectList: <double?>[7.7],
          listList: <List<double?>?>[
            <double?>[1.1],
          ],
          mapList: <Map<GenericsAnEnum?, String?>?>[
            <GenericsAnEnum?, String?>{GenericsAnEnum.one: 'test'},
          ],
          recursiveClassList: <GenericsAllNullableTypes?>[
            null,
          ],
          map: <GenericsAnEnum?, GenericsAnEnum?>{
            GenericsAnEnum.one: GenericsAnEnum.two,
          },
          stringMap: <GenericsAnEnum?, GenericsAnEnum?>{
            GenericsAnEnum.three: GenericsAnEnum.fortyTwo,
          },
          intMap: <String?, double?>{'pi': 3.14},
          enumMap: <GenericsAnEnum?, GenericsAnEnum?>{
            GenericsAnEnum.one: GenericsAnEnum.two,
          },
          objectMap: <Object?, Object?>{'key': 123},
          listMap: <int?, List<double?>?>{
            2: <double?>[2.2, 3.3],
          },
          mapMap: <int?, Map<double?, double?>?>{
            3: <double?, double?>{1.1: 2.2},
          },
          recursiveClassMap: <int?, GenericsAllNullableTypes?>{
            2: null,
          },
        );
        final GenericsAllNullableTypesTyped<GenericsAnEnum, double, String>
        result = await api.echoTypedNullableEnumDoubleString(input);
        expect(result.aNullableBool, equals(input.aNullableBool));
        expect(result.aNullableString, equals(input.aNullableString));
        expect(result.aNullableEnum, equals(input.aNullableEnum));
      });

      testWidgets('generic container with typed nullable echo works', (
        WidgetTester _,
      ) async {
        final GenericsAllNullableTypesTyped<String, int, double> typedInput =
            GenericsAllNullableTypesTyped<String, int, double>(
              aNullableBool: true,
              aNullableInt: 42,
              aNullableInt64: 64,
              aNullableDouble: 3.14,
              aNullableByteArray: Uint8List.fromList(<int>[1]),
              aNullable4ByteArray: Int32List.fromList(<int>[2]),
              aNullable8ByteArray: Int64List.fromList(<int>[3]),
              aNullableFloatArray: Float64List.fromList(<double>[4.0]),
              aNullableEnum: GenericsAnEnum.one,
              anotherNullableEnum: GenericsAnotherEnum.justInCase,
              aNullableString: 'container-test',
              aNullableObject: 'obj',
              stringList: <String?>['test'],
              intList: <double?>[1.0],
              doubleList: <int?>[2],
              boolList: <String?>[null],
              enumList: <double?>[3.0],
              objectList: <int?>[4],
              stringMap: <String?, String?>{'k': 'v'},
              enumMap: <GenericsAnEnum?, GenericsAnEnum?>{},
            );
        final GenericContainer<
          GenericsAllNullableTypesTyped<String, int, double>
        >
        input = GenericContainer<
          GenericsAllNullableTypesTyped<String, int, double>
        >(
          value: typedInput,
          values: <GenericsAllNullableTypesTyped<String, int, double>>[
            typedInput,
          ],
        );
        final GenericContainer<
          GenericsAllNullableTypesTyped<String, int, double>
        >
        result = await api.echoGenericContainerTypedNullable(input);
        expect(
          result.value?.aNullableString,
          equals(typedInput.aNullableString),
        );
        expect(result.values.length, equals(input.values.length));
      });

      testWidgets('list of typed nullable echo works', (WidgetTester _) async {
        final GenericsAllNullableTypesTyped<String, int, double> typed1 =
            GenericsAllNullableTypesTyped<String, int, double>(
              aNullableBool: true,
              aNullableInt: 1,
              aNullableInt64: 2,
              aNullableDouble: 1.0,
              aNullableByteArray: Uint8List.fromList(<int>[1]),
              aNullable4ByteArray: Int32List.fromList(<int>[1]),
              aNullable8ByteArray: Int64List.fromList(<int>[1]),
              aNullableFloatArray: Float64List.fromList(<double>[1.0]),
              aNullableEnum: GenericsAnEnum.one,
              anotherNullableEnum: GenericsAnotherEnum.justInCase,
              aNullableString: 'list-test-1',
              aNullableObject: 'obj1',
              stringList: <String?>['a'],
              intList: <double?>[1.0],
              doubleList: <int?>[1],
              boolList: <String?>['x'],
              enumList: <double?>[1.0],
              objectList: <int?>[1],
              stringMap: <String?, String?>{'a': 'b'},
            );
        final GenericsAllNullableTypesTyped<String, int, double> typed2 =
            GenericsAllNullableTypesTyped<String, int, double>(
              aNullableBool: false,
              aNullableInt: 2,
              aNullableInt64: 3,
              aNullableDouble: 2.0,
              aNullableByteArray: Uint8List.fromList(<int>[2]),
              aNullable4ByteArray: Int32List.fromList(<int>[2]),
              aNullable8ByteArray: Int64List.fromList(<int>[2]),
              aNullableFloatArray: Float64List.fromList(<double>[2.0]),
              aNullableEnum: GenericsAnEnum.two,
              anotherNullableEnum: GenericsAnotherEnum.justInCase,
              aNullableString: 'list-test-2',
              aNullableObject: 'obj2',
              stringList: <String?>['b'],
              intList: <double?>[2.0],
              doubleList: <int?>[2],
              boolList: <String?>['y'],
              enumList: <double?>[2.0],
              objectList: <int?>[2],
              stringMap: <String?, String?>{'c': 'd'},
            );
        final List<GenericsAllNullableTypesTyped<String, int, double>> input =
            <GenericsAllNullableTypesTyped<String, int, double>>[
              typed1,
              typed2,
            ];
        final List<GenericsAllNullableTypesTyped<String, int, double>> result =
            await api.echoListTypedNullable(input);
        expect(result.length, equals(2));
        expect(result[0].aNullableString, equals('list-test-1'));
        expect(result[1].aNullableString, equals('list-test-2'));
      });

      testWidgets('map with typed nullable echo works', (WidgetTester _) async {
        final GenericsAllNullableTypesTyped<int, String, double> typedValue =
            GenericsAllNullableTypesTyped<int, String, double>(
              aNullableInt: 99,
              aNullableInt64: 100,
              aNullableDouble: 9.99,
              aNullableEnum: GenericsAnEnum.fortyTwo,
              aNullableString: 'map-test',
              aNullableObject: 'map-obj',
              stringList: <int?>[99],
              intList: <double?>[9.99],
              doubleList: <String?>[null],
              boolList: <int?>[99],
              enumList: <double?>[9.99],
              objectList: <String?>['map'],
              stringMap: <int?, int?>{99: 100},
            );
        final Map<String, GenericsAllNullableTypesTyped<int, String, double>>
        input = <String, GenericsAllNullableTypesTyped<int, String, double>>{
          'key1': typedValue,
        };
        final Map<String, GenericsAllNullableTypesTyped<int, String, double>>
        result = await api.echoMapTypedNullable(input);
        expect(result.containsKey('key1'), isTrue);
        expect(result['key1']?.aNullableString, equals('map-test'));
      });

      testWidgets('async typed nullable string-int-double echo works', (
        WidgetTester _,
      ) async {
        final GenericsAllNullableTypesTyped<String, int, double> input =
            GenericsAllNullableTypesTyped<String, int, double>(
              aNullableBool: true,
              aNullableInt: 42,
              aNullableInt64: 64,
              aNullableDouble: 3.14,
              aNullableByteArray: Uint8List.fromList(<int>[1, 2, 3]),
              aNullable4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
              aNullable8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
              aNullableFloatArray: Float64List.fromList(<double>[
                1.1,
                2.2,
                3.3,
              ]),
              aNullableEnum: GenericsAnEnum.fortyTwo,
              anotherNullableEnum: GenericsAnotherEnum.justInCase,
              aNullableString: 'async-test',
              aNullableObject: 'async-object',
              stringList: <String?>['async'],
              intList: <double?>[1.0],
              doubleList: <int?>[1],
              boolList: <String?>['x'],
              enumList: <double?>[2.0],
              objectList: <int?>[2],
              stringMap: <String?, String?>{'async': 'test'},
            );
        final GenericsAllNullableTypesTyped<String, int, double> result =
            await api.echoAsyncTypedNullableStringIntDouble(input);
        expect(result.aNullableBool, equals(input.aNullableBool));
        expect(result.aNullableString, equals(input.aNullableString));
      });

      testWidgets('async generic container typed nullable echo works', (
        WidgetTester _,
      ) async {
        final GenericsAllNullableTypesTyped<String, int, double> typedInput =
            GenericsAllNullableTypesTyped<String, int, double>(
              aNullableBool: false,
              aNullableInt: 123,
              aNullableInt64: 456,
              aNullableDouble: 7.89,
              aNullableString: 'async-container',
              aNullableObject: 'container-obj',
            );
        final GenericContainer<
          GenericsAllNullableTypesTyped<String, int, double>
        >
        input = GenericContainer<
          GenericsAllNullableTypesTyped<String, int, double>
        >(
          value: typedInput,
          values: <GenericsAllNullableTypesTyped<String, int, double>>[
            typedInput,
          ],
        );
        final GenericContainer<
          GenericsAllNullableTypesTyped<String, int, double>
        >
        result = await api.echoAsyncGenericContainerTypedNullable(input);
        expect(result.value?.aNullableString, equals('async-container'));
        expect(result.values.length, equals(1));
      });

      testWidgets('GenericDefaults echo works', (WidgetTester _) async {
        final HostGenericApi api = HostGenericApi();

        final GenericDefaults input = GenericDefaults(
          genericInt: const GenericContainer<int>(
            value: 100,
            values: <int>[10, 20, 30],
          ),
          genericString: const GenericContainer<String>(
            value: 'test',
            values: <String>['x', 'y', 'z'],
          ),
          genericDouble: const GenericContainer<double>(
            value: 2.5,
            values: <double>[1.1, 2.2, 3.3],
          ),
          genericBool: const GenericContainer<bool>(
            value: false,
            values: <bool>[false, true, false],
          ),
          genericPairStringInt: const GenericPair<String, int>(
            first: 'test-key',
            second: 999,
            map: <String, int>{'test': 123, 'another': 456},
          ),
          genericPairIntString: const GenericPair<int, String>(
            first: 777,
            second: 'test-value',
            map: <int, String>{100: 'hundred', 200: 'two-hundred'},
          ),
          nestedGenericDefault: const NestedGeneric<String, int, double>(
            container: GenericContainer<String>(
              value: 'nested-test',
              values: <String>['a', 'b', 'c'],
            ),
            pairs: <GenericPair<int, double>>[
              GenericPair<int, double>(
                first: 5,
                second: 5.5,
                map: <int, double>{5: 5.5, 6: 6.6},
              ),
            ],
            nestedMap: <String, GenericContainer<int>>{
              'test-nested': GenericContainer<int>(
                value: 55,
                values: <int>[50, 60, 70],
              ),
            },
            listOfMaps: <Map<int, double>>[
              <int, double>{100: 100.0, 200: 200.0},
            ],
          ),
          genericPairEither: const GenericPair<int, Either<String, int>>(
            first: 0,
            second: Right<String, int>(value: 84),
            map: <int, Either<String, int>>{
              1: Right<String, int>(
                value: 2,
              ),
              2: Left<String, int>(value: 'result'),
            },
          ),
        );

        final GenericDefaults result = await api.echoGenericDefaults(input);

        // Verify GenericContainer<int>
        expect(result.genericInt.value, equals(input.genericInt.value));
        expect(result.genericInt.values, equals(input.genericInt.values));

        // Verify GenericContainer<String>
        expect(result.genericString.value, equals(input.genericString.value));
        expect(result.genericString.values, equals(input.genericString.values));

        // Verify GenericContainer<double>
        expect(result.genericDouble.value, equals(input.genericDouble.value));
        expect(result.genericDouble.values, equals(input.genericDouble.values));

        // Verify GenericContainer<bool>
        expect(result.genericBool.value, equals(input.genericBool.value));
        expect(result.genericBool.values, equals(input.genericBool.values));

        // Verify GenericPair<String, int>
        expect(
          result.genericPairStringInt.first,
          equals(input.genericPairStringInt.first),
        );
        expect(
          result.genericPairStringInt.second,
          equals(input.genericPairStringInt.second),
        );
        expect(
          result.genericPairStringInt.map,
          equals(input.genericPairStringInt.map),
        );

        expect(
          result.genericPairIntString.first,
          equals(input.genericPairIntString.first),
        );
        expect(
          result.genericPairIntString.second,
          equals(input.genericPairIntString.second),
        );
        expect(
          result.genericPairIntString.map,
          equals(input.genericPairIntString.map),
        );

        expect(
          result.nestedGenericDefault.container.value,
          equals(input.nestedGenericDefault.container.value),
        );
        expect(
          result.nestedGenericDefault.pairs.length,
          equals(input.nestedGenericDefault.pairs.length),
        );
        expect(
          result.nestedGenericDefault.pairs[0].first,
          equals(input.nestedGenericDefault.pairs[0].first),
        );
      });

      testWidgets('GenericDefaults returnGenericDefaults works', (
        WidgetTester _,
      ) async {
        final HostGenericApi api = HostGenericApi();

        final GenericDefaults result = await api.returnGenericDefaults();

        // Verify default values are returned correctly
        expect(result.genericInt.value, equals(42));
        expect(result.genericInt.values, equals(<int>[1, 2, 3]));

        expect(result.genericString.value, equals('default'));
        expect(result.genericString.values, equals(<String>['a', 'b', 'c']));

        expect(result.genericDouble.value, equals(3.14));
        expect(result.genericDouble.values, equals(<double>[1.0, 2.0, 3.0]));

        expect(result.genericBool.value, equals(true));
        expect(result.genericBool.values, equals(<bool>[true, false, true]));

        expect(result.genericPairStringInt.first, equals('default'));
        expect(result.genericPairStringInt.second, equals(42));
        expect(result.genericPairStringInt.map['key1'], equals(1));
        expect(result.genericPairStringInt.map['key2'], equals(2));

        expect(result.genericPairIntString.first, equals(100));
        expect(result.genericPairIntString.second, equals('value'));

        expect(result.nestedGenericDefault.container.value, equals('nested'));
        expect(
          result.nestedGenericDefault.container.values,
          equals(<String>['x', 'y', 'z']),
        );
      });

      testWidgets('GenericDefaults async echo works', (WidgetTester _) async {
        final HostGenericApi api = HostGenericApi();

        final GenericDefaults input = GenericDefaults();
        final GenericDefaults result = await api.echoAsyncGenericDefaults(
          input,
        );

        // Verify async echo returns the same values
        expect(result.genericInt.value, equals(input.genericInt.value));
        expect(result.genericString.value, equals(input.genericString.value));
        expect(result.genericDouble.value, equals(input.genericDouble.value));
        expect(result.genericBool.value, equals(input.genericBool.value));
      });
    },
  );

  group('FlutterGenericApi tests', () {
    setUp(() {
      FlutterGenericApi.setUp(_FlutterGenericApiTestImplementation());
    });

    testWidgets('generic containers serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      const GenericContainer<int> sentContainer = GenericContainer<int>(
        value: 42,
        values: <int>[1, 2, 3],
      );
      final GenericContainer<int> echoContainer = await api
          .callFlutterEchoGenericInt(sentContainer);
      expect(echoContainer.value, sentContainer.value);
      expect(echoContainer.values, sentContainer.values);
    });

    testWidgets(
      'generic string containers serialize and deserialize correctly',
      (
        WidgetTester _,
      ) async {
        final HostGenericApi api = HostGenericApi();

        const GenericContainer<String> sentContainer = GenericContainer<String>(
          value: 'test',
          values: <String>['a', 'b', 'c'],
        );
        final GenericContainer<String> echoContainer = await api
            .callFlutterEchoGenericString(sentContainer);
        expect(echoContainer.value, sentContainer.value);
        expect(echoContainer.values, sentContainer.values);
      },
    );

    testWidgets('generic pairs serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      const GenericPair<String, int> sentPair = GenericPair<String, int>(
        first: 'hello',
        second: 42,
        map: <String, int>{'key1': 1, 'key2': 2},
      );
      final GenericPair<String, int> echoPair = await api
          .callFlutterEchoGenericPairStringInt(sentPair);
      expect(echoPair.first, sentPair.first);
      expect(echoPair.second, sentPair.second);
      expect(echoPair.map, sentPair.map);
    });

    testWidgets('generic defaults serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      final GenericDefaults sentDefaults = GenericDefaults();
      final GenericDefaults echoDefaults = await api
          .callFlutterEchoGenericDefaults(sentDefaults);
      expect(echoDefaults.genericInt.value, sentDefaults.genericInt.value);
      expect(echoDefaults.genericInt.values, sentDefaults.genericInt.values);
      expect(
        echoDefaults.genericString.value,
        sentDefaults.genericString.value,
      );
      expect(
        echoDefaults.genericString.values,
        sentDefaults.genericString.values,
      );
    });

    testWidgets('generic defaults int extraction works correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      final GenericDefaults sentDefaults = GenericDefaults();
      final GenericContainer<int> echoContainer = await api
          .callFlutterEchoGenericDefaultsInt(sentDefaults);
      expect(echoContainer.value, sentDefaults.genericInt.value);
      expect(echoContainer.values, sentDefaults.genericInt.values);
    });

    testWidgets('nested generics serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      final GenericDefaults sentDefaults = GenericDefaults();
      final NestedGeneric<String, int, double> echoNested = await api
          .callFlutterEchoGenericDefaultsNested(sentDefaults);
      expect(
        echoNested.container.value,
        sentDefaults.nestedGenericDefault.container.value,
      );
      expect(
        echoNested.container.values,
        sentDefaults.nestedGenericDefault.container.values,
      );
      expect(
        echoNested.pairs.length,
        sentDefaults.nestedGenericDefault.pairs.length,
      );
    });

    testWidgets('generic pair either extraction works correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      final GenericDefaults sentDefaults = GenericDefaults();
      final GenericPair<int, Either<String, int>> echoPair = await api
          .callFlutterEchoGenericDefaultsPairEither(sentDefaults);
      expect(echoPair.first, sentDefaults.genericPairEither.first);
      expect(echoPair.second, sentDefaults.genericPairEither.second);
    });

    testWidgets('typed nullables serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      final GenericsAllNullableTypesTyped<String, int, double> sentTyped =
          GenericsAllNullableTypesTyped<String, int, double>(
            aNullableString: 'test',
            aNullableInt: 42,
            aNullableDouble: 3.14,
          );
      final GenericsAllNullableTypesTyped<String, int, double> echoTyped =
          await api.callFlutterEchoTypedNullableStringIntDouble(sentTyped);
      expect(echoTyped.aNullableString, sentTyped.aNullableString);
      expect(echoTyped.aNullableInt, sentTyped.aNullableInt);
      expect(echoTyped.aNullableDouble, sentTyped.aNullableDouble);
    });

    testWidgets('typed nullables with different type params work correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      final GenericsAllNullableTypesTyped<int, String, bool> sentTyped =
          GenericsAllNullableTypesTyped<int, String, bool>(
            aNullableString: 'typed-test',
            aNullableInt: 99,
            aNullableDouble: 2.71,
          );
      final GenericsAllNullableTypesTyped<int, String, bool> echoTyped =
          await api.callFlutterEchoTypedNullableIntStringBool(sentTyped);
      expect(echoTyped.aNullableString, sentTyped.aNullableString);
      expect(echoTyped.aNullableInt, sentTyped.aNullableInt);
      expect(echoTyped.aNullableDouble, sentTyped.aNullableDouble);
    });

    testWidgets('nested generics with specific types work correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      const NestedGeneric<String, int, double> sentNested =
          NestedGeneric<String, int, double>(
            container: GenericContainer<String>(
              value: 'nested',
              values: <String>['x', 'y', 'z'],
            ),
            pairs: <GenericPair<int, double>>[
              GenericPair<int, double>(
                first: 1,
                second: 1.1,
                map: <int, double>{1: 1.1, 2: 2.2},
              ),
            ],
            nestedMap: <String, GenericContainer<int>>{
              'key': GenericContainer<int>(value: 99, values: <int>[9, 8, 7]),
            },
            listOfMaps: <Map<int, double>>[
              <int, double>{1: 1.0, 2: 2.0},
            ],
          );
      final NestedGeneric<String, int, double> echoNested = await api
          .callFlutterEchoNestedGenericStringIntDouble(sentNested);
      expect(echoNested.container.value, sentNested.container.value);
      expect(echoNested.pairs.length, sentNested.pairs.length);
      expect(echoNested.nestedMap.keys, sentNested.nestedMap.keys);
    });

    testWidgets('generic container typed nullable works correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      final GenericContainer<GenericsAllNullableTypesTyped<String, int, double>>
      sentContainer =
          GenericContainer<GenericsAllNullableTypesTyped<String, int, double>>(
            value: GenericsAllNullableTypesTyped<String, int, double>(
              aNullableString: 'container',
              aNullableInt: 100,
              aNullableDouble: 2.71,
            ),
            values: <GenericsAllNullableTypesTyped<String, int, double>>[],
          );
      final GenericContainer<GenericsAllNullableTypesTyped<String, int, double>>
      echoContainer = await api.callFlutterEchoGenericContainerTypedNullable(
        sentContainer,
      );
      expect(
        echoContainer.value?.aNullableString,
        sentContainer.value?.aNullableString,
      );
      expect(
        echoContainer.value?.aNullableInt,
        sentContainer.value?.aNullableInt,
      );
      expect(echoContainer.values.length, sentContainer.values.length);
    });

    testWidgets('list of generic containers works correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      const List<GenericContainer<int>> sentList = <GenericContainer<int>>[
        GenericContainer<int>(value: 1, values: <int>[1, 2]),
        GenericContainer<int>(value: 2, values: <int>[3, 4]),
      ];
      final List<GenericContainer<int>> echoList = await api
          .callFlutterEchoListGenericContainer(sentList);
      expect(echoList.length, sentList.length);
      expect(echoList[0].value, sentList[0].value);
      expect(echoList[1].values, sentList[1].values);
    });

    testWidgets('list of typed nullables works correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      final List<GenericsAllNullableTypesTyped<String, int, double>> sentList =
          <GenericsAllNullableTypesTyped<String, int, double>>[
            GenericsAllNullableTypesTyped<String, int, double>(
              aNullableString: 'first',
              aNullableInt: 1,
              aNullableDouble: 1.0,
            ),
            GenericsAllNullableTypesTyped<String, int, double>(
              aNullableString: 'second',
              aNullableInt: 2,
              aNullableDouble: 2.0,
            ),
          ];
      final List<GenericsAllNullableTypesTyped<String, int, double>> echoList =
          await api.callFlutterEchoListTypedNullable(sentList);
      expect(echoList.length, sentList.length);
      expect(echoList[0].aNullableString, sentList[0].aNullableString);
      expect(echoList[1].aNullableInt, sentList[1].aNullableInt);
    });

    testWidgets('map of generic containers works correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      const Map<String, GenericContainer<int>> sentMap =
          <String, GenericContainer<int>>{
            'key1': GenericContainer<int>(value: 1, values: <int>[1, 2]),
            'key2': GenericContainer<int>(value: 2, values: <int>[3, 4]),
          };
      final Map<String, GenericContainer<int>> echoMap = await api
          .callFlutterEchoMapGenericContainer(sentMap);
      expect(echoMap.length, sentMap.length);
      expect(echoMap['key1']?.value, sentMap['key1']?.value);
      expect(echoMap['key2']?.values, sentMap['key2']?.values);
    });

    testWidgets('map of typed nullables works correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      final Map<String, GenericsAllNullableTypesTyped<int, String, double>>
      sentMap = <String, GenericsAllNullableTypesTyped<int, String, double>>{
        'key1': GenericsAllNullableTypesTyped<int, String, double>(
          aNullableString: 'first-value',
          aNullableInt: 1,
          aNullableDouble: 1.0,
        ),
        'key2': GenericsAllNullableTypesTyped<int, String, double>(
          aNullableString: 'second-value',
          aNullableInt: 2,
          aNullableDouble: 2.0,
        ),
      };
      final Map<String, GenericsAllNullableTypesTyped<int, String, double>>
      echoMap = await api.callFlutterEchoMapTypedNullable(sentMap);
      expect(echoMap.length, sentMap.length);
      expect(
        echoMap['key1']?.aNullableString,
        sentMap['key1']?.aNullableString,
      );
      expect(echoMap['key2']?.aNullableInt, sentMap['key2']?.aNullableInt);
    });

    testWidgets('return generic defaults either left works correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      final GenericContainer<Either<String, int>> result =
          await api.callFlutterReturnGenericDefaultsEitherLeft();
      expect(result.value, isA<Left<String, int>>());
      expect((result.value as Left<String, int>).value, 'default-left');
      expect(result.values.length, 2);
    });

    testWidgets('return generic defaults either right works correctly', (
      WidgetTester _,
    ) async {
      final HostGenericApi api = HostGenericApi();

      final GenericContainer<Either<String, int>> result =
          await api.callFlutterReturnGenericDefaultsEitherRight();
      expect(result.value, isA<Right<String, int>>());
      expect((result.value as Right<String, int>).value, 2);
      expect(result.values.length, 2);
    });
  });
}

class _FlutterApiTestImplementation implements FlutterIntegrationCoreApi {
  @override
  AllTypes echoAllTypes(AllTypes everything) {
    return everything;
  }

  @override
  AllNullableTypes? echoAllNullableTypes(AllNullableTypes? everything) {
    return everything;
  }

  @override
  AllNullableTypesWithoutRecursion? echoAllNullableTypesWithoutRecursion(
    AllNullableTypesWithoutRecursion? everything,
  ) {
    return everything;
  }

  @override
  void noop() {}

  @override
  Object? throwError() {
    throw FlutterError('this is an error');
  }

  @override
  void throwErrorFromVoid() {
    throw FlutterError('this is an error');
  }

  @override
  AllNullableTypes sendMultipleNullableTypes(
    bool? aNullableBool,
    int? aNullableInt,
    String? aNullableString,
  ) {
    return AllNullableTypes(
      aNullableBool: aNullableBool,
      aNullableInt: aNullableInt,
      aNullableString: aNullableString,
    );
  }

  @override
  AllNullableTypesWithoutRecursion sendMultipleNullableTypesWithoutRecursion(
    bool? aNullableBool,
    int? aNullableInt,
    String? aNullableString,
  ) {
    return AllNullableTypesWithoutRecursion(
      aNullableBool: aNullableBool,
      aNullableInt: aNullableInt,
      aNullableString: aNullableString,
    );
  }

  @override
  bool echoBool(bool aBool) => aBool;

  @override
  double echoDouble(double aDouble) => aDouble;

  @override
  int echoInt(int anInt) => anInt;

  @override
  String echoString(String aString) => aString;

  @override
  Uint8List echoUint8List(Uint8List list) => list;

  @override
  List<Object?> echoList(List<Object?> list) => list;

  @override
  List<AnEnum?> echoEnumList(List<AnEnum?> enumList) => enumList;

  @override
  List<AllNullableTypes?> echoClassList(List<AllNullableTypes?> classList) {
    return classList;
  }

  @override
  List<AnEnum> echoNonNullEnumList(List<AnEnum> enumList) => enumList;

  @override
  List<AllNullableTypes> echoNonNullClassList(
    List<AllNullableTypes> classList,
  ) {
    return classList;
  }

  @override
  Map<Object?, Object?> echoMap(Map<Object?, Object?> map) => map;

  @override
  Map<String?, String?> echoStringMap(Map<String?, String?> stringMap) =>
      stringMap;

  @override
  Map<int?, int?> echoIntMap(Map<int?, int?> intMap) => intMap;

  @override
  Map<AnEnum?, AnEnum?> echoEnumMap(Map<AnEnum?, AnEnum?> enumMap) => enumMap;

  @override
  Map<int?, AllNullableTypes?> echoClassMap(
    Map<int?, AllNullableTypes?> classMap,
  ) {
    return classMap;
  }

  @override
  Map<String, String> echoNonNullStringMap(Map<String, String> stringMap) =>
      stringMap;

  @override
  Map<int, int> echoNonNullIntMap(Map<int, int> intMap) => intMap;

  @override
  Map<AnEnum, AnEnum> echoNonNullEnumMap(Map<AnEnum, AnEnum> enumMap) =>
      enumMap;

  @override
  Map<int, AllNullableTypes> echoNonNullClassMap(
    Map<int, AllNullableTypes> classMap,
  ) {
    return classMap;
  }

  @override
  AnEnum echoEnum(AnEnum anEnum) => anEnum;

  @override
  AnotherEnum echoAnotherEnum(AnotherEnum anotherEnum) => anotherEnum;

  @override
  bool? echoNullableBool(bool? aBool) => aBool;

  @override
  double? echoNullableDouble(double? aDouble) => aDouble;

  @override
  int? echoNullableInt(int? anInt) => anInt;

  @override
  List<Object?>? echoNullableList(List<Object?>? list) => list;

  @override
  List<AnEnum?>? echoNullableEnumList(List<AnEnum?>? enumList) => enumList;

  @override
  List<AllNullableTypes?>? echoNullableClassList(
    List<AllNullableTypes?>? classList,
  ) {
    return classList;
  }

  @override
  List<AnEnum>? echoNullableNonNullEnumList(List<AnEnum>? enumList) {
    return enumList;
  }

  @override
  List<AllNullableTypes>? echoNullableNonNullClassList(
    List<AllNullableTypes>? classList,
  ) {
    return classList;
  }

  @override
  Map<Object?, Object?>? echoNullableMap(Map<Object?, Object?>? map) => map;

  @override
  Map<String?, String?>? echoNullableStringMap(
    Map<String?, String?>? stringMap,
  ) {
    return stringMap;
  }

  @override
  Map<int?, int?>? echoNullableIntMap(Map<int?, int?>? intMap) => intMap;

  @override
  Map<AnEnum?, AnEnum?>? echoNullableEnumMap(Map<AnEnum?, AnEnum?>? enumMap) {
    return enumMap;
  }

  @override
  Map<int?, AllNullableTypes?>? echoNullableClassMap(
    Map<int?, AllNullableTypes?>? classMap,
  ) {
    return classMap;
  }

  @override
  Map<String, String>? echoNullableNonNullStringMap(
    Map<String, String>? stringMap,
  ) {
    return stringMap;
  }

  @override
  Map<int, int>? echoNullableNonNullIntMap(Map<int, int>? intMap) {
    return intMap;
  }

  @override
  Map<AnEnum, AnEnum>? echoNullableNonNullEnumMap(
    Map<AnEnum, AnEnum>? enumMap,
  ) {
    return enumMap;
  }

  @override
  Map<int, AllNullableTypes>? echoNullableNonNullClassMap(
    Map<int, AllNullableTypes>? classMap,
  ) {
    return classMap;
  }

  @override
  String? echoNullableString(String? aString) => aString;

  @override
  Uint8List? echoNullableUint8List(Uint8List? list) => list;

  @override
  AnEnum? echoNullableEnum(AnEnum? anEnum) => anEnum;

  @override
  AnotherEnum? echoAnotherNullableEnum(AnotherEnum? anotherEnum) => anotherEnum;

  @override
  Future<void> noopAsync() async {}

  @override
  Future<String> echoAsyncString(String aString) async {
    return aString;
  }
}

class _SmallFlutterApi implements FlutterSmallApi {
  @override
  String echoString(String aString) {
    return aString;
  }

  @override
  TestMessage echoWrappedList(TestMessage msg) {
    return msg;
  }
}

ProxyApiTestClass _createGenericProxyApiTestClass({
  void Function(ProxyApiTestClass instance)? flutterNoop,
  Object? Function(ProxyApiTestClass instance)? flutterThrowError,
  void Function(ProxyApiTestClass instance)? flutterThrowErrorFromVoid,
  bool Function(ProxyApiTestClass instance, bool aBool)? flutterEchoBool,
  int Function(ProxyApiTestClass instance, int anInt)? flutterEchoInt,
  double Function(ProxyApiTestClass instance, double aDouble)?
  flutterEchoDouble,
  String Function(ProxyApiTestClass instance, String aString)?
  flutterEchoString,
  Uint8List Function(ProxyApiTestClass instance, Uint8List aList)?
  flutterEchoUint8List,
  List<Object?> Function(ProxyApiTestClass instance, List<Object?> aList)?
  flutterEchoList,
  List<ProxyApiTestClass?> Function(
    ProxyApiTestClass instance,
    List<ProxyApiTestClass?> aList,
  )?
  flutterEchoProxyApiList,
  Map<String?, Object?> Function(
    ProxyApiTestClass instance,
    Map<String?, Object?> aMap,
  )?
  flutterEchoMap,
  Map<String?, ProxyApiTestClass?> Function(
    ProxyApiTestClass instance,
    Map<String?, ProxyApiTestClass?> aMap,
  )?
  flutterEchoProxyApiMap,
  ProxyApiTestEnum Function(
    ProxyApiTestClass instance,
    ProxyApiTestEnum anEnum,
  )?
  flutterEchoEnum,
  ProxyApiSuperClass Function(
    ProxyApiTestClass instance,
    ProxyApiSuperClass aProxyApi,
  )?
  flutterEchoProxyApi,
  bool? Function(ProxyApiTestClass instance, bool? aBool)?
  flutterEchoNullableBool,
  int? Function(ProxyApiTestClass instance, int? anInt)? flutterEchoNullableInt,
  double? Function(ProxyApiTestClass instance, double? aDouble)?
  flutterEchoNullableDouble,
  String? Function(ProxyApiTestClass instance, String? aString)?
  flutterEchoNullableString,
  Uint8List? Function(ProxyApiTestClass instance, Uint8List? aList)?
  flutterEchoNullableUint8List,
  List<Object?>? Function(ProxyApiTestClass instance, List<Object?>? aList)?
  flutterEchoNullableList,
  Map<String?, Object?>? Function(
    ProxyApiTestClass instance,
    Map<String?, Object?>? aMap,
  )?
  flutterEchoNullableMap,
  ProxyApiTestEnum? Function(
    ProxyApiTestClass instance,
    ProxyApiTestEnum? anEnum,
  )?
  flutterEchoNullableEnum,
  ProxyApiSuperClass? Function(
    ProxyApiTestClass instance,
    ProxyApiSuperClass? aProxyApi,
  )?
  flutterEchoNullableProxyApi,
  Future<void> Function(ProxyApiTestClass instance)? flutterNoopAsync,
  Future<String> Function(ProxyApiTestClass instance, String aString)?
  flutterEchoAsyncString,
}) {
  return ProxyApiTestClass(
    aBool: true,
    anInt: 0,
    aDouble: 0.0,
    aString: '',
    aUint8List: Uint8List(0),
    aList: const <Object?>[],
    aMap: const <String?, Object?>{},
    anEnum: ProxyApiTestEnum.one,
    aProxyApi: ProxyApiSuperClass(),
    boolParam: true,
    intParam: 0,
    doubleParam: 0.0,
    stringParam: '',
    aUint8ListParam: Uint8List(0),
    listParam: const <Object?>[],
    mapParam: const <String?, Object?>{},
    enumParam: ProxyApiTestEnum.one,
    proxyApiParam: ProxyApiSuperClass(),
    flutterNoop: flutterNoop,
    flutterThrowError: flutterThrowError,
    flutterThrowErrorFromVoid: flutterThrowErrorFromVoid,
    flutterEchoBool:
        flutterEchoBool ?? (ProxyApiTestClass instance, bool aBool) => true,
    flutterEchoInt: flutterEchoInt ?? (_, __) => 3,
    flutterEchoDouble: flutterEchoDouble ?? (_, __) => 1.0,
    flutterEchoString: flutterEchoString ?? (_, __) => '',
    flutterEchoUint8List: flutterEchoUint8List ?? (_, __) => Uint8List(0),
    flutterEchoList: flutterEchoList ?? (_, __) => <Object?>[],
    flutterEchoProxyApiList:
        flutterEchoProxyApiList ?? (_, __) => <ProxyApiTestClass?>[],
    flutterEchoMap: flutterEchoMap ?? (_, __) => <String?, Object?>{},
    flutterEchoEnum: flutterEchoEnum ?? (_, __) => ProxyApiTestEnum.one,
    flutterEchoProxyApi: flutterEchoProxyApi ?? (_, __) => ProxyApiSuperClass(),
    flutterEchoNullableBool: flutterEchoNullableBool,
    flutterEchoNullableInt: flutterEchoNullableInt,
    flutterEchoNullableDouble: flutterEchoNullableDouble,
    flutterEchoNullableString: flutterEchoNullableString,
    flutterEchoNullableUint8List: flutterEchoNullableUint8List,
    flutterEchoNullableList: flutterEchoNullableList,
    flutterEchoNullableMap: flutterEchoNullableMap,
    flutterEchoNullableEnum: flutterEchoNullableEnum,
    flutterEchoNullableProxyApi: flutterEchoNullableProxyApi,
    flutterNoopAsync: flutterNoopAsync,
    flutterEchoAsyncString: flutterEchoAsyncString ?? (_, __) async => '',
    flutterEchoProxyApiMap:
        flutterEchoProxyApiMap ?? (_, __) => <String?, ProxyApiTestClass?>{},
  );
}

class _FlutterGenericApiTestImplementation implements FlutterGenericApi {
  @override
  GenericContainer<GenericsAllNullableTypesTyped<String, int, double>>
  echoGenericContainerTypedNullable(
    GenericContainer<GenericsAllNullableTypesTyped<String, int, double>>
    container,
  ) {
    return container;
  }

  @override
  GenericDefaults echoGenericDefaults(GenericDefaults defaults) {
    print('jopa: CALLED!');

    return defaults;
  }

  @override
  GenericContainer<int> echoGenericDefaultsInt(GenericDefaults defaults) {
    return defaults.genericInt;
  }

  @override
  NestedGeneric<String, int, double> echoGenericDefaultsNested(
    GenericDefaults defaults,
  ) {
    return defaults.nestedGenericDefault;
  }

  @override
  GenericPair<int, Either<String, int>> echoGenericDefaultsPairEither(
    GenericDefaults defaults,
  ) {
    return defaults.genericPairEither;
  }

  @override
  GenericContainer<int> echoGenericInt(GenericContainer<int> container) {
    return container;
  }

  @override
  GenericPair<String, int> echoGenericPairStringInt(
    GenericPair<String, int> pair,
  ) {
    return pair;
  }

  @override
  GenericContainer<String> echoGenericString(
    GenericContainer<String> container,
  ) {
    return container;
  }

  @override
  List<GenericContainer<int>> echoListGenericContainer(
    List<GenericContainer<int>> list,
  ) {
    return list;
  }

  @override
  List<GenericsAllNullableTypesTyped<String, int, double>>
  echoListTypedNullable(
    List<GenericsAllNullableTypesTyped<String, int, double>> list,
  ) {
    return list;
  }

  @override
  Map<String, GenericContainer<int>> echoMapGenericContainer(
    Map<String, GenericContainer<int>> map,
  ) {
    return map;
  }

  @override
  Map<String, GenericsAllNullableTypesTyped<int, String, double>>
  echoMapTypedNullable(
    Map<String, GenericsAllNullableTypesTyped<int, String, double>> map,
  ) {
    return map;
  }

  @override
  NestedGeneric<String, int, double> echoNestedGenericStringIntDouble(
    NestedGeneric<String, int, double> nested,
  ) {
    return nested;
  }

  @override
  GenericsAllNullableTypesTyped<int, String, bool>
  echoTypedNullableIntStringBool(
    GenericsAllNullableTypesTyped<int, String, bool> typed,
  ) {
    return typed;
  }

  @override
  GenericsAllNullableTypesTyped<String, int, double>
  echoTypedNullableStringIntDouble(
    GenericsAllNullableTypesTyped<String, int, double> typed,
  ) {
    return typed;
  }

  @override
  GenericContainer<Either<String, int>> returnGenericDefaultsEitherLeft() {
    return const GenericContainer<Either<String, int>>(
      value: Left<String, int>(value: 'default-left'),
      values: <Either<String, int>>[
        Left<String, int>(value: 'left1'),
        Right<String, int>(value: 2),
      ],
    );
  }

  @override
  GenericContainer<Either<String, int>> returnGenericDefaultsEitherRight() {
    return const GenericContainer<Either<String, int>>(
      value: Right<String, int>(value: 2),
      values: <Either<String, int>>[
        Left<String, int>(value: 'left1'),
        Right<String, int>(value: 2),
      ],
    );
  }
}
