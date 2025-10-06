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

class ProxyApiRegistrar(binaryMessenger: BinaryMessenger) :
    ProxyApiTestsGolubProxyApiRegistrar(binaryMessenger) {
  override fun getGolubApiProxyApiTestClass(): GolubApiProxyApiTestClass {
    return ProxyApiTestClassApi(this)
  }

  override fun getGolubApiProxyApiSuperClass(): GolubApiProxyApiSuperClass {
    return ProxyApiSuperClassApi(this)
  }

  override fun getGolubApiClassWithApiRequirement(): GolubApiClassWithApiRequirement {
    return ClassWithApiRequirementApi(this)
  }
}

class ProxyApiTestClassApi(override val golubRegistrar: ProxyApiRegistrar) :
    GolubApiProxyApiTestClass(golubRegistrar) {

  override fun golub_defaultConstructor(
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

  override fun attachedField(golub_instance: ProxyApiTestClass): ProxyApiSuperClass {
    return ProxyApiSuperClass()
  }

  override fun staticAttachedField(): ProxyApiSuperClass {
    return ProxyApiSuperClass()
  }

  override fun noop(golub_instance: ProxyApiTestClass) {}

  override fun throwError(golub_instance: ProxyApiTestClass): Any? {
    throw Exception("message")
  }

  override fun throwErrorFromVoid(golub_instance: ProxyApiTestClass) {
    throw Exception("message")
  }

  override fun throwFlutterError(golub_instance: ProxyApiTestClass): Any? {
    throw ProxyApiTestsError("code", "message", "details")
  }

  override fun echoInt(golub_instance: ProxyApiTestClass, anInt: Long): Long {
    return anInt
  }

  override fun echoDouble(golub_instance: ProxyApiTestClass, aDouble: Double): Double {
    return aDouble
  }

  override fun echoBool(golub_instance: ProxyApiTestClass, aBool: Boolean): Boolean {
    return aBool
  }

  override fun echoString(golub_instance: ProxyApiTestClass, aString: String): String {
    return aString
  }

  override fun echoUint8List(golub_instance: ProxyApiTestClass, aUint8List: ByteArray): ByteArray {
    return aUint8List
  }

  override fun echoObject(golub_instance: ProxyApiTestClass, anObject: Any): Any {
    return anObject
  }

  override fun echoList(golub_instance: ProxyApiTestClass, aList: List<Any?>): List<Any?> {
    return aList
  }

  override fun echoProxyApiList(
      golub_instance: ProxyApiTestClass,
      aList: List<ProxyApiTestClass>
  ): List<ProxyApiTestClass> {
    return aList
  }

  override fun echoMap(
      golub_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>
  ): Map<String?, Any?> {
    return aMap
  }

  override fun echoProxyApiMap(
      golub_instance: ProxyApiTestClass,
      aMap: Map<String, ProxyApiTestClass>
  ): Map<String, ProxyApiTestClass> {
    return aMap
  }

  override fun echoEnum(
      golub_instance: ProxyApiTestClass,
      anEnum: ProxyApiTestEnum
  ): ProxyApiTestEnum {
    return anEnum
  }

  override fun echoProxyApi(
      golub_instance: ProxyApiTestClass,
      aProxyApi: ProxyApiSuperClass
  ): ProxyApiSuperClass {
    return aProxyApi
  }

  override fun echoNullableInt(golub_instance: ProxyApiTestClass, aNullableInt: Long?): Long? {
    return aNullableInt
  }

  override fun echoNullableDouble(
      golub_instance: ProxyApiTestClass,
      aNullableDouble: Double?
  ): Double? {
    return aNullableDouble
  }

  override fun echoNullableBool(
      golub_instance: ProxyApiTestClass,
      aNullableBool: Boolean?
  ): Boolean? {
    return aNullableBool
  }

  override fun echoNullableString(
      golub_instance: ProxyApiTestClass,
      aNullableString: String?
  ): String? {
    return aNullableString
  }

  override fun echoNullableUint8List(
      golub_instance: ProxyApiTestClass,
      aNullableUint8List: ByteArray?
  ): ByteArray? {
    return aNullableUint8List
  }

  override fun echoNullableObject(golub_instance: ProxyApiTestClass, aNullableObject: Any?): Any? {
    return aNullableObject
  }

  override fun echoNullableList(
      golub_instance: ProxyApiTestClass,
      aNullableList: List<Any?>?
  ): List<Any?>? {
    return aNullableList
  }

  override fun echoNullableMap(
      golub_instance: ProxyApiTestClass,
      aNullableMap: Map<String?, Any?>?
  ): Map<String?, Any?>? {
    return aNullableMap
  }

  override fun echoNullableEnum(
      golub_instance: ProxyApiTestClass,
      aNullableEnum: ProxyApiTestEnum?
  ): ProxyApiTestEnum? {
    return aNullableEnum
  }

  override fun echoNullableProxyApi(
      golub_instance: ProxyApiTestClass,
      aNullableProxyApi: ProxyApiSuperClass?
  ): ProxyApiSuperClass? {
    return aNullableProxyApi
  }

  override fun noopAsync(golub_instance: ProxyApiTestClass, callback: (Result<Unit>) -> Unit) {
    callback(Result.success(Unit))
  }

  override fun echoAsyncInt(
      golub_instance: ProxyApiTestClass,
      anInt: Long,
      callback: (Result<Long>) -> Unit
  ) {
    callback(Result.success(anInt))
  }

  override fun echoAsyncDouble(
      golub_instance: ProxyApiTestClass,
      aDouble: Double,
      callback: (Result<Double>) -> Unit
  ) {
    callback(Result.success(aDouble))
  }

  override fun echoAsyncBool(
      golub_instance: ProxyApiTestClass,
      aBool: Boolean,
      callback: (Result<Boolean>) -> Unit
  ) {
    callback(Result.success(aBool))
  }

  override fun echoAsyncString(
      golub_instance: ProxyApiTestClass,
      aString: String,
      callback: (Result<String>) -> Unit
  ) {
    callback(Result.success(aString))
  }

  override fun echoAsyncUint8List(
      golub_instance: ProxyApiTestClass,
      aUint8List: ByteArray,
      callback: (Result<ByteArray>) -> Unit
  ) {
    callback(Result.success(aUint8List))
  }

  override fun echoAsyncObject(
      golub_instance: ProxyApiTestClass,
      anObject: Any,
      callback: (Result<Any>) -> Unit
  ) {
    callback(Result.success(anObject))
  }

  override fun echoAsyncList(
      golub_instance: ProxyApiTestClass,
      aList: List<Any?>,
      callback: (Result<List<Any?>>) -> Unit
  ) {
    callback(Result.success(aList))
  }

  override fun echoAsyncMap(
      golub_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>,
      callback: (Result<Map<String?, Any?>>) -> Unit
  ) {
    callback(Result.success(aMap))
  }

  override fun echoAsyncEnum(
      golub_instance: ProxyApiTestClass,
      anEnum: ProxyApiTestEnum,
      callback: (Result<ProxyApiTestEnum>) -> Unit
  ) {
    callback(Result.success(anEnum))
  }

  override fun throwAsyncError(
      golub_instance: ProxyApiTestClass,
      callback: (Result<Any?>) -> Unit
  ) {
    callback(Result.failure(Exception("message")))
  }

  override fun throwAsyncErrorFromVoid(
      golub_instance: ProxyApiTestClass,
      callback: (Result<Unit>) -> Unit
  ) {
    callback(Result.failure(Exception("message")))
  }

  override fun throwAsyncFlutterError(
      golub_instance: ProxyApiTestClass,
      callback: (Result<Any?>) -> Unit
  ) {
    callback(Result.failure(ProxyApiTestsError("code", "message", "details")))
  }

  override fun echoAsyncNullableInt(
      golub_instance: ProxyApiTestClass,
      anInt: Long?,
      callback: (Result<Long?>) -> Unit
  ) {
    callback(Result.success(anInt))
  }

  override fun echoAsyncNullableDouble(
      golub_instance: ProxyApiTestClass,
      aDouble: Double?,
      callback: (Result<Double?>) -> Unit
  ) {
    callback(Result.success(aDouble))
  }

  override fun echoAsyncNullableBool(
      golub_instance: ProxyApiTestClass,
      aBool: Boolean?,
      callback: (Result<Boolean?>) -> Unit
  ) {
    callback(Result.success(aBool))
  }

  override fun echoAsyncNullableString(
      golub_instance: ProxyApiTestClass,
      aString: String?,
      callback: (Result<String?>) -> Unit
  ) {
    callback(Result.success(aString))
  }

  override fun echoAsyncNullableUint8List(
      golub_instance: ProxyApiTestClass,
      aUint8List: ByteArray?,
      callback: (Result<ByteArray?>) -> Unit
  ) {
    callback(Result.success(aUint8List))
  }

  override fun echoAsyncNullableObject(
      golub_instance: ProxyApiTestClass,
      anObject: Any?,
      callback: (Result<Any?>) -> Unit
  ) {
    callback(Result.success(anObject))
  }

  override fun echoAsyncNullableList(
      golub_instance: ProxyApiTestClass,
      aList: List<Any?>?,
      callback: (Result<List<Any?>?>) -> Unit
  ) {
    callback(Result.success(aList))
  }

  override fun echoAsyncNullableMap(
      golub_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>?,
      callback: (Result<Map<String?, Any?>?>) -> Unit
  ) {
    callback(Result.success(aMap))
  }

  override fun echoAsyncNullableEnum(
      golub_instance: ProxyApiTestClass,
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
      golub_instance: ProxyApiTestClass,
      callback: (Result<Unit>) -> Unit
  ) {
    flutterNoop(golub_instance, callback)
  }

  override fun callFlutterThrowError(
      golub_instance: ProxyApiTestClass,
      callback: (Result<Any?>) -> Unit
  ) {
    flutterThrowError(golub_instance) { result ->
      val exception = result.exceptionOrNull()
      callback(Result.failure(exception!!))
    }
  }

  override fun callFlutterThrowErrorFromVoid(
      golub_instance: ProxyApiTestClass,
      callback: (Result<Unit>) -> Unit
  ) {
    flutterThrowErrorFromVoid(golub_instance) { result ->
      val exception = result.exceptionOrNull()
      callback(Result.failure(exception!!))
    }
  }

  override fun callFlutterEchoBool(
      golub_instance: ProxyApiTestClass,
      aBool: Boolean,
      callback: (Result<Boolean>) -> Unit
  ) {
    flutterEchoBool(golub_instance, aBool, callback)
  }

  override fun callFlutterEchoInt(
      golub_instance: ProxyApiTestClass,
      anInt: Long,
      callback: (Result<Long>) -> Unit
  ) {
    flutterEchoInt(golub_instance, anInt, callback)
  }

  override fun callFlutterEchoDouble(
      golub_instance: ProxyApiTestClass,
      aDouble: Double,
      callback: (Result<Double>) -> Unit
  ) {
    flutterEchoDouble(golub_instance, aDouble, callback)
  }

  override fun callFlutterEchoString(
      golub_instance: ProxyApiTestClass,
      aString: String,
      callback: (Result<String>) -> Unit
  ) {
    flutterEchoString(golub_instance, aString, callback)
  }

  override fun callFlutterEchoUint8List(
      golub_instance: ProxyApiTestClass,
      aUint8List: ByteArray,
      callback: (Result<ByteArray>) -> Unit
  ) {
    flutterEchoUint8List(golub_instance, aUint8List, callback)
  }

  override fun callFlutterEchoList(
      golub_instance: ProxyApiTestClass,
      aList: List<Any?>,
      callback: (Result<List<Any?>>) -> Unit
  ) {
    flutterEchoList(golub_instance, aList, callback)
  }

  override fun callFlutterEchoProxyApiList(
      golub_instance: ProxyApiTestClass,
      aList: List<ProxyApiTestClass?>,
      callback: (Result<List<ProxyApiTestClass?>>) -> Unit
  ) {
    flutterEchoProxyApiList(golub_instance, aList, callback)
  }

  override fun callFlutterEchoMap(
      golub_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>,
      callback: (Result<Map<String?, Any?>>) -> Unit
  ) {
    flutterEchoMap(golub_instance, aMap, callback)
  }

  override fun callFlutterEchoProxyApiMap(
      golub_instance: ProxyApiTestClass,
      aMap: Map<String?, ProxyApiTestClass?>,
      callback: (Result<Map<String?, ProxyApiTestClass?>>) -> Unit
  ) {
    flutterEchoProxyApiMap(golub_instance, aMap, callback)
  }

  override fun callFlutterEchoEnum(
      golub_instance: ProxyApiTestClass,
      anEnum: ProxyApiTestEnum,
      callback: (Result<ProxyApiTestEnum>) -> Unit
  ) {
    flutterEchoEnum(golub_instance, anEnum, callback)
  }

  override fun callFlutterEchoProxyApi(
      golub_instance: ProxyApiTestClass,
      aProxyApi: ProxyApiSuperClass,
      callback: (Result<ProxyApiSuperClass>) -> Unit
  ) {
    flutterEchoProxyApi(golub_instance, aProxyApi, callback)
  }

  override fun callFlutterEchoNullableBool(
      golub_instance: ProxyApiTestClass,
      aBool: Boolean?,
      callback: (Result<Boolean?>) -> Unit
  ) {
    flutterEchoNullableBool(golub_instance, aBool, callback)
  }

  override fun callFlutterEchoNullableInt(
      golub_instance: ProxyApiTestClass,
      anInt: Long?,
      callback: (Result<Long?>) -> Unit
  ) {
    flutterEchoNullableInt(golub_instance, anInt, callback)
  }

  override fun callFlutterEchoNullableDouble(
      golub_instance: ProxyApiTestClass,
      aDouble: Double?,
      callback: (Result<Double?>) -> Unit
  ) {
    flutterEchoNullableDouble(golub_instance, aDouble, callback)
  }

  override fun callFlutterEchoNullableString(
      golub_instance: ProxyApiTestClass,
      aString: String?,
      callback: (Result<String?>) -> Unit
  ) {
    flutterEchoNullableString(golub_instance, aString, callback)
  }

  override fun callFlutterEchoNullableUint8List(
      golub_instance: ProxyApiTestClass,
      aUint8List: ByteArray?,
      callback: (Result<ByteArray?>) -> Unit
  ) {
    flutterEchoNullableUint8List(golub_instance, aUint8List, callback)
  }

  override fun callFlutterEchoNullableList(
      golub_instance: ProxyApiTestClass,
      aList: List<Any?>?,
      callback: (Result<List<Any?>?>) -> Unit
  ) {
    flutterEchoNullableList(golub_instance, aList, callback)
  }

  override fun callFlutterEchoNullableMap(
      golub_instance: ProxyApiTestClass,
      aMap: Map<String?, Any?>?,
      callback: (Result<Map<String?, Any?>?>) -> Unit
  ) {
    flutterEchoNullableMap(golub_instance, aMap, callback)
  }

  override fun callFlutterEchoNullableEnum(
      golub_instance: ProxyApiTestClass,
      anEnum: ProxyApiTestEnum?,
      callback: (Result<ProxyApiTestEnum?>) -> Unit
  ) {
    flutterEchoNullableEnum(golub_instance, anEnum, callback)
  }

  override fun callFlutterEchoNullableProxyApi(
      golub_instance: ProxyApiTestClass,
      aProxyApi: ProxyApiSuperClass?,
      callback: (Result<ProxyApiSuperClass?>) -> Unit
  ) {
    flutterEchoNullableProxyApi(golub_instance, aProxyApi, callback)
  }

  override fun callFlutterNoopAsync(
      golub_instance: ProxyApiTestClass,
      callback: (Result<Unit>) -> Unit
  ) {
    flutterNoopAsync(golub_instance, callback)
  }

  override fun callFlutterEchoAsyncString(
      golub_instance: ProxyApiTestClass,
      aString: String,
      callback: (Result<String>) -> Unit
  ) {
    flutterEchoAsyncString(golub_instance, aString, callback)
  }
}

class ProxyApiSuperClassApi(override val golubRegistrar: ProxyApiRegistrar) :
    GolubApiProxyApiSuperClass(golubRegistrar) {
  override fun golub_defaultConstructor(): ProxyApiSuperClass {
    return ProxyApiSuperClass()
  }

  override fun aSuperMethod(golub_instance: ProxyApiSuperClass) {}
}

class ClassWithApiRequirementApi(override val golubRegistrar: ProxyApiRegistrar) :
    GolubApiClassWithApiRequirement(golubRegistrar) {
  @RequiresApi(25)
  override fun golub_defaultConstructor(): ClassWithApiRequirement {
    return ClassWithApiRequirement()
  }

  override fun aMethod(golub_instance: ClassWithApiRequirement) {
    // Do nothing
  }
}
