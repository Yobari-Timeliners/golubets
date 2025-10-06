// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef FLUTTER_PLUGIN_TEST_PLUGIN_H_
#define FLUTTER_PLUGIN_TEST_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>
#include <optional>
#include <string>
#include <thread>

#include "pigeon/core_tests.gen.h"

namespace test_plugin {

class TestSmallApi : public core_tests_golubets_test::HostSmallApi {
 public:
  TestSmallApi();
  virtual ~TestSmallApi();

  TestSmallApi(const TestSmallApi&) = delete;
  TestSmallApi& operator=(const TestSmallApi&) = delete;

  void Echo(
      const std::string& a_string,
      std::function<void(core_tests_golubets_test::ErrorOr<std::string> reply)>
          result) override;

  void VoidVoid(
      std::function<
          void(std::optional<core_tests_golubets_test::FlutterError> reply)>
          result) override;
};

// This plugin handles the native side of the integration tests in
// example/integration_test/
class TestPlugin : public flutter::Plugin,
                   public core_tests_golubets_test::HostIntegrationCoreApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  TestPlugin(flutter::BinaryMessenger* binary_messenger,
             std::unique_ptr<TestSmallApi> host_small_api_one,
             std::unique_ptr<TestSmallApi> host_small_api_two);

  virtual ~TestPlugin();

  // Disallow copy and assign.
  TestPlugin(const TestPlugin&) = delete;
  TestPlugin& operator=(const TestPlugin&) = delete;

  // HostIntegrationCoreApi.
  std::optional<core_tests_golubets_test::FlutterError> Noop() override;
  core_tests_golubets_test::ErrorOr<core_tests_golubets_test::AllTypes>
  EchoAllTypes(const core_tests_golubets_test::AllTypes& everything) override;
  core_tests_golubets_test::ErrorOr<
      std::optional<core_tests_golubets_test::AllNullableTypes>>
  EchoAllNullableTypes(
      const core_tests_golubets_test::AllNullableTypes* everything) override;
  core_tests_golubets_test::ErrorOr<
      std::optional<core_tests_golubets_test::AllNullableTypesWithoutRecursion>>
  EchoAllNullableTypesWithoutRecursion(
      const core_tests_golubets_test::AllNullableTypesWithoutRecursion*
          everything) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableValue>>
  ThrowError() override;
  std::optional<core_tests_golubets_test::FlutterError> ThrowErrorFromVoid()
      override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableValue>>
  ThrowFlutterError() override;
  core_tests_golubets_test::ErrorOr<int64_t> EchoInt(int64_t an_int) override;
  core_tests_golubets_test::ErrorOr<double> EchoDouble(
      double a_double) override;
  core_tests_golubets_test::ErrorOr<bool> EchoBool(bool a_bool) override;
  core_tests_golubets_test::ErrorOr<std::string> EchoString(
      const std::string& a_string) override;
  core_tests_golubets_test::ErrorOr<std::vector<uint8_t>> EchoUint8List(
      const std::vector<uint8_t>& a_uint8_list) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableValue> EchoObject(
      const flutter::EncodableValue& an_object) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableList> EchoList(
      const flutter::EncodableList& a_list) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableList> EchoEnumList(
      const flutter::EncodableList& enum_list) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableList> EchoClassList(
      const flutter::EncodableList& class_list) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableList> EchoNonNullEnumList(
      const flutter::EncodableList& enum_list) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableList>
  EchoNonNullClassList(const flutter::EncodableList& class_list) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableMap> EchoMap(
      const flutter::EncodableMap& map) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableMap> EchoStringMap(
      const flutter::EncodableMap& string_map) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableMap> EchoIntMap(
      const flutter::EncodableMap& int_map) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableMap> EchoEnumMap(
      const flutter::EncodableMap& enum_map) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableMap> EchoClassMap(
      const flutter::EncodableMap& class_map) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableMap> EchoNonNullStringMap(
      const flutter::EncodableMap& string_map) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableMap> EchoNonNullIntMap(
      const flutter::EncodableMap& int_map) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableMap> EchoNonNullEnumMap(
      const flutter::EncodableMap& enum_map) override;
  core_tests_golubets_test::ErrorOr<flutter::EncodableMap> EchoNonNullClassMap(
      const flutter::EncodableMap& class_map) override;
  core_tests_golubets_test::ErrorOr<core_tests_golubets_test::AllClassesWrapper>
  EchoClassWrapper(
      const core_tests_golubets_test::AllClassesWrapper& wrapper) override;
  core_tests_golubets_test::ErrorOr<core_tests_golubets_test::AnEnum> EchoEnum(
      const core_tests_golubets_test::AnEnum& an_enum) override;
  core_tests_golubets_test::ErrorOr<core_tests_golubets_test::AnotherEnum>
  EchoAnotherEnum(
      const core_tests_golubets_test::AnotherEnum& another_enum) override;
  core_tests_golubets_test::ErrorOr<std::string> EchoNamedDefaultString(
      const std::string& a_string) override;
  core_tests_golubets_test::ErrorOr<double> EchoOptionalDefaultDouble(
      double a_double) override;
  core_tests_golubets_test::ErrorOr<
      core_tests_golubets_test::AllTypesWithDefaults>
  CreateAllTypesWithDefaults() override;
  core_tests_golubets_test::ErrorOr<
      core_tests_golubets_test::AllTypesWithDefaults>
  EchoAllTypesWithDefaults(
      const core_tests_golubets_test::AllTypesWithDefaults& all_types) override;
  core_tests_golubets_test::ErrorOr<int64_t> EchoRequiredInt(
      int64_t an_int) override;
  core_tests_golubets_test::ErrorOr<std::optional<std::string>>
  ExtractNestedNullableString(
      const core_tests_golubets_test::AllClassesWrapper& wrapper) override;
  core_tests_golubets_test::ErrorOr<core_tests_golubets_test::AllClassesWrapper>
  CreateNestedNullableString(const std::string* nullable_string) override;
  core_tests_golubets_test::ErrorOr<core_tests_golubets_test::AllNullableTypes>
  SendMultipleNullableTypes(const bool* a_nullable_bool,
                            const int64_t* a_nullable_int,
                            const std::string* a_nullable_string) override;
  core_tests_golubets_test::ErrorOr<
      core_tests_golubets_test::AllNullableTypesWithoutRecursion>
  SendMultipleNullableTypesWithoutRecursion(
      const bool* a_nullable_bool, const int64_t* a_nullable_int,
      const std::string* a_nullable_string) override;
  core_tests_golubets_test::ErrorOr<std::optional<int64_t>> EchoNullableInt(
      const int64_t* a_nullable_int) override;
  core_tests_golubets_test::ErrorOr<std::optional<double>> EchoNullableDouble(
      const double* a_nullable_double) override;
  core_tests_golubets_test::ErrorOr<std::optional<bool>> EchoNullableBool(
      const bool* a_nullable_bool) override;
  core_tests_golubets_test::ErrorOr<std::optional<std::string>>
  EchoNullableString(const std::string* a_nullable_string) override;
  core_tests_golubets_test::ErrorOr<std::optional<std::vector<uint8_t>>>
  EchoNullableUint8List(
      const std::vector<uint8_t>* a_nullable_uint8_list) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableValue>>
  EchoNullableObject(const flutter::EncodableValue* a_nullable_object) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableList>>
  EchoNullableList(const flutter::EncodableList* a_nullable_list) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableList>>
  EchoNullableEnumList(const flutter::EncodableList* enum_list) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableList>>
  EchoNullableClassList(const flutter::EncodableList* class_list) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableList>>
  EchoNullableNonNullEnumList(const flutter::EncodableList* enum_list) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableList>>
  EchoNullableNonNullClassList(
      const flutter::EncodableList* class_list) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableMap>>
  EchoNullableMap(const flutter::EncodableMap* map) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableMap>>
  EchoNullableStringMap(const flutter::EncodableMap* string_map) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableMap>>
  EchoNullableIntMap(const flutter::EncodableMap* int_map) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableMap>>
  EchoNullableEnumMap(const flutter::EncodableMap* enum_map) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableMap>>
  EchoNullableClassMap(const flutter::EncodableMap* class_map) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableMap>>
  EchoNullableNonNullStringMap(
      const flutter::EncodableMap* string_map) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableMap>>
  EchoNullableNonNullIntMap(const flutter::EncodableMap* int_map) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableMap>>
  EchoNullableNonNullEnumMap(const flutter::EncodableMap* enum_map) override;
  core_tests_golubets_test::ErrorOr<std::optional<flutter::EncodableMap>>
  EchoNullableNonNullClassMap(const flutter::EncodableMap* class_map) override;
  core_tests_golubets_test::ErrorOr<
      std::optional<core_tests_golubets_test::AnEnum>>
  EchoNullableEnum(const core_tests_golubets_test::AnEnum* an_enum) override;
  core_tests_golubets_test::ErrorOr<
      std::optional<core_tests_golubets_test::AnotherEnum>>
  EchoAnotherNullableEnum(
      const core_tests_golubets_test::AnotherEnum* another_enum) override;
  core_tests_golubets_test::ErrorOr<std::optional<int64_t>>
  EchoOptionalNullableInt(const int64_t* a_nullable_int) override;
  core_tests_golubets_test::ErrorOr<std::optional<std::string>>
  EchoNamedNullableString(const std::string* a_nullable_string) override;
  void NoopAsync(
      std::function<
          void(std::optional<core_tests_golubets_test::FlutterError> reply)>
          result) override;
  void ThrowAsyncError(
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableValue>>
                             reply)>
          result) override;
  void ThrowAsyncErrorFromVoid(
      std::function<
          void(std::optional<core_tests_golubets_test::FlutterError> reply)>
          result) override;
  void ThrowAsyncFlutterError(
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableValue>>
                             reply)>
          result) override;
  void EchoAsyncAllTypes(
      const core_tests_golubets_test::AllTypes& everything,
      std::function<void(
          core_tests_golubets_test::ErrorOr<core_tests_golubets_test::AllTypes>
              reply)>
          result) override;
  void EchoModernAsyncAllTypes(
      const core_tests_golubets_test::AllTypes& everything,
      std::function<void(
          core_tests_golubets_test::ErrorOr<core_tests_golubets_test::AllTypes>
              reply)>
          result) override;
  void EchoModernAsyncAllTypesAndNotThrow(
      const core_tests_golubets_test::AllTypes& everything,
      std::function<void(
          core_tests_golubets_test::ErrorOr<core_tests_golubets_test::AllTypes>
              reply)>
          result) override;
  void EchoModernAsyncAllTypesAndThrow(
      const core_tests_golubets_test::AllTypes& everything,
      std::function<void(
          core_tests_golubets_test::ErrorOr<core_tests_golubets_test::AllTypes>
              reply)>
          result) override;
  void EchoAsyncNullableAllNullableTypes(
      const core_tests_golubets_test::AllNullableTypes* everything,
      std::function<void(core_tests_golubets_test::ErrorOr<std::optional<
                             core_tests_golubets_test::AllNullableTypes>>
                             reply)>
          result) override;
  void EchoModernAsyncNullableAllNullableTypes(
      const core_tests_golubets_test::AllNullableTypes* everything,
      std::function<void(core_tests_golubets_test::ErrorOr<std::optional<
                             core_tests_golubets_test::AllNullableTypes>>
                             reply)>
          result) override;
  void EchoAsyncNullableAllNullableTypesWithoutRecursion(
      const core_tests_golubets_test::AllNullableTypesWithoutRecursion*
          everything,
      std::function<
          void(core_tests_golubets_test::ErrorOr<std::optional<
                   core_tests_golubets_test::AllNullableTypesWithoutRecursion>>
                   reply)>
          result) override;
  void EchoAsyncInt(
      int64_t an_int,
      std::function<void(core_tests_golubets_test::ErrorOr<int64_t> reply)>
          result) override;
  void EchoAsyncDouble(
      double a_double,
      std::function<void(core_tests_golubets_test::ErrorOr<double> reply)>
          result) override;
  void EchoAsyncBool(
      bool a_bool,
      std::function<void(core_tests_golubets_test::ErrorOr<bool> reply)> result)
      override;
  void EchoAsyncString(
      const std::string& a_string,
      std::function<void(core_tests_golubets_test::ErrorOr<std::string> reply)>
          result) override;
  void EchoAsyncUint8List(
      const std::vector<uint8_t>& a_uint8_list,
      std::function<
          void(core_tests_golubets_test::ErrorOr<std::vector<uint8_t>> reply)>
          result) override;
  void EchoAsyncObject(
      const flutter::EncodableValue& an_object,
      std::function<void(
          core_tests_golubets_test::ErrorOr<flutter::EncodableValue> reply)>
          result) override;
  void EchoAsyncList(
      const flutter::EncodableList& a_list,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableList> reply)>
          result) override;
  void EchoAsyncEnumList(
      const flutter::EncodableList& enum_list,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableList> reply)>
          result) override;
  void EchoAsyncClassList(
      const flutter::EncodableList& class_list,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableList> reply)>
          result) override;
  void EchoAsyncMap(
      const flutter::EncodableMap& map,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void EchoAsyncStringMap(
      const flutter::EncodableMap& string_map,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void EchoAsyncIntMap(
      const flutter::EncodableMap& int_map,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void EchoAsyncEnumMap(
      const flutter::EncodableMap& enum_map,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void EchoAsyncClassMap(
      const flutter::EncodableMap& class_map,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void EchoAsyncEnum(
      const core_tests_golubets_test::AnEnum& an_enum,
      std::function<void(
          core_tests_golubets_test::ErrorOr<core_tests_golubets_test::AnEnum>
              reply)>
          result) override;
  void EchoAnotherAsyncEnum(
      const core_tests_golubets_test::AnotherEnum& another_enum,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         core_tests_golubets_test::AnotherEnum>
                             reply)>
          result) override;
  void EchoAsyncNullableInt(
      const int64_t* an_int,
      std::function<
          void(core_tests_golubets_test::ErrorOr<std::optional<int64_t>> reply)>
          result) override;
  void EchoAsyncNullableDouble(
      const double* a_double,
      std::function<
          void(core_tests_golubets_test::ErrorOr<std::optional<double>> reply)>
          result) override;
  void EchoAsyncNullableBool(
      const bool* a_bool,
      std::function<
          void(core_tests_golubets_test::ErrorOr<std::optional<bool>> reply)>
          result) override;
  void EchoAsyncNullableString(
      const std::string* a_string,
      std::function<void(
          core_tests_golubets_test::ErrorOr<std::optional<std::string>> reply)>
          result) override;
  void EchoAsyncNullableUint8List(
      const std::vector<uint8_t>* a_uint8_list,
      std::function<void(
          core_tests_golubets_test::ErrorOr<std::optional<std::vector<uint8_t>>>
              reply)>
          result) override;
  void EchoAsyncNullableObject(
      const flutter::EncodableValue* an_object,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableValue>>
                             reply)>
          result) override;
  void EchoAsyncNullableList(
      const flutter::EncodableList* a_list,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableList>>
                             reply)>
          result) override;
  void EchoAsyncNullableEnumList(
      const flutter::EncodableList* enum_list,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableList>>
                             reply)>
          result) override;
  void EchoAsyncNullableClassList(
      const flutter::EncodableList* class_list,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableList>>
                             reply)>
          result) override;
  void EchoAsyncNullableMap(
      const flutter::EncodableMap* map,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableMap>>
                             reply)>
          result) override;
  void EchoAsyncNullableStringMap(
      const flutter::EncodableMap* string_map,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableMap>>
                             reply)>
          result) override;
  void EchoAsyncNullableIntMap(
      const flutter::EncodableMap* int_map,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableMap>>
                             reply)>
          result) override;
  void EchoAsyncNullableEnumMap(
      const flutter::EncodableMap* enum_map,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableMap>>
                             reply)>
          result) override;
  void EchoAsyncNullableClassMap(
      const flutter::EncodableMap* class_map,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableMap>>
                             reply)>
          result) override;
  void EchoAsyncNullableEnum(
      const core_tests_golubets_test::AnEnum* an_enum,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<core_tests_golubets_test::AnEnum>>
                             reply)>
          result) override;
  void EchoAnotherAsyncNullableEnum(
      const core_tests_golubets_test::AnotherEnum* another_enum,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<core_tests_golubets_test::AnotherEnum>>
                             reply)>
          result) override;
  core_tests_golubets_test::ErrorOr<bool> DefaultIsMainThread() override;
  core_tests_golubets_test::ErrorOr<bool> TaskQueueIsBackgroundThread()
      override;
  void CallFlutterNoop(
      std::function<
          void(std::optional<core_tests_golubets_test::FlutterError> reply)>
          result) override;
  void CallFlutterThrowError(
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableValue>>
                             reply)>
          result) override;
  void CallFlutterThrowErrorFromVoid(
      std::function<
          void(std::optional<core_tests_golubets_test::FlutterError> reply)>
          result) override;
  void CallFlutterEchoAllTypes(
      const core_tests_golubets_test::AllTypes& everything,
      std::function<void(
          core_tests_golubets_test::ErrorOr<core_tests_golubets_test::AllTypes>
              reply)>
          result) override;
  void CallFlutterEchoAllNullableTypes(
      const core_tests_golubets_test::AllNullableTypes* everything,
      std::function<void(core_tests_golubets_test::ErrorOr<std::optional<
                             core_tests_golubets_test::AllNullableTypes>>
                             reply)>
          result) override;
  void CallFlutterSendMultipleNullableTypes(
      const bool* a_nullable_bool, const int64_t* a_nullable_int,
      const std::string* a_nullable_string,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         core_tests_golubets_test::AllNullableTypes>
                             reply)>
          result) override;
  void CallFlutterEchoAllNullableTypesWithoutRecursion(
      const core_tests_golubets_test::AllNullableTypesWithoutRecursion*
          everything,
      std::function<
          void(core_tests_golubets_test::ErrorOr<std::optional<
                   core_tests_golubets_test::AllNullableTypesWithoutRecursion>>
                   reply)>
          result) override;
  void CallFlutterSendMultipleNullableTypesWithoutRecursion(
      const bool* a_nullable_bool, const int64_t* a_nullable_int,
      const std::string* a_nullable_string,
      std::function<
          void(core_tests_golubets_test::ErrorOr<
               core_tests_golubets_test::AllNullableTypesWithoutRecursion>
                   reply)>
          result) override;
  void CallFlutterEchoBool(
      bool a_bool,
      std::function<void(core_tests_golubets_test::ErrorOr<bool> reply)> result)
      override;
  void CallFlutterEchoInt(
      int64_t an_int,
      std::function<void(core_tests_golubets_test::ErrorOr<int64_t> reply)>
          result) override;
  void CallFlutterEchoDouble(
      double a_double,
      std::function<void(core_tests_golubets_test::ErrorOr<double> reply)>
          result) override;
  void CallFlutterEchoString(
      const std::string& a_string,
      std::function<void(core_tests_golubets_test::ErrorOr<std::string> reply)>
          result) override;
  void CallFlutterEchoUint8List(
      const std::vector<uint8_t>& a_list,
      std::function<
          void(core_tests_golubets_test::ErrorOr<std::vector<uint8_t>> reply)>
          result) override;
  void CallFlutterEchoList(
      const flutter::EncodableList& a_list,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableList> reply)>
          result) override;
  void CallFlutterEchoEnumList(
      const flutter::EncodableList& enum_list,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableList> reply)>
          result) override;
  void CallFlutterEchoClassList(
      const flutter::EncodableList& class_list,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableList> reply)>
          result) override;
  void CallFlutterEchoNonNullEnumList(
      const flutter::EncodableList& enum_list,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableList> reply)>
          result) override;
  void CallFlutterEchoNonNullClassList(
      const flutter::EncodableList& class_list,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableList> reply)>
          result) override;
  void CallFlutterEchoMap(
      const flutter::EncodableMap& map,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void CallFlutterEchoStringMap(
      const flutter::EncodableMap& string_map,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void CallFlutterEchoIntMap(
      const flutter::EncodableMap& int_map,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void CallFlutterEchoEnumMap(
      const flutter::EncodableMap& enum_map,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void CallFlutterEchoClassMap(
      const flutter::EncodableMap& class_map,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void CallFlutterEchoNonNullStringMap(
      const flutter::EncodableMap& string_map,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void CallFlutterEchoNonNullIntMap(
      const flutter::EncodableMap& int_map,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void CallFlutterEchoNonNullEnumMap(
      const flutter::EncodableMap& enum_map,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void CallFlutterEchoNonNullClassMap(
      const flutter::EncodableMap& class_map,
      std::function<
          void(core_tests_golubets_test::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void CallFlutterEchoEnum(
      const core_tests_golubets_test::AnEnum& an_enum,
      std::function<void(
          core_tests_golubets_test::ErrorOr<core_tests_golubets_test::AnEnum>
              reply)>
          result) override;
  void CallFlutterEchoAnotherEnum(
      const core_tests_golubets_test::AnotherEnum& another_enum,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         core_tests_golubets_test::AnotherEnum>
                             reply)>
          result) override;
  void CallFlutterEchoNullableBool(
      const bool* a_bool,
      std::function<
          void(core_tests_golubets_test::ErrorOr<std::optional<bool>> reply)>
          result) override;
  void CallFlutterEchoNullableInt(
      const int64_t* an_int,
      std::function<
          void(core_tests_golubets_test::ErrorOr<std::optional<int64_t>> reply)>
          result) override;
  void CallFlutterEchoNullableDouble(
      const double* a_double,
      std::function<
          void(core_tests_golubets_test::ErrorOr<std::optional<double>> reply)>
          result) override;
  void CallFlutterEchoNullableString(
      const std::string* a_string,
      std::function<void(
          core_tests_golubets_test::ErrorOr<std::optional<std::string>> reply)>
          result) override;
  void CallFlutterEchoNullableUint8List(
      const std::vector<uint8_t>* a_list,
      std::function<void(
          core_tests_golubets_test::ErrorOr<std::optional<std::vector<uint8_t>>>
              reply)>
          result) override;
  void CallFlutterEchoNullableList(
      const flutter::EncodableList* a_list,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableList>>
                             reply)>
          result) override;
  void CallFlutterEchoNullableEnumList(
      const flutter::EncodableList* enum_list,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableList>>
                             reply)>
          result) override;
  void CallFlutterEchoNullableClassList(
      const flutter::EncodableList* class_list,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableList>>
                             reply)>
          result) override;
  void CallFlutterEchoNullableNonNullEnumList(
      const flutter::EncodableList* enum_list,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableList>>
                             reply)>
          result) override;
  void CallFlutterEchoNullableNonNullClassList(
      const flutter::EncodableList* class_list,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableList>>
                             reply)>
          result) override;
  void CallFlutterEchoNullableMap(
      const flutter::EncodableMap* map,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableMap>>
                             reply)>
          result) override;
  void CallFlutterEchoNullableStringMap(
      const flutter::EncodableMap* string_map,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableMap>>
                             reply)>
          result) override;
  void CallFlutterEchoNullableIntMap(
      const flutter::EncodableMap* int_map,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableMap>>
                             reply)>
          result) override;
  void CallFlutterEchoNullableEnumMap(
      const flutter::EncodableMap* enum_map,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableMap>>
                             reply)>
          result) override;
  void CallFlutterEchoNullableClassMap(
      const flutter::EncodableMap* class_map,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableMap>>
                             reply)>
          result) override;
  void CallFlutterEchoNullableNonNullStringMap(
      const flutter::EncodableMap* string_map,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableMap>>
                             reply)>
          result) override;
  void CallFlutterEchoNullableNonNullIntMap(
      const flutter::EncodableMap* int_map,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableMap>>
                             reply)>
          result) override;
  void CallFlutterEchoNullableNonNullEnumMap(
      const flutter::EncodableMap* enum_map,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableMap>>
                             reply)>
          result) override;
  void CallFlutterEchoNullableNonNullClassMap(
      const flutter::EncodableMap* class_map,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<flutter::EncodableMap>>
                             reply)>
          result) override;
  void CallFlutterEchoNullableEnum(
      const core_tests_golubets_test::AnEnum* an_enum,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<core_tests_golubets_test::AnEnum>>
                             reply)>
          result) override;
  void CallFlutterEchoAnotherNullableEnum(
      const core_tests_golubets_test::AnotherEnum* another_enum,
      std::function<void(core_tests_golubets_test::ErrorOr<
                         std::optional<core_tests_golubets_test::AnotherEnum>>
                             reply)>
          result) override;
  void CallFlutterSmallApiEchoString(
      const std::string& a_string,
      std::function<void(core_tests_golubets_test::ErrorOr<std::string> reply)>
          result) override;
  core_tests_golubets_test::UnusedClass TestUnusedClassGenerates();

 private:
  std::unique_ptr<core_tests_golubets_test::FlutterIntegrationCoreApi>
      flutter_api_;
  std::unique_ptr<core_tests_golubets_test::FlutterSmallApi>
      flutter_small_api_one_;
  std::unique_ptr<core_tests_golubets_test::FlutterSmallApi>
      flutter_small_api_two_;
  std::unique_ptr<TestSmallApi> host_small_api_one_;
  std::unique_ptr<TestSmallApi> host_small_api_two_;
  std::thread::id main_thread_id_;
};

}  // namespace test_plugin

#endif  // FLUTTER_PLUGIN_TEST_PLUGIN_H_
