// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel

/** This plugin handles the native side of the integration tests in example/integration_test/. */
class TestPlugin :
    FlutterPlugin, HostIntegrationCoreApi, SealedClassApi, KotlinNestedSealedApi, HostGenericApi {
  private var flutterApi: FlutterIntegrationCoreApi? = null
  private var flutterSmallApiOne: FlutterSmallApi? = null
  private var flutterSmallApiTwo: FlutterSmallApi? = null
  private var proxyApiRegistrar: ProxyApiRegistrar? = null
  private var coroutineScope: CoroutineScope? = null
  private var flutterGenericApi: FlutterGenericApi? = null

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    HostIntegrationCoreApi.setUp(binding.binaryMessenger, this, coroutineScope = coroutineScope!!)
    val testSuffixApiOne = TestPluginWithSuffix()
    testSuffixApiOne.setUp(binding, "suffixOne")
    val testSuffixApiTwo = TestPluginWithSuffix()
    testSuffixApiTwo.setUp(binding, "suffixTwo")
    flutterApi = FlutterIntegrationCoreApi(binding.binaryMessenger)
    flutterSmallApiOne = FlutterSmallApi(binding.binaryMessenger, "suffixOne")
    flutterSmallApiTwo = FlutterSmallApi(binding.binaryMessenger, "suffixTwo")
    flutterGenericApi = FlutterGenericApi(binding.binaryMessenger)

    proxyApiRegistrar = ProxyApiRegistrar(binding.binaryMessenger)
    proxyApiRegistrar!!.setUp()

    StreamEventsStreamHandler.register(binding.binaryMessenger, SendClass)
    StreamIntsStreamHandler.register(binding.binaryMessenger, SendInts)
    StreamConsistentNumbersStreamHandler.register(
        binding.binaryMessenger, SendConsistentNumbers(1), "1")
    StreamConsistentNumbersStreamHandler.register(
        binding.binaryMessenger, SendConsistentNumbers(2), "2")
    SealedClassApi.setUp(binding.binaryMessenger, this)
    KotlinNestedSealedApi.setUp(binding.binaryMessenger, this)
    HostGenericApi.setUp(binding.binaryMessenger, this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    proxyApiRegistrar?.tearDown()
    coroutineScope?.cancel()
  }

  // HostIntegrationCoreApi

  override fun noop() {}

  override fun echoAllTypes(everything: AllTypes): AllTypes {
    return everything
  }

  override fun echoAllNullableTypes(everything: AllNullableTypes?): AllNullableTypes? {
    return everything
  }

  override fun echoAllNullableTypesWithoutRecursion(
      everything: AllNullableTypesWithoutRecursion?
  ): AllNullableTypesWithoutRecursion? {
    return everything
  }

  override fun throwError(): Any? {
    throw Exception("An error")
  }

  override fun throwErrorFromVoid() {
    throw Exception("An error")
  }

  override fun throwFlutterError(): Any? {
    throw FlutterError("code", "message", "details")
  }

  override fun echoInt(anInt: Long): Long {
    return anInt
  }

  override fun echoDouble(aDouble: Double): Double {
    return aDouble
  }

  override fun echoBool(aBool: Boolean): Boolean {
    return aBool
  }

  override fun echoString(aString: String): String {
    return aString
  }

  override fun echoUint8List(aUint8List: ByteArray): ByteArray {
    return aUint8List
  }

  override fun echoObject(anObject: Any): Any {
    return anObject
  }

  override fun echoList(list: List<Any?>): List<Any?> {
    return list
  }

  override fun echoEnumList(enumList: List<AnEnum?>): List<AnEnum?> {
    return enumList
  }

  override fun echoClassList(classList: List<AllNullableTypes?>): List<AllNullableTypes?> {
    return classList
  }

  override fun echoNonNullEnumList(enumList: List<AnEnum>): List<AnEnum> {
    return enumList
  }

  override fun echoNonNullClassList(classList: List<AllNullableTypes>): List<AllNullableTypes> {
    return classList
  }

  override fun echoMap(map: Map<Any?, Any?>): Map<Any?, Any?> {
    return map
  }

  override fun echoStringMap(stringMap: Map<String?, String?>): Map<String?, String?> {
    return stringMap
  }

  override fun echoIntMap(intMap: Map<Long?, Long?>): Map<Long?, Long?> {
    return intMap
  }

  override fun echoEnumMap(enumMap: Map<AnEnum?, AnEnum?>): Map<AnEnum?, AnEnum?> {
    return enumMap
  }

  override fun echoClassMap(
      classMap: Map<Long?, AllNullableTypes?>
  ): Map<Long?, AllNullableTypes?> {
    return classMap
  }

  override fun echoNonNullStringMap(stringMap: Map<String, String>): Map<String, String> {
    return stringMap
  }

  override fun echoNonNullIntMap(intMap: Map<Long, Long>): Map<Long, Long> {
    return intMap
  }

  override fun echoNonNullEnumMap(enumMap: Map<AnEnum, AnEnum>): Map<AnEnum, AnEnum> {
    return enumMap
  }

  override fun echoNonNullClassMap(
      classMap: Map<Long, AllNullableTypes>
  ): Map<Long, AllNullableTypes> {
    return classMap
  }

  override fun echoClassWrapper(wrapper: AllClassesWrapper): AllClassesWrapper {
    return wrapper
  }

  override fun echoEnum(anEnum: AnEnum): AnEnum {
    return anEnum
  }

  override fun echoAnotherEnum(anotherEnum: AnotherEnum): AnotherEnum {
    return anotherEnum
  }

  override fun echoNamedDefaultString(aString: String): String {
    return aString
  }

  override fun echoOptionalDefaultDouble(aDouble: Double): Double {
    return aDouble
  }

  override fun createAllTypesWithDefaults(): AllTypesWithDefaults {
    return AllTypesWithDefaults()
  }

  override fun echoAllTypesWithDefaults(allTypes: AllTypesWithDefaults): AllTypesWithDefaults {
    return allTypes
  }

  override fun echoRequiredInt(anInt: Long): Long {
    return anInt
  }

  override fun extractNestedNullableString(wrapper: AllClassesWrapper): String? {
    return wrapper.allNullableTypes.aNullableString
  }

  override fun createNestedNullableString(nullableString: String?): AllClassesWrapper {
    return AllClassesWrapper(
        AllNullableTypes(aNullableString = nullableString),
        classList = arrayOf<AllTypes>().toList(),
        classMap = HashMap())
  }

  override fun sendMultipleNullableTypes(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): AllNullableTypes {
    return AllNullableTypes(
        aNullableBool = aNullableBool,
        aNullableInt = aNullableInt,
        aNullableString = aNullableString)
  }

  override fun sendMultipleNullableTypesWithoutRecursion(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): AllNullableTypesWithoutRecursion {
    return AllNullableTypesWithoutRecursion(
        aNullableBool = aNullableBool,
        aNullableInt = aNullableInt,
        aNullableString = aNullableString)
  }

  override fun echoNullableInt(aNullableInt: Long?): Long? {
    return aNullableInt
  }

  override fun echoNullableDouble(aNullableDouble: Double?): Double? {
    return aNullableDouble
  }

  override fun echoNullableBool(aNullableBool: Boolean?): Boolean? {
    return aNullableBool
  }

  override fun echoNullableString(aNullableString: String?): String? {
    return aNullableString
  }

  override fun echoNullableUint8List(aNullableUint8List: ByteArray?): ByteArray? {
    return aNullableUint8List
  }

  override fun echoNullableObject(aNullableObject: Any?): Any? {
    return aNullableObject
  }

  override fun echoNullableList(aNullableList: List<Any?>?): List<Any?>? {
    return aNullableList
  }

  override fun echoNullableEnumList(enumList: List<AnEnum?>?): List<AnEnum?>? {
    return enumList
  }

  override fun echoNullableClassList(
      classList: List<AllNullableTypes?>?
  ): List<AllNullableTypes?>? {
    return classList
  }

  override fun echoNullableNonNullEnumList(enumList: List<AnEnum>?): List<AnEnum>? {
    return enumList
  }

  override fun echoNullableNonNullClassList(
      classList: List<AllNullableTypes>?
  ): List<AllNullableTypes>? {
    return classList
  }

  override fun echoNullableMap(map: Map<Any?, Any?>?): Map<Any?, Any?>? {
    return map
  }

  override fun echoNullableStringMap(stringMap: Map<String?, String?>?): Map<String?, String?>? {
    return stringMap
  }

  override fun echoNullableIntMap(intMap: Map<Long?, Long?>?): Map<Long?, Long?>? {
    return intMap
  }

  override fun echoNullableEnumMap(enumMap: Map<AnEnum?, AnEnum?>?): Map<AnEnum?, AnEnum?>? {
    return enumMap
  }

  override fun echoNullableClassMap(
      classMap: Map<Long?, AllNullableTypes?>?
  ): Map<Long?, AllNullableTypes?>? {
    return classMap
  }

  override fun echoNullableNonNullStringMap(stringMap: Map<String, String>?): Map<String, String>? {
    return stringMap
  }

  override fun echoNullableNonNullIntMap(intMap: Map<Long, Long>?): Map<Long, Long>? {
    return intMap
  }

  override fun echoNullableNonNullEnumMap(enumMap: Map<AnEnum, AnEnum>?): Map<AnEnum, AnEnum>? {
    return enumMap
  }

  override fun echoNullableNonNullClassMap(
      classMap: Map<Long, AllNullableTypes>?
  ): Map<Long, AllNullableTypes>? {
    return classMap
  }

  override fun echoNullableEnum(anEnum: AnEnum?): AnEnum? {
    return anEnum
  }

  override fun echoAnotherNullableEnum(anotherEnum: AnotherEnum?): AnotherEnum? {
    return anotherEnum
  }

  override fun echoOptionalNullableInt(aNullableInt: Long?): Long? {
    return aNullableInt
  }

  override fun echoNamedNullableString(aNullableString: String?): String? {
    return aNullableString
  }

  override fun noopAsync(callback: (Result<Unit>) -> Unit) {
    callback(Result.success(Unit))
  }

  override fun throwAsyncError(callback: (Result<Any?>) -> Unit) {
    callback(Result.failure(Exception("except")))
  }

  override fun throwAsyncErrorFromVoid(callback: (Result<Unit>) -> Unit) {
    callback(Result.failure(Exception("except")))
  }

  override fun throwAsyncFlutterError(callback: (Result<Any?>) -> Unit) {
    callback(Result.failure(FlutterError("code", "message", "details")))
  }

  override fun echoAsyncAllTypes(everything: AllTypes, callback: (Result<AllTypes>) -> Unit) {
    callback(Result.success(everything))
  }

  override suspend fun echoModernAsyncAllTypes(everything: AllTypes): AllTypes {
    return everything
  }

  override suspend fun echoModernAsyncAllTypesAndNotThrow(everything: AllTypes): AllTypes {
    return everything
  }

  override suspend fun echoModernAsyncAllTypesAndThrow(everything: AllTypes): AllTypes {
    throw FlutterError("code", "message", "details")
  }

  override fun echoAsyncNullableAllNullableTypes(
      everything: AllNullableTypes?,
      callback: (Result<AllNullableTypes?>) -> Unit
  ) {
    callback(Result.success(everything))
  }

  override suspend fun echoModernAsyncNullableAllNullableTypes(
      everything: AllNullableTypes?
  ): AllNullableTypes? {
    return everything
  }

  override fun echoAsyncNullableAllNullableTypesWithoutRecursion(
      everything: AllNullableTypesWithoutRecursion?,
      callback: (Result<AllNullableTypesWithoutRecursion?>) -> Unit
  ) {
    callback(Result.success(everything))
  }

  override fun echoAsyncInt(anInt: Long, callback: (Result<Long>) -> Unit) {
    callback(Result.success(anInt))
  }

  override fun echoAsyncDouble(aDouble: Double, callback: (Result<Double>) -> Unit) {
    callback(Result.success(aDouble))
  }

  override fun echoAsyncBool(aBool: Boolean, callback: (Result<Boolean>) -> Unit) {
    callback(Result.success(aBool))
  }

  override fun echoAsyncString(aString: String, callback: (Result<String>) -> Unit) {
    callback(Result.success(aString))
  }

  override fun echoAsyncUint8List(aUint8List: ByteArray, callback: (Result<ByteArray>) -> Unit) {
    callback(Result.success(aUint8List))
  }

  override fun echoAsyncObject(anObject: Any, callback: (Result<Any>) -> Unit) {
    callback(Result.success(anObject))
  }

  override fun echoAsyncList(list: List<Any?>, callback: (Result<List<Any?>>) -> Unit) {
    callback(Result.success(list))
  }

  override fun echoAsyncEnumList(
      enumList: List<AnEnum?>,
      callback: (Result<List<AnEnum?>>) -> Unit
  ) {
    callback(Result.success(enumList))
  }

  override fun echoAsyncClassList(
      classList: List<AllNullableTypes?>,
      callback: (Result<List<AllNullableTypes?>>) -> Unit
  ) {
    callback(Result.success(classList))
  }

  override fun echoAsyncMap(map: Map<Any?, Any?>, callback: (Result<Map<Any?, Any?>>) -> Unit) {
    callback(Result.success(map))
  }

  override fun echoAsyncStringMap(
      stringMap: Map<String?, String?>,
      callback: (Result<Map<String?, String?>>) -> Unit
  ) {
    callback(Result.success(stringMap))
  }

  override fun echoAsyncIntMap(
      intMap: Map<Long?, Long?>,
      callback: (Result<Map<Long?, Long?>>) -> Unit
  ) {
    callback(Result.success(intMap))
  }

  override fun echoAsyncEnumMap(
      enumMap: Map<AnEnum?, AnEnum?>,
      callback: (Result<Map<AnEnum?, AnEnum?>>) -> Unit
  ) {
    callback(Result.success(enumMap))
  }

  override fun echoAsyncClassMap(
      classMap: Map<Long?, AllNullableTypes?>,
      callback: (Result<Map<Long?, AllNullableTypes?>>) -> Unit
  ) {
    callback(Result.success(classMap))
  }

  override fun echoAsyncEnum(anEnum: AnEnum, callback: (Result<AnEnum>) -> Unit) {
    callback(Result.success(anEnum))
  }

  override fun echoAnotherAsyncEnum(
      anotherEnum: AnotherEnum,
      callback: (Result<AnotherEnum>) -> Unit
  ) {
    callback(Result.success(anotherEnum))
  }

  override fun echoAsyncNullableInt(anInt: Long?, callback: (Result<Long?>) -> Unit) {
    callback(Result.success(anInt))
  }

  override fun echoAsyncNullableDouble(aDouble: Double?, callback: (Result<Double?>) -> Unit) {
    callback(Result.success(aDouble))
  }

  override fun echoAsyncNullableBool(aBool: Boolean?, callback: (Result<Boolean?>) -> Unit) {
    callback(Result.success(aBool))
  }

  override fun echoAsyncNullableString(aString: String?, callback: (Result<String?>) -> Unit) {
    callback(Result.success(aString))
  }

  override fun echoAsyncNullableUint8List(
      aUint8List: ByteArray?,
      callback: (Result<ByteArray?>) -> Unit
  ) {
    callback(Result.success(aUint8List))
  }

  override fun echoAsyncNullableObject(anObject: Any?, callback: (Result<Any?>) -> Unit) {
    callback(Result.success(anObject))
  }

  override fun echoAsyncNullableList(list: List<Any?>?, callback: (Result<List<Any?>?>) -> Unit) {
    callback(Result.success(list))
  }

  override fun echoAsyncNullableEnumList(
      enumList: List<AnEnum?>?,
      callback: (Result<List<AnEnum?>?>) -> Unit
  ) {
    callback(Result.success(enumList))
  }

  override fun echoAsyncNullableClassList(
      classList: List<AllNullableTypes?>?,
      callback: (Result<List<AllNullableTypes?>?>) -> Unit
  ) {
    callback(Result.success(classList))
  }

  override fun echoAsyncNullableMap(
      map: Map<Any?, Any?>?,
      callback: (Result<Map<Any?, Any?>?>) -> Unit
  ) {
    callback(Result.success(map))
  }

  override fun echoAsyncNullableStringMap(
      stringMap: Map<String?, String?>?,
      callback: (Result<Map<String?, String?>?>) -> Unit
  ) {
    callback(Result.success(stringMap))
  }

  override fun echoAsyncNullableIntMap(
      intMap: Map<Long?, Long?>?,
      callback: (Result<Map<Long?, Long?>?>) -> Unit
  ) {
    callback(Result.success(intMap))
  }

  override fun echoAsyncNullableEnumMap(
      enumMap: Map<AnEnum?, AnEnum?>?,
      callback: (Result<Map<AnEnum?, AnEnum?>?>) -> Unit
  ) {
    callback(Result.success(enumMap))
  }

  override fun echoAsyncNullableClassMap(
      classMap: Map<Long?, AllNullableTypes?>?,
      callback: (Result<Map<Long?, AllNullableTypes?>?>) -> Unit
  ) {
    callback(Result.success(classMap))
  }

  override fun echoAsyncNullableEnum(anEnum: AnEnum?, callback: (Result<AnEnum?>) -> Unit) {
    callback(Result.success(anEnum))
  }

  override fun echoAnotherAsyncNullableEnum(
      anotherEnum: AnotherEnum?,
      callback: (Result<AnotherEnum?>) -> Unit
  ) {
    callback(Result.success(anotherEnum))
  }

  override fun defaultIsMainThread(): Boolean {
    return Thread.currentThread() == Looper.getMainLooper().getThread()
  }

  override fun taskQueueIsBackgroundThread(): Boolean {
    return Thread.currentThread() != Looper.getMainLooper().getThread()
  }

  override fun callFlutterNoop(callback: (Result<Unit>) -> Unit) {
    flutterApi!!.noop { callback(Result.success(Unit)) }
  }

  override fun callFlutterThrowError(callback: (Result<Any?>) -> Unit) {
    flutterApi!!.throwError { result -> callback(result) }
  }

  override fun callFlutterThrowErrorFromVoid(callback: (Result<Unit>) -> Unit) {
    flutterApi!!.throwErrorFromVoid { result -> callback(result) }
  }

  override fun callFlutterEchoAllTypes(everything: AllTypes, callback: (Result<AllTypes>) -> Unit) {
    flutterApi!!.echoAllTypes(everything) { echo -> callback(echo) }
  }

  override fun callFlutterSendMultipleNullableTypes(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?,
      callback: (Result<AllNullableTypes>) -> Unit
  ) {
    flutterApi!!.sendMultipleNullableTypes(aNullableBool, aNullableInt, aNullableString) { echo ->
      callback(echo)
    }
  }

  override fun callFlutterEchoAllNullableTypesWithoutRecursion(
      everything: AllNullableTypesWithoutRecursion?,
      callback: (Result<AllNullableTypesWithoutRecursion?>) -> Unit
  ) {
    flutterApi!!.echoAllNullableTypesWithoutRecursion(everything) { echo -> callback(echo) }
  }

  override fun callFlutterSendMultipleNullableTypesWithoutRecursion(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?,
      callback: (Result<AllNullableTypesWithoutRecursion>) -> Unit
  ) {
    flutterApi!!.sendMultipleNullableTypesWithoutRecursion(
        aNullableBool, aNullableInt, aNullableString) { echo ->
          callback(echo)
        }
  }

  override fun callFlutterEchoBool(aBool: Boolean, callback: (Result<Boolean>) -> Unit) {
    flutterApi!!.echoBool(aBool) { echo -> callback(echo) }
  }

  override fun callFlutterEchoInt(anInt: Long, callback: (Result<Long>) -> Unit) {
    flutterApi!!.echoInt(anInt) { echo -> callback(echo) }
  }

  override fun callFlutterEchoDouble(aDouble: Double, callback: (Result<Double>) -> Unit) {
    flutterApi!!.echoDouble(aDouble) { echo -> callback(echo) }
  }

  override fun callFlutterEchoString(aString: String, callback: (Result<String>) -> Unit) {
    flutterApi!!.echoString(aString) { echo -> callback(echo) }
  }

  override fun callFlutterEchoUint8List(list: ByteArray, callback: (Result<ByteArray>) -> Unit) {
    flutterApi!!.echoUint8List(list) { echo -> callback(echo) }
  }

  override fun callFlutterEchoList(list: List<Any?>, callback: (Result<List<Any?>>) -> Unit) {
    flutterApi!!.echoList(list) { echo -> callback(echo) }
  }

  override fun callFlutterEchoEnumList(
      enumList: List<AnEnum?>,
      callback: (Result<List<AnEnum?>>) -> Unit
  ) {
    flutterApi!!.echoEnumList(enumList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoClassList(
      classList: List<AllNullableTypes?>,
      callback: (Result<List<AllNullableTypes?>>) -> Unit
  ) {
    flutterApi!!.echoClassList(classList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNonNullEnumList(
      enumList: List<AnEnum>,
      callback: (Result<List<AnEnum>>) -> Unit
  ) {
    flutterApi!!.echoNonNullEnumList(enumList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNonNullClassList(
      classList: List<AllNullableTypes>,
      callback: (Result<List<AllNullableTypes>>) -> Unit
  ) {
    flutterApi!!.echoNonNullClassList(classList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoMap(
      map: Map<Any?, Any?>,
      callback: (Result<Map<Any?, Any?>>) -> Unit
  ) {
    flutterApi!!.echoMap(map) { echo -> callback(echo) }
  }

  override fun callFlutterEchoStringMap(
      stringMap: Map<String?, String?>,
      callback: (Result<Map<String?, String?>>) -> Unit
  ) {
    flutterApi!!.echoStringMap(stringMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoIntMap(
      intMap: Map<Long?, Long?>,
      callback: (Result<Map<Long?, Long?>>) -> Unit
  ) {
    flutterApi!!.echoIntMap(intMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoEnumMap(
      enumMap: Map<AnEnum?, AnEnum?>,
      callback: (Result<Map<AnEnum?, AnEnum?>>) -> Unit
  ) {
    flutterApi!!.echoEnumMap(enumMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoClassMap(
      classMap: Map<Long?, AllNullableTypes?>,
      callback: (Result<Map<Long?, AllNullableTypes?>>) -> Unit
  ) {
    flutterApi!!.echoClassMap(classMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNonNullStringMap(
      stringMap: Map<String, String>,
      callback: (Result<Map<String, String>>) -> Unit
  ) {
    flutterApi!!.echoNonNullStringMap(stringMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNonNullIntMap(
      intMap: Map<Long, Long>,
      callback: (Result<Map<Long, Long>>) -> Unit
  ) {
    flutterApi!!.echoNonNullIntMap(intMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNonNullEnumMap(
      enumMap: Map<AnEnum, AnEnum>,
      callback: (Result<Map<AnEnum, AnEnum>>) -> Unit
  ) {
    flutterApi!!.echoNonNullEnumMap(enumMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNonNullClassMap(
      classMap: Map<Long, AllNullableTypes>,
      callback: (Result<Map<Long, AllNullableTypes>>) -> Unit
  ) {
    flutterApi!!.echoNonNullClassMap(classMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoEnum(anEnum: AnEnum, callback: (Result<AnEnum>) -> Unit) {
    flutterApi!!.echoEnum(anEnum) { echo -> callback(echo) }
  }

  override fun callFlutterEchoAnotherEnum(
      anotherEnum: AnotherEnum,
      callback: (Result<AnotherEnum>) -> Unit
  ) {
    flutterApi!!.echoAnotherEnum(anotherEnum) { echo -> callback(echo) }
  }

  override fun callFlutterEchoAllNullableTypes(
      everything: AllNullableTypes?,
      callback: (Result<AllNullableTypes?>) -> Unit
  ) {
    flutterApi!!.echoAllNullableTypes(everything) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableBool(aBool: Boolean?, callback: (Result<Boolean?>) -> Unit) {
    flutterApi!!.echoNullableBool(aBool) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableInt(anInt: Long?, callback: (Result<Long?>) -> Unit) {
    flutterApi!!.echoNullableInt(anInt) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableDouble(
      aDouble: Double?,
      callback: (Result<Double?>) -> Unit
  ) {
    flutterApi!!.echoNullableDouble(aDouble) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableString(
      aString: String?,
      callback: (Result<String?>) -> Unit
  ) {
    flutterApi!!.echoNullableString(aString) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableUint8List(
      list: ByteArray?,
      callback: (Result<ByteArray?>) -> Unit
  ) {
    flutterApi!!.echoNullableUint8List(list) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableList(
      list: List<Any?>?,
      callback: (Result<List<Any?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableList(list) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableEnumList(
      enumList: List<AnEnum?>?,
      callback: (Result<List<AnEnum?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableEnumList(enumList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableClassList(
      classList: List<AllNullableTypes?>?,
      callback: (Result<List<AllNullableTypes?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableClassList(classList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableNonNullEnumList(
      enumList: List<AnEnum>?,
      callback: (Result<List<AnEnum>?>) -> Unit
  ) {
    flutterApi!!.echoNullableNonNullEnumList(enumList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableNonNullClassList(
      classList: List<AllNullableTypes>?,
      callback: (Result<List<AllNullableTypes>?>) -> Unit
  ) {
    flutterApi!!.echoNullableNonNullClassList(classList) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableMap(
      map: Map<Any?, Any?>?,
      callback: (Result<Map<Any?, Any?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableMap(map) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableStringMap(
      stringMap: Map<String?, String?>?,
      callback: (Result<Map<String?, String?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableStringMap(stringMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableIntMap(
      intMap: Map<Long?, Long?>?,
      callback: (Result<Map<Long?, Long?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableIntMap(intMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableEnumMap(
      enumMap: Map<AnEnum?, AnEnum?>?,
      callback: (Result<Map<AnEnum?, AnEnum?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableEnumMap(enumMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableClassMap(
      classMap: Map<Long?, AllNullableTypes?>?,
      callback: (Result<Map<Long?, AllNullableTypes?>?>) -> Unit
  ) {
    flutterApi!!.echoNullableClassMap(classMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableNonNullStringMap(
      stringMap: Map<String, String>?,
      callback: (Result<Map<String, String>?>) -> Unit
  ) {
    flutterApi!!.echoNullableNonNullStringMap(stringMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableNonNullIntMap(
      intMap: Map<Long, Long>?,
      callback: (Result<Map<Long, Long>?>) -> Unit
  ) {
    flutterApi!!.echoNullableNonNullIntMap(intMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableNonNullEnumMap(
      enumMap: Map<AnEnum, AnEnum>?,
      callback: (Result<Map<AnEnum, AnEnum>?>) -> Unit
  ) {
    flutterApi!!.echoNullableNonNullEnumMap(enumMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableNonNullClassMap(
      classMap: Map<Long, AllNullableTypes>?,
      callback: (Result<Map<Long, AllNullableTypes>?>) -> Unit
  ) {
    flutterApi!!.echoNullableNonNullClassMap(classMap) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNullableEnum(anEnum: AnEnum?, callback: (Result<AnEnum?>) -> Unit) {
    flutterApi!!.echoNullableEnum(anEnum) { echo -> callback(echo) }
  }

  override fun callFlutterEchoAnotherNullableEnum(
      anotherEnum: AnotherEnum?,
      callback: (Result<AnotherEnum?>) -> Unit
  ) {
    flutterApi!!.echoAnotherNullableEnum(anotherEnum) { echo -> callback(echo) }
  }

  override fun callFlutterSmallApiEchoString(aString: String, callback: (Result<String>) -> Unit) {
    flutterSmallApiOne!!.echoString(aString) { echoOne ->
      flutterSmallApiTwo!!.echoString(aString) { echoTwo ->
        if (echoOne == echoTwo) {
          callback(echoTwo)
        } else {
          callback(
              Result.failure(
                  Exception("Multi-instance responses were not matching: $echoOne, $echoTwo")))
        }
      }
    }
  }

  fun testUnusedClassesGenerate(): UnusedClass {
    return UnusedClass()
  }

  override fun echo(event: PlatformEvent): PlatformEvent = event

  override fun echo(state: SomeState): SomeState = state

  // HostGenericApi implementation

  override fun echoGenericInt(container: GenericContainer<Long>): GenericContainer<Long> {
    return container
  }

  override fun echoGenericString(container: GenericContainer<String>): GenericContainer<String> {
    return container
  }

  override fun echoGenericDouble(container: GenericContainer<Double>): GenericContainer<Double> {
    return container
  }

  override fun echoGenericBool(container: GenericContainer<Boolean>): GenericContainer<Boolean> {
    return container
  }

  override fun echoGenericEnum(
      container: GenericContainer<GenericsAnEnum>
  ): GenericContainer<GenericsAnEnum> {
    return container
  }

  override fun echoGenericNullableInt(container: GenericContainer<Long?>): GenericContainer<Long?> {
    return container
  }

  override fun echoGenericNullableString(
      container: GenericContainer<String?>
  ): GenericContainer<String?> {
    return container
  }

  override fun echoGenericPairStringInt(
      pair: GenericPair<String, Long>
  ): GenericPair<String, Long> {
    return pair
  }

  override fun echoGenericPairIntString(
      pair: GenericPair<Long, String>
  ): GenericPair<Long, String> {
    return pair
  }

  override fun echoGenericPairDoubleBool(
      pair: GenericPair<Double, Boolean>
  ): GenericPair<Double, Boolean> {
    return pair
  }

  override fun echoGenericContainerAllTypes(
      container: GenericContainer<GenericsAllTypes>
  ): GenericContainer<GenericsAllTypes> {
    return container
  }

  override fun echoGenericPairClasses(
      pair: GenericPair<GenericsAllTypes, GenericsAllNullableTypes>
  ): GenericPair<GenericsAllTypes, GenericsAllNullableTypes> {
    return pair
  }

  override fun echoNestedGenericStringIntDouble(
      nested: NestedGeneric<String, Long, Double>
  ): NestedGeneric<String, Long, Double> {
    return nested
  }

  override fun echoNestedGenericWithClasses(
      nested: NestedGeneric<GenericsAllTypes, String, Long>
  ): NestedGeneric<GenericsAllTypes, String, Long> {
    return nested
  }

  override fun echoListGenericContainer(
      list: List<GenericContainer<Long>>
  ): List<GenericContainer<Long>> {
    return list
  }

  override fun echoListGenericPair(
      list: List<GenericPair<String, Long>>
  ): List<GenericPair<String, Long>> {
    return list
  }

  override fun echoMapGenericContainer(
      map: Map<String, GenericContainer<Long>>
  ): Map<String, GenericContainer<Long>> {
    return map
  }

  override fun echoMapGenericPair(
      map: Map<Long, GenericPair<String, Double>>
  ): Map<Long, GenericPair<String, Double>> {
    return map
  }

  override fun echoAsyncGenericInt(
      container: GenericContainer<Long>,
      callback: (Result<GenericContainer<Long>>) -> Unit
  ) {
    callback(Result.success(container))
  }

  override fun echoAsyncNestedGeneric(
      nested: NestedGeneric<String, Long, Double>,
      callback: (Result<NestedGeneric<String, Long, Double>>) -> Unit
  ) {
    callback(Result.success(nested))
  }

  override fun echoEitherGenericIntOrString(
      input: Either<GenericContainer<Long>, GenericContainer<String>>
  ): Either<GenericContainer<Long>, GenericContainer<String>> {
    return input
  }

  override fun echoEitherGenericPairStringIntOrIntString(
      input: Either<GenericPair<String, Long>, GenericPair<Long, String>>
  ): Either<GenericPair<String, Long>, GenericPair<Long, String>> {
    return input
  }

  override fun echoEitherNestedGenericStringIntDoubleOrClasses(
      input:
          Either<NestedGeneric<String, Long, Double>, NestedGeneric<GenericsAllTypes, String, Long>>
  ): Either<NestedGeneric<String, Long, Double>, NestedGeneric<GenericsAllTypes, String, Long>> {
    return input
  }

  // GenericsAllNullableTypesTyped echo methods implementation
  override fun echoTypedNullableStringIntDouble(
      typed: GenericsAllNullableTypesTyped<String, Long, Double>
  ): GenericsAllNullableTypesTyped<String, Long, Double> {
    return typed
  }

  override fun echoTypedNullableIntStringBool(
      typed: GenericsAllNullableTypesTyped<Long, String, Boolean>
  ): GenericsAllNullableTypesTyped<Long, String, Boolean> {
    return typed
  }

  override fun echoTypedNullableEnumDoubleString(
      typed: GenericsAllNullableTypesTyped<GenericsAnEnum, Double, String>
  ): GenericsAllNullableTypesTyped<GenericsAnEnum, Double, String> {
    return typed
  }

  override fun echoGenericContainerTypedNullable(
      container: GenericContainer<GenericsAllNullableTypesTyped<String, Long, Double>>
  ): GenericContainer<GenericsAllNullableTypesTyped<String, Long, Double>> {
    return container
  }

  override fun echoGenericPairTypedNullable(
      pair:
          GenericPair<
              GenericsAllNullableTypesTyped<String, Long, Double>,
              GenericsAllNullableTypesTyped<Long, String, Boolean>>
  ): GenericPair<
      GenericsAllNullableTypesTyped<String, Long, Double>,
      GenericsAllNullableTypesTyped<Long, String, Boolean>> {
    return pair
  }

  override fun echoListTypedNullable(
      list: List<GenericsAllNullableTypesTyped<String, Long, Double>>
  ): List<GenericsAllNullableTypesTyped<String, Long, Double>> {
    return list
  }

  override fun echoMapTypedNullable(
      map: Map<String, GenericsAllNullableTypesTyped<Long, String, Double>>
  ): Map<String, GenericsAllNullableTypesTyped<Long, String, Double>> {
    return map
  }

  override fun echoAsyncTypedNullableStringIntDouble(
      typed: GenericsAllNullableTypesTyped<String, Long, Double>,
      callback: (Result<GenericsAllNullableTypesTyped<String, Long, Double>>) -> Unit
  ) {
    callback(Result.success(typed))
  }

  override fun echoAsyncGenericContainerTypedNullable(
      container: GenericContainer<GenericsAllNullableTypesTyped<String, Long, Double>>,
      callback:
          (Result<GenericContainer<GenericsAllNullableTypesTyped<String, Long, Double>>>) -> Unit
  ) {
    callback(Result.success(container))
  }

  // GenericDefaults echo methods
  override fun echoGenericDefaults(defaults: GenericDefaults): GenericDefaults {
    return defaults
  }

  override fun returnGenericDefaults(): GenericDefaults {
    return GenericDefaults(
        genericInt = GenericContainer(value = 42, values = listOf(1, 2, 3)),
        genericString = GenericContainer(value = "default", values = listOf("a", "b", "c")),
        genericDouble = GenericContainer(value = 3.14, values = listOf(1.0, 2.0, 3.0)),
        genericBool = GenericContainer(value = true, values = listOf(true, false, true)),
        genericPairStringInt =
            GenericPair(first = "default", second = 42, map = mapOf("key1" to 1, "key2" to 2)),
        genericPairIntString =
            GenericPair(first = 100L, second = "value", map = mapOf(1L to "one", 2L to "two")),
        nestedGenericDefault =
            NestedGeneric(
                container = GenericContainer(value = "nested", values = listOf("x", "y", "z")),
                pairs =
                    listOf(
                        GenericPair(first = 1L, second = 1.1, map = mapOf(1L to 1.1, 2L to 2.2))),
                nestedMap =
                    mapOf("nested" to GenericContainer(value = 99, values = listOf(9, 8, 7))),
                listOfMaps = listOf(mapOf(10L to 10.0, 20L to 20.0))),
        genericPairEither =
            GenericPair(
                first = 1L,
                second = Either.Right<String, Long>(5L),
                map =
                    mapOf(
                        3L to Either.Right<String, Long>(4L),
                        4L to Either.Left<String, Long>("hello"))))
  }

  override fun echoAsyncGenericDefaults(
      defaults: GenericDefaults,
      callback: (Result<GenericDefaults>) -> Unit
  ) {
    callback(Result.success(defaults))
  }

  override fun callFlutterEchoGenericContainerTypedNullable(
      container: GenericContainer<GenericsAllNullableTypesTyped<String, Long, Double>>,
      callback:
          (Result<GenericContainer<GenericsAllNullableTypesTyped<String, Long, Double>>>) -> Unit
  ) {
    flutterGenericApi!!.echoGenericContainerTypedNullable(container) { echo -> callback(echo) }
  }

  override fun callFlutterEchoGenericDefaults(
      defaults: GenericDefaults,
      callback: (Result<GenericDefaults>) -> Unit
  ) {
    flutterGenericApi!!.echoGenericDefaults(defaults) { echo ->
      println(echo)
      callback(echo)
    }
  }

  override fun callFlutterEchoGenericDefaultsInt(
      defaults: GenericDefaults,
      callback: (Result<GenericContainer<Long>>) -> Unit
  ) {
    flutterGenericApi!!.echoGenericDefaultsInt(defaults) { echo -> callback(echo) }
  }

  override fun callFlutterEchoGenericDefaultsNested(
      defaults: GenericDefaults,
      callback: (Result<NestedGeneric<String, Long, Double>>) -> Unit
  ) {
    flutterGenericApi!!.echoGenericDefaultsNested(defaults) { echo -> callback(echo) }
  }

  override fun callFlutterEchoGenericDefaultsPairEither(
      defaults: GenericDefaults,
      callback: (Result<GenericPair<Long, Either<String, Long>>>) -> Unit
  ) {
    flutterGenericApi!!.echoGenericDefaultsPairEither(defaults) { echo -> callback(echo) }
  }

  override fun callFlutterEchoGenericInt(
      container: GenericContainer<Long>,
      callback: (Result<GenericContainer<Long>>) -> Unit
  ) {
    flutterGenericApi!!.echoGenericInt(container) { echo -> callback(echo) }
  }

  override fun callFlutterEchoGenericPairStringInt(
      pair: GenericPair<String, Long>,
      callback: (Result<GenericPair<String, Long>>) -> Unit
  ) {
    flutterGenericApi!!.echoGenericPairStringInt(pair) { echo -> callback(echo) }
  }

  override fun callFlutterEchoGenericString(
      container: GenericContainer<String>,
      callback: (Result<GenericContainer<String>>) -> Unit
  ) {
    flutterGenericApi!!.echoGenericString(container) { echo -> callback(echo) }
  }

  override fun callFlutterEchoListGenericContainer(
      list: List<GenericContainer<Long>>,
      callback: (Result<List<GenericContainer<Long>>>) -> Unit
  ) {
    flutterGenericApi!!.echoListGenericContainer(list) { echo -> callback(echo) }
  }

  override fun callFlutterEchoListTypedNullable(
      list: List<GenericsAllNullableTypesTyped<String, Long, Double>>,
      callback: (Result<List<GenericsAllNullableTypesTyped<String, Long, Double>>>) -> Unit
  ) {
    flutterGenericApi!!.echoListTypedNullable(list) { echo -> callback(echo) }
  }

  override fun callFlutterEchoMapGenericContainer(
      map: Map<String, GenericContainer<Long>>,
      callback: (Result<Map<String, GenericContainer<Long>>>) -> Unit
  ) {
    flutterGenericApi!!.echoMapGenericContainer(map) { echo -> callback(echo) }
  }

  override fun callFlutterEchoMapTypedNullable(
      map: Map<String, GenericsAllNullableTypesTyped<Long, String, Double>>,
      callback: (Result<Map<String, GenericsAllNullableTypesTyped<Long, String, Double>>>) -> Unit
  ) {
    flutterGenericApi!!.echoMapTypedNullable(map) { echo -> callback(echo) }
  }

  override fun callFlutterEchoNestedGenericStringIntDouble(
      nested: NestedGeneric<String, Long, Double>,
      callback: (Result<NestedGeneric<String, Long, Double>>) -> Unit
  ) {
    flutterGenericApi!!.echoNestedGenericStringIntDouble(nested) { echo -> callback(echo) }
  }

  override fun callFlutterEchoTypedNullableIntStringBool(
      typed: GenericsAllNullableTypesTyped<Long, String, Boolean>,
      callback: (Result<GenericsAllNullableTypesTyped<Long, String, Boolean>>) -> Unit
  ) {
    flutterGenericApi!!.echoTypedNullableIntStringBool(typed) { echo -> callback(echo) }
  }

  override fun callFlutterEchoTypedNullableStringIntDouble(
      typed: GenericsAllNullableTypesTyped<String, Long, Double>,
      callback: (Result<GenericsAllNullableTypesTyped<String, Long, Double>>) -> Unit
  ) {
    flutterGenericApi!!.echoTypedNullableStringIntDouble(typed) { echo -> callback(echo) }
  }

  override fun callFlutterReturnGenericDefaultsEitherLeft(
      callback: (Result<GenericContainer<Either<String, Long>>>) -> Unit
  ) {
    flutterGenericApi!!.returnGenericDefaultsEitherLeft { echo -> callback(echo) }
  }

  override fun callFlutterReturnGenericDefaultsEitherRight(
      callback: (Result<GenericContainer<Either<String, Long>>>) -> Unit
  ) {
    flutterGenericApi!!.returnGenericDefaultsEitherRight { echo -> callback(echo) }
  }
}

class TestPluginWithSuffix : HostSmallApi {

  fun setUp(binding: FlutterPluginBinding, suffix: String) {
    HostSmallApi.setUp(binding.binaryMessenger, this, suffix)
  }

  override fun echo(aString: String, callback: (Result<String>) -> Unit) {
    callback(Result.success(aString))
  }

  override fun voidVoid(callback: (Result<Unit>) -> Unit) {
    callback(Result.success(Unit))
  }
}

object SendInts : StreamIntsStreamHandler() {
  val handler = Handler(Looper.getMainLooper())

  override fun onListen(p0: Any?, sink: GolubetsEventSink<Long>) {
    var count: Long = 0
    val r: Runnable =
        object : Runnable {
          override fun run() {
            handler.post {
              if (count >= 5) {
                sink.endOfStream()
              } else {
                sink.success(count)
                count++
                handler.postDelayed(this, 10)
              }
            }
          }
        }
    handler.postDelayed(r, 10)
  }
}

object SendClass : StreamEventsStreamHandler() {
  val handler = Handler(Looper.getMainLooper())
  val eventList =
      listOf(
          IntEvent(1),
          StringEvent("string"),
          BoolEvent(false),
          DoubleEvent(3.14),
          ObjectsEvent(true),
          EnumEvent(EventEnum.FORTY_TWO),
          ClassEvent(EventAllNullableTypes(aNullableInt = 0)),
          EmptyEvent())

  override fun onListen(p0: Any?, sink: GolubetsEventSink<PlatformEvent>) {
    var count: Int = 0
    val r: Runnable =
        object : Runnable {
          override fun run() {
            if (count >= eventList.size) {
              sink.endOfStream()
            } else {
              handler.post {
                sink.success(eventList[count])
                count++
              }
              handler.postDelayed(this, 10)
            }
          }
        }
    handler.postDelayed(r, 10)
  }
}

class SendConsistentNumbers(private val numberToSend: Long) :
    StreamConsistentNumbersStreamHandler() {
  private val handler = Handler(Looper.getMainLooper())

  override fun onListen(p0: Any?, sink: GolubetsEventSink<Long>) {
    var count: Int = 0
    val r: Runnable =
        object : Runnable {
          override fun run() {
            if (count >= 10) {
              sink.endOfStream()
            } else {
              handler.post {
                sink.success(numberToSend)
                count++
              }
              handler.postDelayed(this, 10)
            }
          }
        }
    handler.postDelayed(r, 10)
  }
}
