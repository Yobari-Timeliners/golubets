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
  var proxyApiRegistrar: ProxyApiTestsPigeonProxyApiRegistrar?

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
    proxyApiRegistrar = ProxyApiTestsPigeonProxyApiRegistrar(
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
    throw PigeonError(code: "code", message: "message", details: "details")
  }

  public func echoModernAsyncNullableAllNullableTypes(_ everything: AllNullableTypes?) async
    -> AllNullableTypes?
  {
    return everything
  }

  public func throwError() throws -> Any? {
    throw PigeonError(code: "code", message: "message", details: "details")
  }

  public func throwErrorFromVoid() throws {
    throw PigeonError(code: "code", message: "message", details: "details")
  }

  public func throwFlutterError() throws -> Any? {
    throw PigeonError(code: "code", message: "message", details: "details")
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
    completion(.failure(PigeonError(code: "code", message: "message", details: "details")))
  }

  public func throwAsyncErrorFromVoid(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(PigeonError(code: "code", message: "message", details: "details")))
  }

  public func throwAsyncFlutterError(completion: @escaping (Result<Any?, Error>) -> Void) {
    completion(.failure(PigeonError(code: "code", message: "message", details: "details")))
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
                  PigeonError(
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

  override public func onListen(withArguments arguments: Any?, sink: PigeonEventSink<Int64>) {
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

  override public func onListen(withArguments arguments: Any?, sink: PigeonEventSink<PlatformEvent>)
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

  override public func onListen(withArguments arguments: Any?, sink: PigeonEventSink<Int64>) {
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

class ProxyApiDelegate: ProxyApiTestsPigeonProxyApiDelegate {
  public func pigeonApiProxyApiTestClass(_ registrar: ProxyApiTestsPigeonProxyApiRegistrar)
    -> PigeonApiProxyApiTestClass
  {
    class ProxyApiTestClassDelegate: PigeonApiDelegateProxyApiTestClass {
      public func pigeonDefaultConstructor(
        pigeonApi: PigeonApiProxyApiTestClass, aBool: Bool, anInt: Int64, aDouble: Double,
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
        pigeonApi: PigeonApiProxyApiTestClass, aBool: Bool, anInt: Int64, aDouble: Double,
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
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      )
        throws -> ProxyApiSuperClass
      {
        return ProxyApiSuperClass()
      }

      public func staticAttachedField(pigeonApi: PigeonApiProxyApiTestClass) throws
        -> ProxyApiSuperClass
      {
        return ProxyApiSuperClass()
      }

      public func aBool(pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass)
        throws
        -> Bool
      {
        return true
      }

      public func anInt(pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass)
        throws
        -> Int64
      {
        return 0
      }

      public func aDouble(pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass)
        throws
        -> Double
      {
        return 0.0
      }

      public func aString(pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass)
        throws
        -> String
      {
        return ""
      }

      public func aUint8List(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      )
        throws -> FlutterStandardTypedData
      {
        return FlutterStandardTypedData(bytes: Data())
      }

      public func aList(pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass)
        throws
        -> [Any?]
      {
        return []
      }

      public func aMap(pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass)
        throws
        -> [String?: Any?]
      {
        return [:]
      }

      public func anEnum(pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass)
        throws
        -> ProxyApiTestEnum
      {
        return ProxyApiTestEnum.one
      }

      public func aProxyApi(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      )
        throws -> ProxyApiSuperClass
      {
        return ProxyApiSuperClass()
      }

      public func aNullableBool(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      )
        throws -> Bool?
      {
        return nil
      }

      public func aNullableInt(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      )
        throws -> Int64?
      {
        return nil
      }

      public func aNullableDouble(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      )
        throws -> Double?
      {
        return nil
      }

      public func aNullableString(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      )
        throws -> String?
      {
        return nil
      }

      public func aNullableUint8List(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      ) throws -> FlutterStandardTypedData? {
        return nil
      }

      public func aNullableList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      )
        throws -> [Any?]?
      {
        return nil
      }

      public func aNullableMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      )
        throws -> [String?: Any?]?
      {
        return nil
      }

      public func aNullableEnum(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      )
        throws -> ProxyApiTestEnum?
      {
        return nil
      }

      public func aNullableProxyApi(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      ) throws -> ProxyApiSuperClass? {
        return nil
      }

      public func noop(pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass)
        throws
      {}

      public func throwError(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      )
        throws -> Any?
      {
        throw ProxyApiTestsError(code: "code", message: "message", details: "details")
      }

      public func throwErrorFromVoid(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      ) throws {
        throw ProxyApiTestsError(code: "code", message: "message", details: "details")
      }

      public func throwFlutterError(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass
      ) throws -> Any? {
        throw ProxyApiTestsError(code: "code", message: "message", details: "details")
      }

      public func echoInt(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64
      ) throws -> Int64 {
        return anInt
      }

      public func echoDouble(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aDouble: Double
      ) throws -> Double {
        return aDouble
      }

      public func echoBool(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool
      ) throws -> Bool {
        return aBool
      }

      public func echoString(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aString: String
      ) throws -> String {
        return aString
      }

      public func echoUint8List(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData
      ) throws -> FlutterStandardTypedData {
        return aUint8List
      }

      public func echoObject(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anObject: Any
      ) throws -> Any {
        return anObject
      }

      public func echoList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aList: [Any?]
      ) throws -> [Any?] {
        return aList
      }

      public func echoProxyApiList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aList: [ProxyApiTestClass]
      ) throws -> [ProxyApiTestClass] {
        return aList
      }

      public func echoMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aMap: [String?: Any?]
      ) throws -> [String?: Any?] {
        return aMap
      }

      public func echoProxyApiMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aMap: [String: ProxyApiTestClass]
      ) throws -> [String: ProxyApiTestClass] {
        return aMap
      }

      public func echoEnum(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum
      ) throws -> ProxyApiTestEnum {
        return anEnum
      }

      public func echoProxyApi(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aProxyApi: ProxyApiSuperClass
      ) throws -> ProxyApiSuperClass {
        return aProxyApi
      }

      public func echoNullableInt(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableInt: Int64?
      ) throws -> Int64? {
        return aNullableInt
      }

      public func echoNullableDouble(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableDouble: Double?
      ) throws -> Double? {
        return aNullableDouble
      }

      public func echoNullableBool(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableBool: Bool?
      ) throws -> Bool? {
        return aNullableBool
      }

      public func echoNullableString(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableString: String?
      ) throws -> String? {
        return aNullableString
      }

      public func echoNullableUint8List(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableUint8List: FlutterStandardTypedData?
      ) throws -> FlutterStandardTypedData? {
        return aNullableUint8List
      }

      public func echoNullableObject(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableObject: Any?
      ) throws -> Any? {
        return aNullableObject
      }

      public func echoNullableList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableList: [Any?]?
      ) throws -> [Any?]? {
        return aNullableList
      }

      public func echoNullableMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableMap: [String?: Any?]?
      ) throws -> [String?: Any?]? {
        return aNullableMap
      }

      public func echoNullableEnum(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableEnum: ProxyApiTestEnum?
      ) throws -> ProxyApiTestEnum? {
        return aNullableEnum
      }

      public func echoNullableProxyApi(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aNullableProxyApi: ProxyApiSuperClass?
      ) throws -> ProxyApiSuperClass? {
        return aNullableProxyApi
      }

      public func noopAsync(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        completion(.success(()))
      }

      public func echoAsyncInt(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64,
        completion: @escaping (Result<Int64, Error>) -> Void
      ) {
        completion(.success(anInt))
      }

      public func echoAsyncDouble(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aDouble: Double,
        completion: @escaping (Result<Double, Error>) -> Void
      ) {
        completion(.success(aDouble))
      }

      public func echoAsyncBool(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
      ) {
        completion(.success(aBool))
      }

      public func echoAsyncString(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aString: String,
        completion: @escaping (Result<String, Error>) -> Void
      ) {
        completion(.success(aString))
      }

      public func echoAsyncUint8List(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData,
        completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
      ) {
        completion(.success(aUint8List))
      }

      public func echoAsyncObject(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anObject: Any,
        completion: @escaping (Result<Any, Error>) -> Void
      ) {
        completion(.success(anObject))
      }

      public func echoAsyncList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aList: [Any?],
        completion: @escaping (Result<[Any?], Error>) -> Void
      ) {
        completion(.success(aList))
      }

      public func echoAsyncMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aMap: [String?: Any?], completion: @escaping (Result<[String?: Any?], Error>) -> Void
      ) {
        completion(.success(aMap))
      }

      public func echoAsyncEnum(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum, completion: @escaping (Result<ProxyApiTestEnum, Error>) -> Void
      ) {
        completion(.success(anEnum))
      }

      public func throwAsyncError(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Any?, Error>) -> Void
      ) {
        completion(
          .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
      }

      public func throwAsyncErrorFromVoid(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        completion(
          .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
      }

      public func throwAsyncFlutterError(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Any?, Error>) -> Void
      ) {
        completion(
          .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
      }

      public func echoAsyncNullableInt(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64?,
        completion: @escaping (Result<Int64?, Error>) -> Void
      ) {
        completion(.success(anInt))
      }

      public func echoAsyncNullableDouble(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aDouble: Double?,
        completion: @escaping (Result<Double?, Error>) -> Void
      ) {
        completion(.success(aDouble))
      }

      public func echoAsyncNullableBool(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool?,
        completion: @escaping (Result<Bool?, Error>) -> Void
      ) {
        completion(.success(aBool))
      }

      public func echoAsyncNullableString(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aString: String?,
        completion: @escaping (Result<String?, Error>) -> Void
      ) {
        completion(.success(aString))
      }

      public func echoAsyncNullableUint8List(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData?,
        completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
      ) {
        completion(.success(aUint8List))
      }

      public func echoAsyncNullableObject(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anObject: Any?,
        completion: @escaping (Result<Any?, Error>) -> Void
      ) {
        completion(.success(anObject))
      }

      public func echoAsyncNullableList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aList: [Any?]?,
        completion: @escaping (Result<[Any?]?, Error>) -> Void
      ) {
        completion(.success(aList))
      }

      public func echoAsyncNullableMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aMap: [String?: Any?]?, completion: @escaping (Result<[String?: Any?]?, Error>) -> Void
      ) {
        completion(.success(aMap))
      }

      public func echoAsyncNullableEnum(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum?, completion: @escaping (Result<ProxyApiTestEnum?, Error>) -> Void
      ) {
        completion(.success(anEnum))
      }

      public func staticNoop(pigeonApi: PigeonApiProxyApiTestClass) throws {}

      public func echoStaticString(pigeonApi: PigeonApiProxyApiTestClass, aString: String) throws
        -> String
      {
        return aString
      }

      public func staticAsyncNoop(
        pigeonApi: PigeonApiProxyApiTestClass, completion: @escaping (Result<Void, Error>) -> Void
      ) {
        completion(.success(()))
      }

      public func callFlutterNoop(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        pigeonApi.flutterNoop(pigeonInstance: pigeonInstance) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterThrowError(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Any?, Error>) -> Void
      ) {
        pigeonApi.flutterThrowError(pigeonInstance: pigeonInstance) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterThrowErrorFromVoid(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        pigeonApi.flutterThrowErrorFromVoid(pigeonInstance: pigeonInstance) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoBool(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
      ) {
        pigeonApi.flutterEchoBool(pigeonInstance: pigeonInstance, aBool: aBool) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoInt(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64,
        completion: @escaping (Result<Int64, Error>) -> Void
      ) {
        pigeonApi.flutterEchoInt(pigeonInstance: pigeonInstance, anInt: anInt) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoDouble(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aDouble: Double,
        completion: @escaping (Result<Double, Error>) -> Void
      ) {
        pigeonApi.flutterEchoDouble(pigeonInstance: pigeonInstance, aDouble: aDouble) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoString(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aString: String,
        completion: @escaping (Result<String, Error>) -> Void
      ) {
        pigeonApi.flutterEchoString(pigeonInstance: pigeonInstance, aString: aString) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoUint8List(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData,
        completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
      ) {
        pigeonApi.flutterEchoUint8List(pigeonInstance: pigeonInstance, aList: aUint8List) {
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
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aList: [Any?],
        completion: @escaping (Result<[Any?], Error>) -> Void
      ) {
        pigeonApi.flutterEchoList(pigeonInstance: pigeonInstance, aList: aList) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoProxyApiList(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aList: [ProxyApiTestClass?],
        completion: @escaping (Result<[ProxyApiTestClass?], Error>) -> Void
      ) {
        pigeonApi.flutterEchoProxyApiList(pigeonInstance: pigeonInstance, aList: aList) {
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
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aMap: [String?: Any?], completion: @escaping (Result<[String?: Any?], Error>) -> Void
      ) {
        pigeonApi.flutterEchoMap(pigeonInstance: pigeonInstance, aMap: aMap) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoProxyApiMap(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aMap: [String?: ProxyApiTestClass?],
        completion: @escaping (Result<[String?: ProxyApiTestClass?], Error>) -> Void
      ) {
        pigeonApi.flutterEchoProxyApiMap(pigeonInstance: pigeonInstance, aMap: aMap) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoEnum(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum, completion: @escaping (Result<ProxyApiTestEnum, Error>) -> Void
      ) {
        pigeonApi.flutterEchoEnum(pigeonInstance: pigeonInstance, anEnum: anEnum) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoProxyApi(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aProxyApi: ProxyApiSuperClass,
        completion: @escaping (Result<ProxyApiSuperClass, Error>) -> Void
      ) {
        pigeonApi.flutterEchoProxyApi(pigeonInstance: pigeonInstance, aProxyApi: aProxyApi) {
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
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool?,
        completion: @escaping (Result<Bool?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableBool(pigeonInstance: pigeonInstance, aBool: aBool) {
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
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, anInt: Int64?,
        completion: @escaping (Result<Int64?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableInt(pigeonInstance: pigeonInstance, anInt: anInt) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoNullableDouble(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aDouble: Double?,
        completion: @escaping (Result<Double?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableDouble(pigeonInstance: pigeonInstance, aDouble: aDouble) {
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
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aString: String?,
        completion: @escaping (Result<String?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableString(pigeonInstance: pigeonInstance, aString: aString) {
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
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aUint8List: FlutterStandardTypedData?,
        completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableUint8List(pigeonInstance: pigeonInstance, aList: aUint8List) {
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
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aList: [Any?]?,
        completion: @escaping (Result<[Any?]?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableList(pigeonInstance: pigeonInstance, aList: aList) {
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
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aMap: [String?: Any?]?, completion: @escaping (Result<[String?: Any?]?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableMap(pigeonInstance: pigeonInstance, aMap: aMap) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoNullableEnum(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        anEnum: ProxyApiTestEnum?, completion: @escaping (Result<ProxyApiTestEnum?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableEnum(pigeonInstance: pigeonInstance, anEnum: anEnum) {
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
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        aProxyApi: ProxyApiSuperClass?,
        completion: @escaping (Result<ProxyApiSuperClass?, Error>) -> Void
      ) {
        pigeonApi.flutterEchoNullableProxyApi(pigeonInstance: pigeonInstance, aProxyApi: aProxyApi)
        { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterNoopAsync(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass,
        completion: @escaping (Result<Void, Error>) -> Void
      ) {
        pigeonApi.flutterNoopAsync(pigeonInstance: pigeonInstance) { response in
          switch response {
          case .success(let res):
            completion(.success(res))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }

      public func callFlutterEchoAsyncString(
        pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aString: String,
        completion: @escaping (Result<String, Error>) -> Void
      ) {
        pigeonApi.flutterEchoAsyncString(pigeonInstance: pigeonInstance, aString: aString) {
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
    return PigeonApiProxyApiTestClass(
      pigeonRegistrar: registrar, delegate: ProxyApiTestClassDelegate())
  }

  public func pigeonApiProxyApiSuperClass(_ registrar: ProxyApiTestsPigeonProxyApiRegistrar)
    -> PigeonApiProxyApiSuperClass
  {
    class ProxyApiSuperClassDelegate: PigeonApiDelegateProxyApiSuperClass {
      public func pigeonDefaultConstructor(pigeonApi: PigeonApiProxyApiSuperClass) throws
        -> ProxyApiSuperClass
      {
        return ProxyApiSuperClass()
      }

      public func aSuperMethod(
        pigeonApi: PigeonApiProxyApiSuperClass, pigeonInstance: ProxyApiSuperClass
      )
        throws
      {}
    }
    return PigeonApiProxyApiSuperClass(
      pigeonRegistrar: registrar, delegate: ProxyApiSuperClassDelegate())
  }

  public func pigeonApiProxyApiInterface(_ registrar: ProxyApiTestsPigeonProxyApiRegistrar)
    -> PigeonApiProxyApiInterface
  {
    class ProxyApiInterfaceDelegate: PigeonApiDelegateProxyApiInterface {}
    return PigeonApiProxyApiInterface(
      pigeonRegistrar: registrar, delegate: ProxyApiInterfaceDelegate())
  }

  public func pigeonApiClassWithApiRequirement(_ registrar: ProxyApiTestsPigeonProxyApiRegistrar)
    -> PigeonApiClassWithApiRequirement
  {
    class ClassWithApiRequirementDelegate: PigeonApiDelegateClassWithApiRequirement {
      @available(iOS 15, macOS 10, *)
      public func pigeonDefaultConstructor(pigeonApi: PigeonApiClassWithApiRequirement) throws
        -> ClassWithApiRequirement
      {
        return ClassWithApiRequirement()
      }

      @available(iOS 15, macOS 10, *)
      public func aMethod(
        pigeonApi: PigeonApiClassWithApiRequirement, pigeonInstance: ClassWithApiRequirement
      ) throws {}
    }

    return PigeonApiClassWithApiRequirement(
      pigeonRegistrar: registrar, delegate: ClassWithApiRequirementDelegate())
  }
}
