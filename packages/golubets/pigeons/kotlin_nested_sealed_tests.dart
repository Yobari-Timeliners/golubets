import 'package:golubets/golubets.dart';

sealed class SomeState {}

class Loading extends SomeState {
  Loading({required this.progress});
  final double progress;
}

class Success extends SomeState {
  Success({required this.data});
  final String data;
}

class Error extends SomeState {
  Error({required this.code});
  final int code;
}

@HostApi()
abstract class KotlinNestedSealedApi {
  SomeState echo(SomeState state);
}
