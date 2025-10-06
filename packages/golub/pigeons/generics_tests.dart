import 'package:pigeon/pigeon.dart';

/// A simple generic container class.
class GenericContainer<T> {
  const GenericContainer({
    required this.value,
    required this.values,
  });

  final T? value;
  final List<T> values;
}

/// A generic class with two type parameters.
class GenericPair<T, K> {
  const GenericPair({
    required this.first,
    required this.second,
    required this.map,
  });

  final T first;
  final K? second;
  final Map<T, K> map;
}

/// A complex nested generic class.
class NestedGeneric<T, K, V> {
  const NestedGeneric({
    required this.container,
    required this.pairs,
    required this.nestedMap,
    required this.listOfMaps,
  });

  final GenericContainer<T> container;
  final List<GenericPair<K, V>> pairs;
  final Map<T, GenericContainer<K>> nestedMap;

  // https://github.com/Yobari-Timeliners/golub/issues/102
  final List<Map<Object?, Object?>> listOfMaps;
}

enum GenericsAnEnum { one, two, three, fortyTwo, fourHundredTwentyTwo }

// Enums require special logic, having multiple ensures that the logic can be
// replicated without collision.
enum GenericsAnotherEnum { justInCase }

/// A class containing all supported types.
class GenericsAllTypes {
  GenericsAllTypes({
    this.aBool = false,
    this.anInt = 0,
    this.anInt64 = 0,
    this.aDouble = 0,
    required this.aByteArray,
    required this.a4ByteArray,
    required this.a8ByteArray,
    required this.aFloatArray,
    this.anEnum = GenericsAnEnum.one,
    this.anotherEnum = GenericsAnotherEnum.justInCase,
    this.aString = '',
    this.anObject = 0,

    // Lists
    // This name is in a different format than the others to ensure that name
    // collision with the word 'list' doesn't occur in the generated files.
    required this.list,
    required this.stringList,
    required this.intList,
    required this.doubleList,
    required this.boolList,
    required this.enumList,
    required this.objectList,
    required this.listList,
    required this.mapList,

    // Maps
    required this.map,
    required this.stringMap,
    required this.intMap,
    required this.enumMap,
    required this.objectMap,
    required this.listMap,
    required this.mapMap,
  });

  bool aBool;
  int anInt;
  int anInt64;
  double aDouble;
  Uint8List aByteArray;
  Int32List a4ByteArray;
  Int64List a8ByteArray;
  Float64List aFloatArray;
  GenericsAnEnum anEnum;
  GenericsAnotherEnum anotherEnum;
  String aString;
  Object anObject;

  // Lists
  // ignore: strict_raw_type, always_specify_types
  List list;
  List<String> stringList;
  List<int> intList;
  List<double> doubleList;
  List<bool> boolList;
  List<GenericsAnEnum> enumList;
  List<Object> objectList;
  List<List<Object?>> listList;
  List<Map<Object?, Object?>> mapList;

  // Maps
  // ignore: strict_raw_type, always_specify_types
  Map map;
  Map<String, String> stringMap;
  Map<int, int> intMap;
  Map<GenericsAnEnum, GenericsAnEnum> enumMap;
  Map<Object, Object> objectMap;
  Map<int, List<Object?>> listMap;
  Map<int, Map<Object?, Object?>> mapMap;
}

/// A class containing all supported nullable types.
@SwiftClass()
class GenericsAllNullableTypes {
  GenericsAllNullableTypes(
    this.aNullableBool,
    this.aNullableInt,
    this.aNullableInt64,
    this.aNullableDouble,
    this.aNullableByteArray,
    this.aNullable4ByteArray,
    this.aNullable8ByteArray,
    this.aNullableFloatArray,
    this.aNullableEnum,
    this.anotherNullableEnum,
    this.aNullableString,
    this.aNullableObject,
    this.allNullableTypes,

    // Lists
    // This name is in a different format than the others to ensure that name
    // collision with the word 'list' doesn't occur in the generated files.
    this.list,
    this.stringList,
    this.intList,
    this.doubleList,
    this.boolList,
    this.enumList,
    this.objectList,
    this.listList,
    this.mapList,
    this.recursiveClassList,

    // Maps
    this.map,
    this.stringMap,
    this.intMap,
    this.enumMap,
    this.objectMap,
    this.listMap,
    this.mapMap,
    this.recursiveClassMap,
  );

  bool? aNullableBool;
  int? aNullableInt;
  int? aNullableInt64;
  double? aNullableDouble;
  Uint8List? aNullableByteArray;
  Int32List? aNullable4ByteArray;
  Int64List? aNullable8ByteArray;
  Float64List? aNullableFloatArray;
  GenericsAnEnum? aNullableEnum;
  GenericsAnotherEnum? anotherNullableEnum;
  String? aNullableString;
  Object? aNullableObject;
  GenericsAllNullableTypes? allNullableTypes;

  // Lists
  // ignore: strict_raw_type, always_specify_types
  List? list;
  List<String?>? stringList;
  List<int?>? intList;
  List<double?>? doubleList;
  List<bool?>? boolList;
  List<GenericsAnEnum?>? enumList;
  List<Object?>? objectList;
  List<List<Object?>?>? listList;
  List<Map<Object?, Object?>?>? mapList;
  List<GenericsAllNullableTypes?>? recursiveClassList;

  // Maps
  // ignore: strict_raw_type, always_specify_types
  Map? map;
  Map<String?, String?>? stringMap;
  Map<int?, int?>? intMap;
  Map<GenericsAnEnum?, GenericsAnEnum?>? enumMap;
  Map<Object?, Object?>? objectMap;
  Map<int?, List<Object?>?>? listMap;
  Map<int?, Map<Object?, Object?>?>? mapMap;
  Map<int?, GenericsAllNullableTypes?>? recursiveClassMap;
}

/// A class containing all supported nullable types.
@SwiftClass()
class GenericsAllNullableTypesTyped<T, K, V> {
  GenericsAllNullableTypesTyped(
    this.aNullableBool,
    this.aNullableInt,
    this.aNullableInt64,
    this.aNullableDouble,
    this.aNullableByteArray,
    this.aNullable4ByteArray,
    this.aNullable8ByteArray,
    this.aNullableFloatArray,
    this.aNullableEnum,
    this.anotherNullableEnum,
    this.aNullableString,
    this.aNullableObject,
    this.allNullableTypes,

    // Lists
    // This name is in a different format than the others to ensure that name
    // collision with the word 'list' doesn't occur in the generated files.
    this.list,
    this.stringList,
    this.intList,
    this.doubleList,
    this.boolList,
    this.enumList,
    this.objectList,
    this.listList,
    this.mapList,
    this.recursiveClassList,

    // Maps
    this.map,
    this.stringMap,
    this.intMap,
    this.enumMap,
    this.objectMap,
    this.listMap,
    this.mapMap,
    this.recursiveClassMap,
  );

  bool? aNullableBool;
  int? aNullableInt;
  int? aNullableInt64;
  double? aNullableDouble;
  Uint8List? aNullableByteArray;
  Int32List? aNullable4ByteArray;
  Int64List? aNullable8ByteArray;
  Float64List? aNullableFloatArray;
  GenericsAnEnum? aNullableEnum;
  GenericsAnotherEnum? anotherNullableEnum;
  String? aNullableString;
  Object? aNullableObject;
  GenericsAllNullableTypes? allNullableTypes;

  // Lists
  // ignore: strict_raw_type, always_specify_types
  List? list;
  List<T?>? stringList;
  List<V?>? intList;
  List<K?>? doubleList;
  List<T?>? boolList;
  List<V?>? enumList;
  List<K?>? objectList;
  List<List<K?>?>? listList;
  List<Map<T?, V?>?>? mapList;
  List<GenericsAllNullableTypes?>? recursiveClassList;

  // Maps
  // ignore: strict_raw_type, always_specify_types
  Map? map;
  Map<T?, T?>? stringMap;
  Map<V?, K?>? intMap;
  Map<GenericsAnEnum?, GenericsAnEnum?>? enumMap;
  Map<Object?, Object?>? objectMap;
  Map<int?, List<K?>?>? listMap;
  Map<int?, Map<K?, K?>?>? mapMap;
  Map<int?, GenericsAllNullableTypes?>? recursiveClassMap;
}

sealed class Either<L, R> {
  const Either();
}

class Left<L, R> extends Either<L, R> {
  const Left({required this.value});
  final L value;
}

class Right<L, R> extends Either<L, R> {
  const Right({required this.value});
  final R value;
}

class GenericDefaults {
  GenericDefaults({
    this.genericInt = const GenericContainer<int>(
      value: 42,
      values: <int>[1, 2, 3],
    ),
    this.genericString = const GenericContainer<String>(
      value: 'default',
      values: <String>['a', 'b', 'c'],
    ),
    this.genericDouble = const GenericContainer<double>(
      value: 3.14,
      values: <double>[1.0, 2.0, 3.0],
    ),
    this.genericBool = const GenericContainer<bool>(
      value: true,
      values: <bool>[true, false, true],
    ),
    this.genericPairStringInt = const GenericPair<String, int>(
      first: 'default',
      second: 42,
      map: <String, int>{'key1': 1, 'key2': 2},
    ),
    this.genericPairIntString = const GenericPair<int, String>(
      first: 100,
      second: 'value',
      map: <int, String>{1: 'one', 2: 'two'},
    ),
    this.nestedGenericDefault = const NestedGeneric<String, int, double>(
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
        'nested': GenericContainer<int>(
          value: 99,
          values: <int>[9, 8, 7],
        ),
      },
      listOfMaps: <Map<int, double>>[
        <int, double>{10: 10.0, 20: 20.0},
      ],
    ),
    this.genericPairEither = const GenericPair<int, Either<String, int>>(
      first: 0,
      second: Right<String, int>(value: 2),
      map: <int, Either<String, int>>{
        3: Right<String, int>(value: 4),
        5: Left<String, int>(value: 'hello'),
      },
    ),
  });

  final GenericContainer<int> genericInt;
  final GenericContainer<String> genericString;
  final GenericContainer<double> genericDouble;
  final GenericContainer<bool> genericBool;
  final GenericPair<String, int> genericPairStringInt;
  final GenericPair<int, String> genericPairIntString;
  final NestedGeneric<String, int, double> nestedGenericDefault;
  final GenericPair<int, Either<String, int>> genericPairEither;
}

/// Generic API for testing various generic type combinations.
@HostApi()
abstract class HostGenericApi {
  // Simple generic echoing
  GenericContainer<int> echoGenericInt(GenericContainer<int> container);
  GenericContainer<String> echoGenericString(
    GenericContainer<String> container,
  );
  GenericContainer<double> echoGenericDouble(
    GenericContainer<double> container,
  );
  GenericContainer<bool> echoGenericBool(GenericContainer<bool> container);
  GenericContainer<GenericsAnEnum> echoGenericEnum(
    GenericContainer<GenericsAnEnum> container,
  );

  // Nullable generic types
  GenericContainer<int?> echoGenericNullableInt(
    GenericContainer<int?> container,
  );
  GenericContainer<String?> echoGenericNullableString(
    GenericContainer<String?> container,
  );

  // Generic pairs with different type combinations
  GenericPair<String, int> echoGenericPairStringInt(
    GenericPair<String, int> pair,
  );
  GenericPair<int, String> echoGenericPairIntString(
    GenericPair<int, String> pair,
  );
  GenericPair<double, bool> echoGenericPairDoubleBool(
    GenericPair<double, bool> pair,
  );

  // Nested generics with classes
  GenericContainer<GenericsAllTypes> echoGenericContainerAllTypes(
    GenericContainer<GenericsAllTypes> container,
  );
  GenericPair<GenericsAllTypes, GenericsAllNullableTypes>
  echoGenericPairClasses(
    GenericPair<GenericsAllTypes, GenericsAllNullableTypes> pair,
  );

  // Complex nested generics
  NestedGeneric<String, int, double> echoNestedGenericStringIntDouble(
    NestedGeneric<String, int, double> nested,
  );
  NestedGeneric<GenericsAllTypes, String, int> echoNestedGenericWithClasses(
    NestedGeneric<GenericsAllTypes, String, int> nested,
  );

  // Lists of generic types
  List<GenericContainer<int>> echoListGenericContainer(
    List<GenericContainer<int>> list,
  );
  List<GenericPair<String, int>> echoListGenericPair(
    List<GenericPair<String, int>> list,
  );

  // Maps with generic values
  Map<String, GenericContainer<int>> echoMapGenericContainer(
    Map<String, GenericContainer<int>> map,
  );
  Map<int, GenericPair<String, double>> echoMapGenericPair(
    Map<int, GenericPair<String, double>> map,
  );

  // Async versions for additional testing
  @async
  GenericContainer<int> echoAsyncGenericInt(GenericContainer<int> container);
  @async
  NestedGeneric<String, int, double> echoAsyncNestedGeneric(
    NestedGeneric<String, int, double> nested,
  );

  Either<GenericContainer<int>, GenericContainer<String>>
  echoEitherGenericIntOrString(
    Either<GenericContainer<int>, GenericContainer<String>> input,
  );

  Either<GenericPair<String, int>, GenericPair<int, String>>
  echoEitherGenericPairStringIntOrIntString(
    Either<GenericPair<String, int>, GenericPair<int, String>> input,
  );

  Either<
    NestedGeneric<String, int, double>,
    NestedGeneric<GenericsAllTypes, String, int>
  >
  echoEitherNestedGenericStringIntDoubleOrClasses(
    Either<
      NestedGeneric<String, int, double>,
      NestedGeneric<GenericsAllTypes, String, int>
    >
    input,
  );

  // GenericsAllNullableTypesTyped echo methods with complex generic combinations
  GenericsAllNullableTypesTyped<String, int, double>
  echoTypedNullableStringIntDouble(
    GenericsAllNullableTypesTyped<String, int, double> typed,
  );

  GenericsAllNullableTypesTyped<int, String, bool>
  echoTypedNullableIntStringBool(
    GenericsAllNullableTypesTyped<int, String, bool> typed,
  );

  GenericsAllNullableTypesTyped<GenericsAnEnum, double, String>
  echoTypedNullableEnumDoubleString(
    GenericsAllNullableTypesTyped<GenericsAnEnum, double, String> typed,
  );

  // Container wrapping typed classes
  GenericContainer<GenericsAllNullableTypesTyped<String, int, double>>
  echoGenericContainerTypedNullable(
    GenericContainer<GenericsAllNullableTypesTyped<String, int, double>>
    container,
  );

  // Pair with typed classes
  GenericPair<
    GenericsAllNullableTypesTyped<String, int, double>,
    GenericsAllNullableTypesTyped<int, String, bool>
  >
  echoGenericPairTypedNullable(
    GenericPair<
      GenericsAllNullableTypesTyped<String, int, double>,
      GenericsAllNullableTypesTyped<int, String, bool>
    >
    pair,
  );

  // Lists of typed classes
  List<GenericsAllNullableTypesTyped<String, int, double>>
  echoListTypedNullable(
    List<GenericsAllNullableTypesTyped<String, int, double>> list,
  );

  // Maps with typed classes
  Map<String, GenericsAllNullableTypesTyped<int, String, double>>
  echoMapTypedNullable(
    Map<String, GenericsAllNullableTypesTyped<int, String, double>> map,
  );

  // Async versions for complex typed generics
  @async
  GenericsAllNullableTypesTyped<String, int, double>
  echoAsyncTypedNullableStringIntDouble(
    GenericsAllNullableTypesTyped<String, int, double> typed,
  );

  @async
  GenericContainer<GenericsAllNullableTypesTyped<String, int, double>>
  echoAsyncGenericContainerTypedNullable(
    GenericContainer<GenericsAllNullableTypesTyped<String, int, double>>
    container,
  );

  // GenericDefaults echo methods
  GenericDefaults echoGenericDefaults(GenericDefaults defaults);

  /// Return a GenericDefaults with all default values
  GenericDefaults returnGenericDefaults();

  // Async version for GenericDefaults
  @async
  GenericDefaults echoAsyncGenericDefaults(GenericDefaults defaults);

  @async
  GenericContainer<GenericsAllNullableTypesTyped<String, int, double>>
  callFlutterEchoGenericContainerTypedNullable(
    GenericContainer<GenericsAllNullableTypesTyped<String, int, double>>
    container,
  );
  @async
  GenericDefaults callFlutterEchoGenericDefaults(GenericDefaults defaults);

  @async
  GenericContainer<int> callFlutterEchoGenericDefaultsInt(
    GenericDefaults defaults,
  );

  @async
  NestedGeneric<String, int, double> callFlutterEchoGenericDefaultsNested(
    GenericDefaults defaults,
  );

  @async
  GenericPair<int, Either<String, int>>
  callFlutterEchoGenericDefaultsPairEither(
    GenericDefaults defaults,
  );

  @async
  GenericContainer<int> callFlutterEchoGenericInt(
    GenericContainer<int> container,
  );

  @async
  GenericPair<String, int> callFlutterEchoGenericPairStringInt(
    GenericPair<String, int> pair,
  );

  @async
  GenericContainer<String> callFlutterEchoGenericString(
    GenericContainer<String> container,
  );

  @async
  List<GenericContainer<int>> callFlutterEchoListGenericContainer(
    List<GenericContainer<int>> list,
  );

  @async
  List<GenericsAllNullableTypesTyped<String, int, double>>
  callFlutterEchoListTypedNullable(
    List<GenericsAllNullableTypesTyped<String, int, double>> list,
  );

  @async
  Map<String, GenericContainer<int>> callFlutterEchoMapGenericContainer(
    Map<String, GenericContainer<int>> map,
  );

  @async
  Map<String, GenericsAllNullableTypesTyped<int, String, double>>
  callFlutterEchoMapTypedNullable(
    Map<String, GenericsAllNullableTypesTyped<int, String, double>> map,
  );

  @async
  NestedGeneric<String, int, double>
  callFlutterEchoNestedGenericStringIntDouble(
    NestedGeneric<String, int, double> nested,
  );

  @async
  GenericsAllNullableTypesTyped<int, String, bool>
  callFlutterEchoTypedNullableIntStringBool(
    GenericsAllNullableTypesTyped<int, String, bool> typed,
  );

  @async
  GenericsAllNullableTypesTyped<String, int, double>
  callFlutterEchoTypedNullableStringIntDouble(
    GenericsAllNullableTypesTyped<String, int, double> typed,
  );

  @async
  GenericContainer<Either<String, int>>
  callFlutterReturnGenericDefaultsEitherLeft();

  @async
  GenericContainer<Either<String, int>>
  callFlutterReturnGenericDefaultsEitherRight();
}

/// Flutter API for testing generic types from Flutter to host.
@FlutterApi()
abstract class FlutterGenericApi {
  // Simple generic echoing
  GenericContainer<int> echoGenericInt(GenericContainer<int> container);
  GenericContainer<String> echoGenericString(
    GenericContainer<String> container,
  );

  // Generic pairs
  GenericPair<String, int> echoGenericPairStringInt(
    GenericPair<String, int> pair,
  );

  // Complex nested generics
  NestedGeneric<String, int, double> echoNestedGenericStringIntDouble(
    NestedGeneric<String, int, double> nested,
  );

  // Lists and maps
  List<GenericContainer<int>> echoListGenericContainer(
    List<GenericContainer<int>> list,
  );
  Map<String, GenericContainer<int>> echoMapGenericContainer(
    Map<String, GenericContainer<int>> map,
  );

  // GenericsAllNullableTypesTyped echo methods for Flutter API
  GenericsAllNullableTypesTyped<String, int, double>
  echoTypedNullableStringIntDouble(
    GenericsAllNullableTypesTyped<String, int, double> typed,
  );

  GenericsAllNullableTypesTyped<int, String, bool>
  echoTypedNullableIntStringBool(
    GenericsAllNullableTypesTyped<int, String, bool> typed,
  );

  // Container and pair with typed classes for Flutter API
  GenericContainer<GenericsAllNullableTypesTyped<String, int, double>>
  echoGenericContainerTypedNullable(
    GenericContainer<GenericsAllNullableTypesTyped<String, int, double>>
    container,
  );

  // Lists and maps with typed classes for Flutter API
  List<GenericsAllNullableTypesTyped<String, int, double>>
  echoListTypedNullable(
    List<GenericsAllNullableTypesTyped<String, int, double>> list,
  );

  Map<String, GenericsAllNullableTypesTyped<int, String, double>>
  echoMapTypedNullable(
    Map<String, GenericsAllNullableTypesTyped<int, String, double>> map,
  );

  // GenericDefaults echo methods for Flutter API
  GenericDefaults echoGenericDefaults(GenericDefaults defaults);

  // Individual field access methods for Flutter API
  GenericContainer<int> echoGenericDefaultsInt(GenericDefaults defaults);

  GenericPair<int, Either<String, int>> echoGenericDefaultsPairEither(
    GenericDefaults defaults,
  );

  NestedGeneric<String, int, double> echoGenericDefaultsNested(
    GenericDefaults defaults,
  );

  GenericContainer<Either<String, int>> returnGenericDefaultsEitherLeft();

  GenericContainer<Either<String, int>> returnGenericDefaultsEitherRight();
}
