// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

/// This plugin handles the native side of the integration tests in
/// example/integration_test/.
public class TestPlugin: NSObject, FlutterPlugin, HostIntegrationCoreApi, SealedClassApi {
  var flutterAPI: FlutterIntegrationCoreApi
  var flutterSmallApiOne: FlutterSmallApi
  var flutterSmallApiTwo: FlutterSmallApi
  var proxyApiRegistrar: ProxyApiTestsGolubProxyApiRegistrar?

  public static func register(with registrar: FlutterPluginRegistrar) {
    // Workaround for https://github.com/flutter/flutter/issues/118103.
    #if os(iOS)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif
    let plugin = TestPlugin(binaryMessenger: messenger)
    HostIntegrationCoreApiSetup.setUp(binaryMessenger: messenger, api: plugin)
    TestPluginWithSuffix.register(with: registrar, suffix: "suffixOne")
    TestPluginWithSuffix.register(with: registrar, suffix: "suffixTwo")
    SealedClassApiSetup.setUp(binaryMessenger: messenger, api: plugin)
    registrar.publish(plugin)
  }

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterAPI = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)
    flutterSmallApiOne = FlutterSmallApi(
      binaryMessenger: binaryMessenger, messageChannelSuffix: "suffixOne")
    flutterSmallApiTwo = FlutterSmallApi(
      binaryMessenger: binaryMessenger, messageChannelSuffix: "suffixTwo")

    StreamIntsStreamHandler.register(with: binaryMessenger, streamHandler: SendInts())
    StreamEventsStreamHandler.register(with: binaryMessenger, streamHandler: SendEvents())
    StreamConsistentNumbersStreamHandler.register(
      with: binaryMessenger, instanceName: "1",
      streamHandler: SendConsistentNumbers(numberToSend: 1))
    StreamConsistentNumbersStreamHandler.register(
      with: binaryMessenger, instanceName: "2",
      streamHandler: SendConsistentNumbers(numberToSend: 2))
    proxyApiRegistrar = ProxyApiTestsGolubProxyApiRegistrar(
      binaryMessenger: binaryMessenger, apiDelegate: ProxyApiDelegate())
    proxyApiRegistrar!.setUp()
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    proxyApiRegistrar!.tearDown()
    proxyApiRegistrar = nil
  }

  // MARK: HostIntegrationCoreApi implementation

  public func noop() {}

  public func echo(_ everything: AllTypes) -> AllTypes {
    return everything
  }

  public func echo(_ everything: AllNullableTypes?) -> AllNullableTypes? {
    return everything
  }

  public func echo(_ everything: AllNullableTypesWithoutRecursion?) throws
    -> AllNullableTypesWithoutRecursion?
  {
    return everything
  }

  public func echoModernAsyncAllTypes(_ everything: AllTypes) async -> AllTypes {
    return everything
  }

  public func echoModernAsyncAllTypesAndNotThrow(_ everything: AllTypes) async throws -> AllTypes {
    return everything
  }

  public func echoModernAsyncAllTypesAndThrow(_ everything: AllTypes) async throws -> AllTypes {
    throw GolubError(code: "code", message: "message", details: "details")
  }

  public func echoModernAsyncNullableAllNullableTypes(_ everything: AllNullableTypes?) async
    -> AllNullableTypes?
  {
    return everything
  }

  public func throwError() throws -> Any? {
    throw GolubError(code: "code", message: "message", details: "details")
  }

  public func throwErrorFromVoid() throws {
    throw GolubError(code: "code", message: "message", details: "details")
  }

  public func throwFlutterError() throws -> Any? {
    throw GolubError(code: "code", message: "message", details: "details")
  }

  public func echo(_ anInt: Int64) -> Int64 {
    return anInt
  }

  public func echo(_ aDouble: Double) -> Double {
    return aDouble
  }

  public func echo(_ aBool: Bool) -> Bool {
    return aBool
  }

  public func echo(_ aString: String) -> String {
    return aString
  }

  public func echo(_ aUint8List: FlutterStandardTypedData) -> FlutterStandardTypedData {
    return aUint8List
  }

  public func echo(_ anObject: Any) -> Any {
    return anObject
  }

  public func echo(_ list: [Any?]) throws -> [Any?] {
    return list
  }

  public func echo(enumList: [AnEnum?]) throws -> [AnEnum?] {
    return enumList
  }

  public func echo(classList: [AllNullableTypes?]) throws -> [AllNullableTypes?] {
    return classList
  }

  public func echoNonNull(enumList: [AnEnum]) throws -> [AnEnum] {
    return enumList
  }

  public func echoNonNull(classList: [AllNullableTypes]) throws -> [AllNullableTypes] {
    return classList
  }

  public func echo(_ map: [AnyHashable?: Any?]) throws -> [AnyHashable?: Any?] {
    return map
  }

  public func echo(stringMap: [String?: String?]) throws -> [String?: String?] {
    return stringMap
  }

  public func echo(intMap: [Int64?: Int64?]) throws -> [Int64?: Int64?] {
    return intMap
  }

  public func echo(enumMap: [AnEnum?: AnEnum?]) throws -> [AnEnum?: AnEnum?] {
    return enumMap
  }

  public func echo(classMap: [Int64?: AllNullableTypes?]) throws -> [Int64?: AllNullableTypes?] {
    return classMap
  }

  public func echoNonNull(stringMap: [String: String]) throws -> [String: String] {
    return stringMap
  }

  public func echoNonNull(intMap: [Int64: Int64]) throws -> [Int64: Int64] {
    return intMap
  }

  public func echoNonNull(enumMap: [AnEnum: AnEnum]) throws -> [AnEnum: AnEnum] {
    return enumMap
  }

  public func echoNonNull(classMap: [Int64: AllNullableTypes]) throws -> [Int64: AllNullableTypes] {
    return classMap
  }

  public func echo(_ wrapper: AllClassesWrapper) throws -> AllClassesWrapper {
    return wrapper
  }

  public func echo(_ anEnum: AnEnum) throws -> AnEnum {
    return anEnum
  }

  public func echo(_ anotherEnum: AnotherEnum) throws -> AnotherEnum {
    return anotherEnum
  }

  public func extractNestedNullableString(from wrapper: AllClassesWrapper) -> String? {
    return wrapper.allNullableTypes.aNullableString
  }

  public func createNestedObject(with nullableString: String?) -> AllClassesWrapper {
    return AllClassesWrapper(
      allNullableTypes: AllNullableTypes(aNullableString: nullableString), classList: [],
      classMap: [:])
  }

  public func sendMultipleNullableTypes(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) -> AllNullableTypes {
    let someThings = AllNullableTypes(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
    return someThings
  }

  public func sendMultipleNullableTypesWithoutRecursion(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) throws -> AllNullableTypesWithoutRecursion {
    let someThings = AllNullableTypesWithoutRecursion(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
    return someThings
  }

  public func echo(_ aNullableInt: Int64?) -> Int64? {
    return aNullableInt
  }

  public func echo(_ aNullableDouble: Double?) -> Double? {
    return aNullableDouble
  }

  public func echo(_ aNullableBool: Bool?) -> Bool? {
    return aNullableBool
  }

  public func echo(_ aNullableString: String?) -> String? {
    return aNullableString
  }

  public func echo(_ aNullableUint8List: FlutterStandardTypedData?) -> FlutterStandardTypedData? {
    return aNullableUint8List
  }

  public func echo(_ aNullableObject: Any?) -> Any? {
    return aNullableObject
  }

  public func echoNamedDefault(_ aString: String) throws -> String {
    return aString
  }

  public func echoOptionalDefault(_ aDouble: Double) throws -> Double {
    return aDouble
  }

  public func createAllTypesWithDefaults() throws -> AllTypesWithDefaults {
    return AllTypesWithDefaults()
  }

  public func echo(allTypesWithDefaults allTypes: AllTypesWithDefaults) throws
    -> AllTypesWithDefaults
  {
    return allTypes
  }

  public func echoRequired(_ anInt: Int64) throws -> Int64 {
    return anInt
  }

  public func echoNullable(_ aNullableList: [Any?]?) throws -> [Any?]? {
    return aNullableList
  }

  public func echoNullable(enumList: [AnEnum?]?) throws -> [AnEnum?]? {
    return enumList
  }

  public func echoNullable(classList: [AllNullableTypes?]?) throws -> [AllNullableTypes?]? {
    return classList
  }

  public func echoNullableNonNull(enumList: [AnEnum]?) throws -> [AnEnum]? {
    return enumList
  }

  public func echoNullableNonNull(classList: [AllNullableTypes]?) throws -> [AllNullableTypes]? {
    return classList
  }

  public func echoNullable(_ map: [AnyHashable?: Any?]?) throws -> [AnyHashable?: Any?]? {
    return map
  }

  public func echoNullable(stringMap: [String?: String?]?) throws -> [String?: String?]? {
    return stringMap
  }

  public func echoNullable(intMap: [Int64?: Int64?]?) throws -> [Int64?: Int64?]? {
    return intMap
  }

  public func echoNullable(enumMap: [AnEnum?: AnEnum?]?) throws -> [AnEnum?: AnEnum?]? {
    return enumMap
  }

  public func echoNullable(classMap: [Int64?: AllNullableTypes?]?) throws -> [Int64?:
    AllNullableTypes?]?
  {
    return classMap
  }

  public func echoNullableNonNull(stringMap: [String: String]?) throws -> [String: String]? {
    return stringMap
  }

  public func echoNullableNonNull(intMap: [Int64: Int64]?) throws -> [Int64: Int64]? {
    return intMap
  }

  public func echoNullableNonNull(enumMap: [AnEnum: AnEnum]?) throws -> [AnEnum: AnEnum]? {
    return enumMap
  }

  public func echoNullableNonNull(classMap: [Int64: AllNullableTypes]?) throws -> [Int64:
    AllNullableTypes]?
  {
    return classMap
  }

  public func echoNullable(_ anEnum: AnEnum?) throws -> AnEnum? {
    return anEnum
  }

  public func echoNullable(_ anotherEnum: AnotherEnum?) throws -> AnotherEnum? {
    return anotherEnum
  }

  public func echoOptional(_ aNullableInt: Int64?) throws -> Int64? {
    return aNullableInt
  }

  public func echoNamed(_ aNullableString: String?) throws -> String? {
    return aNullableString
  }

  public func noopAsync(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.success(()))
  }

  public func throwAsyncError(completion: @escaping (Result<Any?, Error>) -> Void) {
    completion(.failure(GolubError(code: "code", message: "message", details: "details")))
  }

  public func throwAsyncErrorFromVoid(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(GolubError(code: "code", message: "message", details: "details")))
  }

  public func throwAsyncFlutterError(completion: @escaping (Result<Any?, Error>) -> Void) {
    completion(.failure(GolubError(code: "code", message: "message", details: "details")))
  }

  public func echoAsync(
    _ everything: AllTypes, completion: @escaping (Result<AllTypes, Error>) -> Void
  ) {
    completion(.success(everything))
  }

  public func echoAsync(
    _ everything: AllNullableTypes?,
    completion: @escaping (Result<AllNullableTypes?, Error>) -> Void
  ) {
    completion(.success(everything))
  }

  public func echoAsync(
    _ everything: AllNullableTypesWithoutRecursion?,
    completion: @escaping (Result<AllNullableTypesWithoutRecursion?, Error>) -> Void
  ) {
    completion(.success(everything))
  }

  public func echoAsync(_ anInt: Int64, completion: @escaping (Result<Int64, Error>) -> Void) {
    completion(.success(anInt))
  }

  public func echoAsync(_ aDouble: Double, completion: @escaping (Result<Double, Error>) -> Void) {
    completion(.success(aDouble))
  }

  public func echoAsync(_ aBool: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
    completion(.success(aBool))
  }

  public func echoAsync(_ aString: String, completion: @escaping (Result<String, Error>) -> Void) {
    completion(.success(aString))
  }

  public func echoAsync(
    _ aUint8List: FlutterStandardTypedData,
    completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
  ) {
    completion(.success(aUint8List))
  }

  public func echoAsync(_ anObject: Any, completion: @escaping (Result<Any, Error>) -> Void) {
    completion(.success(anObject))
  }

  public func echoAsync(_ list: [Any?], completion: @escaping (Result<[Any?], Error>) -> Void) {
    completion(.success(list))
  }

  public func echoAsync(
    enumList: [AnEnum?], completion: @escaping (Result<[AnEnum?], Error>) -> Void
  ) {
    completion(.success(enumList))
  }

  public func echoAsync(
    classList: [AllNullableTypes?],
    completion: @escaping (Result<[AllNullableTypes?], Error>) -> Void
  ) {
    completion(.success(classList))
  }

  public func echoAsync(
    _ map: [AnyHashable?: Any?], completion: @escaping (Result<[AnyHashable?: Any?], Error>) -> Void
  ) {
    completion(.success(map))
  }

  public func echoAsync(
    stringMap: [String?: String?], completion: @escaping (Result<[String?: String?], Error>) -> Void
  ) {
    completion(.success(stringMap))
  }

  public func echoAsync(
    intMap: [Int64?: Int64?], completion: @escaping (Result<[Int64?: Int64?], Error>) -> Void
  ) {
    completion(.success(intMap))
  }

  public func echoAsync(
    enumMap: [AnEnum?: AnEnum?], completion: @escaping (Result<[AnEnum?: AnEnum?], Error>) -> Void
  ) {
    completion(.success(enumMap))
  }

  public func echoAsync(
    classMap: [Int64?: AllNullableTypes?],
    completion: @escaping (Result<[Int64?: AllNullableTypes?], Error>) -> Void
  ) {
    completion(.success(classMap))
  }

  public func echoAsync(_ anEnum: AnEnum, completion: @escaping (Result<AnEnum, Error>) -> Void) {
    completion(.success(anEnum))
  }

  public func echoAsync(
    _ anotherEnum: AnotherEnum, completion: @escaping (Result<AnotherEnum, Error>) -> Void
  ) {
    completion(.success(anotherEnum))
  }

  public func echoAsyncNullable(
    _ anInt: Int64?, completion: @escaping (Result<Int64?, Error>) -> Void
  ) {
    completion(.success(anInt))
  }

  public func echoAsyncNullable(
    _ aDouble: Double?, completion: @escaping (Result<Double?, Error>) -> Void
  ) {
    completion(.success(aDouble))
  }

  public func echoAsyncNullable(
    _ aBool: Bool?, completion: @escaping (Result<Bool?, Error>) -> Void
  ) {
    completion(.success(aBool))
  }

  public func echoAsyncNullable(
    _ aString: String?, completion: @escaping (Result<String?, Error>) -> Void
  ) {
    completion(.success(aString))
  }

  public func echoAsyncNullable(
    _ aUint8List: FlutterStandardTypedData?,
    completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
  ) {
    completion(.success(aUint8List))
  }

  public func echoAsyncNullable(
    _ anObject: Any?, completion: @escaping (Result<Any?, Error>) -> Void
  ) {
    completion(.success(anObject))
  }

  public func echoAsyncNullable(
    _ list: [Any?]?, completion: @escaping (Result<[Any?]?, Error>) -> Void
  ) {
    completion(.success(list))
  }

  public func echoAsyncNullable(
    enumList: [AnEnum?]?, completion: @escaping (Result<[AnEnum?]?, Error>) -> Void
  ) {
    completion(.success(enumList))
  }

  public func echoAsyncNullable(
    classList: [AllNullableTypes?]?,
    completion: @escaping (Result<[AllNullableTypes?]?, Error>) -> Void
  ) {
    completion(.success(classList))
  }

  public func echoAsyncNullable(
    _ map: [AnyHashable?: Any?]?,
    completion: @escaping (Result<[AnyHashable?: Any?]?, Error>) -> Void
  ) {
    completion(.success(map))
  }

  public func echoAsyncNullable(
    stringMap: [String?: String?]?,
    completion: @escaping (Result<[String?: String?]?, Error>) -> Void
  ) {
    completion(.success(stringMap))
  }

  public func echoAsyncNullable(
    intMap: [Int64?: Int64?]?, completion: @escaping (Result<[Int64?: Int64?]?, Error>) -> Void
  ) {
    completion(.success(intMap))
  }

  public func echoAsyncNullable(
    enumMap: [AnEnum?: AnEnum?]?, completion: @escaping (Result<[AnEnum?: AnEnum?]?, Error>) -> Void
  ) {
    completion(.success(enumMap))
  }

  public func echoAsyncNullable(
    classMap: [Int64?: AllNullableTypes?]?,
    completion: @escaping (Result<[Int64?: AllNullableTypes?]?, Error>) -> Void
  ) {
    completion(.success(classMap))
  }

  public func echoAsyncNullable(
    _ anEnum: AnEnum?, completion: @escaping (Result<AnEnum?, Error>) -> Void
  ) {
    completion(.success(anEnum))
  }

  public func echoAsyncNullable(
    _ anotherEnum: AnotherEnum?, completion: @escaping (Result<AnotherEnum?, Error>) -> Void
  ) {
    completion(.success(anotherEnum))
  }

  public func defaultIsMainThread() -> Bool {
    return Thread.isMainThread
  }

  public func taskQueueIsBackgroundThread() -> Bool {
    return !Thread.isMainThread
  }

  public func callFlutterNoop(completion: @escaping (Result<Void, Error>) -> Void) {
    flutterAPI.noop { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterThrowError(completion: @escaping (Result<Any?, Error>) -> Void) {
    flutterAPI.throwError { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterThrowErrorFromVoid(completion: @escaping (Result<Void, Error>) -> Void) {
    flutterAPI.throwErrorFromVoid { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    _ everything: AllTypes, completion: @escaping (Result<AllTypes, Error>) -> Void
  ) {
    flutterAPI.echo(everything) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    _ everything: AllNullableTypes?,
    completion: @escaping (Result<AllNullableTypes?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(everything) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    _ everything: AllNullableTypesWithoutRecursion?,
    completion: @escaping (Result<AllNullableTypesWithoutRecursion?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(everything) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterSendMultipleNullableTypes(
    aBool aNullableBool: Bool?,
    anInt aNullableInt: Int64?,
    aString aNullableString: String?,
    completion: @escaping (Result<AllNullableTypes, Error>) -> Void
  ) {
    flutterAPI.sendMultipleNullableTypes(
      aBool: aNullableBool,
      anInt: aNullableInt,
      aString: aNullableString
    ) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterSendMultipleNullableTypesWithoutRecursion(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?,
    completion: @escaping (Result<AllNullableTypesWithoutRecursion, Error>) -> Void
  ) {
    flutterAPI.sendMultipleNullableTypesWithoutRecursion(
      aBool: aNullableBool,
      anInt: aNullableInt,
      aString: aNullableString
    ) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(_ aBool: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
    flutterAPI.echo(aBool) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(_ anInt: Int64, completion: @escaping (Result<Int64, Error>) -> Void)
  {
    flutterAPI.echo(anInt) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    _ aDouble: Double, completion: @escaping (Result<Double, Error>) -> Void
  ) {
    flutterAPI.echo(aDouble) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    _ aString: String, completion: @escaping (Result<String, Error>) -> Void
  ) {
    flutterAPI.echo(aString) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    _ list: FlutterStandardTypedData,
    completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
  ) {
    flutterAPI.echo(list) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(_ list: [Any?], completion: @escaping (Result<[Any?], Error>) -> Void)
  {
    flutterAPI.echo(list) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    enumList: [AnEnum?], completion: @escaping (Result<[AnEnum?], Error>) -> Void
  ) {
    flutterAPI.echo(enumList: enumList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    classList: [AllNullableTypes?],
    completion: @escaping (Result<[AllNullableTypes?], Error>) -> Void
  ) {
    flutterAPI.echo(classList: classList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNonNull(
    enumList: [AnEnum], completion: @escaping (Result<[AnEnum], Error>) -> Void
  ) {
    flutterAPI.echoNonNull(enumList: enumList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNonNull(
    classList: [AllNullableTypes], completion: @escaping (Result<[AllNullableTypes], Error>) -> Void
  ) {
    flutterAPI.echoNonNull(classList: classList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    _ map: [AnyHashable?: Any?], completion: @escaping (Result<[AnyHashable?: Any?], Error>) -> Void
  ) {
    flutterAPI.echo(map) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    stringMap: [String?: String?], completion: @escaping (Result<[String?: String?], Error>) -> Void
  ) {
    flutterAPI.echo(stringMap: stringMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    intMap: [Int64?: Int64?], completion: @escaping (Result<[Int64?: Int64?], Error>) -> Void
  ) {
    flutterAPI.echo(intMap: intMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    enumMap: [AnEnum?: AnEnum?], completion: @escaping (Result<[AnEnum?: AnEnum?], Error>) -> Void
  ) {
    flutterAPI.echo(enumMap: enumMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    classMap: [Int64?: AllNullableTypes?],
    completion: @escaping (Result<[Int64?: AllNullableTypes?], Error>) -> Void
  ) {
    flutterAPI.echo(classMap: classMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNonNull(
    stringMap: [String: String], completion: @escaping (Result<[String: String], Error>) -> Void
  ) {
    flutterAPI.echoNonNull(stringMap: stringMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNonNull(
    intMap: [Int64: Int64], completion: @escaping (Result<[Int64: Int64], Error>) -> Void
  ) {
    flutterAPI.echoNonNull(intMap: intMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNonNull(
    enumMap: [AnEnum: AnEnum], completion: @escaping (Result<[AnEnum: AnEnum], Error>) -> Void
  ) {
    flutterAPI.echoNonNull(enumMap: enumMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNonNull(
    classMap: [Int64: AllNullableTypes],
    completion: @escaping (Result<[Int64: AllNullableTypes], Error>) -> Void
  ) {
    flutterAPI.echoNonNull(classMap: classMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    _ anEnum: AnEnum, completion: @escaping (Result<AnEnum, Error>) -> Void
  ) {
    flutterAPI.echo(anEnum) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEcho(
    _ anotherEnum: AnotherEnum, completion: @escaping (Result<AnotherEnum, Error>) -> Void
  ) {
    flutterAPI.echo(anotherEnum) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    _ aBool: Bool?, completion: @escaping (Result<Bool?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(aBool) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    _ anInt: Int64?, completion: @escaping (Result<Int64?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(anInt) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    _ aDouble: Double?, completion: @escaping (Result<Double?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(aDouble) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    _ aString: String?, completion: @escaping (Result<String?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(aString) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    _ list: FlutterStandardTypedData?,
    completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(list) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    _ list: [Any?]?, completion: @escaping (Result<[Any?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(list) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    enumList: [AnEnum?]?, completion: @escaping (Result<[AnEnum?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(enumList: enumList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    classList: [AllNullableTypes?]?,
    completion: @escaping (Result<[AllNullableTypes?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(classList: classList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullableNonNull(
    enumList: [AnEnum]?, completion: @escaping (Result<[AnEnum]?, Error>) -> Void
  ) {
    flutterAPI.echoNullableNonNull(enumList: enumList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullableNonNull(
    classList: [AllNullableTypes]?,
    completion: @escaping (Result<[AllNullableTypes]?, Error>) -> Void
  ) {
    flutterAPI.echoNullableNonNull(classList: classList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    _ map: [AnyHashable?: Any?]?,
    completion: @escaping (Result<[AnyHashable?: Any?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(map) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    stringMap: [String?: String?]?,
    completion: @escaping (Result<[String?: String?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(stringMap: stringMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    intMap: [Int64?: Int64?]?, completion: @escaping (Result<[Int64?: Int64?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(intMap: intMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    enumMap: [AnEnum?: AnEnum?]?, completion: @escaping (Result<[AnEnum?: AnEnum?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(enumMap: enumMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    classMap: [Int64?: AllNullableTypes?]?,
    completion: @escaping (Result<[Int64?: AllNullableTypes?]?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(classMap: classMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullableNonNull(
    stringMap: [String: String]?, completion: @escaping (Result<[String: String]?, Error>) -> Void
  ) {
    flutterAPI.echoNullableNonNull(stringMap: stringMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullableNonNull(
    intMap: [Int64: Int64]?, completion: @escaping (Result<[Int64: Int64]?, Error>) -> Void
  ) {
    flutterAPI.echoNullableNonNull(intMap: intMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullableNonNull(
    enumMap: [AnEnum: AnEnum]?, completion: @escaping (Result<[AnEnum: AnEnum]?, Error>) -> Void
  ) {
    flutterAPI.echoNullableNonNull(enumMap: enumMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullableNonNull(
    classMap: [Int64: AllNullableTypes]?,
    completion: @escaping (Result<[Int64: AllNullableTypes]?, Error>) -> Void
  ) {
    flutterAPI.echoNullableNonNull(classMap: classMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    _ anEnum: AnEnum?, completion: @escaping (Result<AnEnum?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(anEnum) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullable(
    _ anotherEnum: AnotherEnum?, completion: @escaping (Result<AnotherEnum?, Error>) -> Void
  ) {
    flutterAPI.echoNullable(anotherEnum) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterSmallApiEcho(
    _ aString: String, completion: @escaping (Result<String, Error>) -> Void
  ) {
    flutterSmallApiOne.echo(string: aString) { responseOne in
      self.flutterSmallApiTwo.echo(string: aString) { responseTwo in
        switch responseOne {
        case .success(let resOne):
          switch responseTwo {
          case .success(let resTwo):
            if resOne == resTwo {
              completion(.success(resOne))
            } else {
              completion(
                .failure(
                  GolubError(
                    code: "",
                    message: "Multi-instance responses were not matching: \(resOne), \(resTwo)",
                    details: nil)))
            }
          case .failure(let error):
            completion(.failure(error))
          }
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }

  public func testUnusedClassesGenerate() -> UnusedClass {
    return UnusedClass()
  }

  public func echo(event: PlatformEvent) throws -> PlatformEvent { event }
}

public class TestPluginWithSuffix: HostSmallApi {
  public static func register(with registrar: FlutterPluginRegistrar, suffix: String) {
    // Workaround for https://github.com/flutter/flutter/issues/118103.
    #if os(iOS)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif
    let plugin = TestPluginWithSuffix()
    HostSmallApiSetup.setUp(
      binaryMessenger: messenger, api: plugin, messageChannelSuffix: suffix)
  }

  public func echo(aString: String, completion: @escaping (Result<String, Error>) -> Void) {
    completion(.success(aString))
  }

  public func voidVoid(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.success(()))
  }
}

class SendInts: StreamIntsStreamHandler {
  var timerActive = false
  var timer: Timer?

  override public func onListen(withArguments arguments: Any?, sink: GolubEventSink<Int64>) {
    var count: Int64 = 0
    if !timerActive {
      timerActive = true
      timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
        DispatchQueue.main.async {
          sink.success(count)
          count += 1
          if count >= 5 {
            sink.endOfStream()
            self.timer?.invalidate()
          }
        }
      }
    }
  }
}

class SendEvents: StreamEventsStreamHandler {
  var timerActive = false
  var timer: Timer?
  var eventList: [PlatformEvent] =
    [
      .intEvent(value: 1),
      .stringEvent(value: "string"),
      .boolEvent(value: false),
      .doubleEvent(value: 3.14),
      .objectsEvent(value: true),
      .enumEvent(value: EventEnum.fortyTwo),
      .classEvent(value: EventAllNullableTypes(aNullableInt: 0)),
      .emptyEvent,
    ]

  override public func onListen(withArguments arguments: Any?, sink: GolubEventSink<PlatformEvent>)
  {
    var count = 0
    if !timerActive {
      timerActive = true
      timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
        DispatchQueue.main.async {
          if count >= self.eventList.count {
            sink.endOfStream()
            self.timer?.invalidate()
          } else {
            sink.success(self.eventList[count])
            count += 1
          }
        }
      }
    }
  }
}

class SendConsistentNumbers: StreamConsistentNumbersStreamHandler {
  let numberToSend: Int64
  init(numberToSend: Int64) {
    self.numberToSend = numberToSend
  }

  var timerActive = false
  var timer: Timer?

  override public func onListen(withArguments arguments: Any?, sink: GolubEventSink<Int64>) {
    let numberThatWillBeSent: Int64 = numberToSend
    var count: Int64 = 0
    if !timerActive {
      timerActive = true
      timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
        DispatchQueue.main.async {
          sink.success(numberThatWillBeSent)
          count += 1
          if count >= 10 {
            sink.endOfStream()
            self.timer?.invalidate()
          }
        }
      }
    }
  }
}

class ProxyApiDelegate: ProxyApiTestsGolubProxyApiDelegate {
  public func golubApiProxyApiTestClass(_ registrar: ProxyApiTestsGolubProxyApiRegistrar)
    -> GolubApiProxyApiTestClass
  {
    class ProxyApiTestClassDelegate: GolubApiDelegateProxyApiTestClass {
      public func golubDefaultConstructor(
        golubApi: GolubApiProxyApiTestClass, aBool: Bool, anInt: Int64, aDouble: Double,
        aString: String, aUint8List: FlutterStandardTypedData, aList: [Any?], aMap: [String?: Any?],
        anEnum: ProxyApiTestEnum, aProxyApi: ProxyApiSuperClass, aNullableBool: Bool?,
        aNullableInt: Int64?, aNullableDouble: Double?, aNullableString: String?,
        aNullableUint8List: FlutterStandardTypedData?, aNullableList: [Any?]?,
        aNullableMap: [String?: Any?]?, aNullableEnum: ProxyApiTestEnum?,
        aNullableProxyApi: ProxyApiSuperClass?, boolParam: Bool, intParam: Int64,
        doubleParam: Double, stringParam: String, aUint8ListParam: FlutterStandardTypedData,
        listParam: [Any?], mapParam: [String?: Any?], enumParam: ProxyApiTestEnum,
        proxyApiParam: ProxyApiSuperClass, nullableBoolParam: Bool?, nullableIntParam: Int64?,
        nullableDoubleParam: Double?, nullableStringParam: String?,
        nullableUint8ListParam: FlutterStandardTypedData?, nullableListParam: [Any?]?,
        nullableMapParam: [String?: Any?]?, nullableEnumParam: ProxyApiTestEnum?,
        nullableProxyApiParam: ProxyApiSuperClass?
      ) throws -> ProxyApiTestClass {
        return ProxyApiTestClass()
      }

      public func namedConstructor(
        golubApi: GolubApiProxyApiTestClass, aBool: Bool, anInt: Int64, aDouble: Double,
        aString: String, aUint8List: FlutterStandardTypedData, aList: [Any?], aMap: [String?: Any?],
        anEnum: ProxyApiTestEnum, aProxyApi: ProxyApiSuperClass, aNullableBool: Bool?,
        aNullableInt: Int64?, aNullableDouble: Double?, aNullableString: String?,
        aNullableUint8List: FlutterStandardTypedData?, aNullableList: [Any?]?,
        aNullableMap: [String?: Any?]?, aNullableEnum: ProxyApiTestEnum?,
        aNullableProxyApi: ProxyApiSuperClass?
      ) throws -> ProxyApiTestClass {
        return ProxyApiTestClass()
      }

      public func attachedField(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      )
        throws -> ProxyApiSuperClass
      {
        return ProxyApiSuperClass()
      }

      public func staticAttachedField(golubApi: GolubApiProxyApiTestClass) throws
        -> ProxyApiSuperClass
      {
        return ProxyApiSuperClass()
      }

      public func aBool(golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass)
        throws
        -> Bool
      {
        return true
      }

      public func anInt(golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass)
        throws
        -> Int64
      {
        return 0
      }

      public func aDouble(golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass)
        throws
        -> Double
      {
        return 0.0
      }

      public func aString(golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass)
        throws
        -> String
      {
        return ""
      }

      public func aUint8List(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      )
        throws -> FlutterStandardTypedData
      {
        return FlutterStandardTypedData(bytes: Data())
      }

      public func aList(golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass)
        throws
        -> [Any?]
      {
        return []
      }

      public func aMap(golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass)
        throws
        -> [String?: Any?]
      {
        return [:]
      }

      public func anEnum(golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass)
        throws
        -> ProxyApiTestEnum
      {
        return ProxyApiTestEnum.one
      }

      public func aProxyApi(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      )
        throws -> ProxyApiSuperClass
      {
        return ProxyApiSuperClass()
      }

      public func aNullableBool(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      )
        throws -> Bool?
      {
        return nil
      }

      public func aNullableInt(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      )
        throws -> Int64?
      {
        return nil
      }

      public func aNullableDouble(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      )
        throws -> Double?
      {
        return nil
      }

      public func aNullableString(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      )
        throws -> String?
      {
        return nil
      }

      public func aNullableUint8List(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      ) throws -> FlutterStandardTypedData? {
        return nil
      }

      public func aNullableList(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      )
        throws -> [Any?]?
      {
        return nil
      }

      public func aNullableMap(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      )
        throws -> [String?: Any?]?
      {
        return nil
      }

      public func aNullableEnum(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      )
        throws -> ProxyApiTestEnum?
      {
        return nil
      }

      public func aNullableProxyApi(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      ) throws -> ProxyApiSuperClass? {
        return nil
      }

      public func noop(golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass)
        throws
      {}

      public func throwError(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      )
        throws -> Any?
      {
        throw ProxyApiTestsError(code: "code", message: "message", details: "details")
      }

      public func throwErrorFromVoid(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      ) throws {
        throw ProxyApiTestsError(code: "code", message: "message", details: "details")
      }

      public func throwFlutterError(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass
      ) throws -> Any? {
        throw ProxyApiTestsError(code: "code", message: "message", details: "details")
      }

      public func echoInt(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, anInt: Int64
      ) throws -> Int64 {
        return anInt
      }

      public func echoDouble(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aDouble: Double
      ) throws -> Double {
        return aDouble
      }

      public func echoBool(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aBool: Bool
      ) throws -> Bool {
        return aBool
      }

      public func echoString(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aString: String
      ) throws -> String {
        return aString
      }

      public func echoUint8List(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData
      ) throws -> FlutterStandardTypedData {
        return aUint8List
      }

      public func echoObject(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, anObject: Any
      ) throws -> Any {
        return anObject
      }

      public func echoList(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aList: [Any?]
      ) throws -> [Any?] {
        return aList
      }

      public func echoProxyApiList(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aList: [ProxyApiTestClass]
      ) throws -> [ProxyApiTestClass] {
        return aList
      }

      public func echoMap(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aMap: [String?: Any?]
      ) throws -> [String?: Any?] {
        return aMap
      }

      public func echoProxyApiMap(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aMap: [String: ProxyApiTestClass]
      ) throws -> [String: ProxyApiTestClass] {
        return aMap
      }

      public func echoEnum(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum
      ) throws -> ProxyApiTestEnum {
        return anEnum
      }

      public func echoProxyApi(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aProxyApi: ProxyApiSuperClass
      ) throws -> ProxyApiSuperClass {
        return aProxyApi
      }

      public func echoNullableInt(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aNullableInt: Int64?
      ) throws -> Int64? {
        return aNullableInt
      }

      public func echoNullableDouble(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aNullableDouble: Double?
      ) throws -> Double? {
        return aNullableDouble
      }

      public func echoNullableBool(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aNullableBool: Bool?
      ) throws -> Bool? {
        return aNullableBool
      }

      public func echoNullableString(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aNullableString: String?
      ) throws -> String? {
        return aNullableString
      }

      public func echoNullableUint8List(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aNullableUint8List: FlutterStandardTypedData?
      ) throws -> FlutterStandardTypedData? {
        return aNullableUint8List
      }

      public func echoNullableObject(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aNullableObject: Any?
      ) throws -> Any? {
        return aNullableObject
      }

      public func echoNullableList(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aNullableList: [Any?]?
      ) throws -> [Any?]? {
        return aNullableList
      }

      public func echoNullableMap(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aNullableMap: [String?: Any?]?
      ) throws -> [String?: Any?]? {
        return aNullableMap
      }

      public func echoNullableEnum(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aNullableEnum: ProxyApiTestEnum?
      ) throws -> ProxyApiTestEnum? {
        return aNullableEnum
      }

      public func echoNullableProxyApi(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aNullableProxyApi: ProxyApiSuperClass?
      ) throws -> ProxyApiSuperClass? {
        return aNullableProxyApi
      }

      public func noopAsync(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        completion(.success(()))
      }

      public func echoAsyncInt(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, anInt: Int64,
        completion: @escaping (Result<Int64, Error>) -> Void
      ) {
        completion(.success(anInt))
      }

      public func echoAsyncDouble(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aDouble: Double,
        completion: @escaping (Result<Double, Error>) -> Void
      ) {
        completion(.success(aDouble))
      }

      public func echoAsyncBool(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aBool: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
      ) {
        completion(.success(aBool))
      }

      public func echoAsyncString(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aString: String,
        completion: @escaping (Result<String, Error>) -> Void
      ) {
        completion(.success(aString))
      }

      public func echoAsyncUint8List(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData,
        completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
      ) {
        completion(.success(aUint8List))
      }

      public func echoAsyncObject(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, anObject: Any,
        completion: @escaping (Result<Any, Error>) -> Void
      ) {
        completion(.success(anObject))
      }

      public func echoAsyncList(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aList: [Any?],
        completion: @escaping (Result<[Any?], Error>) -> Void
      ) {
        completion(.success(aList))
      }

      public func echoAsyncMap(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aMap: [String?: Any?], completion: @escaping (Result<[String?: Any?], Error>) -> Void
      ) {
        completion(.success(aMap))
      }

      public func echoAsyncEnum(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum, completion: @escaping (Result<ProxyApiTestEnum, Error>) -> Void
      ) {
        completion(.success(anEnum))
      }

      public func throwAsyncError(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        completion: @escaping (Result<Any?, Error>) -> Void
      ) {
        completion(
          .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
      }

      public func throwAsyncErrorFromVoid(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        completion(
          .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
      }

      public func throwAsyncFlutterError(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        completion: @escaping (Result<Any?, Error>) -> Void
      ) {
        completion(
          .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
      }

      public func echoAsyncNullableInt(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, anInt: Int64?,
        completion: @escaping (Result<Int64?, Error>) -> Void
      ) {
        completion(.success(anInt))
      }

      public func echoAsyncNullableDouble(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aDouble: Double?,
        completion: @escaping (Result<Double?, Error>) -> Void
      ) {
        completion(.success(aDouble))
      }

      public func echoAsyncNullableBool(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aBool: Bool?,
        completion: @escaping (Result<Bool?, Error>) -> Void
      ) {
        completion(.success(aBool))
      }

      public func echoAsyncNullableString(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aString: String?,
        completion: @escaping (Result<String?, Error>) -> Void
      ) {
        completion(.success(aString))
      }

      public func echoAsyncNullableUint8List(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData?,
        completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
      ) {
        completion(.success(aUint8List))
      }

      public func echoAsyncNullableObject(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, anObject: Any?,
        completion: @escaping (Result<Any?, Error>) -> Void
      ) {
        completion(.success(anObject))
      }

      public func echoAsyncNullableList(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aList: [Any?]?,
        completion: @escaping (Result<[Any?]?, Error>) -> Void
      ) {
        completion(.success(aList))
      }

      public func echoAsyncNullableMap(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aMap: [String?: Any?]?, completion: @escaping (Result<[String?: Any?]?, Error>) -> Void
      ) {
        completion(.success(aMap))
      }

      public func echoAsyncNullableEnum(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum?, completion: @escaping (Result<ProxyApiTestEnum?, Error>) -> Void
      ) {
        completion(.success(anEnum))
      }

      public func staticNoop(golubApi: GolubApiProxyApiTestClass) throws {}

      public func echoStaticString(golubApi: GolubApiProxyApiTestClass, aString: String) throws
        -> String
      {
        return aString
      }

      public func staticAsyncNoop(
        golubApi: GolubApiProxyApiTestClass, completion: @escaping (Result<Void, Error>) -> Void
      ) {
        completion(.success(()))
      }

      public func callFlutterNoop(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        golubApi.flutterNoop(golubInstance: golubInstance) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterThrowError(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        completion: @escaping (Result<Any?, Error>) -> Void
      ) {
        golubApi.flutterThrowError(golubInstance: golubInstance) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterThrowErrorFromVoid(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        golubApi.flutterThrowErrorFromVoid(golubInstance: golubInstance) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoBool(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aBool: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
      ) {
        golubApi.flutterEchoBool(golubInstance: golubInstance, aBool: aBool) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoInt(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, anInt: Int64,
        completion: @escaping (Result<Int64, Error>) -> Void
      ) {
        golubApi.flutterEchoInt(golubInstance: golubInstance, anInt: anInt) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoDouble(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aDouble: Double,
        completion: @escaping (Result<Double, Error>) -> Void
      ) {
        golubApi.flutterEchoDouble(golubInstance: golubInstance, aDouble: aDouble) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoString(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aString: String,
        completion: @escaping (Result<String, Error>) -> Void
      ) {
        golubApi.flutterEchoString(golubInstance: golubInstance, aString: aString) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoUint8List(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData,
        completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
      ) {
        golubApi.flutterEchoUint8List(golubInstance: golubInstance, aList: aUint8List) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoList(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aList: [Any?],
        completion: @escaping (Result<[Any?], Error>) -> Void
      ) {
        golubApi.flutterEchoList(golubInstance: golubInstance, aList: aList) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoProxyApiList(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aList: [ProxyApiTestClass?],
        completion: @escaping (Result<[ProxyApiTestClass?], Error>) -> Void
      ) {
        golubApi.flutterEchoProxyApiList(golubInstance: golubInstance, aList: aList) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoMap(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aMap: [String?: Any?], completion: @escaping (Result<[String?: Any?], Error>) -> Void
      ) {
        golubApi.flutterEchoMap(golubInstance: golubInstance, aMap: aMap) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoProxyApiMap(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aMap: [String?: ProxyApiTestClass?],
        completion: @escaping (Result<[String?: ProxyApiTestClass?], Error>) -> Void
      ) {
        golubApi.flutterEchoProxyApiMap(golubInstance: golubInstance, aMap: aMap) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoEnum(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum, completion: @escaping (Result<ProxyApiTestEnum, Error>) -> Void
      ) {
        golubApi.flutterEchoEnum(golubInstance: golubInstance, anEnum: anEnum) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoProxyApi(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aProxyApi: ProxyApiSuperClass,
        completion: @escaping (Result<ProxyApiSuperClass, Error>) -> Void
      ) {
        golubApi.flutterEchoProxyApi(golubInstance: golubInstance, aProxyApi: aProxyApi) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoNullableBool(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aBool: Bool?,
        completion: @escaping (Result<Bool?, Error>) -> Void
      ) {
        golubApi.flutterEchoNullableBool(golubInstance: golubInstance, aBool: aBool) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoNullableInt(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, anInt: Int64?,
        completion: @escaping (Result<Int64?, Error>) -> Void
      ) {
        golubApi.flutterEchoNullableInt(golubInstance: golubInstance, anInt: anInt) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoNullableDouble(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aDouble: Double?,
        completion: @escaping (Result<Double?, Error>) -> Void
      ) {
        golubApi.flutterEchoNullableDouble(golubInstance: golubInstance, aDouble: aDouble) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoNullableString(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aString: String?,
        completion: @escaping (Result<String?, Error>) -> Void
      ) {
        golubApi.flutterEchoNullableString(golubInstance: golubInstance, aString: aString) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoNullableUint8List(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData?,
        completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
      ) {
        golubApi.flutterEchoNullableUint8List(golubInstance: golubInstance, aList: aUint8List) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoNullableList(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aList: [Any?]?,
        completion: @escaping (Result<[Any?]?, Error>) -> Void
      ) {
        golubApi.flutterEchoNullableList(golubInstance: golubInstance, aList: aList) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoNullableMap(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aMap: [String?: Any?]?, completion: @escaping (Result<[String?: Any?]?, Error>) -> Void
      ) {
        golubApi.flutterEchoNullableMap(golubInstance: golubInstance, aMap: aMap) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoNullableEnum(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum?, completion: @escaping (Result<ProxyApiTestEnum?, Error>) -> Void
      ) {
        golubApi.flutterEchoNullableEnum(golubInstance: golubInstance, anEnum: anEnum) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoNullableProxyApi(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        aProxyApi: ProxyApiSuperClass?,
        completion: @escaping (Result<ProxyApiSuperClass?, Error>) -> Void
      ) {
        golubApi.flutterEchoNullableProxyApi(golubInstance: golubInstance, aProxyApi: aProxyApi) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterNoopAsync(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        golubApi.flutterNoopAsync(golubInstance: golubInstance) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoAsyncString(
        golubApi: GolubApiProxyApiTestClass, golubInstance: ProxyApiTestClass, aString: String,
        completion: @escaping (Result<String, Error>) -> Void
      ) {
        golubApi.flutterEchoAsyncString(golubInstance: golubInstance, aString: aString) {
          response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }
    }
    return GolubApiProxyApiTestClass(
      golubRegistrar: registrar, delegate: ProxyApiTestClassDelegate())
  }

  public func golubApiProxyApiSuperClass(_ registrar: ProxyApiTestsGolubProxyApiRegistrar)
    -> GolubApiProxyApiSuperClass
  {
    class ProxyApiSuperClassDelegate: GolubApiDelegateProxyApiSuperClass {
      public func golubDefaultConstructor(golubApi: GolubApiProxyApiSuperClass) throws
        -> ProxyApiSuperClass
      {
        return ProxyApiSuperClass()
      }

      public func aSuperMethod(
        golubApi: GolubApiProxyApiSuperClass, golubInstance: ProxyApiSuperClass
      )
        throws
      {}
    }
    return GolubApiProxyApiSuperClass(
      golubRegistrar: registrar, delegate: ProxyApiSuperClassDelegate())
  }

  public func golubApiProxyApiInterface(_ registrar: ProxyApiTestsGolubProxyApiRegistrar)
    -> GolubApiProxyApiInterface
  {
    class ProxyApiInterfaceDelegate: GolubApiDelegateProxyApiInterface {}
    return GolubApiProxyApiInterface(
      golubRegistrar: registrar, delegate: ProxyApiInterfaceDelegate())
  }

  public func golubApiClassWithApiRequirement(_ registrar: ProxyApiTestsGolubProxyApiRegistrar)
    -> GolubApiClassWithApiRequirement
  {
    class ClassWithApiRequirementDelegate: GolubApiDelegateClassWithApiRequirement {
      @available(iOS 15, macOS 10, *)
      public func golubDefaultConstructor(golubApi: GolubApiClassWithApiRequirement) throws
        -> ClassWithApiRequirement
      {
        return ClassWithApiRequirement()
      }

      @available(iOS 15, macOS 10, *)
      public func aMethod(
        golubApi: GolubApiClassWithApiRequirement, golubInstance: ClassWithApiRequirement
      ) throws {}
    }

    return GolubApiClassWithApiRequirement(
      golubRegistrar: registrar, delegate: ClassWithApiRequirementDelegate())
  }
}
