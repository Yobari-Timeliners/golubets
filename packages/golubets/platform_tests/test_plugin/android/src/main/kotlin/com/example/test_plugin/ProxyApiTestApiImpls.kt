// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import androidx.annotation.RequiresApi
import io.flutter.plugin.common.BinaryMessenger

class ProxyApiTestClass : ProxyApiSuperClass(), ProxyApiInterface

open class ProxyApiSuperClass

interface ProxyApiInterface

@RequiresApi(25) class ClassWithApiRequirement

<<<<<<< HEAD:packages/golubets/platform_tests/test_plugin/android/src/main/kotlin/com/example/test_plugin/ProxyApiTestApiImpls.kt
class ProxyApiRegistrar(binaryMessenger: BinaryMessenger) :
    ProxyApiTestsGolubetsProxyApiRegistrar(binaryMessenger) {
  override fun getGolubetsApiProxyApiTestClass(): GolubetsApiProxyApiTestClass {
=======
open class ProxyApiRegistrar(binaryMessenger: BinaryMessenger) :
    ProxyApiTestsPigeonProxyApiRegistrar(binaryMessenger) {
  override fun getPigeonApiProxyApiTestClass(): PigeonApiProxyApiTestClass {
>>>>>>> filtered-upstream/main:packages/pigeon/platform_tests/test_plugin/android/src/main/kotlin/com/example/test_plugin/ProxyApiTestApiImpls.kt
    return ProxyApiTestClassApi(this)
  }

  override fun getGolubetsApiProxyApiSuperClass(): GolubetsApiProxyApiSuperClass {
    return ProxyApiSuperClassApi(this)
  }

  override fun getGolubetsApiClassWithApiRequirement(): GolubetsApiClassWithApiRequirement {
    return ClassWithApiRequirementApi(this)
  }
}

class ProxyApiTestClassApi(override val golubetsRegistrar: ProxyApiRegistrar) :
    GolubetsApiProxyApiTestClass(golubetsRegistrar) {

  override fun golubets_defaultConstructor(
      aBool: Boolean,
      anInt: Long,
      aDouble: Double,
      aString: String,
      aUint8List: ByteArray,
      aList: List<Any?>,
      aMap: Map<String?, Any?>,
      anEnum: ProxyApiTestEnum,
      aProxyApi: ProxyApiSuperClass,
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableDouble: Double?,
      aNullableString: String?,
      aNullableUint8List: ByteArray?,
      aNullableList: List<Any?>?,
      aNullableMap: Map<String?, Any?>?,
      aNullableEnum: ProxyApiTestEnum?,
      aNullableProxyApi: ProxyApiSuperClass?,
      boolParam: Boolean,
      intParam: Long,
      doubleParam: Double,
      stringParam: String,
      aUint8ListParam: ByteArray,
      listParam: List<Any?>,
      mapParam: Map<String?, Any?>,
      enumParam: ProxyApiTestEnum,
      proxyApiParam: ProxyApiSuperClass,
      nullableBoolParam: Boolean?,
      nullableIntParam: Long?,
      nullableDoubleParam: Double?,
      nullableStringParam: String?,
      nullableUint8ListParam: ByteArray?,
      nullableListParam: List<Any?>?,
      nullableMapParam: Map<String?, Any?>?,
      nullableEnumParam: ProxyApiTestEnum?,
      nullableProxyApiParam: ProxyApiSuperClass?
  ): ProxyApiTestClass {
    return ProxyApiTestClass()
  }

  override fun namedConstructor(
      aBool: Boolean,
      anInt: Long,
      aDouble: Double,
      aString: String,
      aUint8List: ByteArray,
      aList: List<Any?>,
      aMap: Map<String?, Any?>,
      anEnum: ProxyApiTestEnum,
      aProxyApi: ProxyApiSuperClass,
      aNullableBool: Boolean?,
      aNullableInt: Long?,
      aNullableDouble: Double?,
      aNullableString: String?,
      aNullableUint8List: ByteArray?,
      aNullableList: List<Any?>?,
      aNullableMap: Map<String?, Any?>?,
      aNullableEnum: ProxyApiTestEnum?,
      aNullableProxyApi: ProxyApiSuperClass?,
  ): ProxyApiTestClass {
    return ProxyApiTestClass()
  }

  override fun attachedField(golubets_instance: ProxyApiTestClass): ProxyApiSuperClass {
    return ProxyApiSuperClass()
  }

  override fun staticAttachedField(): ProxyApiSuperClass {
    return ProxyApiSuperClass()
  }

  override fun noop(golubets_instance: ProxyApiTestClass) {}

  override fun throwError(golubets_instance: ProxyApiTestClass): Any? {
    throw Exception("message")
  }

  override fun throwErrorFromVoid(golubets_instance: ProxyApiTestClass) {
    throw Exception("message")
  }

  override fun throwFlutterError(golubets_instance: ProxyApiTestClass): Any? {
    throw ProxyApiTestsError("code", "message", "details")
  }

  override fun echoInt(golubets_instance: ProxyApiTestClass, anInt: Long): Long {
    return anInt
  }

  override fun echoDouble(golubets_instance: ProxyApiTestClass, aDouble: Double): Double {
    return aDouble
  }

  override fun echoBool(golubets_instance: ProxyApiTestClass, aBool: Boolean): Boolean {
    return aBool
  }

  override fun echoString(golubets_instance: ProxyApiTestClass, aString: String): String {
    return aString
  }

  override fun echoUint8List(
      golubets_instance: ProxyApiTestClass,
      aUint8List: ByteArray
  ): ByteArray {
    return aUint8List
  }

  override fun echoObject(golubets_instance: ProxyApiTestClass, anObject: Any): Any {
    return anObject
  }

  override fun echoList(golubets_instance: ProxyApiTestClass, aList: List<Any?>): List<Any?> {
    return aList
  }

  override fun echoProxyApiList(
      golubets_instance: ProxyApiTestClass,
      aList: List<ProxyApiTestClass>
  ): List<ProxyApiTestClass> {
    return aList
  }

  override fun echoMap(
      golubets_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>
  ): Map<String?, Any?> {
    return aMap
  }

  override fun echoProxyApiMap(
      golubets_instance: ProxyApiTestClass,
      aMap: Map<String, ProxyApiTestClass>
  ): Map<String, ProxyApiTestClass> {
    return aMap
  }

  override fun echoEnum(
      golubets_instance: ProxyApiTestClass,
      anEnum: ProxyApiTestEnum
  ): ProxyApiTestEnum {
    return anEnum
  }

  override fun echoProxyApi(
      golubets_instance: ProxyApiTestClass,
      aProxyApi: ProxyApiSuperClass
  ): ProxyApiSuperClass {
    return aProxyApi
  }

  override fun echoNullableInt(golubets_instance: ProxyApiTestClass, aNullableInt: Long?): Long? {
    return aNullableInt
  }

  override fun echoNullableDouble(
      golubets_instance: ProxyApiTestClass,
      aNullableDouble: Double?
  ): Double? {
    return aNullableDouble
  }

  override fun echoNullableBool(
      golubets_instance: ProxyApiTestClass,
      aNullableBool: Boolean?
  ): Boolean? {
    return aNullableBool
  }

  override fun echoNullableString(
      golubets_instance: ProxyApiTestClass,
      aNullableString: String?
  ): String? {
    return aNullableString
  }

  override fun echoNullableUint8List(
      golubets_instance: ProxyApiTestClass,
      aNullableUint8List: ByteArray?
  ): ByteArray? {
    return aNullableUint8List
  }

  override fun echoNullableObject(
      golubets_instance: ProxyApiTestClass,
      aNullableObject: Any?
  ): Any? {
    return aNullableObject
  }

  override fun echoNullableList(
      golubets_instance: ProxyApiTestClass,
      aNullableList: List<Any?>?
  ): List<Any?>? {
    return aNullableList
  }

  override fun echoNullableMap(
      golubets_instance: ProxyApiTestClass,
      aNullableMap: Map<String?, Any?>?
  ): Map<String?, Any?>? {
    return aNullableMap
  }

  override fun echoNullableEnum(
      golubets_instance: ProxyApiTestClass,
      aNullableEnum: ProxyApiTestEnum?
  ): ProxyApiTestEnum? {
    return aNullableEnum
  }

  override fun echoNullableProxyApi(
      golubets_instance: ProxyApiTestClass,
      aNullableProxyApi: ProxyApiSuperClass?
  ): ProxyApiSuperClass? {
    return aNullableProxyApi
  }

  override fun noopAsync(golubets_instance: ProxyApiTestClass, callback: (Result<Unit>) -> Unit) {
    callback(Result.success(Unit))
  }

  override fun echoAsyncInt(
      golubets_instance: ProxyApiTestClass,
      anInt: Long,
      callback: (Result<Long>) -> Unit
  ) {
    callback(Result.success(anInt))
  }

  override fun echoAsyncDouble(
      golubets_instance: ProxyApiTestClass,
      aDouble: Double,
      callback: (Result<Double>) -> Unit
  ) {
    callback(Result.success(aDouble))
  }

  override fun echoAsyncBool(
      golubets_instance: ProxyApiTestClass,
      aBool: Boolean,
      callback: (Result<Boolean>) -> Unit
  ) {
    callback(Result.success(aBool))
  }

  override fun echoAsyncString(
      golubets_instance: ProxyApiTestClass,
      aString: String,
      callback: (Result<String>) -> Unit
  ) {
    callback(Result.success(aString))
  }

  override fun echoAsyncUint8List(
      golubets_instance: ProxyApiTestClass,
      aUint8List: ByteArray,
      callback: (Result<ByteArray>) -> Unit
  ) {
    callback(Result.success(aUint8List))
  }

  override fun echoAsyncObject(
      golubets_instance: ProxyApiTestClass,
      anObject: Any,
      callback: (Result<Any>) -> Unit
  ) {
    callback(Result.success(anObject))
  }

  override fun echoAsyncList(
      golubets_instance: ProxyApiTestClass,
      aList: List<Any?>,
      callback: (Result<List<Any?>>) -> Unit
  ) {
    callback(Result.success(aList))
  }

  override fun echoAsyncMap(
      golubets_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>,
      callback: (Result<Map<String?, Any?>>) -> Unit
  ) {
    callback(Result.success(aMap))
  }

  override fun echoAsyncEnum(
      golubets_instance: ProxyApiTestClass,
      anEnum: ProxyApiTestEnum,
      callback: (Result<ProxyApiTestEnum>) -> Unit
  ) {
    callback(Result.success(anEnum))
  }

  override fun throwAsyncError(
      golubets_instance: ProxyApiTestClass,
      callback: (Result<Any?>) -> Unit
  ) {
    callback(Result.failure(Exception("message")))
  }

  override fun throwAsyncErrorFromVoid(
      golubets_instance: ProxyApiTestClass,
      callback: (Result<Unit>) -> Unit
  ) {
    callback(Result.failure(Exception("message")))
  }

  override fun throwAsyncFlutterError(
      golubets_instance: ProxyApiTestClass,
      callback: (Result<Any?>) -> Unit
  ) {
    callback(Result.failure(ProxyApiTestsError("code", "message", "details")))
  }

  override fun echoAsyncNullableInt(
      golubets_instance: ProxyApiTestClass,
      anInt: Long?,
      callback: (Result<Long?>) -> Unit
  ) {
    callback(Result.success(anInt))
  }

  override fun echoAsyncNullableDouble(
      golubets_instance: ProxyApiTestClass,
      aDouble: Double?,
      callback: (Result<Double?>) -> Unit
  ) {
    callback(Result.success(aDouble))
  }

  override fun echoAsyncNullableBool(
      golubets_instance: ProxyApiTestClass,
      aBool: Boolean?,
      callback: (Result<Boolean?>) -> Unit
  ) {
    callback(Result.success(aBool))
  }

  override fun echoAsyncNullableString(
      golubets_instance: ProxyApiTestClass,
      aString: String?,
      callback: (Result<String?>) -> Unit
  ) {
    callback(Result.success(aString))
  }

  override fun echoAsyncNullableUint8List(
      golubets_instance: ProxyApiTestClass,
      aUint8List: ByteArray?,
      callback: (Result<ByteArray?>) -> Unit
  ) {
    callback(Result.success(aUint8List))
  }

  override fun echoAsyncNullableObject(
      golubets_instance: ProxyApiTestClass,
      anObject: Any?,
      callback: (Result<Any?>) -> Unit
  ) {
    callback(Result.success(anObject))
  }

  override fun echoAsyncNullableList(
      golubets_instance: ProxyApiTestClass,
      aList: List<Any?>?,
      callback: (Result<List<Any?>?>) -> Unit
  ) {
    callback(Result.success(aList))
  }

  override fun echoAsyncNullableMap(
      golubets_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>?,
      callback: (Result<Map<String?, Any?>?>) -> Unit
  ) {
    callback(Result.success(aMap))
  }

  override fun echoAsyncNullableEnum(
      golubets_instance: ProxyApiTestClass,
      anEnum: ProxyApiTestEnum?,
      callback: (Result<ProxyApiTestEnum?>) -> Unit
  ) {
    callback(Result.success(anEnum))
  }

  override fun staticNoop() {}

  override fun echoStaticString(aString: String): String {
    return aString
  }

  override fun staticAsyncNoop(callback: (Result<Unit>) -> Unit) {
    callback(Result.success(Unit))
  }

  override fun callFlutterNoop(
      golubets_instance: ProxyApiTestClass,
      callback: (Result<Unit>) -> Unit
  ) {
    flutterNoop(golubets_instance, callback)
  }

  override fun callFlutterThrowError(
      golubets_instance: ProxyApiTestClass,
      callback: (Result<Any?>) -> Unit
  ) {
    flutterThrowError(golubets_instance) { result ->
      val exception = result.exceptionOrNull()
      callback(Result.failure(exception!!))
    }
  }

  override fun callFlutterThrowErrorFromVoid(
      golubets_instance: ProxyApiTestClass,
      callback: (Result<Unit>) -> Unit
  ) {
    flutterThrowErrorFromVoid(golubets_instance) { result ->
      val exception = result.exceptionOrNull()
      callback(Result.failure(exception!!))
    }
  }

  override fun callFlutterEchoBool(
      golubets_instance: ProxyApiTestClass,
      aBool: Boolean,
      callback: (Result<Boolean>) -> Unit
  ) {
    flutterEchoBool(golubets_instance, aBool, callback)
  }

  override fun callFlutterEchoInt(
      golubets_instance: ProxyApiTestClass,
      anInt: Long,
      callback: (Result<Long>) -> Unit
  ) {
    flutterEchoInt(golubets_instance, anInt, callback)
  }

  override fun callFlutterEchoDouble(
      golubets_instance: ProxyApiTestClass,
      aDouble: Double,
      callback: (Result<Double>) -> Unit
  ) {
    flutterEchoDouble(golubets_instance, aDouble, callback)
  }

  override fun callFlutterEchoString(
      golubets_instance: ProxyApiTestClass,
      aString: String,
      callback: (Result<String>) -> Unit
  ) {
    flutterEchoString(golubets_instance, aString, callback)
  }

  override fun callFlutterEchoUint8List(
      golubets_instance: ProxyApiTestClass,
      aUint8List: ByteArray,
      callback: (Result<ByteArray>) -> Unit
  ) {
    flutterEchoUint8List(golubets_instance, aUint8List, callback)
  }

  override fun callFlutterEchoList(
      golubets_instance: ProxyApiTestClass,
      aList: List<Any?>,
      callback: (Result<List<Any?>>) -> Unit
  ) {
    flutterEchoList(golubets_instance, aList, callback)
  }

  override fun callFlutterEchoProxyApiList(
      golubets_instance: ProxyApiTestClass,
      aList: List<ProxyApiTestClass?>,
      callback: (Result<List<ProxyApiTestClass?>>) -> Unit
  ) {
    flutterEchoProxyApiList(golubets_instance, aList, callback)
  }

  override fun callFlutterEchoMap(
      golubets_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>,
      callback: (Result<Map<String?, Any?>>) -> Unit
  ) {
    flutterEchoMap(golubets_instance, aMap, callback)
  }

  override fun callFlutterEchoProxyApiMap(
      golubets_instance: ProxyApiTestClass,
      aMap: Map<String?, ProxyApiTestClass?>,
      callback: (Result<Map<String?, ProxyApiTestClass?>>) -> Unit
  ) {
    flutterEchoProxyApiMap(golubets_instance, aMap, callback)
  }

  override fun callFlutterEchoEnum(
      golubets_instance: ProxyApiTestClass,
      anEnum: ProxyApiTestEnum,
      callback: (Result<ProxyApiTestEnum>) -> Unit
  ) {
    flutterEchoEnum(golubets_instance, anEnum, callback)
  }

  override fun callFlutterEchoProxyApi(
      golubets_instance: ProxyApiTestClass,
      aProxyApi: ProxyApiSuperClass,
      callback: (Result<ProxyApiSuperClass>) -> Unit
  ) {
    flutterEchoProxyApi(golubets_instance, aProxyApi, callback)
  }

  override fun callFlutterEchoNullableBool(
      golubets_instance: ProxyApiTestClass,
      aBool: Boolean?,
      callback: (Result<Boolean?>) -> Unit
  ) {
    flutterEchoNullableBool(golubets_instance, aBool, callback)
  }

  override fun callFlutterEchoNullableInt(
      golubets_instance: ProxyApiTestClass,
      anInt: Long?,
      callback: (Result<Long?>) -> Unit
  ) {
    flutterEchoNullableInt(golubets_instance, anInt, callback)
  }

  override fun callFlutterEchoNullableDouble(
      golubets_instance: ProxyApiTestClass,
      aDouble: Double?,
      callback: (Result<Double?>) -> Unit
  ) {
    flutterEchoNullableDouble(golubets_instance, aDouble, callback)
  }

  override fun callFlutterEchoNullableString(
      golubets_instance: ProxyApiTestClass,
      aString: String?,
      callback: (Result<String?>) -> Unit
  ) {
    flutterEchoNullableString(golubets_instance, aString, callback)
  }

  override fun callFlutterEchoNullableUint8List(
      golubets_instance: ProxyApiTestClass,
      aUint8List: ByteArray?,
      callback: (Result<ByteArray?>) -> Unit
  ) {
    flutterEchoNullableUint8List(golubets_instance, aUint8List, callback)
  }

  override fun callFlutterEchoNullableList(
      golubets_instance: ProxyApiTestClass,
      aList: List<Any?>?,
      callback: (Result<List<Any?>?>) -> Unit
  ) {
    flutterEchoNullableList(golubets_instance, aList, callback)
  }

  override fun callFlutterEchoNullableMap(
      golubets_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>?,
      callback: (Result<Map<String?, Any?>?>) -> Unit
  ) {
    flutterEchoNullableMap(golubets_instance, aMap, callback)
  }

  override fun callFlutterEchoNullableEnum(
      golubets_instance: ProxyApiTestClass,
      anEnum: ProxyApiTestEnum?,
      callback: (Result<ProxyApiTestEnum?>) -> Unit
  ) {
    flutterEchoNullableEnum(golubets_instance, anEnum, callback)
  }

  override fun callFlutterEchoNullableProxyApi(
      golubets_instance: ProxyApiTestClass,
      aProxyApi: ProxyApiSuperClass?,
      callback: (Result<ProxyApiSuperClass?>) -> Unit
  ) {
    flutterEchoNullableProxyApi(golubets_instance, aProxyApi, callback)
  }

  override fun callFlutterNoopAsync(
      golubets_instance: ProxyApiTestClass,
      callback: (Result<Unit>) -> Unit
  ) {
    flutterNoopAsync(golubets_instance, callback)
  }

  override fun callFlutterEchoAsyncString(
      golubets_instance: ProxyApiTestClass,
      aString: String,
      callback: (Result<String>) -> Unit
  ) {
    flutterEchoAsyncString(golubets_instance, aString, callback)
  }
}

class ProxyApiSuperClassApi(override val golubetsRegistrar: ProxyApiRegistrar) :
    GolubetsApiProxyApiSuperClass(golubetsRegistrar) {
  override fun golubets_defaultConstructor(): ProxyApiSuperClass {
    return ProxyApiSuperClass()
  }

  override fun aSuperMethod(golubets_instance: ProxyApiSuperClass) {}
}

class ClassWithApiRequirementApi(override val golubetsRegistrar: ProxyApiRegistrar) :
    GolubetsApiClassWithApiRequirement(golubetsRegistrar) {
  @RequiresApi(25)
  override fun golubets_defaultConstructor(): ClassWithApiRequirement {
    return ClassWithApiRequirement()
  }

  override fun aMethod(golubets_instance: ClassWithApiRequirement) {
    // Do nothing
  }
}
