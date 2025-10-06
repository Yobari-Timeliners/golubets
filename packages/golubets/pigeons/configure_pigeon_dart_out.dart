// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:golubets/golubets.dart';

@ConfigureGolubets(
  GolubetsOptions(
    dartOut: 'stdout',
    javaOut: 'stdout',
    dartOptions: DartOptions(),
  ),
)
@HostApi()
abstract class ConfigureGolubApi {
  void ping();
}
