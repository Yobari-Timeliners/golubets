// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:golubets/golubets.dart';

class FlutterSearchRequest {
  String? query;
}

class FlutterSearchReply {
  String? result;
  String? error;
}

class FlutterSearchRequests {
  // ignore: always_specify_types, strict_raw_type
  List? requests;
}

class FlutterSearchReplies {
  // ignore: always_specify_types, strict_raw_type
  List? replies;
}

/// A color whose Dart constructors are kept as written.
class FlutterColor {
  const FlutterColor(this.red, this.green, this.blue, {this.alpha = 255});

  /// Creates a color from alpha, red, green, and blue values.
  const FlutterColor.fromARGB(this.alpha, this.red, this.green, this.blue);

  final int alpha;
  final int red;
  final int green;
  final int blue;
}

@HostApi()
abstract class Api {
  FlutterSearchReply search(FlutterSearchRequest request);
  FlutterSearchReplies doSearches(FlutterSearchRequests request);
  FlutterSearchRequests echo(FlutterSearchRequests requests);
  int anInt(int value);
}
