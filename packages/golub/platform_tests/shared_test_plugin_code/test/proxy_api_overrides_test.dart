// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_test_plugin_code/src/generated/proxy_api_tests.gen.dart';

void main() {
  test('can override ProxyApi constructors', () {
    GolubOverrides.golub_reset();

    final ProxyApiSuperClass instance = ProxyApiSuperClass.golub_detached();
    GolubOverrides.proxyApiSuperClass_new = () => instance;

    expect(ProxyApiSuperClass(), instance);
  });

  test('can override ProxyApi static attached fields', () {
    GolubOverrides.golub_reset();

    final ProxyApiSuperClass instance = ProxyApiSuperClass.golub_detached();
    GolubOverrides.proxyApiTestClass_staticAttachedField = instance;

    expect(ProxyApiTestClass.staticAttachedField, instance);
  });

  test('can override ProxyApi static methods', () async {
    GolubOverrides.golub_reset();

    GolubOverrides.proxyApiTestClass_echoStaticString = (String value) async {
      return value;
    };

    const String value = 'testString';
    expect(await ProxyApiTestClass.echoStaticString(value), value);
  });

  test('golub_reset sets constructor overrides to null', () {
    GolubOverrides.proxyApiSuperClass_new =
        () => ProxyApiSuperClass.golub_detached();

    GolubOverrides.golub_reset();
    expect(GolubOverrides.proxyApiSuperClass_new, isNull);
  });

  test('golub_reset sets attached field overrides to null', () {
    GolubOverrides.proxyApiTestClass_staticAttachedField =
        ProxyApiSuperClass.golub_detached();

    GolubOverrides.golub_reset();
    expect(GolubOverrides.proxyApiTestClass_staticAttachedField, isNull);
  });

  test('golub_reset sets static method overrides to null', () {
    GolubOverrides.proxyApiTestClass_echoStaticString = (String value) async {
      return value;
    };

    GolubOverrides.golub_reset();
    expect(GolubOverrides.proxyApiTestClass_echoStaticString, isNull);
  });
}
