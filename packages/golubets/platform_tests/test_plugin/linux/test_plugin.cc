// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "include/test_plugin/test_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>
#include <thread>

#include "pigeon/core_tests.gen.h"
#include "test_plugin_private.h"

struct _TestPlugin {
  GObject parent_instance;

  FlBinaryMessenger* messenger;

  CoreTestsGolubetsTestFlutterIntegrationCoreApi* flutter_core_api;

  CoreTestsGolubetsTestFlutterSmallApi* flutter_small_api_one;
  CoreTestsGolubetsTestFlutterSmallApi* flutter_small_api_two;

  GCancellable* cancellable;

  std::thread::id main_thread_id;
};

G_DEFINE_TYPE(TestPlugin, test_plugin, G_TYPE_OBJECT)

typedef struct {
  TestPlugin* self;
  CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle;
} CallbackData;

static CallbackData* callback_data_new(
    TestPlugin* self, CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle*
                          response_handle) {
  CallbackData* data = g_new0(CallbackData, 1);
  data->self = TEST_PLUGIN(g_object_ref(self));
  data->response_handle =
      CORE_TESTS_GOLUBETS_TEST_HOST_INTEGRATION_CORE_API_RESPONSE_HANDLE(
          g_object_ref(response_handle));
  return data;
}

static void callback_data_free(CallbackData* data) {
  g_object_unref(data->self);
  g_object_unref(data->response_handle);
  free(data);
}

G_DEFINE_AUTOPTR_CLEANUP_FUNC(CallbackData, callback_data_free)

static CoreTestsGolubetsTestHostIntegrationCoreApiNoopResponse* noop(
    gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_noop_response_new();
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoAllTypesResponse*
echo_all_types(CoreTestsGolubetsTestAllTypes* everything, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_all_types_response_new(
      everything);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiThrowErrorResponse*
throw_error(gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_throw_error_response_new_error(
      "An error", "", nullptr);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiThrowErrorFromVoidResponse*
throw_error_from_void(gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_throw_error_from_void_response_new_error(
      "An error", "", nullptr);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiThrowFlutterErrorResponse*
throw_flutter_error(gpointer user_data) {
  g_autoptr(FlValue) details = fl_value_new_string("details");
  return core_tests_golubets_test_host_integration_core_api_throw_flutter_error_response_new_error(
      "code", "message", details);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoIntResponse* echo_int(
    int64_t an_int, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_int_response_new(
      an_int);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoDoubleResponse*
echo_double(double a_double, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_double_response_new(
      a_double);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoBoolResponse* echo_bool(
    gboolean a_bool, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_bool_response_new(
      a_bool);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoStringResponse*
echo_string(const gchar* a_string, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_string_response_new(
      a_string);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoUint8ListResponse*
echo_uint8_list(const uint8_t* a_uint8_list, size_t a_uint8_list_length,
                gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_uint8_list_response_new(
      a_uint8_list, a_uint8_list_length);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoObjectResponse*
echo_object(FlValue* an_object, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_object_response_new(
      an_object);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoListResponse* echo_list(
    FlValue* a_list, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_list_response_new(
      a_list);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoEnumListResponse*
echo_enum_list(FlValue* enum_list, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_enum_list_response_new(
      enum_list);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoClassListResponse*
echo_class_list(FlValue* class_list, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_class_list_response_new(
      class_list);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNonNullEnumListResponse*
echo_non_null_enum_list(FlValue* enum_list, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_non_null_enum_list_response_new(
      enum_list);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNonNullClassListResponse*
echo_non_null_class_list(FlValue* class_list, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_non_null_class_list_response_new(
      class_list);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoMapResponse* echo_map(
    FlValue* map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_map_response_new(
      map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoStringMapResponse*
echo_string_map(FlValue* string_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_string_map_response_new(
      string_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoIntMapResponse*
echo_int_map(FlValue* int_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_int_map_response_new(
      int_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoEnumMapResponse*
echo_enum_map(FlValue* _enum_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_enum_map_response_new(
      _enum_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoClassMapResponse*
echo_class_map(FlValue* class_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_class_map_response_new(
      class_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNonNullStringMapResponse*
echo_non_null_string_map(FlValue* string_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_non_null_string_map_response_new(
      string_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNonNullIntMapResponse*
echo_non_null_int_map(FlValue* int_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_non_null_int_map_response_new(
      int_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNonNullEnumMapResponse*
echo_non_null_enum_map(FlValue* _enum_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_non_null_enum_map_response_new(
      _enum_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNonNullClassMapResponse*
echo_non_null_class_map(FlValue* class_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_non_null_class_map_response_new(
      class_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoClassWrapperResponse*
echo_class_wrapper(CoreTestsGolubetsTestAllClassesWrapper* wrapper,
                   gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_class_wrapper_response_new(
      wrapper);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoEnumResponse* echo_enum(

    CoreTestsGolubetsTestAnEnum an_enum, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_enum_response_new(
      an_enum);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoAnotherEnumResponse*
echo_another_enum(

    CoreTestsGolubetsTestAnotherEnum another_enum, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_another_enum_response_new(
      another_enum);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNamedDefaultStringResponse*
echo_named_default_string(const gchar* a_string, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_named_default_string_response_new(
      a_string);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoOptionalDefaultDoubleResponse*
echo_optional_default_double(double a_double, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_optional_default_double_response_new(
      a_double);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoRequiredIntResponse*
echo_required_int(int64_t an_int, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_required_int_response_new(
      an_int);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiCreateAllTypesWithDefaultsResponse*
create_all_types_with_defaults(gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_create_all_types_with_defaults_response_new_error(
      "NotImplemented",
      "createAllTypesWithDefaults is not implemented - test will never be "
      "executed",
      nullptr);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoAllTypesWithDefaultsResponse*
echo_all_types_with_defaults(
    CoreTestsGolubetsTestAllTypesWithDefaults* all_types, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_all_types_with_defaults_response_new(
      all_types);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoAllNullableTypesResponse*
echo_all_nullable_types(CoreTestsGolubetsTestAllNullableTypes* everything,
                        gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_all_nullable_types_response_new(
      everything);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoAllNullableTypesWithoutRecursionResponse*
echo_all_nullable_types_without_recursion(

    CoreTestsGolubetsTestAllNullableTypesWithoutRecursion* everything,
    gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_all_nullable_types_without_recursion_response_new(
      everything);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiExtractNestedNullableStringResponse*
extract_nested_nullable_string(CoreTestsGolubetsTestAllClassesWrapper* wrapper,
                               gpointer user_data) {
  CoreTestsGolubetsTestAllNullableTypes* types =
      core_tests_golubets_test_all_classes_wrapper_get_all_nullable_types(
          wrapper);
  return core_tests_golubets_test_host_integration_core_api_extract_nested_nullable_string_response_new(
      core_tests_golubets_test_all_nullable_types_get_a_nullable_string(types));
}

static CoreTestsGolubetsTestHostIntegrationCoreApiCreateNestedNullableStringResponse*
create_nested_nullable_string(const gchar* nullable_string,
                              gpointer user_data) {
  g_autoptr(CoreTestsGolubetsTestAllNullableTypes) types =
      core_tests_golubets_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, nullptr, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullable_string, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr);
  FlValue* classList = fl_value_new_list();
  FlValue* classMap = fl_value_new_map();
  g_autoptr(CoreTestsGolubetsTestAllClassesWrapper) wrapper =
      core_tests_golubets_test_all_classes_wrapper_new(
          types, nullptr, nullptr, classList, nullptr, classMap, nullptr);
  return core_tests_golubets_test_host_integration_core_api_create_nested_nullable_string_response_new(
      wrapper);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiSendMultipleNullableTypesResponse*
send_multiple_nullable_types(gboolean* a_nullable_bool, int64_t* a_nullable_int,
                             const gchar* a_nullable_string,
                             gpointer user_data) {
  g_autoptr(CoreTestsGolubetsTestAllNullableTypes) types =
      core_tests_golubets_test_all_nullable_types_new(
          a_nullable_bool, a_nullable_int, nullptr, nullptr, nullptr, 0,
          nullptr, 0, nullptr, 0, nullptr, 0, nullptr, nullptr,
          a_nullable_string, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr);
  return core_tests_golubets_test_host_integration_core_api_send_multiple_nullable_types_response_new(
      types);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiSendMultipleNullableTypesWithoutRecursionResponse*
send_multiple_nullable_types_without_recursion(gboolean* a_nullable_bool,
                                               int64_t* a_nullable_int,
                                               const gchar* a_nullable_string,
                                               gpointer user_data) {
  g_autoptr(CoreTestsGolubetsTestAllNullableTypesWithoutRecursion) types =
      core_tests_golubets_test_all_nullable_types_without_recursion_new(
          a_nullable_bool, a_nullable_int, nullptr, nullptr, nullptr, 0,
          nullptr, 0, nullptr, 0, nullptr, 0, nullptr, nullptr,
          a_nullable_string, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr);
  return core_tests_golubets_test_host_integration_core_api_send_multiple_nullable_types_without_recursion_response_new(
      types);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableIntResponse*
echo_nullable_int(int64_t* a_nullable_int, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_int_response_new(
      a_nullable_int);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableDoubleResponse*
echo_nullable_double(double* a_nullable_double, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_double_response_new(
      a_nullable_double);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableBoolResponse*
echo_nullable_bool(gboolean* a_nullable_bool, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_bool_response_new(
      a_nullable_bool);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableStringResponse*
echo_nullable_string(const gchar* a_nullable_string, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_string_response_new(
      a_nullable_string);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableUint8ListResponse*
echo_nullable_uint8_list(const uint8_t* a_nullable_uint8_list,
                         size_t a_nullable_uint8_list_length,
                         gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_uint8_list_response_new(
      a_nullable_uint8_list, a_nullable_uint8_list_length);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableObjectResponse*
echo_nullable_object(FlValue* a_nullable_object, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_object_response_new(
      a_nullable_object);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableListResponse*
echo_nullable_list(FlValue* a_nullable_list, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_list_response_new(
      a_nullable_list);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableEnumListResponse*
echo_nullable_enum_list(FlValue* enum_list, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_enum_list_response_new(
      enum_list);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableClassListResponse*
echo_nullable_class_list(FlValue* class_list, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_class_list_response_new(
      class_list);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableNonNullEnumListResponse*
echo_nullable_non_null_enum_list(FlValue* enum_list, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_non_null_enum_list_response_new(
      enum_list);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableNonNullClassListResponse*
echo_nullable_non_null_class_list(FlValue* class_list, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_non_null_class_list_response_new(
      class_list);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableMapResponse*
echo_nullable_map(FlValue* map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_map_response_new(
      map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableStringMapResponse*
echo_nullable_string_map(FlValue* string_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_string_map_response_new(
      string_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableIntMapResponse*
echo_nullable_int_map(FlValue* int_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_int_map_response_new(
      int_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableEnumMapResponse*
echo_nullable_enum_map(FlValue* enum_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_enum_map_response_new(
      enum_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableClassMapResponse*
echo_nullable_class_map(FlValue* class_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_class_map_response_new(
      class_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableNonNullStringMapResponse*
echo_nullable_non_null_string_map(FlValue* string_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_non_null_string_map_response_new(
      string_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableNonNullIntMapResponse*
echo_nullable_non_null_int_map(FlValue* int_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_non_null_int_map_response_new(
      int_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableNonNullEnumMapResponse*
echo_nullable_non_null_enum_map(FlValue* enum_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_non_null_enum_map_response_new(
      enum_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableNonNullClassMapResponse*
echo_nullable_non_null_class_map(FlValue* class_map, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_non_null_class_map_response_new(
      class_map);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNullableEnumResponse*
echo_nullable_enum(CoreTestsGolubetsTestAnEnum* an_enum, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_nullable_enum_response_new(
      an_enum);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoAnotherNullableEnumResponse*
echo_another_nullable_enum(CoreTestsGolubetsTestAnotherEnum* another_enum,
                           gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_another_nullable_enum_response_new(
      another_enum);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoOptionalNullableIntResponse*
echo_optional_nullable_int(int64_t* a_nullable_int, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_optional_nullable_int_response_new(
      a_nullable_int);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiEchoNamedNullableStringResponse*
echo_named_nullable_string(const gchar* a_nullable_string, gpointer user_data) {
  return core_tests_golubets_test_host_integration_core_api_echo_named_nullable_string_response_new(
      a_nullable_string);
}

static void noop_async(

    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_noop_async(
      response_handle);
}

static void echo_async_int(
    int64_t an_int,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_int(
      response_handle, an_int);
}

static void echo_async_double(
    double a_double,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_double(
      response_handle, a_double);
}

static void echo_async_bool(
    gboolean a_bool,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_bool(
      response_handle, a_bool);
}

static void echo_async_string(
    const gchar* a_string,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_string(
      response_handle, a_string);
}

static void echo_async_uint8_list(
    const uint8_t* a_uint8_list, size_t a_uint8_list_length,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_uint8_list(
      response_handle, a_uint8_list, a_uint8_list_length);
}

static void echo_async_object(
    FlValue* an_object,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_object(
      response_handle, an_object);
}

static void echo_async_list(
    FlValue* a_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_list(
      response_handle, a_list);
}

static void echo_async_enum_list(
    FlValue* enum_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_enum_list(
      response_handle, enum_list);
}

static void echo_async_class_list(
    FlValue* class_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_class_list(
      response_handle, class_list);
}

static void echo_async_map(
    FlValue* map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_map(
      response_handle, map);
}

static void echo_async_string_map(
    FlValue* string_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_string_map(
      response_handle, string_map);
}

static void echo_async_int_map(
    FlValue* int_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_int_map(
      response_handle, int_map);
}

static void echo_async_enum_map(
    FlValue* enum_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_enum_map(
      response_handle, enum_map);
}

static void echo_async_class_map(
    FlValue* class_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_class_map(
      response_handle, class_map);
}

static void echo_async_enum(

    CoreTestsGolubetsTestAnEnum an_enum,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_enum(
      response_handle, an_enum);
}

static void echo_another_async_enum(

    CoreTestsGolubetsTestAnotherEnum another_enum,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_another_async_enum(
      response_handle, another_enum);
}

static void throw_async_error(

    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  g_autoptr(FlValue) details = fl_value_new_string("details");
  core_tests_golubets_test_host_integration_core_api_respond_error_throw_async_error(
      response_handle, "code", "message", details);
}

static void throw_async_error_from_void(

    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  g_autoptr(FlValue) details = fl_value_new_string("details");
  core_tests_golubets_test_host_integration_core_api_respond_error_throw_async_error_from_void(
      response_handle, "code", "message", details);
}

static void throw_async_flutter_error(

    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  g_autoptr(FlValue) details = fl_value_new_string("details");
  core_tests_golubets_test_host_integration_core_api_respond_error_throw_async_flutter_error(
      response_handle, "code", "message", details);
}

static void echo_async_all_types(

    CoreTestsGolubetsTestAllTypes* everything,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_all_types(
      response_handle, everything);
}

static void echo_modern_async_all_types(

    CoreTestsGolubetsTestAllTypes* everything,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_modern_async_all_types(
      response_handle, everything);
}

static void echo_modern_async_all_types_and_not_throw(

    CoreTestsGolubetsTestAllTypes* everything,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_modern_async_all_types_and_not_throw(
      response_handle, everything);
}

static void echo_modern_async_all_types_and_throw(

    CoreTestsGolubetsTestAllTypes* everything,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  g_autoptr(FlValue) details = fl_value_new_string("details");
  core_tests_golubets_test_host_integration_core_api_respond_error_echo_modern_async_all_types_and_throw(
      response_handle, "code", "message", details);
}

static void echo_async_nullable_all_nullable_types(

    CoreTestsGolubetsTestAllNullableTypes* everything,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_all_nullable_types(
      response_handle, everything);
}

static void echo_modern_async_nullable_all_nullable_types(

    CoreTestsGolubetsTestAllNullableTypes* everything,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_modern_async_nullable_all_nullable_types(
      response_handle, everything);
}

static void echo_async_nullable_all_nullable_types_without_recursion(

    CoreTestsGolubetsTestAllNullableTypesWithoutRecursion* everything,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_all_nullable_types_without_recursion(
      response_handle, everything);
}

static void echo_async_nullable_int(
    int64_t* an_int,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_int(
      response_handle, an_int);
}

static void echo_async_nullable_double(
    double* a_double,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_double(
      response_handle, a_double);
}

static void echo_async_nullable_bool(
    gboolean* a_bool,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_bool(
      response_handle, a_bool);
}

static void echo_async_nullable_string(
    const gchar* a_string,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_string(
      response_handle, a_string);
}

static void echo_async_nullable_uint8_list(
    const uint8_t* a_uint8_list, size_t a_uint8_list_length,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_uint8_list(
      response_handle, a_uint8_list, a_uint8_list_length);
}

static void echo_async_nullable_object(
    FlValue* an_object,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_object(
      response_handle, an_object);
}

static void echo_async_nullable_list(
    FlValue* a_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_list(
      response_handle, a_list);
}

static void echo_async_nullable_enum_list(
    FlValue* enum_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_enum_list(
      response_handle, enum_list);
}

static void echo_async_nullable_class_list(
    FlValue* class_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_class_list(
      response_handle, class_list);
}

static void echo_async_nullable_map(
    FlValue* map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_map(
      response_handle, map);
}

static void echo_async_nullable_string_map(
    FlValue* string_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_string_map(
      response_handle, string_map);
}

static void echo_async_nullable_int_map(
    FlValue* int_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_int_map(
      response_handle, int_map);
}

static void echo_async_nullable_enum_map(
    FlValue* enum_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_enum_map(
      response_handle, enum_map);
}

static void echo_async_nullable_class_map(
    FlValue* class_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_class_map(
      response_handle, class_map);
}

static void echo_async_nullable_enum(

    CoreTestsGolubetsTestAnEnum* an_enum,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_async_nullable_enum(
      response_handle, an_enum);
}

static void echo_another_async_nullable_enum(

    CoreTestsGolubetsTestAnotherEnum* another_enum,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_integration_core_api_respond_echo_another_async_nullable_enum(
      response_handle, another_enum);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiDefaultIsMainThreadResponse*
default_is_main_thread(gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);
  return core_tests_golubets_test_host_integration_core_api_default_is_main_thread_response_new(
      std::this_thread::get_id() == self->main_thread_id);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiTaskQueueIsBackgroundThreadResponse*
task_queue_is_background_thread(gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);
  return core_tests_golubets_test_host_integration_core_api_task_queue_is_background_thread_response_new(
      std::this_thread::get_id() != self->main_thread_id);
}

static void noop_cb(GObject* object, GAsyncResult* result, gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(CoreTestsGolubetsTestFlutterIntegrationCoreApiNoopResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_noop_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_noop(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_noop_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_noop_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_noop_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_noop_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_noop(
      data->response_handle);
}

static void call_flutter_noop(

    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_noop(
      self->flutter_core_api, nullptr, noop_cb,
      callback_data_new(self, response_handle));
}

static void throw_error_cb(GObject* object, GAsyncResult* result,
                           gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiThrowErrorResponse) response =
      core_tests_golubets_test_flutter_integration_core_api_throw_error_finish(
          CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
          &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_throw_error(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_throw_error_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_throw_error_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_throw_error_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_throw_error_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_throw_error(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_throw_error_response_get_return_value(
          response));
}

static void call_flutter_throw_error(

    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_throw_error(
      self->flutter_core_api, nullptr, throw_error_cb,
      callback_data_new(self, response_handle));
}

static void throw_error_from_void_cb(GObject* object, GAsyncResult* result,
                                     gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiThrowErrorFromVoidResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_throw_error_from_void_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_throw_error_from_void(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_throw_error_from_void_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_throw_error_from_void_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_throw_error_from_void_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_throw_error_from_void_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_throw_error_from_void(
      data->response_handle);
}

static void call_flutter_throw_error_from_void(

    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_throw_error_from_void(
      self->flutter_core_api, nullptr, throw_error_from_void_cb,
      callback_data_new(self, response_handle));
}

static void echo_all_types_cb(GObject* object, GAsyncResult* result,
                              gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoAllTypesResponse) response =
      core_tests_golubets_test_flutter_integration_core_api_echo_all_types_finish(
          CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
          &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_all_types(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_all_types_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_all_types_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_all_types_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_all_types_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_all_types(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_all_types_response_get_return_value(
          response));
}

static void call_flutter_echo_all_types(

    CoreTestsGolubetsTestAllTypes* everything,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_all_types(
      self->flutter_core_api, everything, self->cancellable, echo_all_types_cb,
      callback_data_new(self, response_handle));
}

static void echo_all_nullable_types_cb(GObject* object, GAsyncResult* result,
                                       gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoAllNullableTypesResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_all_nullable_types_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_all_nullable_types(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_all_nullable_types_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_all_nullable_types_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_all_nullable_types_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_all_nullable_types_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_all_nullable_types(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_all_nullable_types_response_get_return_value(
          response));
}

static void call_flutter_echo_all_nullable_types(

    CoreTestsGolubetsTestAllNullableTypes* everything,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_all_nullable_types(
      self->flutter_core_api, everything, self->cancellable,
      echo_all_nullable_types_cb, callback_data_new(self, response_handle));
}

static void send_multiple_nullable_types_cb(GObject* object,
                                            GAsyncResult* result,
                                            gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiSendMultipleNullableTypesResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_send_multiple_nullable_types_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_send_multiple_nullable_types(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_send_multiple_nullable_types_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_send_multiple_nullable_types_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_send_multiple_nullable_types_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_send_multiple_nullable_types_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_send_multiple_nullable_types(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_send_multiple_nullable_types_response_get_return_value(
          response));
}

static void call_flutter_send_multiple_nullable_types(
    gboolean* a_nullable_bool, int64_t* a_nullable_int,
    const gchar* a_nullable_string,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_send_multiple_nullable_types(
      self->flutter_core_api, a_nullable_bool, a_nullable_int,
      a_nullable_string, self->cancellable, send_multiple_nullable_types_cb,
      callback_data_new(self, response_handle));
}

static void echo_all_nullable_types_without_recursion_cb(GObject* object,
                                                         GAsyncResult* result,
                                                         gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoAllNullableTypesWithoutRecursionResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_all_nullable_types_without_recursion_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_all_nullable_types_without_recursion(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_all_nullable_types_without_recursion_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_all_nullable_types_without_recursion_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_all_nullable_types_without_recursion_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_all_nullable_types_without_recursion_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_all_nullable_types_without_recursion(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_all_nullable_types_without_recursion_response_get_return_value(
          response));
}

static void call_flutter_echo_all_nullable_types_without_recursion(

    CoreTestsGolubetsTestAllNullableTypesWithoutRecursion* everything,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_all_nullable_types_without_recursion(
      self->flutter_core_api, everything, self->cancellable,
      echo_all_nullable_types_without_recursion_cb,
      callback_data_new(self, response_handle));
}

static void send_multiple_nullable_types_without_recursion_cb(
    GObject* object, GAsyncResult* result, gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiSendMultipleNullableTypesWithoutRecursionResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_send_multiple_nullable_types_without_recursion_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_send_multiple_nullable_types_without_recursion(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_send_multiple_nullable_types_without_recursion_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_send_multiple_nullable_types_without_recursion_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_send_multiple_nullable_types_without_recursion_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_send_multiple_nullable_types_without_recursion_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_send_multiple_nullable_types_without_recursion(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_send_multiple_nullable_types_without_recursion_response_get_return_value(
          response));
}

static void call_flutter_send_multiple_nullable_types_without_recursion(
    gboolean* a_nullable_bool, int64_t* a_nullable_int,
    const gchar* a_nullable_string,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_send_multiple_nullable_types_without_recursion(
      self->flutter_core_api, a_nullable_bool, a_nullable_int,
      a_nullable_string, self->cancellable,
      send_multiple_nullable_types_without_recursion_cb,
      callback_data_new(self, response_handle));
}

static void echo_bool_cb(GObject* object, GAsyncResult* result,
                         gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoBoolResponse) response =
      core_tests_golubets_test_flutter_integration_core_api_echo_bool_finish(
          CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
          &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_bool_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_bool_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_bool_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_bool_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_bool(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_bool_response_get_return_value(
          response));
}

static void call_flutter_echo_bool(
    gboolean a_bool,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_bool(
      self->flutter_core_api, a_bool, self->cancellable, echo_bool_cb,
      callback_data_new(self, response_handle));
}

static void echo_int_cb(GObject* object, GAsyncResult* result,
                        gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoIntResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_int_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_int(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_int_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_int_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_int_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_int_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_int(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_int_response_get_return_value(
          response));
}

static void call_flutter_echo_int(
    int64_t an_int,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_int(
      self->flutter_core_api, an_int, self->cancellable, echo_int_cb,
      callback_data_new(self, response_handle));
}

static void echo_double_cb(GObject* object, GAsyncResult* result,
                           gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoDoubleResponse) response =
      core_tests_golubets_test_flutter_integration_core_api_echo_double_finish(
          CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
          &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_double(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_double_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_double_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_double_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_double_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_double(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_double_response_get_return_value(
          response));
}

static void call_flutter_echo_double(
    double a_double,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_double(
      self->flutter_core_api, a_double, self->cancellable, echo_double_cb,
      callback_data_new(self, response_handle));
}

static void echo_string_cb(GObject* object, GAsyncResult* result,
                           gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoStringResponse) response =
      core_tests_golubets_test_flutter_integration_core_api_echo_string_finish(
          CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
          &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_string(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_string_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_string_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_string_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_string_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_string(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_string_response_get_return_value(
          response));
}

static void call_flutter_echo_string(
    const gchar* a_string,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_string(
      self->flutter_core_api, a_string, self->cancellable, echo_string_cb,
      callback_data_new(self, response_handle));
}

static void echo_uint8_list_cb(GObject* object, GAsyncResult* result,
                               gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoUint8ListResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_uint8_list_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_uint8_list(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_uint8_list_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_uint8_list_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_uint8_list_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_uint8_list_response_get_error_details(
            response));
    return;
  }

  size_t return_value_length;
  const uint8_t* return_value =
      core_tests_golubets_test_flutter_integration_core_api_echo_uint8_list_response_get_return_value(
          response, &return_value_length);
  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_uint8_list(
      data->response_handle, return_value, return_value_length);
}

static void call_flutter_echo_uint8_list(
    const uint8_t* a_list, size_t a_list_length,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_uint8_list(
      self->flutter_core_api, a_list, a_list_length, self->cancellable,
      echo_uint8_list_cb, callback_data_new(self, response_handle));
}

static void echo_list_cb(GObject* object, GAsyncResult* result,
                         gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoListResponse) response =
      core_tests_golubets_test_flutter_integration_core_api_echo_list_finish(
          CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
          &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_list(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_list_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_list_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_list_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_list_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_list(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_list_response_get_return_value(
          response));
}

static void call_flutter_echo_list(
    FlValue* a_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_list(
      self->flutter_core_api, a_list, self->cancellable, echo_list_cb,
      callback_data_new(self, response_handle));
}

static void echo_enum_list_cb(GObject* object, GAsyncResult* result,
                              gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoEnumListResponse) response =
      core_tests_golubets_test_flutter_integration_core_api_echo_enum_list_finish(
          CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
          &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_enum_list(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_enum_list_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_enum_list_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_enum_list_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_enum_list_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_enum_list(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_enum_list_response_get_return_value(
          response));
}

static void call_flutter_echo_enum_list(
    FlValue* enum_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_enum_list(
      self->flutter_core_api, enum_list, self->cancellable, echo_enum_list_cb,
      callback_data_new(self, response_handle));
}

static void echo_class_list_cb(GObject* object, GAsyncResult* result,
                               gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoClassListResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_class_list_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_class_list(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_class_list_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_class_list_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_class_list_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_class_list_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_class_list(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_class_list_response_get_return_value(
          response));
}

static void call_flutter_echo_class_list(
    FlValue* class_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_class_list(
      self->flutter_core_api, class_list, self->cancellable, echo_class_list_cb,
      callback_data_new(self, response_handle));
}

static void echo_non_null_enum_list_cb(GObject* object, GAsyncResult* result,
                                       gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNonNullEnumListResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_non_null_enum_list_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_non_null_enum_list(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_non_null_enum_list_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_enum_list_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_enum_list_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_enum_list_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_non_null_enum_list(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_non_null_enum_list_response_get_return_value(
          response));
}

static void call_flutter_echo_non_null_enum_list(
    FlValue* enum_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_non_null_enum_list(
      self->flutter_core_api, enum_list, self->cancellable,
      echo_non_null_enum_list_cb, callback_data_new(self, response_handle));
}

static void echo_non_null_class_list_cb(GObject* object, GAsyncResult* result,
                                        gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNonNullClassListResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_non_null_class_list_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_non_null_class_list(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_non_null_class_list_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_class_list_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_class_list_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_class_list_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_non_null_class_list(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_non_null_class_list_response_get_return_value(
          response));
}

static void call_flutter_echo_non_null_class_list(
    FlValue* class_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_non_null_class_list(
      self->flutter_core_api, class_list, self->cancellable,
      echo_non_null_class_list_cb, callback_data_new(self, response_handle));
}

static void echo_map_cb(GObject* object, GAsyncResult* result,
                        gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_map_response_get_return_value(
          response));
}

static void call_flutter_echo_map(
    FlValue* map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_map(
      self->flutter_core_api, map, self->cancellable, echo_map_cb,
      callback_data_new(self, response_handle));
}

static void echo_string_map_cb(GObject* object, GAsyncResult* result,
                               gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoStringMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_string_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_string_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_string_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_string_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_string_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_string_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_string_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_string_map_response_get_return_value(
          response));
}

static void call_flutter_echo_string_map(
    FlValue* string_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_string_map(
      self->flutter_core_api, string_map, self->cancellable, echo_string_map_cb,
      callback_data_new(self, response_handle));
}

static void echo_int_map_cb(GObject* object, GAsyncResult* result,
                            gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoIntMapResponse) response =
      core_tests_golubets_test_flutter_integration_core_api_echo_int_map_finish(
          CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
          &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_int_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_int_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_int_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_int_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_int_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_int_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_int_map_response_get_return_value(
          response));
}

static void call_flutter_echo_int_map(
    FlValue* int_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_int_map(
      self->flutter_core_api, int_map, self->cancellable, echo_int_map_cb,
      callback_data_new(self, response_handle));
}

static void echo_enum_map_cb(GObject* object, GAsyncResult* result,
                             gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoEnumMapResponse) response =
      core_tests_golubets_test_flutter_integration_core_api_echo_enum_map_finish(
          CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
          &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_enum_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_enum_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_enum_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_enum_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_enum_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_enum_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_enum_map_response_get_return_value(
          response));
}

static void call_flutter_echo_enum_map(
    FlValue* enum_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_enum_map(
      self->flutter_core_api, enum_map, self->cancellable, echo_enum_map_cb,
      callback_data_new(self, response_handle));
}

static void echo_class_map_cb(GObject* object, GAsyncResult* result,
                              gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoClassMapResponse) response =
      core_tests_golubets_test_flutter_integration_core_api_echo_class_map_finish(
          CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
          &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_class_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_class_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_class_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_class_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_class_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_class_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_class_map_response_get_return_value(
          response));
}

static void call_flutter_echo_class_map(
    FlValue* class_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_class_map(
      self->flutter_core_api, class_map, self->cancellable, echo_class_map_cb,
      callback_data_new(self, response_handle));
}

static void echo_non_null_string_map_cb(GObject* object, GAsyncResult* result,
                                        gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNonNullStringMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_non_null_string_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_non_null_string_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_non_null_string_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_string_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_string_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_string_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_non_null_string_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_non_null_string_map_response_get_return_value(
          response));
}

static void call_flutter_echo_non_null_string_map(
    FlValue* string_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_non_null_string_map(
      self->flutter_core_api, string_map, self->cancellable,
      echo_non_null_string_map_cb, callback_data_new(self, response_handle));
}

static void echo_non_null_int_map_cb(GObject* object, GAsyncResult* result,
                                     gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNonNullIntMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_non_null_int_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_non_null_int_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_non_null_int_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_int_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_int_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_int_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_non_null_int_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_non_null_int_map_response_get_return_value(
          response));
}

static void call_flutter_echo_non_null_int_map(
    FlValue* int_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_non_null_int_map(
      self->flutter_core_api, int_map, self->cancellable,
      echo_non_null_int_map_cb, callback_data_new(self, response_handle));
}

static void echo_non_null_enum_map_cb(GObject* object, GAsyncResult* result,
                                      gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNonNullEnumMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_non_null_enum_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_non_null_enum_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_non_null_enum_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_enum_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_enum_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_enum_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_non_null_enum_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_non_null_enum_map_response_get_return_value(
          response));
}

static void call_flutter_echo_non_null_enum_map(
    FlValue* enum_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_non_null_enum_map(
      self->flutter_core_api, enum_map, self->cancellable,
      echo_non_null_enum_map_cb, callback_data_new(self, response_handle));
}

static void echo_non_null_class_map_cb(GObject* object, GAsyncResult* result,
                                       gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNonNullClassMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_non_null_class_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_non_null_class_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_non_null_class_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_class_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_class_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_non_null_class_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_non_null_class_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_non_null_class_map_response_get_return_value(
          response));
}

static void call_flutter_echo_non_null_class_map(
    FlValue* class_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_non_null_class_map(
      self->flutter_core_api, class_map, self->cancellable,
      echo_non_null_class_map_cb, callback_data_new(self, response_handle));
}

static void echo_enum_cb(GObject* object, GAsyncResult* result,
                         gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoEnumResponse) response =
      core_tests_golubets_test_flutter_integration_core_api_echo_enum_finish(
          CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object), result,
          &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_enum(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_enum_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_enum_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_enum_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_enum_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_enum(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_enum_response_get_return_value(
          response));
}

static void call_flutter_echo_enum(

    CoreTestsGolubetsTestAnEnum an_enum,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_enum(
      self->flutter_core_api, an_enum, self->cancellable, echo_enum_cb,
      callback_data_new(self, response_handle));
}

static void echo_another_enum_cb(GObject* object, GAsyncResult* result,
                                 gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoAnotherEnumResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_another_enum_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_another_enum(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_another_enum_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_another_enum_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_another_enum_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_another_enum_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_another_enum(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_another_enum_response_get_return_value(
          response));
}

static void call_flutter_echo_another_enum(

    CoreTestsGolubetsTestAnotherEnum another_enum,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_another_enum(
      self->flutter_core_api, another_enum, self->cancellable,
      echo_another_enum_cb, callback_data_new(self, response_handle));
}

static void echo_nullable_bool_cb(GObject* object, GAsyncResult* result,
                                  gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableBoolResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_bool_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_bool(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_bool_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_bool_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_bool_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_bool_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_bool(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_bool_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_bool(
    gboolean* a_bool,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_bool(
      self->flutter_core_api, a_bool, self->cancellable, echo_nullable_bool_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_int_cb(GObject* object, GAsyncResult* result,
                                 gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableIntResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_int_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_int(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_int_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_int_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_int_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_int_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_int(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_int_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_int(
    int64_t* an_int,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_int(
      self->flutter_core_api, an_int, self->cancellable, echo_nullable_int_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_double_cb(GObject* object, GAsyncResult* result,
                                    gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableDoubleResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_double_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_double(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_double_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_double_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_double_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_double_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_double(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_double_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_double(
    double* a_double,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_double(
      self->flutter_core_api, a_double, self->cancellable,
      echo_nullable_double_cb, callback_data_new(self, response_handle));
}

static void echo_nullable_string_cb(GObject* object, GAsyncResult* result,
                                    gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableStringResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_string_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_string(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_string_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_string_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_string_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_string_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_string(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_string_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_string(
    const gchar* a_string,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_string(
      self->flutter_core_api, a_string, self->cancellable,
      echo_nullable_string_cb, callback_data_new(self, response_handle));
}

static void echo_nullable_uint8_list_cb(GObject* object, GAsyncResult* result,
                                        gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableUint8ListResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_uint8_list_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_uint8_list(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_uint8_list_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_uint8_list_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_uint8_list_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_uint8_list_response_get_error_details(
            response));
    return;
  }

  size_t return_value_length;
  const uint8_t* return_value =
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_uint8_list_response_get_return_value(
          response, &return_value_length);
  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_uint8_list(
      data->response_handle, return_value, return_value_length);
}

static void call_flutter_echo_nullable_uint8_list(
    const uint8_t* a_list, size_t a_list_length,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_uint8_list(
      self->flutter_core_api, a_list, a_list_length, self->cancellable,
      echo_nullable_uint8_list_cb, callback_data_new(self, response_handle));
}

static void echo_nullable_list_cb(GObject* object, GAsyncResult* result,
                                  gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableListResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_list_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_list(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_list_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_list_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_list_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_list_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_list(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_list_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_list(
    FlValue* a_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_list(
      self->flutter_core_api, a_list, self->cancellable, echo_nullable_list_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_enum_list_cb(GObject* object, GAsyncResult* result,
                                       gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableEnumListResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_list_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_enum_list(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_list_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_list_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_list_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_list_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_enum_list(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_list_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_enum_list(
    FlValue* enum_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_list(
      self->flutter_core_api, enum_list, self->cancellable,
      echo_nullable_enum_list_cb, callback_data_new(self, response_handle));
}

static void echo_nullable_class_list_cb(GObject* object, GAsyncResult* result,
                                        gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableClassListResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_class_list_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_class_list(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_class_list_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_class_list_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_class_list_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_class_list_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_class_list(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_class_list_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_class_list(
    FlValue* class_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_class_list(
      self->flutter_core_api, class_list, self->cancellable,
      echo_nullable_class_list_cb, callback_data_new(self, response_handle));
}

static void echo_nullable_non_null_enum_list_cb(GObject* object,
                                                GAsyncResult* result,
                                                gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableNonNullEnumListResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_enum_list_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_non_null_enum_list(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_enum_list_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_enum_list_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_enum_list_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_enum_list_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_non_null_enum_list(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_enum_list_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_non_null_enum_list(
    FlValue* enum_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_enum_list(
      self->flutter_core_api, enum_list, self->cancellable,
      echo_nullable_non_null_enum_list_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_non_null_class_list_cb(GObject* object,
                                                 GAsyncResult* result,
                                                 gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableNonNullClassListResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_class_list_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_non_null_class_list(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_class_list_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_class_list_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_class_list_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_class_list_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_non_null_class_list(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_class_list_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_non_null_class_list(
    FlValue* class_list,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_class_list(
      self->flutter_core_api, class_list, self->cancellable,
      echo_nullable_non_null_class_list_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_map_cb(GObject* object, GAsyncResult* result,
                                 gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_map_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_map(
    FlValue* map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_map(
      self->flutter_core_api, map, self->cancellable, echo_nullable_map_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_string_map_cb(GObject* object, GAsyncResult* result,
                                        gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableStringMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_string_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_string_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_string_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_string_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_string_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_string_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_string_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_string_map_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_string_map(
    FlValue* string_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_string_map(
      self->flutter_core_api, string_map, self->cancellable,
      echo_nullable_string_map_cb, callback_data_new(self, response_handle));
}

static void echo_nullable_int_map_cb(GObject* object, GAsyncResult* result,
                                     gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableIntMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_int_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_int_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_int_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_int_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_int_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_int_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_int_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_int_map_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_int_map(
    FlValue* int_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_int_map(
      self->flutter_core_api, int_map, self->cancellable,
      echo_nullable_int_map_cb, callback_data_new(self, response_handle));
}

static void echo_nullable_enum_map_cb(GObject* object, GAsyncResult* result,
                                      gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableEnumMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_enum_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_enum_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_map_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_enum_map(
    FlValue* enum_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_map(
      self->flutter_core_api, enum_map, self->cancellable,
      echo_nullable_enum_map_cb, callback_data_new(self, response_handle));
}

static void echo_nullable_class_map_cb(GObject* object, GAsyncResult* result,
                                       gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableClassMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_class_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_class_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_class_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_class_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_class_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_class_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_class_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_class_map_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_class_map(
    FlValue* class_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_class_map(
      self->flutter_core_api, class_map, self->cancellable,
      echo_nullable_class_map_cb, callback_data_new(self, response_handle));
}

static void echo_nullable_non_null_string_map_cb(GObject* object,
                                                 GAsyncResult* result,
                                                 gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableNonNullStringMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_string_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_non_null_string_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_string_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_string_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_string_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_string_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_non_null_string_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_string_map_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_non_null_string_map(
    FlValue* string_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_string_map(
      self->flutter_core_api, string_map, self->cancellable,
      echo_nullable_non_null_string_map_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_non_null_int_map_cb(GObject* object,
                                              GAsyncResult* result,
                                              gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableNonNullIntMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_int_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_non_null_int_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_int_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_int_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_int_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_int_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_non_null_int_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_int_map_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_non_null_int_map(
    FlValue* int_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_int_map(
      self->flutter_core_api, int_map, self->cancellable,
      echo_nullable_non_null_int_map_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_non_null_enum_map_cb(GObject* object,
                                               GAsyncResult* result,
                                               gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableNonNullEnumMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_enum_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_non_null_enum_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_enum_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_enum_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_enum_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_enum_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_non_null_enum_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_enum_map_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_non_null_enum_map(
    FlValue* enum_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_enum_map(
      self->flutter_core_api, enum_map, self->cancellable,
      echo_nullable_non_null_enum_map_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_non_null_class_map_cb(GObject* object,
                                                GAsyncResult* result,
                                                gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableNonNullClassMapResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_class_map_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_non_null_class_map(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_class_map_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_class_map_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_class_map_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_class_map_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_non_null_class_map(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_class_map_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_non_null_class_map(
    FlValue* class_map,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_non_null_class_map(
      self->flutter_core_api, class_map, self->cancellable,
      echo_nullable_non_null_class_map_cb,
      callback_data_new(self, response_handle));
}

static void echo_nullable_enum_cb(GObject* object, GAsyncResult* result,
                                  gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoNullableEnumResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_nullable_enum(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_nullable_enum(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum_response_get_return_value(
          response));
}

static void call_flutter_echo_nullable_enum(

    CoreTestsGolubetsTestAnEnum* an_enum,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_nullable_enum(
      self->flutter_core_api, an_enum, self->cancellable, echo_nullable_enum_cb,
      callback_data_new(self, response_handle));
}

static void echo_another_nullable_enum_cb(GObject* object, GAsyncResult* result,
                                          gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(
      CoreTestsGolubetsTestFlutterIntegrationCoreApiEchoAnotherNullableEnumResponse)
      response =
          core_tests_golubets_test_flutter_integration_core_api_echo_another_nullable_enum_finish(
              CORE_TESTS_GOLUBETS_TEST_FLUTTER_INTEGRATION_CORE_API(object),
              result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_another_nullable_enum(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_integration_core_api_echo_another_nullable_enum_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_integration_core_api_echo_another_nullable_enum_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_another_nullable_enum_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_integration_core_api_echo_another_nullable_enum_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_echo_another_nullable_enum(
      data->response_handle,
      core_tests_golubets_test_flutter_integration_core_api_echo_another_nullable_enum_response_get_return_value(
          response));
}

static void call_flutter_echo_another_nullable_enum(

    CoreTestsGolubetsTestAnotherEnum* another_enum,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_integration_core_api_echo_another_nullable_enum(
      self->flutter_core_api, another_enum, self->cancellable,
      echo_another_nullable_enum_cb, callback_data_new(self, response_handle));
}

static void small_api_two_echo_string_cb(GObject* object, GAsyncResult* result,
                                         gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);

  g_autoptr(GError) error = nullptr;
  g_autoptr(CoreTestsGolubetsTestFlutterSmallApiEchoStringResponse) response =
      core_tests_golubets_test_flutter_small_api_echo_string_finish(
          CORE_TESTS_GOLUBETS_TEST_FLUTTER_SMALL_API(object), result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_small_api_echo_string(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_small_api_echo_string_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_small_api_echo_string_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_small_api_echo_string_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_small_api_echo_string_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_host_integration_core_api_respond_call_flutter_small_api_echo_string(
      data->response_handle,
      core_tests_golubets_test_flutter_small_api_echo_string_response_get_return_value(
          response));
}

static void small_api_one_echo_string_cb(GObject* object, GAsyncResult* result,
                                         gpointer user_data) {
  g_autoptr(CallbackData) data = static_cast<CallbackData*>(user_data);
  TestPlugin* self = data->self;

  g_autoptr(GError) error = nullptr;
  g_autoptr(CoreTestsGolubetsTestFlutterSmallApiEchoStringResponse) response =
      core_tests_golubets_test_flutter_small_api_echo_string_finish(
          CORE_TESTS_GOLUBETS_TEST_FLUTTER_SMALL_API(object), result, &error);
  if (response == nullptr) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_small_api_echo_string(
        data->response_handle, "Internal Error", error->message, nullptr);
    return;
  }
  if (core_tests_golubets_test_flutter_small_api_echo_string_response_is_error(
          response)) {
    core_tests_golubets_test_host_integration_core_api_respond_error_call_flutter_echo_bool(
        data->response_handle,
        core_tests_golubets_test_flutter_small_api_echo_string_response_get_error_code(
            response),
        core_tests_golubets_test_flutter_small_api_echo_string_response_get_error_message(
            response),
        core_tests_golubets_test_flutter_small_api_echo_string_response_get_error_details(
            response));
    return;
  }

  core_tests_golubets_test_flutter_small_api_echo_string(
      self->flutter_small_api_two,
      core_tests_golubets_test_flutter_small_api_echo_string_response_get_return_value(
          response),
      self->cancellable, small_api_two_echo_string_cb, g_steal_pointer(&data));
}

static void call_flutter_small_api_echo_string(
    const gchar* a_string,
    CoreTestsGolubetsTestHostIntegrationCoreApiResponseHandle* response_handle,
    gpointer user_data) {
  TestPlugin* self = TEST_PLUGIN(user_data);

  core_tests_golubets_test_flutter_small_api_echo_string(
      self->flutter_small_api_one, a_string, self->cancellable,
      small_api_one_echo_string_cb, callback_data_new(self, response_handle));
}

CoreTestsGolubetsTestUnusedClass* test_unused_class_generated() {
  return core_tests_golubets_test_unused_class_new(nullptr);
}

static CoreTestsGolubetsTestHostIntegrationCoreApiVTable host_core_api_vtable =
    {.noop = noop,
     .echo_all_types = echo_all_types,
     .throw_error = throw_error,
     .throw_error_from_void = throw_error_from_void,
     .throw_flutter_error = throw_flutter_error,
     .echo_int = echo_int,
     .echo_double = echo_double,
     .echo_bool = echo_bool,
     .echo_string = echo_string,
     .echo_uint8_list = echo_uint8_list,
     .echo_object = echo_object,
     .echo_list = echo_list,
     .echo_enum_list = echo_enum_list,
     .echo_class_list = echo_class_list,
     .echo_non_null_enum_list = echo_non_null_enum_list,
     .echo_non_null_class_list = echo_non_null_class_list,
     .echo_map = echo_map,
     .echo_string_map = echo_string_map,
     .echo_int_map = echo_int_map,
     .echo_enum_map = echo_enum_map,
     .echo_class_map = echo_class_map,
     .echo_non_null_string_map = echo_non_null_string_map,
     .echo_non_null_int_map = echo_non_null_int_map,
     .echo_non_null_enum_map = echo_non_null_enum_map,
     .echo_non_null_class_map = echo_non_null_class_map,
     .echo_class_wrapper = echo_class_wrapper,
     .echo_enum = echo_enum,
     .echo_another_enum = echo_another_enum,
     .echo_named_default_string = echo_named_default_string,
     .echo_optional_default_double = echo_optional_default_double,
     .create_all_types_with_defaults = create_all_types_with_defaults,
     .echo_all_types_with_defaults = echo_all_types_with_defaults,
     .echo_required_int = echo_required_int,
     .echo_all_nullable_types = echo_all_nullable_types,
     .echo_all_nullable_types_without_recursion =
         echo_all_nullable_types_without_recursion,
     .extract_nested_nullable_string = extract_nested_nullable_string,
     .create_nested_nullable_string = create_nested_nullable_string,
     .send_multiple_nullable_types = send_multiple_nullable_types,
     .send_multiple_nullable_types_without_recursion =
         send_multiple_nullable_types_without_recursion,
     .echo_nullable_int = echo_nullable_int,
     .echo_nullable_double = echo_nullable_double,
     .echo_nullable_bool = echo_nullable_bool,
     .echo_nullable_string = echo_nullable_string,
     .echo_nullable_uint8_list = echo_nullable_uint8_list,
     .echo_nullable_object = echo_nullable_object,
     .echo_nullable_list = echo_nullable_list,
     .echo_nullable_enum_list = echo_nullable_enum_list,
     .echo_nullable_class_list = echo_nullable_class_list,
     .echo_nullable_non_null_enum_list = echo_nullable_non_null_enum_list,
     .echo_nullable_non_null_class_list = echo_nullable_non_null_class_list,
     .echo_nullable_map = echo_nullable_map,
     .echo_nullable_string_map = echo_nullable_string_map,
     .echo_nullable_int_map = echo_nullable_int_map,
     .echo_nullable_enum_map = echo_nullable_enum_map,
     .echo_nullable_class_map = echo_nullable_class_map,
     .echo_nullable_non_null_string_map = echo_nullable_non_null_string_map,
     .echo_nullable_non_null_int_map = echo_nullable_non_null_int_map,
     .echo_nullable_non_null_enum_map = echo_nullable_non_null_enum_map,
     .echo_nullable_non_null_class_map = echo_nullable_non_null_class_map,
     .echo_nullable_enum = echo_nullable_enum,
     .echo_another_nullable_enum = echo_another_nullable_enum,
     .echo_optional_nullable_int = echo_optional_nullable_int,
     .echo_named_nullable_string = echo_named_nullable_string,
     .noop_async = noop_async,
     .echo_async_int = echo_async_int,
     .echo_async_double = echo_async_double,
     .echo_async_bool = echo_async_bool,
     .echo_async_string = echo_async_string,
     .echo_async_uint8_list = echo_async_uint8_list,
     .echo_async_object = echo_async_object,
     .echo_async_list = echo_async_list,
     .echo_async_enum_list = echo_async_enum_list,
     .echo_async_class_list = echo_async_class_list,
     .echo_async_map = echo_async_map,
     .echo_async_string_map = echo_async_string_map,
     .echo_async_int_map = echo_async_int_map,
     .echo_async_enum_map = echo_async_enum_map,
     .echo_async_class_map = echo_async_class_map,
     .echo_async_enum = echo_async_enum,
     .echo_another_async_enum = echo_another_async_enum,
     .throw_async_error = throw_async_error,
     .throw_async_error_from_void = throw_async_error_from_void,
     .throw_async_flutter_error = throw_async_flutter_error,
     .echo_async_all_types = echo_async_all_types,
     .echo_modern_async_all_types = echo_modern_async_all_types,
     .echo_modern_async_all_types_and_not_throw =
         echo_modern_async_all_types_and_not_throw,
     .echo_modern_async_all_types_and_throw =
         echo_modern_async_all_types_and_throw,
     .echo_async_nullable_all_nullable_types =
         echo_async_nullable_all_nullable_types,
     .echo_modern_async_nullable_all_nullable_types =
         echo_modern_async_nullable_all_nullable_types,
     .echo_async_nullable_all_nullable_types_without_recursion =
         echo_async_nullable_all_nullable_types_without_recursion,
     .echo_async_nullable_int = echo_async_nullable_int,
     .echo_async_nullable_double = echo_async_nullable_double,
     .echo_async_nullable_bool = echo_async_nullable_bool,
     .echo_async_nullable_string = echo_async_nullable_string,
     .echo_async_nullable_uint8_list = echo_async_nullable_uint8_list,
     .echo_async_nullable_object = echo_async_nullable_object,
     .echo_async_nullable_list = echo_async_nullable_list,
     .echo_async_nullable_enum_list = echo_async_nullable_enum_list,
     .echo_async_nullable_class_list = echo_async_nullable_class_list,
     .echo_async_nullable_map = echo_async_nullable_map,
     .echo_async_nullable_string_map = echo_async_nullable_string_map,
     .echo_async_nullable_int_map = echo_async_nullable_int_map,
     .echo_async_nullable_enum_map = echo_async_nullable_enum_map,
     .echo_async_nullable_class_map = echo_async_nullable_class_map,
     .echo_async_nullable_enum = echo_async_nullable_enum,
     .echo_another_async_nullable_enum = echo_another_async_nullable_enum,
     .default_is_main_thread = default_is_main_thread,
     .task_queue_is_background_thread = task_queue_is_background_thread,
     .call_flutter_noop = call_flutter_noop,
     .call_flutter_throw_error = call_flutter_throw_error,
     .call_flutter_throw_error_from_void = call_flutter_throw_error_from_void,
     .call_flutter_echo_all_types = call_flutter_echo_all_types,
     .call_flutter_echo_all_nullable_types =
         call_flutter_echo_all_nullable_types,
     .call_flutter_send_multiple_nullable_types =
         call_flutter_send_multiple_nullable_types,
     .call_flutter_echo_all_nullable_types_without_recursion =
         call_flutter_echo_all_nullable_types_without_recursion,
     .call_flutter_send_multiple_nullable_types_without_recursion =
         call_flutter_send_multiple_nullable_types_without_recursion,
     .call_flutter_echo_bool = call_flutter_echo_bool,
     .call_flutter_echo_int = call_flutter_echo_int,
     .call_flutter_echo_double = call_flutter_echo_double,
     .call_flutter_echo_string = call_flutter_echo_string,
     .call_flutter_echo_uint8_list = call_flutter_echo_uint8_list,
     .call_flutter_echo_list = call_flutter_echo_list,
     .call_flutter_echo_enum_list = call_flutter_echo_enum_list,
     .call_flutter_echo_class_list = call_flutter_echo_class_list,
     .call_flutter_echo_non_null_enum_list =
         call_flutter_echo_non_null_enum_list,
     .call_flutter_echo_non_null_class_list =
         call_flutter_echo_non_null_class_list,
     .call_flutter_echo_map = call_flutter_echo_map,
     .call_flutter_echo_string_map = call_flutter_echo_string_map,
     .call_flutter_echo_int_map = call_flutter_echo_int_map,
     .call_flutter_echo_enum_map = call_flutter_echo_enum_map,
     .call_flutter_echo_class_map = call_flutter_echo_class_map,
     .call_flutter_echo_non_null_string_map =
         call_flutter_echo_non_null_string_map,
     .call_flutter_echo_non_null_int_map = call_flutter_echo_non_null_int_map,
     .call_flutter_echo_non_null_enum_map = call_flutter_echo_non_null_enum_map,
     .call_flutter_echo_non_null_class_map =
         call_flutter_echo_non_null_class_map,
     .call_flutter_echo_enum = call_flutter_echo_enum,
     .call_flutter_echo_another_enum = call_flutter_echo_another_enum,
     .call_flutter_echo_nullable_bool = call_flutter_echo_nullable_bool,
     .call_flutter_echo_nullable_int = call_flutter_echo_nullable_int,
     .call_flutter_echo_nullable_double = call_flutter_echo_nullable_double,
     .call_flutter_echo_nullable_string = call_flutter_echo_nullable_string,
     .call_flutter_echo_nullable_uint8_list =
         call_flutter_echo_nullable_uint8_list,
     .call_flutter_echo_nullable_list = call_flutter_echo_nullable_list,
     .call_flutter_echo_nullable_enum_list =
         call_flutter_echo_nullable_enum_list,
     .call_flutter_echo_nullable_class_list =
         call_flutter_echo_nullable_class_list,
     .call_flutter_echo_nullable_non_null_enum_list =
         call_flutter_echo_nullable_non_null_enum_list,
     .call_flutter_echo_nullable_non_null_class_list =
         call_flutter_echo_nullable_non_null_class_list,
     .call_flutter_echo_nullable_map = call_flutter_echo_nullable_map,
     .call_flutter_echo_nullable_string_map =
         call_flutter_echo_nullable_string_map,
     .call_flutter_echo_nullable_int_map = call_flutter_echo_nullable_int_map,
     .call_flutter_echo_nullable_enum_map = call_flutter_echo_nullable_enum_map,
     .call_flutter_echo_nullable_class_map =
         call_flutter_echo_nullable_class_map,
     .call_flutter_echo_nullable_non_null_string_map =
         call_flutter_echo_nullable_non_null_string_map,
     .call_flutter_echo_nullable_non_null_int_map =
         call_flutter_echo_nullable_non_null_int_map,
     .call_flutter_echo_nullable_non_null_enum_map =
         call_flutter_echo_nullable_non_null_enum_map,
     .call_flutter_echo_nullable_non_null_class_map =
         call_flutter_echo_nullable_non_null_class_map,
     .call_flutter_echo_nullable_enum = call_flutter_echo_nullable_enum,
     .call_flutter_echo_another_nullable_enum =
         call_flutter_echo_another_nullable_enum,
     .call_flutter_small_api_echo_string = call_flutter_small_api_echo_string};

static void echo(
    const gchar* a_string,
    CoreTestsGolubetsTestHostSmallApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_small_api_respond_echo(response_handle,
                                                       a_string);
}

static void void_void(
    CoreTestsGolubetsTestHostSmallApiResponseHandle* response_handle,
    gpointer user_data) {
  core_tests_golubets_test_host_small_api_respond_void_void(response_handle);
}

static CoreTestsGolubetsTestHostSmallApiVTable host_small_api_vtable = {
    .echo = echo, .void_void = void_void};

static void test_plugin_dispose(GObject* object) {
  TestPlugin* self = TEST_PLUGIN(object);

  g_cancellable_cancel(self->cancellable);

  core_tests_golubets_test_host_integration_core_api_clear_method_handlers(
      self->messenger, nullptr);
  core_tests_golubets_test_host_small_api_clear_method_handlers(self->messenger,
                                                                "suffixOne");
  core_tests_golubets_test_host_small_api_clear_method_handlers(self->messenger,
                                                                "suffixTwo");

  g_clear_object(&self->flutter_core_api);
  g_clear_object(&self->flutter_small_api_one);
  g_clear_object(&self->flutter_small_api_two);
  g_clear_object(&self->cancellable);

  G_OBJECT_CLASS(test_plugin_parent_class)->dispose(object);
}

static void test_plugin_class_init(TestPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = test_plugin_dispose;
}

static void test_plugin_init(TestPlugin* self) {
  self->cancellable = g_cancellable_new();
}

static TestPlugin* test_plugin_new(FlBinaryMessenger* messenger) {
  TestPlugin* self = TEST_PLUGIN(g_object_new(test_plugin_get_type(), nullptr));

  self->messenger = messenger;
  core_tests_golubets_test_host_integration_core_api_set_method_handlers(
      messenger, nullptr, &host_core_api_vtable, g_object_ref(self),
      g_object_unref);
  core_tests_golubets_test_host_small_api_set_method_handlers(
      messenger, "suffixOne", &host_small_api_vtable, g_object_ref(self),
      g_object_unref);
  core_tests_golubets_test_host_small_api_set_method_handlers(
      messenger, "suffixTwo", &host_small_api_vtable, g_object_ref(self),
      g_object_unref);
  self->flutter_core_api =
      core_tests_golubets_test_flutter_integration_core_api_new(messenger,
                                                                nullptr);
  self->flutter_small_api_one =
      core_tests_golubets_test_flutter_small_api_new(messenger, "suffixOne");
  self->flutter_small_api_two =
      core_tests_golubets_test_flutter_small_api_new(messenger, "suffixTwo");

  self->main_thread_id = std::this_thread::get_id();

  return self;
}

void test_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  g_autoptr(TestPlugin) plugin =
      test_plugin_new(fl_plugin_registrar_get_messenger(registrar));
  (void)plugin;  // unused variable

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "test_plugin", FL_METHOD_CODEC(codec));
  (void)channel;  // unused variable
}
