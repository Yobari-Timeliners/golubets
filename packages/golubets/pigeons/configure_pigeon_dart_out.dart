// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:golubets/golubets.dart';

<<<<<<< HEAD:packages/golubets/pigeons/configure_pigeon_dart_out.dart
@ConfigureGolubets(
  GolubetsOptions(
    dartOut: 'stdout',
    javaOut: 'stdout',
    dartOptions: DartOptions(ignoreLints: false),
  ),
=======
@ConfigurePigeon(
  PigeonOptions(dartOut: 'stdout', javaOut: 'stdout', dartOptions: DartOptions(ignoreLints: false)),
>>>>>>> filtered-upstream/main:packages/pigeon/pigeons/configure_pigeon_dart_out.dart
)
@HostApi()
abstract class ConfigureGolubApi {
  void ping();
}
