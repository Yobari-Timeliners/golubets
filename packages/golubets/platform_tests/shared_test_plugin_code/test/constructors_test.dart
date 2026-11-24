// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_test_plugin_code/src/generated/flutter_unittests.gen.dart';

void main() {
  test('unnamed constructor keeps positional and named parameters', () {
    const color = FlutterColor(1, 2, 3);

    expect(color.alpha, 255);
    expect(color.red, 1);
    expect(color.green, 2);
    expect(color.blue, 3);
    expect(const FlutterColor(1, 2, 3, alpha: 4).alpha, 4);
  });

  test('named constructor is kept', () {
    const color = FlutterColor.fromARGB(4, 1, 2, 3);

    expect(color, const FlutterColor(1, 2, 3, alpha: 4));
  });

  test('decode calls the unnamed constructor with the right arguments', () {
    const color = FlutterColor.fromARGB(4, 1, 2, 3);

    expect(FlutterColor.decode(color.encode()), color);
  });
}
