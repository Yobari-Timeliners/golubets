// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
<<<<<<< HEAD
import kotlinx.coroutines.CoroutineScope
||||||| bc74248f73ad0f3af0de312406e107554753550b
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
=======
import java.lang.ref.WeakReference
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlinx.coroutines.CompletableDeferred
>>>>>>> 3cb08b37a0e8d188474f527d1b94759b53e610fd
import kotlinx.coroutines.Dispatchers
<<<<<<< HEAD
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
||||||| bc74248f73ad0f3af0de312406e107554753550b
import kotlinx.coroutines.suspendCancellableCoroutine
=======
import kotlinx.coroutines.NonCancellable
import kotlinx.coroutines.suspendCancellableCoroutine
>>>>>>> 3cb08b37a0e8d188474f527d1b94759b53e610fd
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull

/** This plugin handles the native side of the integration tests in example/integration_test/. */
class TestPlugin :
    FlutterPlugin,
    HostIntegrationCoreApi,
    HostCallbackCoreApi,
    SealedClassApi,
    KotlinNestedSealedApi,
    HostGenericApi {
  private var flutterApi: FlutterIntegrationCoreApi? = null
  private var flutterCallbackApi: FlutterCallbackCoreApi? = null
  private var flutterSmallApiOne: FlutterSmallApi? = null
  private var flutterSmallApiTwo: FlutterSmallApi? = null
  private var proxyApiRegistrar: ProxyApiRegistrar? = null
<<<<<<< HEAD
  private var coroutineScope: CoroutineScope? = null
  private var flutterGenericApi: FlutterGenericApi? = null
  private var niMessageApi: NativeInteropHostIntegrationCoreApiRegistrar? = null
||||||| bc74248f73ad0f3af0de312406e107554753550b
  private var niMessageApi: NativeInteropHostIntegrationCoreApiRegistrar? = null
=======
  internal var niMessageApiImpl: NativeInteropIntegrationTests? = null
  private var niReservedNamesImpl: NativeInteropReservedNamesHostApiImpl? = null
  private var niSealedClassImpl: NativeInteropSealedClassHostApiImpl? = null
  private var eventChannelOne: StreamConsistentNumbersEventChannel? = null
>>>>>>> 3cb08b37a0e8d188474f527d1b94759b53e610fd

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    HostIntegrationCoreApi.setUp(binding.binaryMessenger, this, coroutineScope = coroutineScope!!)
    HostCallbackCoreApi.setUp(binding.binaryMessenger, this)
    val testSuffixApiOne = TestPluginWithSuffix()
    testSuffixApiOne.setUp(binding, "suffixOne")
    val testSuffixApiTwo = TestPluginWithSuffix()
    testSuffixApiTwo.setUp(binding, "suffixTwo")
    val niTests = NativeInteropIntegrationTests(binding.applicationContext, binding)
    niMessageApiImpl = niTests
    NativeInteropHostIntegrationCoreApiRegistrar().register(niTests, binding)
    val reservedImpl = NativeInteropReservedNamesHostApiImpl(binding)
    niReservedNamesImpl = reservedImpl
    NativeInteropReservedNamesHostApiRegistrar().register(reservedImpl, binding)
    val sealedImpl = NativeInteropSealedClassHostApiImpl(binding)
    niSealedClassImpl = sealedImpl
    NativeInteropSealedClassHostApiRegistrar().register(sealedImpl, binding)
    flutterApi = FlutterIntegrationCoreApi(binding.binaryMessenger)
    flutterCallbackApi = FlutterCallbackCoreApi(binding.binaryMessenger)
    flutterSmallApiOne = FlutterSmallApi(binding.binaryMessenger, "suffixOne")
    flutterSmallApiTwo = FlutterSmallApi(binding.binaryMessenger, "suffixTwo")
    flutterGenericApi = FlutterGenericApi(binding.binaryMessenger)

    proxyApiRegistrar = ProxyApiRegistrar(binding.binaryMessenger)
    proxyApiRegistrar!!.setUp()

    StreamEventsStreamHandler.register(binding.binaryMessenger, SendClass)
    StreamIntsStreamHandler.register(binding.binaryMessenger, SendInts)
    // Store one handler to exercise the handler removal codepath, and discard
    // the other to test that the return value can be safely ignored.
    val streamHandlerOne = SendConsistentNumbers(1)
    eventChannelOne =
        StreamConsistentNumbersStreamHandler.register(
            binding.binaryMessenger, streamHandlerOne, "1")
    streamHandlerOne.onCancelled = { eventChannelOne?.setStreamHandler(null) }
    StreamConsistentNumbersStreamHandler.register(
        binding.binaryMessenger, SendConsistentNumbers(2), "2")
    SealedClassApi.setUp(binding.binaryMessenger, this)
    KotlinNestedSealedApi.setUp(binding.binaryMessenger, this)
    HostGenericApi.setUp(binding.binaryMessenger, this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    HostCallbackCoreApi.setUp(binding.binaryMessenger, null)
    niMessageApiImpl?.let { NativeInteropHostIntegrationCoreApiRegistrar().unregister(it, binding) }
    niMessageApiImpl = null
    niReservedNamesImpl?.let {
      NativeInteropReservedNamesHostApiRegistrar().unregister(it, binding)
    }
    niReservedNamesImpl = null
    niSealedClassImpl?.let { NativeInteropSealedClassHostApiRegistrar().unregister(it, binding) }
    niSealedClassImpl = null
    proxyApiRegistrar?.tearDown()
    coroutineScope?.cancel()
  }

  // HostCallbackCoreApi

  override fun noop(callback: (Result<Unit>) -> Unit) {
    callback(Result.success(Unit))
  }

  override fun echoString(aString: String, callback: (Result<String>) -> Unit) {
    callback(Result.success(aString))
  }

  override fun echoAllTypes(everything: AllTypes, callback: (Result<AllTypes>) -> Unit) {
    callback(Result.success(everything))
  }

  override fun echoNullableString(aString: String?, callback: (Result<String?>) -> Unit) {
    callback(Result.success(aString))
  }

  override fun throwError(callback: (Result<Any?>) -> Unit) {
    callback(Result.failure(FlutterError("code", "message", "details")))
  }

  override fun throwErrorFromVoid(callback: (Result<Unit>) -> Unit) {
    callback(Result.failure(FlutterError("code", "message", "details")))
  }

  override fun taskQueueIsBackgroundThread(callback: (Result<Boolean>) -> Unit) {
    callback(Result.success(Looper.myLooper() != Looper.getMainLooper()))
  }

  // HostIntegrationCoreApi

  override fun noop() {}

  override fun echoAllTypes(everything: AllTypes): AllTypes {
    return everything
  }

  override fun echoAllNullableTypes(everything: AllNullableTypes?): AllNullableTypes? {
    return everything
  }

  override fun areAllNullableTypesEqual(a: AllNullableTypes, b: AllNullableTypes): Boolean {
    return a == b
  }

  override fun getAllNullableTypesHash(value: AllNullableTypes): Long {
    return value.hashCode().toLong()
  }

  override fun getAllNullableTypesWithoutRecursionHash(
      value: AllNullableTypesWithoutRecursion
  ): Long {
    return value.hashCode().toLong()
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

  override fun echoStringList(stringList: List<String?>): List<String?> {
    return stringList
  }

  override fun echoIntList(intList: List<Long?>): List<Long?> {
    return intList
  }

  override fun echoDoubleList(doubleList: List<Double?>): List<Double?> {
    return doubleList
  }

  override fun echoBoolList(boolList: List<Boolean?>): List<Boolean?> {
    return boolList
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

  override fun asyncTaskQueueIsBackgroundThread(callback: (Result<Boolean>) -> Unit) {
    callback(Result.success(Thread.currentThread() != Looper.getMainLooper().getThread()))
  }

  override fun callFlutterCallbackNoop(callback: (Result<Unit>) -> Unit) {
    flutterCallbackApi!!.noop(callback)
  }

  override fun callFlutterCallbackEchoString(aString: String, callback: (Result<String>) -> Unit) {
    flutterCallbackApi!!.echoString(aString, callback)
  }

  override fun callFlutterCallbackThrowError(callback: (Result<Any?>) -> Unit) {
    flutterCallbackApi!!.throwError(callback)
  }

  override fun callFlutterCallbackThrowErrorFromVoid(callback: (Result<Unit>) -> Unit) {
    flutterCallbackApi!!.throwErrorFromVoid(callback)
  }

  override fun callFlutterIsAsyncFlutterApiOnRoot(callback: (Result<Boolean>) -> Unit) {
    if (Looper.myLooper() != Looper.getMainLooper()) {
      callback(Result.success(false))
      return
    }
    flutterApi!!.isAsyncFlutterApiOnRoot { result ->
      callback(result.map { it && Looper.myLooper() == Looper.getMainLooper() })
    }
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

  override fun echoFlutterReturnEitherGenericEnumOrListStringContainer(
      arg: Either<GenericsAnEnum, List<SimpleStringContainer>>
  ): Either<GenericsAnEnum, List<SimpleStringContainer>> {
    return arg
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

/** Source of the per-instance labels returned by [NativeInteropIntegrationTests.engineLabel]. */
private val nextLabelId = java.util.concurrent.atomic.AtomicInteger(1)

/**
 * Native Interop host API implementation used by the integration tests.
 *
 * [binding] is the plugin binding of the engine this instance was registered for. It is used to
 * find the Flutter API registered by the Dart code running on that engine.
 */
class NativeInteropIntegrationTests(
    private val context: Context? = null,
    private val binding: FlutterPluginBinding? = null
) : NativeInteropHostIntegrationCoreApi {
  private val label = "instance-${nextLabelId.getAndIncrement()}"

  override fun engineLabel(): String = label

  private fun requireBinding(): FlutterPluginBinding =
      checkNotNull(binding) { "NativeInteropIntegrationTests was not created with a binding." }

  private fun niFlutterApi(name: String? = null): NativeInteropFlutterIntegrationCoreApi? {
    val registrar = NativeInteropFlutterIntegrationCoreApiRegistrar()
    return if (name == null) registrar.getInstance(requireBinding())
    else registrar.getInstance(requireBinding(), name)
  }

  override fun noop() {}

  override fun echoAllTypes(everything: NativeInteropAllTypes): NativeInteropAllTypes {
    return everything
  }

  override fun throwError(): Any? {
    throw Exception("An error")
  }

  override fun throwErrorFromVoid() {
    throw Exception("An error")
  }

  override fun throwFlutterError(): Any? {
    throw NativeInteropTestsError("code", "message", "details")
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

  override fun echoInt32List(aInt32List: IntArray): IntArray {
    return aInt32List
  }

  override fun echoInt64List(aInt64List: LongArray): LongArray {
    return aInt64List
  }

  override fun echoFloat64List(aFloat64List: DoubleArray): DoubleArray {
    return aFloat64List
  }

  override fun echoObject(anObject: Any): Any {
    return anObject
  }

  override fun echoList(list: List<Any?>): List<Any?> {
    return list
  }

  override fun echoStringList(stringList: List<String?>): List<String?> {
    return stringList
  }

  override fun echoIntList(intList: List<Long?>): List<Long?> {
    return intList
  }

  override fun echoDoubleList(doubleList: List<Double?>): List<Double?> {
    return doubleList
  }

  override fun echoBoolList(boolList: List<Boolean?>): List<Boolean?> {
    return boolList
  }

  override fun echoEnumList(enumList: List<NativeInteropAnEnum?>): List<NativeInteropAnEnum?> {
    return enumList
  }

  override fun echoClassList(
      classList: List<NativeInteropAllNullableTypes?>
  ): List<NativeInteropAllNullableTypes?> {
    return classList
  }

  override fun echoNonNullEnumList(enumList: List<NativeInteropAnEnum>): List<NativeInteropAnEnum> {
    return enumList
  }

  override fun echoNonNullClassList(
      classList: List<NativeInteropAllNullableTypes>
  ): List<NativeInteropAllNullableTypes> {
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

  override fun echoEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?> {
    return enumMap
  }

  override fun echoClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>
  ): Map<Long?, NativeInteropAllNullableTypes?> {
    return classMap
  }

  override fun echoNonNullStringMap(stringMap: Map<String, String>): Map<String, String> {
    return stringMap
  }

  override fun echoNonNullIntMap(intMap: Map<Long, Long>): Map<Long, Long> {
    return intMap
  }

  override fun echoNonNullEnumMap(
      enumMap: Map<NativeInteropAnEnum, NativeInteropAnEnum>
  ): Map<NativeInteropAnEnum, NativeInteropAnEnum> {
    return enumMap
  }

  override fun echoNonNullClassMap(
      classMap: Map<Long, NativeInteropAllNullableTypes>
  ): Map<Long, NativeInteropAllNullableTypes> {
    return classMap
  }

  override fun echoClassWrapper(
      wrapper: NativeInteropAllClassesWrapper
  ): NativeInteropAllClassesWrapper {
    return wrapper
  }

  override fun echoSealedClass(sealedClass: NativeInteropSealedClass): NativeInteropSealedClass {
    return sealedClass
  }

  override fun echoNullableSealedClass(
      sealedClass: NativeInteropSealedClass?
  ): NativeInteropSealedClass? {
    return sealedClass
  }

  override fun echoSealedClassList(
      sealedClassList: List<NativeInteropSealedClass>
  ): List<NativeInteropSealedClass> {
    return sealedClassList
  }

  override fun echoSealedClassWrapper(
      wrapper: NativeInteropSealedClassWrapper
  ): NativeInteropSealedClassWrapper {
    return wrapper
  }

  override fun echoEnum(anEnum: NativeInteropAnEnum): NativeInteropAnEnum {
    return anEnum
  }

  override fun echoAnotherEnum(anotherEnum: NativeInteropAnotherEnum): NativeInteropAnotherEnum {
    return anotherEnum
  }

  override fun echoNamedDefaultString(aString: String): String {
    return aString
  }

  override fun echoOptionalDefaultDouble(aDouble: Double): Double {
    return aDouble
  }

  override fun echoRequiredInt(anInt: Long): Long {
    return anInt
  }

  override fun echoAllNullableTypes(
      everything: NativeInteropAllNullableTypes?
  ): NativeInteropAllNullableTypes? {
    return everything
  }

  override fun echoAllNullableTypesWithoutRecursion(
      everything: NativeInteropAllNullableTypesWithoutRecursion?
  ): NativeInteropAllNullableTypesWithoutRecursion? {
    return everything
  }

  override fun extractNestedNullableString(wrapper: NativeInteropAllClassesWrapper): String? {
    return wrapper.allNullableTypes.aNullableString
  }

  override fun createNestedNullableString(nullableString: String?): NativeInteropAllClassesWrapper {
    return NativeInteropAllClassesWrapper(
        NativeInteropAllNullableTypes(aNullableString = nullableString),
        classList = arrayOf<NativeInteropAllTypes>().toList(),
        classMap = HashMap())
  }

  override fun sendMultipleNullableTypes(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): NativeInteropAllNullableTypes {
    return NativeInteropAllNullableTypes(
        aNullableBool = aNullableBool,
        aNullableInt = aNullableInt,
        aNullableString = aNullableString)
  }

  override fun sendMultipleNullableTypesWithoutRecursion(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): NativeInteropAllNullableTypesWithoutRecursion {
    return NativeInteropAllNullableTypesWithoutRecursion(
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

  override fun echoNullableInt32List(aNullableInt32List: IntArray?): IntArray? {
    return aNullableInt32List
  }

  override fun echoNullableInt64List(aNullableInt64List: LongArray?): LongArray? {
    return aNullableInt64List
  }

  override fun echoNullableFloat64List(aNullableFloat64List: DoubleArray?): DoubleArray? {
    return aNullableFloat64List
  }

  override fun echoNullableObject(aNullableObject: Any?): Any? {
    return aNullableObject
  }

  override fun echoNullableList(aNullableList: List<Any?>?): List<Any?>? {
    return aNullableList
  }

  override fun echoNullableEnumList(
      enumList: List<NativeInteropAnEnum?>?
  ): List<NativeInteropAnEnum?>? {
    return enumList
  }

  override fun echoNullableClassList(
      classList: List<NativeInteropAllNullableTypes?>?
  ): List<NativeInteropAllNullableTypes?>? {
    return classList
  }

  override fun echoNullableNonNullEnumList(
      enumList: List<NativeInteropAnEnum>?
  ): List<NativeInteropAnEnum>? {
    return enumList
  }

  override fun echoNullableNonNullClassList(
      classList: List<NativeInteropAllNullableTypes>?
  ): List<NativeInteropAllNullableTypes>? {
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

  override fun echoNullableEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>?
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? {
    return enumMap
  }

  override fun echoNullableClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>?
  ): Map<Long?, NativeInteropAllNullableTypes?>? {
    return classMap
  }

  override fun echoNullableNonNullStringMap(stringMap: Map<String, String>?): Map<String, String>? {
    return stringMap
  }

  override fun echoNullableNonNullIntMap(intMap: Map<Long, Long>?): Map<Long, Long>? {
    return intMap
  }

  override fun echoNullableNonNullEnumMap(
      enumMap: Map<NativeInteropAnEnum, NativeInteropAnEnum>?
  ): Map<NativeInteropAnEnum, NativeInteropAnEnum>? {
    return enumMap
  }

  override fun echoNullableNonNullClassMap(
      classMap: Map<Long, NativeInteropAllNullableTypes>?
  ): Map<Long, NativeInteropAllNullableTypes>? {
    return classMap
  }

  override fun echoNullableEnum(anEnum: NativeInteropAnEnum?): NativeInteropAnEnum? {
    return anEnum
  }

  override fun echoAnotherNullableEnum(
      anotherEnum: NativeInteropAnotherEnum?
  ): NativeInteropAnotherEnum? {
    return anotherEnum
  }

  override fun echoOptionalNullableInt(aNullableInt: Long?): Long? {
    return aNullableInt
  }

  override fun echoNamedNullableString(aNullableString: String?): String? {
    return aNullableString
  }

  override suspend fun noopAsync() {
    return
  }

  override suspend fun echoAsyncInt(anInt: Long): Long {
    return anInt
  }

  override suspend fun echoAsyncDouble(aDouble: Double): Double {
    return aDouble
  }

  override suspend fun echoAsyncBool(aBool: Boolean): Boolean {
    return aBool
  }

  override suspend fun echoAsyncString(aString: String): String {
    return aString
  }

  override suspend fun echoAsyncUint8List(aUint8List: ByteArray): ByteArray {
    return aUint8List
  }

  override suspend fun echoAsyncInt32List(aInt32List: IntArray): IntArray {
    return aInt32List
  }

  override suspend fun echoAsyncInt64List(aInt64List: LongArray): LongArray {
    return aInt64List
  }

  override suspend fun echoAsyncFloat64List(aFloat64List: DoubleArray): DoubleArray {
    return aFloat64List
  }

  override suspend fun echoAsyncObject(anObject: Any): Any {
    return anObject
  }

  override suspend fun echoAsyncList(list: List<Any?>): List<Any?> {
    return list
  }

  override suspend fun echoAsyncEnumList(
      enumList: List<NativeInteropAnEnum?>
  ): List<NativeInteropAnEnum?> {
    return enumList
  }

  override suspend fun echoAsyncClassList(
      classList: List<NativeInteropAllNullableTypes?>
  ): List<NativeInteropAllNullableTypes?> {
    return classList
  }

  override suspend fun echoAsyncMap(map: Map<Any?, Any?>): Map<Any?, Any?> {
    return map
  }

  override suspend fun echoAsyncStringMap(stringMap: Map<String?, String?>): Map<String?, String?> {
    return stringMap
  }

  override suspend fun echoAsyncIntMap(intMap: Map<Long?, Long?>): Map<Long?, Long?> {
    return intMap
  }

  override suspend fun echoAsyncEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?> {
    return enumMap
  }

  override suspend fun echoAsyncClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>
  ): Map<Long?, NativeInteropAllNullableTypes?> {
    return classMap
  }

  override suspend fun echoAsyncEnum(anEnum: NativeInteropAnEnum): NativeInteropAnEnum {
    return anEnum
  }

  override suspend fun echoAnotherAsyncEnum(
      anotherEnum: NativeInteropAnotherEnum
  ): NativeInteropAnotherEnum {
    return anotherEnum
  }

  override suspend fun throwAsyncError(): Any? {
    throw Exception("An error")
  }

  override suspend fun throwAsyncErrorFromVoid() {
    throw Exception("An error")
  }

  override suspend fun throwAsyncFlutterError(): Any? {
    throw NativeInteropTestsError("code", "message", "details")
  }

  override suspend fun echoAsyncNativeInteropAllTypes(
      everything: NativeInteropAllTypes
  ): NativeInteropAllTypes {
    return everything
  }

  override suspend fun echoAsyncSealedClass(
      sealedClass: NativeInteropSealedClass
  ): NativeInteropSealedClass {
    return sealedClass
  }

  override suspend fun echoAsyncNullableNativeInteropAllNullableTypes(
      everything: NativeInteropAllNullableTypes?
  ): NativeInteropAllNullableTypes? {
    return everything
  }

  override suspend fun echoAsyncNullableNativeInteropAllNullableTypesWithoutRecursion(
      everything: NativeInteropAllNullableTypesWithoutRecursion?
  ): NativeInteropAllNullableTypesWithoutRecursion? {
    return everything
  }

  override suspend fun echoAsyncNullableInt(anInt: Long?): Long? {
    return anInt
  }

  override suspend fun echoAsyncNullableDouble(aDouble: Double?): Double? {
    return aDouble
  }

  override suspend fun echoAsyncNullableBool(aBool: Boolean?): Boolean? {
    return aBool
  }

  override suspend fun echoAsyncNullableString(aString: String?): String? {
    return aString
  }

  override suspend fun echoAsyncNullableUint8List(aUint8List: ByteArray?): ByteArray? {
    return aUint8List
  }

  override suspend fun echoAsyncNullableInt32List(aInt32List: IntArray?): IntArray? {
    return aInt32List
  }

  override suspend fun echoAsyncNullableInt64List(aInt64List: LongArray?): LongArray? {
    return aInt64List
  }

  override suspend fun echoAsyncNullableFloat64List(aFloat64List: DoubleArray?): DoubleArray? {
    return aFloat64List
  }

  override suspend fun echoAsyncNullableObject(anObject: Any?): Any? {
    return anObject
  }

  override suspend fun echoAsyncNullableList(list: List<Any?>?): List<Any?>? {
    return list
  }

  override suspend fun echoAsyncNullableEnumList(
      enumList: List<NativeInteropAnEnum?>?
  ): List<NativeInteropAnEnum?>? {
    return enumList
  }

  override suspend fun echoAsyncNullableClassList(
      classList: List<NativeInteropAllNullableTypes?>?
  ): List<NativeInteropAllNullableTypes?>? {
    return classList
  }

  override suspend fun echoAsyncNullableMap(map: Map<Any?, Any?>?): Map<Any?, Any?>? {
    return map
  }

  override suspend fun echoAsyncNullableStringMap(
      stringMap: Map<String?, String?>?
  ): Map<String?, String?>? {
    return stringMap
  }

  override suspend fun echoAsyncNullableIntMap(intMap: Map<Long?, Long?>?): Map<Long?, Long?>? {
    return intMap
  }

  override suspend fun echoAsyncNullableEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>?
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? {
    return enumMap
  }

  override suspend fun echoAsyncNullableClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>?
  ): Map<Long?, NativeInteropAllNullableTypes?>? {
    return classMap
  }

  override suspend fun echoAsyncNullableEnum(anEnum: NativeInteropAnEnum?): NativeInteropAnEnum? {
    return anEnum
  }

  override suspend fun echoAnotherAsyncNullableEnum(
      anotherEnum: NativeInteropAnotherEnum?
  ): NativeInteropAnotherEnum? {
    return anotherEnum
  }

  override fun callFlutterNoop() {
    return niFlutterApi()!!.noop()
  }

  override fun callFlutterThrowError(): Any? {
    return niFlutterApi()!!.throwError()
  }

  override fun callFlutterThrowErrorFromVoid() {
    return niFlutterApi()!!.throwErrorFromVoid()
  }

  override fun callFlutterEchoNativeInteropAllTypes(
      everything: NativeInteropAllTypes
  ): NativeInteropAllTypes {
    return niFlutterApi()!!.echoNativeInteropAllTypes(everything)
  }

  override fun callFlutterEchoNativeInteropAllNullableTypes(
      everything: NativeInteropAllNullableTypes?
  ): NativeInteropAllNullableTypes? {
    return niFlutterApi()!!.echoNativeInteropAllNullableTypes(everything)
  }

  override fun callFlutterEchoSealedClass(
      sealedClass: NativeInteropSealedClass
  ): NativeInteropSealedClass {
    return niFlutterApi()!!.echoNativeInteropSealedClass(sealedClass)
  }

  override fun callFlutterSendMultipleNullableTypes(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): NativeInteropAllNullableTypes {
    return niFlutterApi()!!.sendMultipleNullableTypes(aNullableBool, aNullableInt, aNullableString)
  }

  override fun callFlutterEchoNativeInteropAllNullableTypesWithoutRecursion(
      everything: NativeInteropAllNullableTypesWithoutRecursion?
  ): NativeInteropAllNullableTypesWithoutRecursion? {
    return niFlutterApi()!!.echoNativeInteropAllNullableTypesWithoutRecursion(everything)
  }

  override fun callFlutterSendMultipleNullableTypesWithoutRecursion(
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableString: String?
  ): NativeInteropAllNullableTypesWithoutRecursion {
    return niFlutterApi()!!.sendMultipleNullableTypesWithoutRecursion(
        aNullableBool, aNullableInt, aNullableString)
  }

  override fun callFlutterEchoBool(aBool: Boolean): Boolean {
    return niFlutterApi()!!.echoBool(aBool)
  }

  override fun callFlutterEchoInt(anInt: Long): Long {
    return niFlutterApi()!!.echoInt(anInt)
  }

  override fun callFlutterEchoDouble(aDouble: Double): Double {
    return niFlutterApi()!!.echoDouble(aDouble)
  }

  override fun callFlutterEchoString(aString: String): String {
    return niFlutterApi()!!.echoString(aString)
  }

  override fun callFlutterEchoUint8List(list: ByteArray): ByteArray {
    return niFlutterApi()!!.echoUint8List(list)
  }

  override fun callFlutterEchoInt32List(list: IntArray): IntArray {
    return niFlutterApi()!!.echoInt32List(list)
  }

  override fun callFlutterEchoInt64List(list: LongArray): LongArray {
    return niFlutterApi()!!.echoInt64List(list)
  }

  override fun callFlutterEchoFloat64List(list: DoubleArray): DoubleArray {
    return niFlutterApi()!!.echoFloat64List(list)
  }

  override fun callFlutterEchoList(list: List<Any?>): List<Any?> {
    return niFlutterApi()!!.echoList(list)
  }

  override fun callFlutterEchoEnumList(
      enumList: List<NativeInteropAnEnum?>
  ): List<NativeInteropAnEnum?> {
    return niFlutterApi()!!.echoEnumList(enumList)
  }

  override fun callFlutterEchoClassList(
      classList: List<NativeInteropAllNullableTypes?>
  ): List<NativeInteropAllNullableTypes?> {
    return niFlutterApi()!!.echoClassList(classList)
  }

  override fun callFlutterEchoNonNullEnumList(
      enumList: List<NativeInteropAnEnum>
  ): List<NativeInteropAnEnum> {
    return niFlutterApi()!!.echoNonNullEnumList(enumList)
  }

  override fun callFlutterEchoNonNullClassList(
      classList: List<NativeInteropAllNullableTypes>
  ): List<NativeInteropAllNullableTypes> {
    return niFlutterApi()!!.echoNonNullClassList(classList)
  }

  override fun callFlutterEchoMap(map: Map<Any?, Any?>): Map<Any?, Any?> {
    return niFlutterApi()!!.echoMap(map)
  }

  override fun callFlutterEchoStringMap(stringMap: Map<String?, String?>): Map<String?, String?> {
    return niFlutterApi()!!.echoStringMap(stringMap)
  }

  override fun callFlutterEchoIntMap(intMap: Map<Long?, Long?>): Map<Long?, Long?> {
    return niFlutterApi()!!.echoIntMap(intMap)
  }

  override fun callFlutterEchoEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?> {
    return niFlutterApi()!!.echoEnumMap(enumMap)
  }

  override fun callFlutterEchoClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>
  ): Map<Long?, NativeInteropAllNullableTypes?> {
    return niFlutterApi()!!.echoClassMap(classMap)
  }

  override fun callFlutterEchoNonNullStringMap(
      stringMap: Map<String, String>
  ): Map<String, String> {
    return niFlutterApi()!!.echoNonNullStringMap(stringMap)
  }

  override fun callFlutterEchoNonNullIntMap(intMap: Map<Long, Long>): Map<Long, Long> {
    return niFlutterApi()!!.echoNonNullIntMap(intMap)
  }

  override fun callFlutterEchoNonNullEnumMap(
      enumMap: Map<NativeInteropAnEnum, NativeInteropAnEnum>
  ): Map<NativeInteropAnEnum, NativeInteropAnEnum> {
    return niFlutterApi()!!.echoNonNullEnumMap(enumMap)
  }

  override fun callFlutterEchoNonNullClassMap(
      classMap: Map<Long, NativeInteropAllNullableTypes>
  ): Map<Long, NativeInteropAllNullableTypes> {
    return niFlutterApi()!!.echoNonNullClassMap(classMap)
  }

  override fun callFlutterEchoEnum(anEnum: NativeInteropAnEnum): NativeInteropAnEnum {
    return niFlutterApi()!!.echoEnum(anEnum)
  }

  override fun callFlutterEchoNativeInteropAnotherEnum(
      anotherEnum: NativeInteropAnotherEnum
  ): NativeInteropAnotherEnum {
    return niFlutterApi()!!.echoNativeInteropAnotherEnum(anotherEnum)
  }

  override fun callFlutterEchoNullableBool(aBool: Boolean?): Boolean? {
    return niFlutterApi()!!.echoNullableBool(aBool)
  }

  override fun callFlutterEchoNullableInt(anInt: Long?): Long? {
    return niFlutterApi()!!.echoNullableInt(anInt)
  }

  override fun callFlutterEchoNullableDouble(aDouble: Double?): Double? {
    return niFlutterApi()!!.echoNullableDouble(aDouble)
  }

  override fun callFlutterEchoNullableString(aString: String?): String? {
    return niFlutterApi()!!.echoNullableString(aString)
  }

  override fun callFlutterEchoNullableUint8List(list: ByteArray?): ByteArray? {
    return niFlutterApi()!!.echoNullableUint8List(list)
  }

  override fun callFlutterEchoNullableInt32List(list: IntArray?): IntArray? {
    return niFlutterApi()!!.echoNullableInt32List(list)
  }

  override fun callFlutterEchoNullableInt64List(list: LongArray?): LongArray? {
    return niFlutterApi()!!.echoNullableInt64List(list)
  }

  override fun callFlutterEchoNullableFloat64List(list: DoubleArray?): DoubleArray? {
    return niFlutterApi()!!.echoNullableFloat64List(list)
  }

  override fun callFlutterEchoNullableList(list: List<Any?>?): List<Any?>? {
    return niFlutterApi()!!.echoNullableList(list)
  }

  override fun callFlutterEchoNullableEnumList(
      enumList: List<NativeInteropAnEnum?>?
  ): List<NativeInteropAnEnum?>? {
    return niFlutterApi()!!.echoNullableEnumList(enumList)
  }

  override fun callFlutterEchoNullableClassList(
      classList: List<NativeInteropAllNullableTypes?>?
  ): List<NativeInteropAllNullableTypes?>? {
    return niFlutterApi()!!.echoNullableClassList(classList)
  }

  override fun callFlutterEchoNullableNonNullEnumList(
      enumList: List<NativeInteropAnEnum>?
  ): List<NativeInteropAnEnum>? {
    return niFlutterApi()!!.echoNullableNonNullEnumList(enumList)
  }

  override fun callFlutterEchoNullableNonNullClassList(
      classList: List<NativeInteropAllNullableTypes>?
  ): List<NativeInteropAllNullableTypes>? {
    return niFlutterApi()!!.echoNullableNonNullClassList(classList)
  }

  override fun callFlutterEchoNullableMap(map: Map<Any?, Any?>?): Map<Any?, Any?>? {
    return niFlutterApi()!!.echoNullableMap(map)
  }

  override fun callFlutterEchoNullableStringMap(
      stringMap: Map<String?, String?>?
  ): Map<String?, String?>? {
    return niFlutterApi()!!.echoNullableStringMap(stringMap)
  }

  override fun callFlutterEchoNullableIntMap(intMap: Map<Long?, Long?>?): Map<Long?, Long?>? {
    return niFlutterApi()!!.echoNullableIntMap(intMap)
  }

  override fun callFlutterEchoNullableEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>?
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? {
    return niFlutterApi()!!.echoNullableEnumMap(enumMap)
  }

  override fun callFlutterEchoNullableClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>?
  ): Map<Long?, NativeInteropAllNullableTypes?>? {
    return niFlutterApi()!!.echoNullableClassMap(classMap)
  }

  override fun callFlutterEchoNullableNonNullStringMap(
      stringMap: Map<String, String>?
  ): Map<String, String>? {
    return niFlutterApi()!!.echoNullableNonNullStringMap(stringMap)
  }

  override fun callFlutterEchoNullableNonNullIntMap(intMap: Map<Long, Long>?): Map<Long, Long>? {
    return niFlutterApi()!!.echoNullableNonNullIntMap(intMap)
  }

  override fun callFlutterEchoNullableNonNullEnumMap(
      enumMap: Map<NativeInteropAnEnum, NativeInteropAnEnum>?
  ): Map<NativeInteropAnEnum, NativeInteropAnEnum>? {
    return niFlutterApi()!!.echoNullableNonNullEnumMap(enumMap)
  }

  override fun callFlutterEchoNullableNonNullClassMap(
      classMap: Map<Long, NativeInteropAllNullableTypes>?
  ): Map<Long, NativeInteropAllNullableTypes>? {
    return niFlutterApi()!!.echoNullableNonNullClassMap(classMap)
  }

  override fun callFlutterEchoNullableEnum(anEnum: NativeInteropAnEnum?): NativeInteropAnEnum? {
    return niFlutterApi()!!.echoNullableEnum(anEnum)
  }

  override fun callFlutterEchoAnotherNullableEnum(
      anotherEnum: NativeInteropAnotherEnum?
  ): NativeInteropAnotherEnum? {
    return niFlutterApi()!!.echoAnotherNullableEnum(anotherEnum)
  }

  override suspend fun callFlutterNoopAsync() {
    return niFlutterApi()!!.noopAsync()
  }

  override suspend fun callFlutterEchoAsyncNativeInteropAllTypes(
      everything: NativeInteropAllTypes
  ): NativeInteropAllTypes {
    return niFlutterApi()!!.echoAsyncNativeInteropAllTypes(everything)
  }

  override suspend fun callFlutterEchoAsyncNullableNativeInteropAllNullableTypes(
      everything: NativeInteropAllNullableTypes?
  ): NativeInteropAllNullableTypes? {
    return niFlutterApi()!!.echoAsyncNullableNativeInteropAllNullableTypes(everything)
  }

  override suspend fun callFlutterEchoAsyncNullableNativeInteropAllNullableTypesWithoutRecursion(
      everything: NativeInteropAllNullableTypesWithoutRecursion?
  ): NativeInteropAllNullableTypesWithoutRecursion? {
    return niFlutterApi()!!.echoAsyncNullableNativeInteropAllNullableTypesWithoutRecursion(
        everything)
  }

  override suspend fun callFlutterEchoAsyncBool(aBool: Boolean): Boolean {
    return niFlutterApi()!!.echoAsyncBool(aBool)
  }

  override suspend fun callFlutterEchoAsyncInt(anInt: Long): Long {
    return niFlutterApi()!!.echoAsyncInt(anInt)
  }

  override suspend fun callFlutterEchoAsyncDouble(aDouble: Double): Double {
    return niFlutterApi()!!.echoAsyncDouble(aDouble)
  }

  override suspend fun callFlutterEchoAsyncString(aString: String): String {
    return niFlutterApi()!!.echoAsyncString(aString)
  }

  override suspend fun callFlutterEchoAsyncUint8List(list: ByteArray): ByteArray {
    return niFlutterApi()!!.echoAsyncUint8List(list)
  }

  override suspend fun callFlutterEchoAsyncInt32List(list: IntArray): IntArray {
    return niFlutterApi()!!.echoAsyncInt32List(list)
  }

  override suspend fun callFlutterEchoAsyncInt64List(list: LongArray): LongArray {
    return niFlutterApi()!!.echoAsyncInt64List(list)
  }

  override suspend fun callFlutterEchoAsyncFloat64List(list: DoubleArray): DoubleArray {
    return niFlutterApi()!!.echoAsyncFloat64List(list)
  }

  override suspend fun callFlutterEchoAsyncObject(anObject: Any): Any {
    return niFlutterApi()!!.echoAsyncObject(anObject)
  }

  override suspend fun callFlutterEchoAsyncList(list: List<Any?>): List<Any?> {
    return niFlutterApi()!!.echoAsyncList(list)
  }

  override suspend fun callFlutterEchoAsyncEnumList(
      enumList: List<NativeInteropAnEnum?>
  ): List<NativeInteropAnEnum?> {
    return niFlutterApi()!!.echoAsyncEnumList(enumList)
  }

  override suspend fun callFlutterEchoAsyncClassList(
      classList: List<NativeInteropAllNullableTypes?>
  ): List<NativeInteropAllNullableTypes?> {
    return niFlutterApi()!!.echoAsyncClassList(classList)
  }

  override suspend fun callFlutterEchoAsyncNonNullEnumList(
      enumList: List<NativeInteropAnEnum>
  ): List<NativeInteropAnEnum> {
    return niFlutterApi()!!.echoAsyncNonNullEnumList(enumList)
  }

  override suspend fun callFlutterEchoAsyncNonNullClassList(
      classList: List<NativeInteropAllNullableTypes>
  ): List<NativeInteropAllNullableTypes> {
    return niFlutterApi()!!.echoAsyncNonNullClassList(classList)
  }

  override suspend fun callFlutterEchoAsyncMap(map: Map<Any?, Any?>): Map<Any?, Any?> {
    return niFlutterApi()!!.echoAsyncMap(map)
  }

  override suspend fun callFlutterEchoAsyncStringMap(
      stringMap: Map<String?, String?>
  ): Map<String?, String?> {
    return niFlutterApi()!!.echoAsyncStringMap(stringMap)
  }

  override suspend fun callFlutterEchoAsyncIntMap(intMap: Map<Long?, Long?>): Map<Long?, Long?> {
    return niFlutterApi()!!.echoAsyncIntMap(intMap)
  }

  override suspend fun callFlutterEchoAsyncEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?> {
    return niFlutterApi()!!.echoAsyncEnumMap(enumMap)
  }

  override suspend fun callFlutterEchoAsyncClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>
  ): Map<Long?, NativeInteropAllNullableTypes?> {
    return niFlutterApi()!!.echoAsyncClassMap(classMap)
  }

  override suspend fun callFlutterEchoAsyncEnum(anEnum: NativeInteropAnEnum): NativeInteropAnEnum {
    return niFlutterApi()!!.echoAsyncEnum(anEnum)
  }

  override suspend fun callFlutterEchoAnotherAsyncEnum(
      anotherEnum: NativeInteropAnotherEnum
  ): NativeInteropAnotherEnum {
    return niFlutterApi()!!.echoAnotherAsyncEnum(anotherEnum)
  }

  override suspend fun callFlutterEchoAsyncNullableBool(aBool: Boolean?): Boolean? {
    return niFlutterApi()!!.echoAsyncNullableBool(aBool)
  }

  override suspend fun callFlutterEchoAsyncNullableInt(anInt: Long?): Long? {
    return niFlutterApi()!!.echoAsyncNullableInt(anInt)
  }

  override suspend fun callFlutterEchoAsyncNullableDouble(aDouble: Double?): Double? {
    return niFlutterApi()!!.echoAsyncNullableDouble(aDouble)
  }

  override suspend fun callFlutterEchoAsyncNullableString(aString: String?): String? {
    return niFlutterApi()!!.echoAsyncNullableString(aString)
  }

  override suspend fun callFlutterEchoAsyncNullableUint8List(list: ByteArray?): ByteArray? {
    return niFlutterApi()!!.echoAsyncNullableUint8List(list)
  }

  override suspend fun callFlutterEchoAsyncNullableInt32List(list: IntArray?): IntArray? {
    return niFlutterApi()!!.echoAsyncNullableInt32List(list)
  }

  override suspend fun callFlutterEchoAsyncNullableInt64List(list: LongArray?): LongArray? {
    return niFlutterApi()!!.echoAsyncNullableInt64List(list)
  }

  override suspend fun callFlutterEchoAsyncNullableFloat64List(list: DoubleArray?): DoubleArray? {
    return niFlutterApi()!!.echoAsyncNullableFloat64List(list)
  }

  override suspend fun callFlutterThrowFlutterErrorAsync(): Any? {
    return niFlutterApi()!!.throwFlutterErrorAsync()
  }

  override suspend fun callFlutterEchoAsyncNullableObject(anObject: Any?): Any? {
    return niFlutterApi()!!.echoAsyncNullableObject(anObject)
  }

  override suspend fun callFlutterEchoAsyncNullableList(list: List<Any?>?): List<Any?>? {
    return niFlutterApi()!!.echoAsyncNullableList(list)
  }

  override suspend fun callFlutterEchoAsyncNullableEnumList(
      enumList: List<NativeInteropAnEnum?>?
  ): List<NativeInteropAnEnum?>? {
    return niFlutterApi()!!.echoAsyncNullableEnumList(enumList)
  }

  override suspend fun callFlutterEchoAsyncNullableClassList(
      classList: List<NativeInteropAllNullableTypes?>?
  ): List<NativeInteropAllNullableTypes?>? {
    return niFlutterApi()!!.echoAsyncNullableClassList(classList)
  }

  override suspend fun callFlutterEchoAsyncNullableNonNullEnumList(
      enumList: List<NativeInteropAnEnum>?
  ): List<NativeInteropAnEnum>? {
    return niFlutterApi()!!.echoAsyncNullableNonNullEnumList(enumList)
  }

  override suspend fun callFlutterEchoAsyncNullableNonNullClassList(
      classList: List<NativeInteropAllNullableTypes>?
  ): List<NativeInteropAllNullableTypes>? {
    return niFlutterApi()!!.echoAsyncNullableNonNullClassList(classList)
  }

  override suspend fun callFlutterEchoAsyncNullableMap(map: Map<Any?, Any?>?): Map<Any?, Any?>? {
    return niFlutterApi()!!.echoAsyncNullableMap(map)
  }

  override suspend fun callFlutterEchoAsyncNullableStringMap(
      stringMap: Map<String?, String?>?
  ): Map<String?, String?>? {
    return niFlutterApi()!!.echoAsyncNullableStringMap(stringMap)
  }

  override suspend fun callFlutterEchoAsyncNullableIntMap(
      intMap: Map<Long?, Long?>?
  ): Map<Long?, Long?>? {
    return niFlutterApi()!!.echoAsyncNullableIntMap(intMap)
  }

  override suspend fun callFlutterEchoAsyncNullableEnumMap(
      enumMap: Map<NativeInteropAnEnum?, NativeInteropAnEnum?>?
  ): Map<NativeInteropAnEnum?, NativeInteropAnEnum?>? {
    return niFlutterApi()!!.echoAsyncNullableEnumMap(enumMap)
  }

  override suspend fun callFlutterEchoAsyncNullableClassMap(
      classMap: Map<Long?, NativeInteropAllNullableTypes?>?
  ): Map<Long?, NativeInteropAllNullableTypes?>? {
    return niFlutterApi()!!.echoAsyncNullableClassMap(classMap)
  }

  override suspend fun callFlutterEchoAsyncNullableEnum(
      anEnum: NativeInteropAnEnum?
  ): NativeInteropAnEnum? {
    return niFlutterApi()!!.echoAsyncNullableEnum(anEnum)
  }

  override suspend fun callFlutterEchoAnotherAsyncNullableEnum(
      anotherEnum: NativeInteropAnotherEnum?
  ): NativeInteropAnotherEnum? {
    return niFlutterApi()!!.echoAnotherAsyncNullableEnum(anotherEnum)
  }

  override fun isMainThread(): Boolean {
    return Thread.currentThread() == Looper.getMainLooper().thread
  }

  override suspend fun asyncIsBackgroundThread(): Boolean {
    return withContext(Dispatchers.Default) {
      Thread.currentThread() != Looper.getMainLooper().thread
    }
  }

  private var getterValue: Long = 0L

  override fun isGetter(): Boolean {
    return true
  }

  override fun getGetter(): Long {
    return getterValue
  }

  override fun setSetter(value: Long) {
    getterValue = value
  }

  override suspend fun callFlutterNoopOnBackgroundThread(): Boolean {
    return withContext(Dispatchers.Default) {
      try {
        niFlutterApi()!!.noopAsync()
        true
      } catch (e: Exception) {
        false
      }
    }
  }

  override fun testDeregisterHostApi(): Boolean {
    val name = "testDeregisterHostInstance"
    val singleApi = NativeInteropIntegrationTests()
    NativeInteropHostIntegrationCoreApiRegistrar()
        .register(singleApi, requireBinding(), name = name)
    if (NativeInteropHostIntegrationCoreApiRegistrar.golubetsResolveInstance(
        Long.MIN_VALUE, Long.MIN_VALUE, name) == null) {
      return false
    }
    NativeInteropHostIntegrationCoreApiRegistrar()
        .unregister(singleApi, requireBinding(), name = name)
    if (NativeInteropHostIntegrationCoreApiRegistrar.golubetsResolveInstance(
        Long.MIN_VALUE, Long.MIN_VALUE, name) != null) {
      return false
    }

    // Out-of-order instance-aware unregister(api) keeps other engine instances intact,
    // and duplicate or never-registered unregister calls are safe no-ops.
    val outOfOrderName = "testOutOfOrderHostInstance"
    val api1 = NativeInteropIntegrationTests()
    val api2 = NativeInteropIntegrationTests()
    val unregisteredApi = NativeInteropIntegrationTests()
    NativeInteropHostIntegrationCoreApiRegistrar()
        .register(api1, requireBinding(), name = outOfOrderName)
    NativeInteropHostIntegrationCoreApiRegistrar()
        .register(api2, requireBinding(), name = outOfOrderName)
    val reg2 =
        NativeInteropHostIntegrationCoreApiRegistrar.golubetsResolveInstance(
            Long.MIN_VALUE, Long.MIN_VALUE, outOfOrderName)
    NativeInteropHostIntegrationCoreApiRegistrar()
        .unregister(api1, requireBinding(), name = outOfOrderName)
    NativeInteropHostIntegrationCoreApiRegistrar()
        .unregister(api1, requireBinding(), name = outOfOrderName)
    NativeInteropHostIntegrationCoreApiRegistrar()
        .unregister(unregisteredApi, requireBinding(), name = outOfOrderName)
    if (reg2 == null ||
        NativeInteropHostIntegrationCoreApiRegistrar.golubetsResolveInstance(
            Long.MIN_VALUE, Long.MIN_VALUE, outOfOrderName) !== reg2) {
      return false
    }
    NativeInteropHostIntegrationCoreApiRegistrar()
        .unregister(api2, requireBinding(), name = outOfOrderName)
    if (NativeInteropHostIntegrationCoreApiRegistrar.golubetsResolveInstance(
        Long.MIN_VALUE, Long.MIN_VALUE, outOfOrderName) != null) {
      return false
    }

    // Default instance is distinct from an explicit empty string (name = "").
    val defaultReservedWrapper =
        NativeInteropReservedNamesHostApiRegistrar.golubetsResolveInstance(
            Long.MIN_VALUE, Long.MIN_VALUE)
    if (defaultReservedWrapper == null ||
        NativeInteropReservedNamesHostApiRegistrar.golubetsResolveInstance(
            Long.MIN_VALUE, Long.MIN_VALUE, "") != null) {
      return false
    }
    val emptyNameApi = NativeInteropReservedNamesHostApiImpl()
    NativeInteropReservedNamesHostApiRegistrar().register(emptyNameApi, requireBinding(), name = "")
    val emptyNameWrapper =
        NativeInteropReservedNamesHostApiRegistrar.golubetsResolveInstance(
            Long.MIN_VALUE, Long.MIN_VALUE, "")
    val emptyNameIsolated =
        emptyNameWrapper != null &&
            emptyNameWrapper !== defaultReservedWrapper &&
            NativeInteropReservedNamesHostApiRegistrar.golubetsResolveInstance(
                Long.MIN_VALUE, Long.MIN_VALUE) === defaultReservedWrapper
    NativeInteropReservedNamesHostApiRegistrar()
        .unregister(emptyNameApi, requireBinding(), name = "")
    if (!emptyNameIsolated ||
        NativeInteropReservedNamesHostApiRegistrar.golubetsResolveInstance(
            Long.MIN_VALUE, Long.MIN_VALUE, "") != null ||
        NativeInteropReservedNamesHostApiRegistrar.golubetsResolveInstance(
            Long.MIN_VALUE, Long.MIN_VALUE) !== defaultReservedWrapper) {
      return false
    }

    // Exercise real secondary FlutterEngine attach and out-of-order destroy while primary engine
    // remains active.
    if (context != null) {
      var engineCheckPassed = false
      val runEngineCheck = {
        val preexistingHostWrapper =
            NativeInteropHostIntegrationCoreApiRegistrar.golubetsResolveInstance(
                Long.MIN_VALUE, Long.MIN_VALUE)
        val engine2 = FlutterEngine(context, null, false)
        val engine3 = FlutterEngine(context, null, false)
        engine2.plugins.add(TestPlugin())
        engine3.plugins.add(TestPlugin())
        val engine3HostWrapper =
            NativeInteropHostIntegrationCoreApiRegistrar.golubetsResolveInstance(
                Long.MIN_VALUE, Long.MIN_VALUE)
        val engine3ReservedWrapper =
            NativeInteropReservedNamesHostApiRegistrar.golubetsResolveInstance(
                Long.MIN_VALUE, Long.MIN_VALUE)
        engine2.destroy()
        val afterSecondDestroyed =
            engine3HostWrapper != null &&
                engine3HostWrapper !== preexistingHostWrapper &&
                engine3ReservedWrapper != null &&
                engine3ReservedWrapper !== defaultReservedWrapper &&
                NativeInteropHostIntegrationCoreApiRegistrar.golubetsResolveInstance(
                    Long.MIN_VALUE, Long.MIN_VALUE) === engine3HostWrapper &&
                NativeInteropReservedNamesHostApiRegistrar.golubetsResolveInstance(
                    Long.MIN_VALUE, Long.MIN_VALUE) === engine3ReservedWrapper
        engine3.destroy()
        val afterThirdDestroyed =
            NativeInteropHostIntegrationCoreApiRegistrar.golubetsResolveInstance(
                Long.MIN_VALUE, Long.MIN_VALUE) === preexistingHostWrapper &&
                NativeInteropReservedNamesHostApiRegistrar.golubetsResolveInstance(
                    Long.MIN_VALUE, Long.MIN_VALUE) === defaultReservedWrapper
        engineCheckPassed = afterSecondDestroyed && afterThirdDestroyed
      }
      if (Looper.myLooper() == Looper.getMainLooper()) {
        runEngineCheck()
      } else {
        val latch = java.util.concurrent.CountDownLatch(1)
        Handler(Looper.getMainLooper()).post {
          try {
            runEngineCheck()
          } finally {
            latch.countDown()
          }
        }
        if (!latch.await(10, java.util.concurrent.TimeUnit.SECONDS)) {
          return false
        }
      }
      if (!engineCheckPassed) {
        return false
      }
    }
    return true
  }

  override fun testDeregisterFlutterApi(): Boolean {
    val name = "testDeregisterFlutterInstance"
    val makeApi = { label: String ->
      object : NativeInteropReservedNamesFlutterApiBridge {
        override fun release(value: String): String = "$label:$value"

        override fun type(): String = label

        override fun implementIn(value: String): String = "$label:$value"

        override fun isNull(): Boolean = false

        override fun getReference(): String = label

        override fun register(value: String): String = "$label:$value"

        override fun dartApi(): String = label
      }
    }
    val api1 = makeApi("engine1")
    val api2 = makeApi("engine2")
    // Registrations without engine keys are found through the top-of-stack fallback.
    val noKey = Long.MIN_VALUE
    val binding = requireBinding()

    NativeInteropReservedNamesFlutterApiRegistrar().registerInstance(api1, noKey, noKey, name)
    NativeInteropReservedNamesFlutterApiRegistrar().registerInstance(api2, noKey, noKey, name)
    if (NativeInteropReservedNamesFlutterApiRegistrar()
        .getInstance(binding, name)
        ?.release("ping") != "engine2:ping") {
      return false
    }

    // Re-registering api1 updates it in place, so api2 stays on top.
    NativeInteropReservedNamesFlutterApiRegistrar().registerInstance(api1, noKey, noKey, name)
    if (NativeInteropReservedNamesFlutterApiRegistrar()
        .getInstance(binding, name)
        ?.release("ping") != "engine2:ping") {
      return false
    }

    // Single unregister(api1) removes api1 completely and restores api2.
    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(api1, name = name)
    if (NativeInteropReservedNamesFlutterApiRegistrar()
        .getInstance(binding, name)
        ?.release("ping") != "engine2:ping") {
      return false
    }

    // Out-of-order unregister on bottom entry leaves top entry intact.
    val api3 = makeApi("engine3")
    NativeInteropReservedNamesFlutterApiRegistrar().registerInstance(api3, noKey, noKey, name)
    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(api2, name = name)
    if (NativeInteropReservedNamesFlutterApiRegistrar()
        .getInstance(binding, name)
        ?.release("ping") != "engine3:ping") {
      return false
    }

    // Unregistering the remaining entry clears the registration list completely.
    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(api3, name = name)
    if (NativeInteropReservedNamesFlutterApiRegistrar().getInstance(binding, name) != null) {
      return false
    }

    // Duplicate unregister is a safe no-op.
    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(api3, name = name)
    return NativeInteropReservedNamesFlutterApiRegistrar().getInstance(binding, name) == null
  }

  private val namedHostApis = mutableMapOf<String, NativeInteropIntegrationTests>()

  override fun registerAndImmediatelyDeregisterHostApi(name: String) {
    val api = NativeInteropIntegrationTests()
    NativeInteropHostIntegrationCoreApiRegistrar().register(api, requireBinding(), name = name)
    NativeInteropHostIntegrationCoreApiRegistrar().unregister(api, requireBinding(), name = name)
  }

  override fun registerNamedHostApi(name: String) {
    val api = NativeInteropIntegrationTests()
    namedHostApis[name] = api
    NativeInteropHostIntegrationCoreApiRegistrar().register(api, requireBinding(), name = name)
  }

  override fun deregisterNamedHostApi(name: String) {
    val api = namedHostApis.remove(name) ?: return
    NativeInteropHostIntegrationCoreApiRegistrar().unregister(api, requireBinding(), name = name)
  }

  override fun testCallDeregisteredFlutterApi(name: String): Boolean {
    return niFlutterApi(name) == null
  }

  override suspend fun testSecondaryEngineDartExecution(): Boolean {
    val appContext = context ?: return false
    val (deferred, concurrentDeferred) =
        SecondaryEngineCheckTracker.begin(expectConcurrentIsolate = true)
    var engine2: FlutterEngine? = null
    try {
      withContext(Dispatchers.Main) {
        // Attach TestPlugin to two secondary engines, destroy the first out-of-order, and execute
        // a live Dart isolate on the second while the primary engine remains active.
        val engine1 = FlutterEngine(appContext, null, false)
        val createdEngine2 = FlutterEngine(appContext, null, false)
        engine2 = createdEngine2
        val plugin1 = TestPlugin()
        val plugin2 = TestPlugin()
        engine1.plugins.add(plugin1)
        createdEngine2.plugins.add(plugin2)
        engine1.destroy()

        SecondaryEngineCheckTracker.markRegistrationReady(plugin2.niMessageApiImpl)
        val appBundlePath = FlutterInjector.instance().flutterLoader().findAppBundlePath()
        val entrypoint =
            DartExecutor.DartEntrypoint(
                appBundlePath,
                "package:shared_test_plugin_code/secondary_engine_entrypoints.dart",
                "secondaryEngineMain")
        createdEngine2.dartExecutor.executeDartEntrypoint(entrypoint)
      }
      return withTimeoutOrNull(15_000L) {
        val secondaryOk = deferred.await()
        concurrentDeferred?.await()
        secondaryOk
      } == true
    } finally {
      SecondaryEngineCheckTracker.reset()
      withContext(NonCancellable + Dispatchers.Main) { engine2?.destroy() }
    }
  }

  override fun isSecondaryEngineRegistrationReady(): Boolean {
    return SecondaryEngineCheckTracker.isReady()
  }

  override fun reportSecondaryEngineCheck(success: Boolean) {
    SecondaryEngineCheckTracker.report(success, this)
  }

  override fun notifyConcurrentIsolateResolved() {
    SecondaryEngineCheckTracker.markConcurrentIsolateResolved()
  }

  override fun registeredEngineKey(): Long {
    val registration =
        NativeInteropHostIntegrationCoreApiRegistrar.golubetsResolveInstance(
            Long.MIN_VALUE, Long.MIN_VALUE)
            ?: throw NativeInteropTestsError("no-registration", "No default Host API registration.")
    return NativeInteropHostIntegrationCoreApiRegistrar.golubetsEngineKeyOf(registration)
  }

  override fun pluginEngineIdentifierIsAvailable(): Boolean {
    // Match by signature rather than by name so that a getter renamed by R8 is still detected;
    // the point of the check is to catch generated code failing to find it after minification.
    val bindingClass = FlutterPlugin.FlutterPluginBinding::class.java
    return bindingClass.methods.any {
      it.declaringClass == bindingClass &&
          it.parameterCount == 0 &&
          it.returnType == java.lang.Long.TYPE
    }
  }
}

internal object SecondaryEngineCheckTracker {
  private val lock = Any()
  private var registrationReady = false
  private var expectedReceiver: WeakReference<NativeInteropIntegrationTests>? = null
  private var resultDeferred: CompletableDeferred<Boolean>? = null
  private var concurrentIsolateDeferred: CompletableDeferred<Unit>? = null

  fun begin(
      expectConcurrentIsolate: Boolean = false
  ): Pair<CompletableDeferred<Boolean>, CompletableDeferred<Unit>?> =
      synchronized(lock) {
        registrationReady = false
        expectedReceiver = null
        val result = CompletableDeferred<Boolean>().also { resultDeferred = it }
        val concurrent =
            if (expectConcurrentIsolate) {
              CompletableDeferred<Unit>().also { concurrentIsolateDeferred = it }
            } else {
              concurrentIsolateDeferred = null
              null
            }
        result to concurrent
      }

  fun markRegistrationReady(expected: NativeInteropIntegrationTests?) {
    synchronized(lock) {
      expectedReceiver = expected?.let { WeakReference(it) }
      registrationReady = true
    }
  }

  fun isReady(): Boolean = synchronized(lock) { registrationReady }

  fun report(success: Boolean, receiver: NativeInteropIntegrationTests) {
    val deferred: CompletableDeferred<Boolean>?
    val receiverMatches: Boolean
    synchronized(lock) {
      deferred = resultDeferred
      receiverMatches = expectedReceiver.let { it == null || it.get() === receiver }
    }
    deferred?.complete(success && receiverMatches)
  }

  fun markConcurrentIsolateResolved() {
    val deferred: CompletableDeferred<Unit>?
    synchronized(lock) { deferred = concurrentIsolateDeferred }
    deferred?.complete(Unit)
  }

  fun reset() {
    synchronized(lock) {
      registrationReady = false
      expectedReceiver = null
      resultDeferred = null
      concurrentIsolateDeferred = null
    }
  }
}

class NativeInteropReservedNamesHostApiImpl(private val binding: FlutterPluginBinding? = null) :
    NativeInteropReservedNamesHostApi {
  private var storedReference = ""

  override fun release(value: String): String {
    return value
  }

  override fun use(value: Long): Long {
    return value
  }

  override fun type(): String {
    return "type"
  }

  override fun isNull(): Boolean {
    return true
  }

  override fun isNullable(): Boolean? {
    return true
  }

  override fun isOpen(): Boolean {
    return true
  }

  override fun getReference(): String {
    return storedReference
  }

  override fun setReference(value: String) {
    storedReference = value
  }

  override fun getDefault(): String {
    return "default"
  }

  override suspend fun getValueAsync(): String {
    return "value"
  }

  override fun register(value: String): String {
    return value
  }

  override fun unregister(value: String): String {
    return value
  }

  override fun getGetInstance(): String {
    return "getInstance"
  }

  override fun echoReservedNames(names: NativeInteropReservedNames): NativeInteropReservedNames {
    return names
  }

  private fun flutterApi(): NativeInteropReservedNamesFlutterApi {
    return NativeInteropReservedNamesFlutterApiRegistrar().getInstance(checkNotNull(binding))!!
  }

  override fun callFlutterRelease(value: String): String {
    return flutterApi().release(value)
  }

  override fun callFlutterType(): String {
    return flutterApi().type()
  }

  override fun callFlutterImplementIn(value: String): String {
    return flutterApi().implementIn(value)
  }

  override fun callFlutterIsNull(): Boolean {
    return flutterApi().isNull()
  }

  override fun callFlutterGetReference(): String {
    return flutterApi().getReference()
  }

  override fun callFlutterRegister(value: String): String {
    return flutterApi().register(value)
  }

  override fun callFlutterDartApi(): String {
    return flutterApi().dartApi()
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
  var onCancelled: (() -> Unit)? = null

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

  // Closing the stream causes the Dart side to send a "cancel" call, so any
  // handler removal must wait until that call has been received. Removing the
  // handler immediately after endOfStream races with the "cancel" call, which
  // then fails with a MissingPluginException.
  override fun onCancel(p0: Any?) {
    onCancelled?.invoke()
  }
}

class NativeInteropSealedClassHostApiImpl(private val binding: FlutterPluginBinding? = null) :
    NativeInteropSealedClassHostApi {
  override fun echoShape(shape: NativeInteropShape): NativeInteropShape {
    return shape
  }

  override fun echoNullableShape(shape: NativeInteropShape?): NativeInteropShape? {
    return shape
  }

  override fun echoShapeList(shapes: List<NativeInteropShape>): List<NativeInteropShape> {
    return shapes
  }

  override fun echoShapeMap(
      shapes: Map<String, NativeInteropShape>
  ): Map<String, NativeInteropShape> {
    return shapes
  }

  override suspend fun echoAsyncShape(shape: NativeInteropShape): NativeInteropShape {
    return shape
  }

  override fun callFlutterEchoShape(shape: NativeInteropShape): NativeInteropShape {
    return NativeInteropSealedClassFlutterApiRegistrar()
        .getInstance(checkNotNull(binding))!!
        .echoShape(shape)
  }
}
