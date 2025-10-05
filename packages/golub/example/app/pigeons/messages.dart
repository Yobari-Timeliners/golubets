// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:golub/golub.dart';

// #docregion config
@ConfigureGolub(
  GolubOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartOptions: DartOptions(),
    cppOptions: CppOptions(namespace: 'golub_example'),
    cppHeaderOut: 'windows/runner/messages.g.h',
    cppSourceOut: 'windows/runner/messages.g.cpp',
    gobjectHeaderOut: 'linux/messages.g.h',
    gobjectSourceOut: 'linux/messages.g.cc',
    gobjectOptions: GObjectOptions(),
    kotlinOut:
        'android/app/src/main/kotlin/dev/flutter/golub_example_app/Messages.g.kt',
    kotlinOptions: KotlinOptions(),
    javaOut: 'android/app/src/main/java/io/flutter/plugins/Messages.java',
    javaOptions: JavaOptions(),
    swiftOut: 'ios/Runner/Messages.g.swift',
    swiftOptions: SwiftOptions(),
    objcHeaderOut: 'macos/Runner/messages.g.h',
    objcSourceOut: 'macos/Runner/messages.g.m',
    // Set this to a unique prefix for your plugin or application, per Objective-C naming conventions.
    objcOptions: ObjcOptions(prefix: 'PGN'),
    copyrightHeader: 'pigeons/copyright.txt',
    dartPackageName: 'golub_example_package',
  ),
)
// #enddocregion config
// #docregion host-definitions
enum Code { one, two }

class MessageData {
  MessageData({
    this.code = Code.one,
    this.data = const <String, String>{
      'hello': 'world',
      'lorem': 'ipsum',
      'golub': 'rocks',
    },
    this.name = 'Golub',
    this.description = 'Example description',
  });

  String? name;
  String? description;
  Code code;
  Map<String, String> data;
}

@HostApi()
abstract class ExampleHostApi {
  String getHostLanguage();

  // These annotations create more idiomatic naming of methods in Objc and Swift.
  @ObjCSelector('addNumber:toNumber:')
  @SwiftFunction('add(_:to:)')
  int add(int a, int b);

  @async
  bool sendMessage(MessageData message);
  // This annotation generates an await-style asynchronous method,
  // unlike the callback-based approach used in sendMessage.
  // In Swift, this method does not throw exceptions (`isSwiftThrows: false`).
  // Will return true if the message was sent from background thread.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  @Async(type: AsyncType.await(isSwiftThrows: false))
  bool sendMessageModernAsync(MessageData message);

  // The same as sendMessageModernAsync, but throws an exception.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  @Async(type: AsyncType.await(isSwiftThrows: true))
  bool sendMessageModernAsyncThrows(MessageData message);
}
// #enddocregion host-definitions

// #docregion flutter-definitions
@FlutterApi()
abstract class MessageFlutterApi {
  String flutterMethod(String? aString);
}

// #enddocregion flutter-definitions
