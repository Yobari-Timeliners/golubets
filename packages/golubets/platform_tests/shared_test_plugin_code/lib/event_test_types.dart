import 'generated.dart';
import 'test_types.dart';

// ignore_for_file: public_member_api_docs

final Map<int, EventAllNullableTypes?> eventAllNullableTypesMap =
    <int, EventAllNullableTypes?>{
      0: genericEventAllNullableTypesWithoutRecursion,
      1: EventAllNullableTypes(),
      2: null,
    };

final Map<EventEnum?, EventEnum?> eventEnumMap = <EventEnum, EventEnum>{
  EventEnum.one: EventEnum.one,
  EventEnum.two: EventEnum.two,
  EventEnum.three: EventEnum.three,
  EventEnum.fortyTwo: EventEnum.fortyTwo,
};

final List<EventEnum?> eventEnumList = <EventEnum>[
  EventEnum.one,
  EventEnum.two,
  EventEnum.three,
  EventEnum.fortyTwo,
];

final List<List<Object?>?> eventListList = <List<Object?>?>[
  list,
  stringList,
  intList,
  doubleList,
  boolList,
  eventEnumList,
  null,
];

final List<Map<Object?, Object?>?> eventMapList = <Map<Object?, Object?>?>[
  map,
  stringMap,
  doubleMap,
  intMap,
  boolMap,
  eventEnumMap,
  null,
];

final Map<int?, List<Object?>?> eventListMap = <int?, List<Object?>?>{
  0: list,
  1: stringList,
  2: doubleList,
  4: intList,
  5: boolList,
  6: eventEnumList,
  7: null,
};

final Map<int?, Map<Object?, Object?>?> eventMapMap =
    <int?, Map<Object?, Object?>?>{
      0: map,
      1: stringMap,
      2: doubleMap,
      4: intMap,
      5: boolMap,
      6: eventEnumMap,
      7: null,
    };

final EventAllNullableTypes genericEventAllNullableTypesWithoutRecursion =
    EventAllNullableTypes(
      aNullableBool: true,
      aNullableInt: regularInt,
      aNullableInt64: biggerThanBigInt,
      aNullableDouble: doublePi,
      aNullableByteArray: genericAllNullableTypes.aNullableByteArray,
      aNullable4ByteArray: genericAllNullableTypes.aNullable4ByteArray,
      aNullable8ByteArray: genericAllNullableTypes.aNullable8ByteArray,
      aNullableFloatArray: genericAllNullableTypes.aNullableFloatArray,
      aNullableEnum: EventEnum.fortyTwo,
      anotherNullableEnum: AnotherEventEnum.justInCase,
      aNullableString: genericAllNullableTypes.aNullableString,
      aNullableObject: genericAllNullableTypes.aNullableObject,
      list: list,
      stringList: stringList,
      intList: intList,
      doubleList: doubleList,
      boolList: boolList,
      enumList: eventEnumList,
      objectList: list,
      listList: eventListList,
      mapList: eventMapList,
      map: map,
      stringMap: stringMap,
      intMap: intMap,
      enumMap: eventEnumMap,
      objectMap: map,
      listMap: eventListMap,
      mapMap: eventMapMap,
    );
