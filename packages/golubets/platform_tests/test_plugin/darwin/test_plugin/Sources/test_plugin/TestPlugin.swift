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
public class TestPlugin: NSObject, FlutterPlugin, HostIntegrationCoreApi, HostCallbackCoreApi,
  SealedClassApi, HostGenericApi
{
  var flutterAPI: FlutterIntegrationCoreApi
  var flutterCallbackAPI: FlutterCallbackCoreApi
  var flutterSmallApiOne: FlutterSmallApi
  var flutterSmallApiTwo: FlutterSmallApi
  var proxyApiRegistrar: ProxyApiTestsGolubetsProxyApiRegistrar?
  var flutterGenericApi: FlutterGenericApi?

  public static func register(with registrar: FlutterPluginRegistrar) {
    // Workaround for https://github.com/flutter/flutter/issues/118103.
    #if os(iOS)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif
    let plugin = TestPlugin(binaryMessenger: messenger)
    HostIntegrationCoreApiSetup.setUp(binaryMessenger: messenger, api: plugin)
    HostCallbackCoreApiSetup.setUp(binaryMessenger: messenger, api: plugin)
    TestPluginWithSuffix.register(with: registrar, suffix: "suffixOne")
    TestPluginWithSuffix.register(with: registrar, suffix: "suffixTwo")
    SealedClassApiSetup.setUp(binaryMessenger: messenger, api: plugin)
    HostGenericApiSetup.setUp(binaryMessenger: messenger, api: plugin)
    registrar.publish(plugin)
  }

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterAPI = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)
    flutterCallbackAPI = FlutterCallbackCoreApi(binaryMessenger: binaryMessenger)
    flutterSmallApiOne = FlutterSmallApi(
      binaryMessenger: binaryMessenger, messageChannelSuffix: "suffixOne")
    flutterSmallApiTwo = FlutterSmallApi(
      binaryMessenger: binaryMessenger, messageChannelSuffix: "suffixTwo")
    flutterGenericApi = FlutterGenericApi(binaryMessenger: binaryMessenger)

    StreamIntsStreamHandler.register(with: binaryMessenger, streamHandler: SendInts())
    StreamEventsStreamHandler.register(with: binaryMessenger, streamHandler: SendEvents())
    StreamConsistentNumbersStreamHandler.register(
      with: binaryMessenger, instanceName: "1",
      streamHandler: SendConsistentNumbers(numberToSend: 1))
    StreamConsistentNumbersStreamHandler.register(
      with: binaryMessenger, instanceName: "2",
      streamHandler: SendConsistentNumbers(numberToSend: 2))
    proxyApiRegistrar = ProxyApiTestsGolubetsProxyApiRegistrar(
      binaryMessenger: binaryMessenger, apiDelegate: ProxyApiDelegate())
    proxyApiRegistrar!.setUp()
    NativeInteropHostIntegrationCoreApiSetup.register(api: NativeInteropTestsClass())
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    proxyApiRegistrar!.tearDown()
    proxyApiRegistrar = nil
  }

  // MARK: HostCallbackCoreApi implementation

  public func noop(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.success(()))
  }

  public func echo(_ aString: String, completion: @escaping (Result<String, Error>) -> Void) {
    completion(.success(aString))
  }

  public func echo(
    _ everything: AllTypes, completion: @escaping (Result<AllTypes, Error>) -> Void
  ) {
    completion(.success(everything))
  }

  public func echoNullable(
    _ aString: String?, completion: @escaping (Result<String?, Error>) -> Void
  ) {
    completion(.success(aString))
  }

  public func throwError(completion: @escaping (Result<Any?, Error>) -> Void) {
    completion(.failure(GolubetsError(code: "code", message: "message", details: "details")))
  }

  public func throwErrorFromVoid(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(GolubetsError(code: "code", message: "message", details: "details")))
  }

  public func taskQueueIsBackgroundThread(completion: @escaping (Result<Bool, Error>) -> Void) {
    completion(.success(!Thread.isMainThread))
  }

  // MARK: HostIntegrationCoreApi implementation

  public func noop() {}

  public func echo(_ everything: AllTypes) -> AllTypes {
    return everything
  }

  public func echo(_ everything: AllNullableTypes?) -> AllNullableTypes? {
    return everything
  }

  public func areAllNullableTypesEqual(a: AllNullableTypes, b: AllNullableTypes) -> Bool {
    return a == b
  }

  public func getAllNullableTypesHash(value: AllNullableTypes) -> Int64 {
    var hasher = Hasher()
    value.hash(into: &hasher)
    return Int64(hasher.finalize())
  }

  public func getAllNullableTypesWithoutRecursionHash(value: AllNullableTypesWithoutRecursion)
    -> Int64
  {
    var hasher = Hasher()
    value.hash(into: &hasher)
    return Int64(hasher.finalize())
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
    throw GolubetsError(code: "code", message: "message", details: "details")
  }

  public func echoModernAsyncNullableAllNullableTypes(_ everything: AllNullableTypes?) async
    -> AllNullableTypes?
  {
    return everything
  }

  public func throwError() throws -> Any? {
    throw GolubetsError(code: "code", message: "message", details: "details")
  }

  public func throwErrorFromVoid() throws {
    throw GolubetsError(code: "code", message: "message", details: "details")
  }

  public func throwFlutterError() throws -> Any? {
    throw GolubetsError(code: "code", message: "message", details: "details")
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

  public func echo(stringList: [String?]) throws -> [String?] {
    return stringList
  }

  public func echo(intList: [Int64?]) throws -> [Int64?] {
    return intList
  }

  public func echo(doubleList: [Double?]) throws -> [Double?] {
    return doubleList
  }

  public func echo(boolList: [Bool?]) throws -> [Bool?] {
    return boolList
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
    completion(.failure(GolubetsError(code: "code", message: "message", details: "details")))
  }

  public func throwAsyncErrorFromVoid(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(GolubetsError(code: "code", message: "message", details: "details")))
  }

  public func throwAsyncFlutterError(completion: @escaping (Result<Any?, Error>) -> Void) {
    completion(.failure(GolubetsError(code: "code", message: "message", details: "details")))
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

  public func asyncTaskQueueIsBackgroundThread(
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    completion(.success(!Thread.isMainThread))
  }

  public func callFlutterCallbackNoop(completion: @escaping (Result<Void, Error>) -> Void) {
    flutterCallbackAPI.noop { completion($0.mapError { $0 }) }
  }

  public func callFlutterCallbackEcho(
    _ aString: String, completion: @escaping (Result<String, Error>) -> Void
  ) {
    flutterCallbackAPI.echo(string: aString) { completion($0.mapError { $0 }) }
  }

  public func callFlutterCallbackThrowError(completion: @escaping (Result<Any?, Error>) -> Void) {
    flutterCallbackAPI.throwError { completion($0.mapError { $0 }) }
  }

  public func callFlutterCallbackThrowErrorFromVoid(
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    flutterCallbackAPI.throwErrorFromVoid { completion($0.mapError { $0 }) }
  }

  public func callFlutterIsAsyncFlutterApiOnRoot(
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    flutterAPI.isAsyncFlutterApiOnRoot { completion($0.mapError { $0 }) }
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
                  GolubetsError(
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

  // MARK: - HostGenericApi implementation

  public func echoGenericInt(container: GenericContainer<Int64>) throws -> GenericContainer<Int64> {
    return container
  }

  public func echoGenericString(container: GenericContainer<String>) throws -> GenericContainer<
    String
  > {
    return container
  }

  public func echoGenericDouble(container: GenericContainer<Double>) throws -> GenericContainer<
    Double
  > {
    return container
  }

  public func echoGenericBool(container: GenericContainer<Bool>) throws -> GenericContainer<Bool> {
    return container
  }

  public func echoGenericEnum(container: GenericContainer<GenericsAnEnum>) throws
    -> GenericContainer<GenericsAnEnum>
  {
    return container
  }

  public func echoGenericNullableInt(container: GenericContainer<Int64?>) throws
    -> GenericContainer<Int64?>
  {
    return container
  }

  public func echoGenericNullableString(container: GenericContainer<String?>) throws
    -> GenericContainer<String?>
  {
    return container
  }

  public func echoGenericPairStringInt(pair: GenericPair<String, Int64>) throws -> GenericPair<
    String, Int64
  > {
    return pair
  }

  public func echoGenericPairIntString(pair: GenericPair<Int64, String>) throws -> GenericPair<
    Int64, String
  > {
    return pair
  }

  public func echoGenericPairDoubleBool(pair: GenericPair<Double, Bool>) throws -> GenericPair<
    Double, Bool
  > {
    return pair
  }

  public func echoGenericContainerAllTypes(container: GenericContainer<GenericsAllTypes>) throws
    -> GenericContainer<GenericsAllTypes>
  {
    return container
  }

  public func echoGenericPairClasses(pair: GenericPair<GenericsAllTypes, GenericsAllNullableTypes>)
    throws -> GenericPair<GenericsAllTypes, GenericsAllNullableTypes>
  {
    return pair
  }

  public func echoFlutterReturnEitherGenericEnumOrListStringContainer(
    arg: Either<GenericsAnEnum, [SimpleStringContainer]>
  )
    throws -> Either<GenericsAnEnum, [SimpleStringContainer]>
  {
    return arg
  }

  public func echoNestedGenericStringIntDouble(nested: NestedGeneric<String, Int64, Double>) throws
    -> NestedGeneric<String, Int64, Double>
  {
    return nested
  }

  public func echoNestedGenericWithClasses(nested: NestedGeneric<GenericsAllTypes, String, Int64>)
    throws -> NestedGeneric<GenericsAllTypes, String, Int64>
  {
    return nested
  }

  public func echoListGenericContainer(list: [GenericContainer<Int64>]) throws -> [GenericContainer<
    Int64
  >] {
    return list
  }

  public func echoListGenericPair(list: [GenericPair<String, Int64>]) throws -> [GenericPair<
    String, Int64
  >] {
    return list
  }

  public func echoMapGenericContainer(map: [String: GenericContainer<Int64>]) throws -> [String:
    GenericContainer<Int64>]
  {
    return map
  }

  public func echoGenericDefaults(defaults: GenericDefaults) throws -> GenericDefaults {
    return defaults
  }

  public func echoMapGenericPair(map: [Int64: GenericPair<String, Double>]) throws -> [Int64:
    GenericPair<String, Double>]
  {
    return map
  }

  public func echoAsyncGenericInt(
    container: GenericContainer<Int64>,
    completion: @escaping (Result<GenericContainer<Int64>, Error>) -> Void
  ) {
    completion(.success(container))
  }

  public func echoAsyncNestedGeneric(
    nested: NestedGeneric<String, Int64, Double>,
    completion: @escaping (Result<NestedGeneric<String, Int64, Double>, Error>) -> Void
  ) {
    completion(.success(nested))
  }

  public func echoEitherGenericIntOrString(
    input: Either<GenericContainer<Int64>, GenericContainer<String>>
  ) throws -> Either<GenericContainer<Int64>, GenericContainer<String>> {
    return input
  }

  public func echoEitherGenericPairStringIntOrIntString(
    input: Either<GenericPair<String, Int64>, GenericPair<Int64, String>>
  ) throws -> Either<GenericPair<String, Int64>, GenericPair<Int64, String>> {
    return input
  }

  public func echoEitherNestedGenericStringIntDoubleOrClasses(
    input: Either<
      NestedGeneric<String, Int64, Double>, NestedGeneric<GenericsAllTypes, String, Int64>
    >
  ) throws -> Either<
    NestedGeneric<String, Int64, Double>, NestedGeneric<GenericsAllTypes, String, Int64>
  > {
    return input
  }

  // MARK: GenericsAllNullableTypesTyped echo methods implementation

  public func echoTypedNullableStringIntDouble(
    typed: GenericsAllNullableTypesTyped<String, Int64, Double>
  ) throws -> GenericsAllNullableTypesTyped<String, Int64, Double> {
    return typed
  }

  public func echoTypedNullableIntStringBool(
    typed: GenericsAllNullableTypesTyped<Int64, String, Bool>
  ) throws -> GenericsAllNullableTypesTyped<Int64, String, Bool> {
    return typed
  }

  public func echoTypedNullableEnumDoubleString(
    typed: GenericsAllNullableTypesTyped<GenericsAnEnum, Double, String>
  ) throws -> GenericsAllNullableTypesTyped<GenericsAnEnum, Double, String> {
    return typed
  }

  public func echoGenericContainerTypedNullable(
    container: GenericContainer<GenericsAllNullableTypesTyped<String, Int64, Double>>
  ) throws -> GenericContainer<GenericsAllNullableTypesTyped<String, Int64, Double>> {
    return container
  }

  public func echoGenericPairTypedNullable(
    pair: GenericPair<
      GenericsAllNullableTypesTyped<String, Int64, Double>,
      GenericsAllNullableTypesTyped<Int64, String, Bool>
    >
  ) throws -> GenericPair<
    GenericsAllNullableTypesTyped<String, Int64, Double>,
    GenericsAllNullableTypesTyped<Int64, String, Bool>
  > {
    return pair
  }

  public func echoListTypedNullable(
    list: [GenericsAllNullableTypesTyped<String, Int64, Double>]
  ) throws -> [GenericsAllNullableTypesTyped<String, Int64, Double>] {
    return list
  }

  public func echoMapTypedNullable(
    map: [String: GenericsAllNullableTypesTyped<Int64, String, Double>]
  ) throws -> [String: GenericsAllNullableTypesTyped<Int64, String, Double>] {
    return map
  }

  public func echoAsyncTypedNullableStringIntDouble(
    typed: GenericsAllNullableTypesTyped<String, Int64, Double>,
    completion:
      @escaping (Result<GenericsAllNullableTypesTyped<String, Int64, Double>, any Error>)
      -> Void
  ) {
    completion(.success(typed))
  }

  public func echoAsyncGenericContainerTypedNullable(
    container: GenericContainer<GenericsAllNullableTypesTyped<String, Int64, Double>>,
    completion:
      @escaping (
        Result<GenericContainer<GenericsAllNullableTypesTyped<String, Int64, Double>>, any Error>
      ) -> Void
  ) {
    completion(.success(container))
  }

  public func echoAsyncGenericDefaults(
    defaults: GenericDefaults, completion: @escaping (Result<GenericDefaults, any Error>) -> Void
  ) {
    completion(.success(defaults))
  }

  public func returnGenericDefaults() throws -> GenericDefaults {
    return GenericDefaults(
      genericInt: GenericContainer<Int64>(
        value: 42,
        values: [1, 2, 3]
      ),
      genericString: GenericContainer<String>(
        value: "default",
        values: ["a", "b", "c"]
      ),
      genericDouble: GenericContainer<Double>(
        value: 3.14,
        values: [1.0, 2.0, 3.0]
      ),
      genericBool: GenericContainer<Bool>(
        value: true,
        values: [true, false, true]
      ),
      genericPairStringInt: GenericPair<String, Int64>(
        first: "default",
        second: 42,
        map: ["key1": 1, "key2": 2]
      ),
      genericPairIntString: GenericPair<Int64, String>(
        first: 100,
        second: "value",
        map: [1: "one", 2: "two"]
      ),
      nestedGenericDefault: NestedGeneric<String, Int64, Double>(
        container: GenericContainer<String>(
          value: "nested",
          values: ["x", "y", "z"]
        ),
        pairs: [
          GenericPair<Int64, Double>(
            first: 1,
            second: 1.1,
            map: [1: 1.1, 2: 2.2]
          )
        ],
        nestedMap: [
          "nested": GenericContainer<Int64>(
            value: 99,
            values: [9, 8, 7]
          )
        ],
        listOfMaps: [
          [10: 10.0, 20: 20.0]
        ]
      ),
      genericPairEither: GenericPair<Int64, Either<String, Int64>>(
        first: 1,
        second: .right(value: 2),
        map: [
          3: .right(value: 4),
          4: .left(value: "hello"),
        ]
      ))
  }

  public func echoAsyncGenericDefaults(defaults: GenericDefaults) async throws -> GenericDefaults {
    return defaults
  }

  public func callFlutterEchoGenericContainerTypedNullable(
    container: GenericContainer<GenericsAllNullableTypesTyped<String, Int64, Double>>,
    completion:
      @escaping (
        Result<GenericContainer<GenericsAllNullableTypesTyped<String, Int64, Double>>, any Error>
      ) -> Void
  ) {
    flutterGenericApi!.echoGenericContainerTypedNullable(container: container) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoGenericDefaults(
    defaults: GenericDefaults, completion: @escaping (Result<GenericDefaults, any Error>) -> Void
  ) {
    flutterGenericApi!.echoGenericDefaults(defaults: defaults) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoGenericDefaultsInt(
    defaults: GenericDefaults,
    completion: @escaping (Result<GenericContainer<Int64>, any Error>) -> Void
  ) {
    flutterGenericApi!.echoGenericDefaultsInt(defaults: defaults) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoGenericDefaultsNested(
    defaults: GenericDefaults,
    completion: @escaping (Result<NestedGeneric<String, Int64, Double>, any Error>) -> Void
  ) {
    flutterGenericApi!.echoGenericDefaultsNested(defaults: defaults) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoGenericDefaultsPairEither(
    defaults: GenericDefaults,
    completion: @escaping (Result<GenericPair<Int64, Either<String, Int64>>, any Error>) -> Void
  ) {
    flutterGenericApi!.echoGenericDefaultsPairEither(defaults: defaults) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoGenericInt(
    container: GenericContainer<Int64>,
    completion: @escaping (Result<GenericContainer<Int64>, any Error>) -> Void
  ) {
    flutterGenericApi!.echoGenericInt(container: container) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoGenericPairStringInt(
    pair: GenericPair<String, Int64>,
    completion: @escaping (Result<GenericPair<String, Int64>, any Error>) -> Void
  ) {
    flutterGenericApi!.echoGenericPairStringInt(pair: pair) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoGenericString(
    container: GenericContainer<String>,
    completion: @escaping (Result<GenericContainer<String>, any Error>) -> Void
  ) {
    flutterGenericApi!.echoGenericString(container: container) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoListGenericContainer(
    list: [GenericContainer<Int64>],
    completion: @escaping (Result<[GenericContainer<Int64>], any Error>) -> Void
  ) {
    flutterGenericApi!.echoListGenericContainer(list: list) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoListTypedNullable(
    list: [GenericsAllNullableTypesTyped<String, Int64, Double>],
    completion:
      @escaping (
        Result<[GenericsAllNullableTypesTyped<String, Int64, Double>], any Error>
      ) -> Void
  ) {
    flutterGenericApi!.echoListTypedNullable(list: list) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoMapGenericContainer(
    map: [String: GenericContainer<Int64>],
    completion: @escaping (Result<[String: GenericContainer<Int64>], any Error>) -> Void
  ) {
    flutterGenericApi!.echoMapGenericContainer(map: map) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoMapTypedNullable(
    map: [String: GenericsAllNullableTypesTyped<Int64, String, Double>],
    completion:
      @escaping (
        Result<[String: GenericsAllNullableTypesTyped<Int64, String, Double>], any Error>
      ) -> Void
  ) {
    flutterGenericApi!.echoMapTypedNullable(map: map) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNestedGenericStringIntDouble(
    nested: NestedGeneric<String, Int64, Double>,
    completion: @escaping (Result<NestedGeneric<String, Int64, Double>, any Error>) -> Void
  ) {
    flutterGenericApi!.echoNestedGenericStringIntDouble(nested: nested) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoTypedNullableIntStringBool(
    typed: GenericsAllNullableTypesTyped<Int64, String, Bool>,
    completion:
      @escaping (Result<GenericsAllNullableTypesTyped<Int64, String, Bool>, any Error>) ->
      Void
  ) {
    flutterGenericApi!.echoTypedNullableIntStringBool(typed: typed) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoTypedNullableStringIntDouble(
    typed: GenericsAllNullableTypesTyped<String, Int64, Double>,
    completion:
      @escaping (Result<GenericsAllNullableTypesTyped<String, Int64, Double>, any Error>)
      -> Void
  ) {
    flutterGenericApi!.echoTypedNullableStringIntDouble(typed: typed) { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterReturnGenericDefaultsEitherLeft(
    completion: @escaping (Result<GenericContainer<Either<String, Int64>>, any Error>) -> Void
  ) {
    flutterGenericApi!.returnGenericDefaultsEitherLeft { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterReturnGenericDefaultsEitherRight(
    completion: @escaping (Result<GenericContainer<Either<String, Int64>>, any Error>) -> Void
  ) {

    flutterGenericApi!.returnGenericDefaultsEitherRight { result in
      switch result {
      case .success(let value):
        completion(.success(value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

class NativeInteropTestsClass: NSObject, NativeInteropHostIntegrationCoreApi {
  func noop() throws {
    return
  }

  func echo(_ everything: NativeInteropAllTypes) throws -> NativeInteropAllTypes {
    return everything
  }

  func throwError() throws -> Any? {
    throw NativeInteropTestsError(code: "code", message: "message", details: "details")
  }

  func throwErrorFromVoid() throws {
    throw NativeInteropTestsError(code: "code", message: "message", details: "details")
  }

  func throwFlutterError() throws -> Any? {
    throw NativeInteropTestsError(code: "code", message: "message", details: "details")
  }

  func echo(_ anInt: Int64) throws -> Int64 {
    return anInt
  }

  func echo(_ aDouble: Double) throws -> Double {
    return aDouble
  }

  func echo(_ aBool: Bool) throws -> Bool {
    return aBool
  }

  func echo(_ aString: String) throws -> String {
    return aString
  }

  func echo(_ aUint8List: [UInt8]) throws -> [UInt8] {
    return aUint8List
  }

  func echo(_ aInt32List: [Int32]) throws -> [Int32] {
    return aInt32List
  }

  func echo(_ aInt64List: [Int64]) throws -> [Int64] {
    return aInt64List
  }

  func echo(_ aFloat64List: [Float64]) throws -> [Float64] {
    return aFloat64List
  }

  func echo(_ anObject: Any) throws -> Any {
    return anObject
  }

  func echo(_ list: [Any?]) throws -> [Any?] {
    return list
  }

  func echo(_ map: [AnyHashable?: Any?]) throws -> [AnyHashable?: Any?] {
    return map
  }

  func echo(stringMap: [String?: String?]) throws -> [String?: String?] {
    return stringMap
  }

  func echo(intMap: [Int64?: Int64?]) throws -> [Int64?: Int64?] {
    return intMap
  }

  func echo(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?]) throws -> [NativeInteropAnEnum?:
    NativeInteropAnEnum?]
  {
    return enumMap
  }

  func echo(classMap: [Int64?: NativeInteropAllNullableTypes?]) throws -> [Int64?:
    NativeInteropAllNullableTypes?]
  {
    return classMap
  }

  func echo(_ anEnum: NativeInteropAnEnum) throws -> NativeInteropAnEnum {
    return anEnum
  }

  func echo(_ anotherEnum: NativeInteropAnotherEnum) throws -> NativeInteropAnotherEnum {
    return anotherEnum
  }

  func echoNamedDefault(_ aString: String) throws -> String {
    return aString
  }

  func echoOptionalDefault(_ aDouble: Double) throws -> Double {
    return aDouble
  }

  func echoRequired(_ anInt: Int64) throws -> Int64 {
    return anInt
  }

  func echoOptional(_ aNullableInt: Int64?) throws -> Int64? {
    return aNullableInt
  }

  func echoNamed(_ aNullableString: String?) throws -> String? {
    return aNullableString
  }

  func echoNonNull(enumList: [NativeInteropAnEnum]) throws -> [NativeInteropAnEnum] {
    return enumList
  }

  func echoNonNull(classList: [NativeInteropAllNullableTypes]) throws
    -> [NativeInteropAllNullableTypes]
  {
    return classList
  }

  func echoNonNull(stringMap: [String: String]) throws -> [String: String] {
    return stringMap
  }

  func echoNonNull(intMap: [Int64: Int64]) throws -> [Int64: Int64] {
    return intMap
  }

  func echoNonNull(enumMap: [NativeInteropAnEnum: NativeInteropAnEnum]) throws
    -> [NativeInteropAnEnum: NativeInteropAnEnum]
  {
    return enumMap
  }

  func echoNonNull(classMap: [Int64: NativeInteropAllNullableTypes]) throws -> [Int64:
    NativeInteropAllNullableTypes]
  {
    return classMap
  }

  func echoNullable(_ everything: NativeInteropAllNullableTypes?) throws
    -> NativeInteropAllNullableTypes?
  {
    return everything
  }

  func echoNullable(_ aNullableUint8List: [UInt8]?) throws -> [UInt8]? {
    return aNullableUint8List
  }

  func echoNullable(_ aNullableInt32List: [Int32]?) throws -> [Int32]? {
    return aNullableInt32List
  }

  func echoNullable(_ aNullableInt64List: [Int64]?) throws -> [Int64]? {
    return aNullableInt64List
  }

  func echoNullable(_ aNullableFloat64List: [Float64]?) throws -> [Float64]? {
    return aNullableFloat64List
  }

  func echoNullable(_ aNullableObject: Any?) throws -> Any? {
    // Return boxed NSNumber instances to test NSNumber/CFBoolean/CFNumber bridging across FFI.
    if let boolValue = aNullableObject as? Bool {
      return NSNumber(value: boolValue)
    }
    if let doubleValue = aNullableObject as? Double {
      return NSNumber(value: doubleValue)
    }
    if let intValue = aNullableObject as? Int64 {
      return NSNumber(value: intValue)
    }
    return aNullableObject
  }

  func echoNullable(_ aNullableList: [Any?]?) throws -> [Any?]? {
    return aNullableList
  }

  func echoNullable(enumList: [NativeInteropAnEnum?]?) throws -> [NativeInteropAnEnum?]? {
    return enumList
  }

  func echoNullable(classList: [NativeInteropAllNullableTypes?]?) throws
    -> [NativeInteropAllNullableTypes?]?
  {
    return classList
  }

  func echoNullable(stringMap: [String?: String?]?) throws -> [String?: String?]? {
    return stringMap
  }

  func echoNullable(intMap: [Int64?: Int64?]?) throws -> [Int64?: Int64?]? {
    return intMap
  }

  func echoNullable(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?]?) throws
    -> [NativeInteropAnEnum?: NativeInteropAnEnum?]?
  {
    return enumMap
  }

  func echoNullable(classMap: [Int64?: NativeInteropAllNullableTypes?]?) throws -> [Int64?:
    NativeInteropAllNullableTypes?]?
  {
    return classMap
  }

  func echoNullable(_ anEnum: NativeInteropAnEnum?) throws -> NativeInteropAnEnum? {
    return anEnum
  }

  func echoNullable(_ anotherEnum: NativeInteropAnotherEnum?) throws -> NativeInteropAnotherEnum? {
    return anotherEnum
  }

  func echoNullableNonNull(enumList: [NativeInteropAnEnum]?) throws -> [NativeInteropAnEnum]? {
    return enumList
  }

  func echoNullableNonNull(classList: [NativeInteropAllNullableTypes]?) throws
    -> [NativeInteropAllNullableTypes]?
  {
    return classList
  }

  func echoNullable(_ map: [AnyHashable?: Any?]?) throws -> [AnyHashable?: Any?]? {
    return map
  }

  func echoNullableNonNull(stringMap: [String: String]?) throws -> [String: String]? {
    return stringMap
  }

  func echoNullableNonNull(intMap: [Int64: Int64]?) throws -> [Int64: Int64]? {
    return intMap
  }

  func echoNullableNonNull(enumMap: [NativeInteropAnEnum: NativeInteropAnEnum]?) throws
    -> [NativeInteropAnEnum: NativeInteropAnEnum]?
  {
    return enumMap
  }

  func echoNullableNonNull(classMap: [Int64: NativeInteropAllNullableTypes]?) throws -> [Int64:
    NativeInteropAllNullableTypes]?
  {
    return classMap
  }

  func extractNestedNullableString(from wrapper: NativeInteropAllClassesWrapper) throws -> String? {
    return wrapper.allNullableTypes.aNullableString
  }

  func createNestedObject(with nullableString: String?) throws -> NativeInteropAllClassesWrapper {
    return NativeInteropAllClassesWrapper(
      allNullableTypes: .init(aNullableString: nullableString), classList: [],
      classMap: [:])
  }

  func sendMultipleNullableTypes(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) throws -> NativeInteropAllNullableTypes {
    return NativeInteropAllNullableTypes(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
  }

  func sendMultipleNullableTypesWithoutRecursion(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) throws -> NativeInteropAllNullableTypesWithoutRecursion {
    return NativeInteropAllNullableTypesWithoutRecursion(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
  }

  func echoAsync(_ aUint8List: [UInt8]) async throws -> [UInt8] {
    return aUint8List
  }

  func echoAsync(_ aInt32List: [Int32]) async throws -> [Int32] {
    return aInt32List
  }

  func echoAsync(_ aInt64List: [Int64]) async throws -> [Int64] {
    return aInt64List
  }

  func echoAsync(_ aFloat64List: [Float64]) async throws -> [Float64] {
    return aFloat64List
  }

  func echoAsync(_ anObject: Any) async throws -> Any {
    return anObject
  }

  func echoAsync(_ list: [Any?]) async throws -> [Any?] {
    return list
  }

  func echoAsync(enumList: [NativeInteropAnEnum?]) async throws -> [NativeInteropAnEnum?] {
    return enumList
  }

  func echoAsync(classList: [NativeInteropAllNullableTypes?]) async throws
    -> [NativeInteropAllNullableTypes?]
  {
    return classList
  }

  func echoAsync(_ map: [AnyHashable?: Any?]) async throws -> [AnyHashable?: Any?] {
    return map
  }

  func echoAsync(stringMap: [String?: String?]) async throws -> [String?: String?] {
    return stringMap
  }

  func echoAsync(intMap: [Int64?: Int64?]) async throws -> [Int64?: Int64?] {
    return intMap
  }

  func echoAsync(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?]) async throws
    -> [NativeInteropAnEnum?: NativeInteropAnEnum?]
  {
    return enumMap
  }

  func echoAsync(classMap: [Int64?: NativeInteropAllNullableTypes?]) async throws -> [Int64?:
    NativeInteropAllNullableTypes?]
  {
    return classMap
  }

  func echoAsync(_ anEnum: NativeInteropAnEnum) async throws -> NativeInteropAnEnum {
    return anEnum
  }

  func echoAsync(_ anotherEnum: NativeInteropAnotherEnum) async throws -> NativeInteropAnotherEnum {
    return anotherEnum
  }

  func throwAsyncError() async throws -> Any? {
    throw NativeInteropTestsError(code: "code", message: "message", details: "details")
  }

  func throwAsyncErrorFromVoid() async throws {
    throw NativeInteropTestsError(code: "code", message: "message", details: "details")
  }

  func throwAsyncFlutterError() async throws -> Any? {
    throw NativeInteropTestsError(code: "code", message: "message", details: "details")
  }

  func echoAsync(_ everything: NativeInteropAllTypes) async throws -> NativeInteropAllTypes {
    return everything
  }

  func echoAsync(_ everything: NativeInteropAllNullableTypes?) async throws
    -> NativeInteropAllNullableTypes?
  {
    return everything
  }

  func echoAsync(_ everything: NativeInteropAllNullableTypesWithoutRecursion?) async throws
    -> NativeInteropAllNullableTypesWithoutRecursion?
  {
    return everything
  }

  func echoAsyncNullable(_ anInt: Int64?) async throws -> Int64? {
    return anInt
  }

  func echoAsyncNullable(_ aDouble: Double?) async throws -> Double? {
    return aDouble
  }

  func echoAsyncNullable(_ aBool: Bool?) async throws -> Bool? {
    return aBool
  }

  func echoAsyncNullable(_ aString: String?) async throws -> String? {
    return aString
  }

  func echoAsyncNullable(_ aUint8List: [UInt8]?) async throws -> [UInt8]? {
    return aUint8List
  }

  func echoAsyncNullable(_ aInt32List: [Int32]?) async throws -> [Int32]? {
    return aInt32List
  }

  func echoAsyncNullable(_ aInt64List: [Int64]?) async throws -> [Int64]? {
    return aInt64List
  }

  func echoAsyncNullable(_ aFloat64List: [Float64]?) async throws -> [Float64]? {
    return aFloat64List
  }

  func echoAsyncNullable(_ anObject: Any?) async throws -> Any? {
    return anObject
  }

  func echoAsyncNullable(_ list: [Any?]?) async throws -> [Any?]? {
    return list
  }

  func echoAsyncNullable(enumList: [NativeInteropAnEnum?]?) async throws -> [NativeInteropAnEnum?]?
  {
    return enumList
  }

  func echoAsyncNullable(classList: [NativeInteropAllNullableTypes?]?) async throws
    -> [NativeInteropAllNullableTypes?]?
  {
    return classList
  }

  func echoAsyncNullable(_ map: [AnyHashable?: Any?]?) async throws -> [AnyHashable?: Any?]? {
    return map
  }

  func echoAsyncNullable(stringMap: [String?: String?]?) async throws -> [String?: String?]? {
    return stringMap
  }

  func echoAsyncNullable(intMap: [Int64?: Int64?]?) async throws -> [Int64?: Int64?]? {
    return intMap
  }

  func echoAsyncNullable(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?]?) async throws
    -> [NativeInteropAnEnum?: NativeInteropAnEnum?]?
  {
    return enumMap
  }

  func echoAsyncNullable(classMap: [Int64?: NativeInteropAllNullableTypes?]?) async throws
    -> [Int64?:
    NativeInteropAllNullableTypes?]?
  {
    return classMap
  }

  func echoAsyncNullable(_ anEnum: NativeInteropAnEnum?) async throws -> NativeInteropAnEnum? {
    return anEnum
  }

  func echoAsyncNullable(_ anotherEnum: NativeInteropAnotherEnum?) async throws
    -> NativeInteropAnotherEnum?
  {
    return anotherEnum
  }

  private func getNativeInteropFlutterApi() throws -> NativeInteropFlutterIntegrationCoreApi {
    guard let flutterApi = NativeInteropFlutterIntegrationCoreApi.getInstance() else {
      throw NativeInteropTestsError(
        code: "not_registered", message: "NativeInteropFlutterIntegrationCoreApi not registered",
        details: nil)
    }
    return flutterApi
  }

  func callFlutterNoop() throws {
    let flutterApi = try getNativeInteropFlutterApi()
    try flutterApi.noop()
  }

  func callFlutterThrowError() throws -> Any? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.throwError()
  }

  func callFlutterThrowErrorFromVoid() throws {
    let flutterApi = try getNativeInteropFlutterApi()
    try flutterApi.throwErrorFromVoid()
  }

  func callFlutterEcho(_ everything: NativeInteropAllTypes) throws -> NativeInteropAllTypes {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNativeInteropAllTypes(everything: everything)
  }

  func callFlutterEcho(_ aBool: Bool) throws -> Bool {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoBool(aBool: aBool)
  }

  func callFlutterEcho(_ anInt: Int64) throws -> Int64 {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoInt(anInt: anInt)
  }

  func callFlutterEcho(_ aDouble: Double) throws -> Double {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoDouble(aDouble: aDouble)
  }

  func callFlutterEcho(_ aString: String) throws -> String {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoString(aString: aString)
  }

  func callFlutterEcho(_ list: [UInt8]) throws -> [UInt8] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoUint8List(list: list)
  }

  func callFlutterEcho(_ list: [Int32]) throws -> [Int32] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoInt32List(list: list)
  }

  func callFlutterEcho(_ list: [Int64]) throws -> [Int64] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoInt64List(list: list)
  }

  func callFlutterEcho(_ list: [Float64]) throws -> [Float64] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoFloat64List(list: list)
  }

  func callFlutterEcho(_ list: [Any?]) throws -> [Any?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoList(list: list)
  }

  func callFlutterEcho(enumList: [NativeInteropAnEnum?]) throws -> [NativeInteropAnEnum?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoEnumList(enumList: enumList)
  }

  func callFlutterEcho(classList: [NativeInteropAllNullableTypes?]) throws
    -> [NativeInteropAllNullableTypes?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoClassList(classList: classList)
  }

  func callFlutterEchoNonNull(enumList: [NativeInteropAnEnum]) throws -> [NativeInteropAnEnum] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNonNullEnumList(enumList: enumList)
  }

  func callFlutterEchoNonNull(classList: [NativeInteropAllNullableTypes]) throws
    -> [NativeInteropAllNullableTypes]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNonNullClassList(classList: classList)
  }

  func callFlutterEcho(_ map: [AnyHashable?: Any?]) throws -> [AnyHashable?: Any?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoMap(map: map)
  }

  func callFlutterEcho(stringMap: [String?: String?]) throws -> [String?: String?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoStringMap(stringMap: stringMap)
  }

  func callFlutterEcho(intMap: [Int64?: Int64?]) throws -> [Int64?: Int64?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoIntMap(intMap: intMap)
  }

  func callFlutterEcho(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?]) throws
    -> [NativeInteropAnEnum?: NativeInteropAnEnum?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoEnumMap(enumMap: enumMap)
  }

  func callFlutterEcho(classMap: [Int64?: NativeInteropAllNullableTypes?]) throws -> [Int64?:
    NativeInteropAllNullableTypes?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoClassMap(classMap: classMap)
  }

  func callFlutterEchoNonNull(stringMap: [String: String]) throws -> [String: String] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNonNullStringMap(stringMap: stringMap)
  }

  func callFlutterEchoNonNull(intMap: [Int64: Int64]) throws -> [Int64: Int64] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNonNullIntMap(intMap: intMap)
  }

  func callFlutterEchoNonNull(enumMap: [NativeInteropAnEnum: NativeInteropAnEnum]) throws
    -> [NativeInteropAnEnum: NativeInteropAnEnum]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNonNullEnumMap(enumMap: enumMap)
  }

  func callFlutterEchoNonNull(classMap: [Int64: NativeInteropAllNullableTypes]) throws -> [Int64:
    NativeInteropAllNullableTypes]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNonNullClassMap(classMap: classMap)
  }

  func callFlutterEchoNullable(_ anEnum: NativeInteropAnEnum?) throws -> NativeInteropAnEnum? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableEnum(anEnum: anEnum)
  }

  func callFlutterEchoNullable(_ anotherEnum: NativeInteropAnotherEnum?) throws
    -> NativeInteropAnotherEnum?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoAnotherNullableEnum(anotherEnum: anotherEnum)
  }

  func callFlutterEchoNullable(_ aBool: Bool?) throws -> Bool? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableBool(aBool: aBool)
  }

  func callFlutterEchoNullable(_ anInt: Int64?) throws -> Int64? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableInt(anInt: anInt)
  }

  func callFlutterEchoNullable(_ aDouble: Double?) throws -> Double? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableDouble(aDouble: aDouble)
  }

  func callFlutterEchoNullable(_ aString: String?) throws -> String? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableString(aString: aString)
  }

  func callFlutterEchoNullable(_ list: [UInt8]?) throws -> [UInt8]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableUint8List(list: list)
  }

  func callFlutterEchoNullable(_ list: [Int32]?) throws -> [Int32]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableInt32List(list: list)
  }

  func callFlutterEchoNullable(_ list: [Int64]?) throws -> [Int64]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableInt64List(list: list)
  }

  func callFlutterEchoNullable(_ list: [Float64]?) throws -> [Float64]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableFloat64List(list: list)
  }

  func callFlutterEchoNullable(_ list: [Any?]?) throws -> [Any?]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableList(list: list)
  }

  func callFlutterEchoNullable(enumList: [NativeInteropAnEnum?]?) throws -> [NativeInteropAnEnum?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableEnumList(enumList: enumList)
  }

  func callFlutterEchoNullable(classList: [NativeInteropAllNullableTypes?]?) throws
    -> [NativeInteropAllNullableTypes?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableClassList(classList: classList)
  }

  func callFlutterEchoNullableNonNull(enumList: [NativeInteropAnEnum]?) throws
    -> [NativeInteropAnEnum]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableNonNullEnumList(enumList: enumList)
  }

  func callFlutterEchoNullableNonNull(classList: [NativeInteropAllNullableTypes]?) throws
    -> [NativeInteropAllNullableTypes]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableNonNullClassList(classList: classList)
  }

  func callFlutterEchoNullable(_ map: [AnyHashable?: Any?]?) throws -> [AnyHashable?: Any?]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableMap(map: map)
  }

  func callFlutterEchoNullable(stringMap: [String?: String?]?) throws -> [String?:
    String?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableStringMap(stringMap: stringMap)
  }

  func callFlutterEchoNullable(intMap: [Int64?: Int64?]?) throws -> [Int64?: Int64?]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableIntMap(intMap: intMap)
  }

  func callFlutterEchoNullable(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?]?) throws
    -> [NativeInteropAnEnum?:
    NativeInteropAnEnum?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableEnumMap(enumMap: enumMap)
  }

  func callFlutterEchoNullable(classMap: [Int64?: NativeInteropAllNullableTypes?]?) throws
    -> [Int64?:
    NativeInteropAllNullableTypes?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableClassMap(classMap: classMap)
  }

  func callFlutterEchoNullableNonNull(stringMap: [String: String]?) throws -> [String:
    String]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableNonNullStringMap(stringMap: stringMap)
  }

  func callFlutterEchoNullableNonNull(intMap: [Int64: Int64]?) throws -> [Int64: Int64]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableNonNullIntMap(intMap: intMap)
  }

  func callFlutterEchoNullableNonNull(enumMap: [NativeInteropAnEnum: NativeInteropAnEnum]?) throws
    -> [NativeInteropAnEnum:
    NativeInteropAnEnum]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableNonNullEnumMap(enumMap: enumMap)
  }

  func callFlutterEchoNullableNonNull(classMap: [Int64: NativeInteropAllNullableTypes]?) throws
    -> [Int64: NativeInteropAllNullableTypes]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNullableNonNullClassMap(classMap: classMap)
  }

  func callFlutterNoopAsync() async throws {
    let flutterApi = try getNativeInteropFlutterApi()
    try await flutterApi.noopAsync()
  }

  func callFlutterEchoAsyncNativeInteropAllTypes(everything: NativeInteropAllTypes) async throws
    -> NativeInteropAllTypes
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNativeInteropAllTypes(everything: everything)
  }

  func callFlutterEchoAsyncNullableNativeInteropAllNullableTypes(
    everything: NativeInteropAllNullableTypes?
  ) async throws
    -> NativeInteropAllNullableTypes?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableNativeInteropAllNullableTypes(
      everything: everything)
  }

  func callFlutterEchoAsyncNullableNativeInteropAllNullableTypesWithoutRecursion(
    everything: NativeInteropAllNullableTypesWithoutRecursion?
  ) async throws -> NativeInteropAllNullableTypesWithoutRecursion? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableNativeInteropAllNullableTypesWithoutRecursion(
      everything: everything)
  }

  func callFlutterEchoAsyncBool(aBool: Bool) async throws -> Bool {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncBool(aBool: aBool)
  }

  func callFlutterEchoAsyncInt(anInt: Int64) async throws -> Int64 {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncInt(anInt: anInt)
  }

  func callFlutterEchoAsyncDouble(aDouble: Double) async throws -> Double {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncDouble(aDouble: aDouble)
  }

  func callFlutterEchoAsyncString(aString: String) async throws -> String {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncString(aString: aString)
  }

  func callFlutterEchoAsyncUint8List(list: [UInt8]) async throws -> [UInt8] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncUint8List(list: list)
  }

  func callFlutterEchoAsyncInt32List(list: [Int32]) async throws -> [Int32] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncInt32List(list: list)
  }

  func callFlutterEchoAsyncInt64List(list: [Int64]) async throws -> [Int64] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncInt64List(list: list)
  }

  func callFlutterEchoAsyncFloat64List(list: [Float64]) async throws -> [Float64] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncFloat64List(list: list)
  }

  func callFlutterEchoAsyncObject(anObject: Any) async throws -> Any {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncObject(anObject: anObject)
  }

  func callFlutterEchoAsyncList(list: [Any?]) async throws -> [Any?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncList(list: list)
  }

  func callFlutterEchoAsyncEnumList(enumList: [NativeInteropAnEnum?]) async throws
    -> [NativeInteropAnEnum?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncEnumList(enumList: enumList)
  }

  func callFlutterEchoAsyncClassList(classList: [NativeInteropAllNullableTypes?]) async throws
    -> [NativeInteropAllNullableTypes?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncClassList(classList: classList)
  }

  func callFlutterEchoAsyncNonNullEnumList(enumList: [NativeInteropAnEnum]) async throws
    -> [NativeInteropAnEnum]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNonNullEnumList(enumList: enumList)
  }

  func callFlutterEchoAsyncNonNullClassList(classList: [NativeInteropAllNullableTypes]) async throws
    -> [NativeInteropAllNullableTypes]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNonNullClassList(classList: classList)
  }

  func callFlutterEchoAsyncMap(map: [AnyHashable?: Any?]) async throws -> [AnyHashable?: Any?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncMap(map: map)
  }

  func callFlutterEchoAsyncStringMap(stringMap: [String?: String?]) async throws -> [String?:
    String?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncStringMap(stringMap: stringMap)
  }

  func callFlutterEchoAsyncIntMap(intMap: [Int64?: Int64?]) async throws -> [Int64?: Int64?] {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncIntMap(intMap: intMap)
  }

  func callFlutterEchoAsyncEnumMap(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?])
    async throws -> [NativeInteropAnEnum?:
    NativeInteropAnEnum?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncEnumMap(enumMap: enumMap)
  }

  func callFlutterThrowFlutterErrorAsync() async throws -> Any? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.throwFlutterErrorAsync()
  }

  func callFlutterEchoAsyncNullableFloat64List(list: [Float64]?) async throws -> [Float64]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableFloat64List(list: list)
  }

  func callFlutterThrowFlutterError() throws -> Any? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.throwFlutterError()
  }

  func callFlutterEcho(_ everything: NativeInteropAllNullableTypes?) throws
    -> NativeInteropAllNullableTypes?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNativeInteropAllNullableTypes(everything: everything)
  }

  func callFlutterSendMultipleNullableTypes(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) throws -> NativeInteropAllNullableTypes {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.sendMultipleNullableTypes(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
  }

  func callFlutterEcho(_ everything: NativeInteropAllNullableTypesWithoutRecursion?)
    throws -> NativeInteropAllNullableTypesWithoutRecursion?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNativeInteropAllNullableTypesWithoutRecursion(everything: everything)
  }

  func callFlutterSendMultipleNullableTypesWithoutRecursion(
    aBool aNullableBool: Bool?, anInt aNullableInt: Int64?, aString aNullableString: String?
  ) throws -> NativeInteropAllNullableTypesWithoutRecursion {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.sendMultipleNullableTypesWithoutRecursion(
      aNullableBool: aNullableBool, aNullableInt: aNullableInt, aNullableString: aNullableString)
  }

  func callFlutterEcho(_ anEnum: NativeInteropAnEnum) throws -> NativeInteropAnEnum {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoEnum(anEnum: anEnum)
  }

  func callFlutterEcho(_ anotherEnum: NativeInteropAnotherEnum) throws -> NativeInteropAnotherEnum {
    let flutterApi = try getNativeInteropFlutterApi()
    return try flutterApi.echoNativeInteropAnotherEnum(anotherEnum: anotherEnum)
  }

  func echoAsync(_ aDouble: Double) async throws -> Double {
    return aDouble
  }

  func echoAsync(_ aBool: Bool) async throws -> Bool {
    return aBool
  }

  func echoAsync(_ aString: String) async throws -> String {
    return aString
  }

  func noopAsync() async throws {
    return
  }

  func echoAsync(_ anInt: Int64) async throws -> Int64 {
    return anInt
  }

  func echo(enumList: [NativeInteropAnEnum?]) throws -> [NativeInteropAnEnum?] {
    return enumList
  }

  func echo(classList: [NativeInteropAllNullableTypes?]) throws
    -> [NativeInteropAllNullableTypes?]
  {
    return classList
  }

  func echo(stringList: [String?]) throws -> [String?] {
    return stringList
  }

  func echo(intList: [Int64?]) throws -> [Int64?] {
    return intList
  }

  func echo(doubleList: [Double?]) throws -> [Double?] {
    return doubleList
  }

  func echo(boolList: [Bool?]) throws -> [Bool?] {
    return boolList
  }

  func echo(_ wrapper: NativeInteropAllClassesWrapper) throws -> NativeInteropAllClassesWrapper {
    return wrapper
  }

  func echoNullable(_ everything: NativeInteropAllNullableTypesWithoutRecursion?) throws
    -> NativeInteropAllNullableTypesWithoutRecursion?
  {
    return everything
  }

  func echoNullable(_ aNullableInt: Int64?) throws -> Int64? {
    return aNullableInt
  }

  func echoNullable(_ aNullableDouble: Double?) throws -> Double? {
    return aNullableDouble
  }

  func echoNullable(_ aNullableBool: Bool?) throws -> Bool? {
    return aNullableBool
  }

  func echoNullable(_ aNullableString: String?) throws -> String? {
    return aNullableString
  }

  func callFlutterEchoAsyncNullableEnumMap(enumMap: [NativeInteropAnEnum?: NativeInteropAnEnum?]?)
    async throws
    -> [NativeInteropAnEnum?: NativeInteropAnEnum?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableEnumMap(enumMap: enumMap)
  }

  func callFlutterEchoAsyncNullableClassMap(classMap: [Int64?: NativeInteropAllNullableTypes?]?)
    async throws
    -> [Int64?: NativeInteropAllNullableTypes?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableClassMap(classMap: classMap)
  }

  func callFlutterEchoAsyncNullableEnum(anEnum: NativeInteropAnEnum?) async throws
    -> NativeInteropAnEnum?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableEnum(anEnum: anEnum)
  }

  func callFlutterEchoAnotherAsyncNullableEnum(anotherEnum: NativeInteropAnotherEnum?) async throws
    -> NativeInteropAnotherEnum?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAnotherAsyncNullableEnum(anotherEnum: anotherEnum)
  }

  func callFlutterEchoAsyncClassMap(classMap: [Int64?: NativeInteropAllNullableTypes?]) async throws
    -> [Int64?:
    NativeInteropAllNullableTypes?]
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncClassMap(classMap: classMap)
  }

  func callFlutterEchoAsyncEnum(anEnum: NativeInteropAnEnum) async throws -> NativeInteropAnEnum {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncEnum(anEnum: anEnum)
  }

  func callFlutterEchoAnotherAsyncEnum(anotherEnum: NativeInteropAnotherEnum) async throws
    -> NativeInteropAnotherEnum
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAnotherAsyncEnum(anotherEnum: anotherEnum)
  }

  func callFlutterEchoAsyncNullableBool(aBool: Bool?) async throws -> Bool? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableBool(aBool: aBool)
  }

  func callFlutterEchoAsyncNullableInt(anInt: Int64?) async throws -> Int64? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableInt(anInt: anInt)
  }

  func callFlutterEchoAsyncNullableDouble(aDouble: Double?) async throws -> Double? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableDouble(aDouble: aDouble)
  }

  func callFlutterEchoAsyncNullableString(aString: String?) async throws -> String? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableString(aString: aString)
  }

  func callFlutterEchoAsyncNullableUint8List(list: [UInt8]?) async throws -> [UInt8]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableUint8List(list: list)
  }

  func callFlutterEchoAsyncNullableInt32List(list: [Int32]?) async throws -> [Int32]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableInt32List(list: list)
  }

  func callFlutterEchoAsyncNullableInt64List(list: [Int64]?) async throws -> [Int64]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableInt64List(list: list)
  }

  func callFlutterEchoAsyncNullableObject(anObject: Any?) async throws -> Any? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableObject(anObject: anObject)
  }

  func callFlutterEchoAsyncNullableList(list: [Any?]?) async throws -> [Any?]? {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableList(list: list)
  }

  func callFlutterEchoAsyncNullableEnumList(enumList: [NativeInteropAnEnum?]?) async throws
    -> [NativeInteropAnEnum?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableEnumList(enumList: enumList)
  }

  func callFlutterEchoAsyncNullableClassList(classList: [NativeInteropAllNullableTypes?]?)
    async throws
    -> [NativeInteropAllNullableTypes?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableClassList(classList: classList)
  }

  func callFlutterEchoAsyncNullableNonNullEnumList(enumList: [NativeInteropAnEnum]?) async throws
    -> [NativeInteropAnEnum]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableNonNullEnumList(enumList: enumList)
  }

  func callFlutterEchoAsyncNullableNonNullClassList(classList: [NativeInteropAllNullableTypes]?)
    async throws
    -> [NativeInteropAllNullableTypes]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableNonNullClassList(classList: classList)
  }

  func callFlutterEchoAsyncNullableMap(map: [AnyHashable?: Any?]?) async throws -> [AnyHashable?:
    Any?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableMap(map: map)
  }

  func callFlutterEchoAsyncNullableStringMap(stringMap: [String?: String?]?) async throws
    -> [String?:
    String?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableStringMap(stringMap: stringMap)
  }

  func callFlutterEchoAsyncNullableIntMap(intMap: [Int64?: Int64?]?) async throws -> [Int64?:
    Int64?]?
  {
    let flutterApi = try getNativeInteropFlutterApi()
    return try await flutterApi.echoAsyncNullableIntMap(intMap: intMap)
  }

  func isMainThread() throws -> Bool {
    return Thread.isMainThread
  }

  func asyncIsBackgroundThread() async throws -> Bool {
    return await withCheckedContinuation { continuation in
      DispatchQueue.global(qos: .background).async {
        continuation.resume(returning: !Thread.isMainThread)
      }
    }
  }

  private var getterValue: Int64 = 0

  func isGetter() throws -> Bool {
    return true
  }

  func getGetter() throws -> Int64 {
    return getterValue
  }

  func setSetter(value: Int64) throws {
    getterValue = value
  }

  func callFlutterNoopOnBackgroundThread() async throws -> Bool {
    return await withCheckedContinuation { continuation in
      DispatchQueue.global(qos: .background).async {
        Task {
          do {
            guard let flutterApi = NativeInteropFlutterIntegrationCoreApi.getInstance() else {
              continuation.resume(returning: false)
              return
            }
            try await flutterApi.noopAsync()
            continuation.resume(returning: true)
          } catch {
            continuation.resume(returning: false)
          }
        }
      }
    }
  }

  func testDeregisterHostApi() throws -> Bool {
    let name = "testDeregisterHostInstance"
    NativeInteropHostIntegrationCoreApiSetup.register(api: NativeInteropTestsClass(), name: name)
    guard NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) != nil else {
      return false
    }
    NativeInteropHostIntegrationCoreApiSetup.register(api: nil, name: name)
    return NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) == nil
  }

  func testDeregisterFlutterApi() throws -> Bool {
    let name = "testDeregisterFlutterInstance"
    NativeInteropFlutterIntegrationCoreApiRegistrar.registerInstance(api: nil, name: name)
    return NativeInteropFlutterIntegrationCoreApiRegistrar.getInstance(name: name) == nil
  }

  func registerAndImmediatelyDeregisterHostApi(name: String) throws {
    NativeInteropHostIntegrationCoreApiSetup.register(api: NativeInteropTestsClass(), name: name)
    NativeInteropHostIntegrationCoreApiSetup.register(api: nil, name: name)
  }

  func testCallDeregisteredFlutterApi(name: String) throws -> Bool {
    NativeInteropFlutterIntegrationCoreApiRegistrar.registerInstance(api: nil, name: name)
    return NativeInteropFlutterIntegrationCoreApi.getInstance(name: name) == nil
  }
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

  override public func onListen(withArguments arguments: Any?, sink: GolubetsEventSink<Int64>) {
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

  override public func onListen(
    withArguments arguments: Any?, sink: GolubetsEventSink<PlatformEvent>
  ) {
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

  override public func onListen(withArguments arguments: Any?, sink: GolubetsEventSink<Int64>) {
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

class ProxyApiTestClassDelegate: GolubetsApiDelegateProxyApiTestClass {
  public func golubetsDefaultConstructor(
    golubetsApi: GolubetsApiProxyApiTestClass, aBool: Bool, anInt: Int64, aDouble: Double,
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
    golubetsApi: GolubetsApiProxyApiTestClass, aBool: Bool, anInt: Int64, aDouble: Double,
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
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws -> ProxyApiSuperClass
  {
    return ProxyApiSuperClass()
  }

  public func staticAttachedField(golubetsApi: GolubetsApiProxyApiTestClass) throws
    -> ProxyApiSuperClass
  {
    return ProxyApiSuperClass()
  }

  public func aBool(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws
    -> Bool
  {
    return true
  }

  public func anInt(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws
    -> Int64
  {
    return 0
  }

  public func aDouble(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws
    -> Double
  {
    return 0.0
  }

  public func aString(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws
    -> String
  {
    return ""
  }

  public func aUint8List(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws -> FlutterStandardTypedData
  {
    return FlutterStandardTypedData(bytes: Data())
  }

  public func aList(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws
    -> [Any?]
  {
    return []
  }

  public func aMap(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws
    -> [String?: Any?]
  {
    return [:]
  }

  public func anEnum(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws
    -> ProxyApiTestEnum
  {
    return ProxyApiTestEnum.one
  }

  public func aProxyApi(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws -> ProxyApiSuperClass
  {
    return ProxyApiSuperClass()
  }

  public func aNullableBool(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws -> Bool?
  {
    return nil
  }

  public func aNullableInt(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws -> Int64?
  {
    return nil
  }

  public func aNullableDouble(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws -> Double?
  {
    return nil
  }

  public func aNullableString(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws -> String?
  {
    return nil
  }

  public func aNullableUint8List(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  ) throws -> FlutterStandardTypedData? {
    return nil
  }

  public func aNullableList(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws -> [Any?]?
  {
    return nil
  }

  public func aNullableMap(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws -> [String?: Any?]?
  {
    return nil
  }

  public func aNullableEnum(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws -> ProxyApiTestEnum?
  {
    return nil
  }

  public func aNullableProxyApi(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  ) throws -> ProxyApiSuperClass? {
    return nil
  }

  public func noop(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws
  {}

  public func throwError(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  )
    throws -> Any?
  {
    throw ProxyApiTestsError(code: "code", message: "message", details: "details")
  }

  public func throwErrorFromVoid(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  ) throws {
    throw ProxyApiTestsError(code: "code", message: "message", details: "details")
  }

  public func throwFlutterError(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass
  ) throws -> Any? {
    throw ProxyApiTestsError(code: "code", message: "message", details: "details")
  }

  public func echoInt(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass, anInt: Int64
  ) throws -> Int64 {
    return anInt
  }

  public func echoDouble(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aDouble: Double
  ) throws -> Double {
    return aDouble
  }

  public func echoBool(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass, aBool: Bool
  ) throws -> Bool {
    return aBool
  }

  public func echoString(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aString: String
  ) throws -> String {
    return aString
  }

  public func echoUint8List(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aUint8List: FlutterStandardTypedData
  ) throws -> FlutterStandardTypedData {
    return aUint8List
  }

  public func echoObject(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    anObject: Any
  ) throws -> Any {
    return anObject
  }

  public func echoList(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aList: [Any?]
  ) throws -> [Any?] {
    return aList
  }

  public func echoProxyApiList(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aList: [ProxyApiTestClass]
  ) throws -> [ProxyApiTestClass] {
    return aList
  }

  public func echoMap(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aMap: [String?: Any?]
  ) throws -> [String?: Any?] {
    return aMap
  }

  public func echoProxyApiMap(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aMap: [String: ProxyApiTestClass]
  ) throws -> [String: ProxyApiTestClass] {
    return aMap
  }

  public func echoEnum(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    anEnum: ProxyApiTestEnum
  ) throws -> ProxyApiTestEnum {
    return anEnum
  }

  public func echoProxyApi(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aProxyApi: ProxyApiSuperClass
  ) throws -> ProxyApiSuperClass {
    return aProxyApi
  }

  public func echoNullableInt(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aNullableInt: Int64?
  ) throws -> Int64? {
    return aNullableInt
  }

  public func echoNullableDouble(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aNullableDouble: Double?
  ) throws -> Double? {
    return aNullableDouble
  }

  public func echoNullableBool(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aNullableBool: Bool?
  ) throws -> Bool? {
    return aNullableBool
  }

  public func echoNullableString(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aNullableString: String?
  ) throws -> String? {
    return aNullableString
  }

  public func echoNullableUint8List(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aNullableUint8List: FlutterStandardTypedData?
  ) throws -> FlutterStandardTypedData? {
    return aNullableUint8List
  }

  public func echoNullableObject(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aNullableObject: Any?
  ) throws -> Any? {
    return aNullableObject
  }

  public func echoNullableList(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aNullableList: [Any?]?
  ) throws -> [Any?]? {
    return aNullableList
  }

  public func echoNullableMap(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aNullableMap: [String?: Any?]?
  ) throws -> [String?: Any?]? {
    return aNullableMap
  }

  public func echoNullableEnum(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aNullableEnum: ProxyApiTestEnum?
  ) throws -> ProxyApiTestEnum? {
    return aNullableEnum
  }

  public func echoNullableProxyApi(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aNullableProxyApi: ProxyApiSuperClass?
  ) throws -> ProxyApiSuperClass? {
    return aNullableProxyApi
  }

  public func noopAsync(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    completion(.success(()))
  }

  public func echoAsyncInt(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    anInt: Int64,
    completion: @escaping (Result<Int64, Error>) -> Void
  ) {
    completion(.success(anInt))
  }

  public func echoAsyncDouble(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aDouble: Double,
    completion: @escaping (Result<Double, Error>) -> Void
  ) {
    completion(.success(aDouble))
  }

  public func echoAsyncBool(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass, aBool: Bool,
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    completion(.success(aBool))
  }

  public func echoAsyncString(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aString: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    completion(.success(aString))
  }

  public func echoAsyncUint8List(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aUint8List: FlutterStandardTypedData,
    completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
  ) {
    completion(.success(aUint8List))
  }

  public func echoAsyncObject(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    anObject: Any,
    completion: @escaping (Result<Any, Error>) -> Void
  ) {
    completion(.success(anObject))
  }

  public func echoAsyncList(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aList: [Any?],
    completion: @escaping (Result<[Any?], Error>) -> Void
  ) {
    completion(.success(aList))
  }

  public func echoAsyncMap(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aMap: [String?: Any?], completion: @escaping (Result<[String?: Any?], Error>) -> Void
  ) {
    completion(.success(aMap))
  }

  public func echoAsyncEnum(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    anEnum: ProxyApiTestEnum, completion: @escaping (Result<ProxyApiTestEnum, Error>) -> Void
  ) {
    completion(.success(anEnum))
  }

  public func throwAsyncError(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    completion: @escaping (Result<Any?, Error>) -> Void
  ) {
    completion(
      .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
  }

  public func throwAsyncErrorFromVoid(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    completion(
      .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
  }

  public func throwAsyncFlutterError(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    completion: @escaping (Result<Any?, Error>) -> Void
  ) {
    completion(
      .failure(ProxyApiTestsError(code: "code", message: "message", details: "details")))
  }

  public func echoAsyncNullableInt(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    anInt: Int64?,
    completion: @escaping (Result<Int64?, Error>) -> Void
  ) {
    completion(.success(anInt))
  }

  public func echoAsyncNullableDouble(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aDouble: Double?,
    completion: @escaping (Result<Double?, Error>) -> Void
  ) {
    completion(.success(aDouble))
  }

  public func echoAsyncNullableBool(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aBool: Bool?,
    completion: @escaping (Result<Bool?, Error>) -> Void
  ) {
    completion(.success(aBool))
  }

  public func echoAsyncNullableString(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aString: String?,
    completion: @escaping (Result<String?, Error>) -> Void
  ) {
    completion(.success(aString))
  }

  public func echoAsyncNullableUint8List(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aUint8List: FlutterStandardTypedData?,
    completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
  ) {
    completion(.success(aUint8List))
  }

  public func echoAsyncNullableObject(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    anObject: Any?,
    completion: @escaping (Result<Any?, Error>) -> Void
  ) {
    completion(.success(anObject))
  }

  public func echoAsyncNullableList(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aList: [Any?]?,
    completion: @escaping (Result<[Any?]?, Error>) -> Void
  ) {
    completion(.success(aList))
  }

  public func echoAsyncNullableMap(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aMap: [String?: Any?]?, completion: @escaping (Result<[String?: Any?]?, Error>) -> Void
  ) {
    completion(.success(aMap))
  }

  public func echoAsyncNullableEnum(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    anEnum: ProxyApiTestEnum?, completion: @escaping (Result<ProxyApiTestEnum?, Error>) -> Void
  ) {
    completion(.success(anEnum))
  }

  public func staticNoop(golubetsApi: GolubetsApiProxyApiTestClass) throws {}

  public func echoStaticString(golubetsApi: GolubetsApiProxyApiTestClass, aString: String)
    throws
    -> String
  {
    return aString
  }

  public func staticAsyncNoop(
    golubetsApi: GolubetsApiProxyApiTestClass,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    completion(.success(()))
  }

  public func callFlutterNoop(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    golubetsApi.flutterNoop(golubetsInstance: golubetsInstance) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterThrowError(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    completion: @escaping (Result<Any?, Error>) -> Void
  ) {
    golubetsApi.flutterThrowError(golubetsInstance: golubetsInstance) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterThrowErrorFromVoid(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    golubetsApi.flutterThrowErrorFromVoid(golubetsInstance: golubetsInstance) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoBool(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass, aBool: Bool,
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    golubetsApi.flutterEchoBool(golubetsInstance: golubetsInstance, aBool: aBool) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoInt(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    anInt: Int64,
    completion: @escaping (Result<Int64, Error>) -> Void
  ) {
    golubetsApi.flutterEchoInt(golubetsInstance: golubetsInstance, anInt: anInt) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoDouble(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aDouble: Double,
    completion: @escaping (Result<Double, Error>) -> Void
  ) {
    golubetsApi.flutterEchoDouble(golubetsInstance: golubetsInstance, aDouble: aDouble) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoString(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aString: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    golubetsApi.flutterEchoString(golubetsInstance: golubetsInstance, aString: aString) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoUint8List(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aUint8List: FlutterStandardTypedData,
    completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
  ) {
    golubetsApi.flutterEchoUint8List(golubetsInstance: golubetsInstance, aList: aUint8List) {
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
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aList: [Any?],
    completion: @escaping (Result<[Any?], Error>) -> Void
  ) {
    golubetsApi.flutterEchoList(golubetsInstance: golubetsInstance, aList: aList) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoProxyApiList(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aList: [ProxyApiTestClass?],
    completion: @escaping (Result<[ProxyApiTestClass?], Error>) -> Void
  ) {
    golubetsApi.flutterEchoProxyApiList(golubetsInstance: golubetsInstance, aList: aList) {
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
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aMap: [String?: Any?], completion: @escaping (Result<[String?: Any?], Error>) -> Void
  ) {
    golubetsApi.flutterEchoMap(golubetsInstance: golubetsInstance, aMap: aMap) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoProxyApiMap(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aMap: [String?: ProxyApiTestClass?],
    completion: @escaping (Result<[String?: ProxyApiTestClass?], Error>) -> Void
  ) {
    golubetsApi.flutterEchoProxyApiMap(golubetsInstance: golubetsInstance, aMap: aMap) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoEnum(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    anEnum: ProxyApiTestEnum, completion: @escaping (Result<ProxyApiTestEnum, Error>) -> Void
  ) {
    golubetsApi.flutterEchoEnum(golubetsInstance: golubetsInstance, anEnum: anEnum) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoProxyApi(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aProxyApi: ProxyApiSuperClass,
    completion: @escaping (Result<ProxyApiSuperClass, Error>) -> Void
  ) {
    golubetsApi.flutterEchoProxyApi(golubetsInstance: golubetsInstance, aProxyApi: aProxyApi) {
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
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aBool: Bool?,
    completion: @escaping (Result<Bool?, Error>) -> Void
  ) {
    golubetsApi.flutterEchoNullableBool(golubetsInstance: golubetsInstance, aBool: aBool) {
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
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    anInt: Int64?,
    completion: @escaping (Result<Int64?, Error>) -> Void
  ) {
    golubetsApi.flutterEchoNullableInt(golubetsInstance: golubetsInstance, anInt: anInt) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullableDouble(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aDouble: Double?,
    completion: @escaping (Result<Double?, Error>) -> Void
  ) {
    golubetsApi.flutterEchoNullableDouble(golubetsInstance: golubetsInstance, aDouble: aDouble) {
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
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aString: String?,
    completion: @escaping (Result<String?, Error>) -> Void
  ) {
    golubetsApi.flutterEchoNullableString(golubetsInstance: golubetsInstance, aString: aString) {
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
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aUint8List: FlutterStandardTypedData?,
    completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void
  ) {
    golubetsApi.flutterEchoNullableUint8List(
      golubetsInstance: golubetsInstance, aList: aUint8List
    ) {
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
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aList: [Any?]?,
    completion: @escaping (Result<[Any?]?, Error>) -> Void
  ) {
    golubetsApi.flutterEchoNullableList(golubetsInstance: golubetsInstance, aList: aList) {
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
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aMap: [String?: Any?]?, completion: @escaping (Result<[String?: Any?]?, Error>) -> Void
  ) {
    golubetsApi.flutterEchoNullableMap(golubetsInstance: golubetsInstance, aMap: aMap) {
      response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoNullableEnum(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    anEnum: ProxyApiTestEnum?, completion: @escaping (Result<ProxyApiTestEnum?, Error>) -> Void
  ) {
    golubetsApi.flutterEchoNullableEnum(golubetsInstance: golubetsInstance, anEnum: anEnum) {
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
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aProxyApi: ProxyApiSuperClass?,
    completion: @escaping (Result<ProxyApiSuperClass?, Error>) -> Void
  ) {
    golubetsApi.flutterEchoNullableProxyApi(
      golubetsInstance: golubetsInstance, aProxyApi: aProxyApi
    ) {
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
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    golubetsApi.flutterNoopAsync(golubetsInstance: golubetsInstance) { response in
      switch response {
      case .success(let res):
        completion(.success(res))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func callFlutterEchoAsyncString(
    golubetsApi: GolubetsApiProxyApiTestClass, golubetsInstance: ProxyApiTestClass,
    aString: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    golubetsApi.flutterEchoAsyncString(golubetsInstance: golubetsInstance, aString: aString) {
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

class ProxyApiDelegate: ProxyApiTestsGolubetsProxyApiDelegate {
  public func golubetsApiProxyApiTestClass(_ registrar: ProxyApiTestsGolubetsProxyApiRegistrar)
    -> GolubetsApiProxyApiTestClass
  {
    return GolubetsApiProxyApiTestClass(
      golubetsRegistrar: registrar, delegate: ProxyApiTestClassDelegate())
  }

  public func golubetsApiProxyApiSuperClass(_ registrar: ProxyApiTestsGolubetsProxyApiRegistrar)
    -> GolubetsApiProxyApiSuperClass
  {
    class ProxyApiSuperClassDelegate: GolubetsApiDelegateProxyApiSuperClass {
      public func golubetsDefaultConstructor(golubetsApi: GolubetsApiProxyApiSuperClass) throws
        -> ProxyApiSuperClass
      {
        return ProxyApiSuperClass()
      }

      public func aSuperMethod(
        golubetsApi: GolubetsApiProxyApiSuperClass, golubetsInstance: ProxyApiSuperClass
      )
        throws
      {}
    }
    return GolubetsApiProxyApiSuperClass(
      golubetsRegistrar: registrar, delegate: ProxyApiSuperClassDelegate())
  }

  public func golubetsApiProxyApiInterface(_ registrar: ProxyApiTestsGolubetsProxyApiRegistrar)
    -> GolubetsApiProxyApiInterface
  {
    class ProxyApiInterfaceDelegate: GolubetsApiDelegateProxyApiInterface {}
    return GolubetsApiProxyApiInterface(
      golubetsRegistrar: registrar, delegate: ProxyApiInterfaceDelegate())
  }

  public func golubetsApiClassWithApiRequirement(
    _ registrar: ProxyApiTestsGolubetsProxyApiRegistrar
  )
    -> GolubetsApiClassWithApiRequirement
  {
    class ClassWithApiRequirementDelegate: GolubetsApiDelegateClassWithApiRequirement {
      @available(iOS 15, macOS 10, *)
      public func golubetsDefaultConstructor(golubetsApi: GolubetsApiClassWithApiRequirement) throws
        -> ClassWithApiRequirement
      {
        return ClassWithApiRequirement()
      }

      @available(iOS 15, macOS 10, *)
      public func aMethod(
        golubetsApi: GolubetsApiClassWithApiRequirement, golubetsInstance: ClassWithApiRequirement
      ) throws {}
    }

    return GolubetsApiClassWithApiRequirement(
      golubetsRegistrar: registrar, delegate: ClassWithApiRequirementDelegate())
  }
}
