import 'package:golubets/golubets.dart';

sealed class SomeState {}

class Loading extends SomeState {
  Loading(this.progress);
  final double progress;
}

class Success extends SomeState {
  Success(this.data);
  final String data;
}

class Error extends SomeState {
  Error(this.code);
  final int code;
}

@HostApi()
abstract class KotlinNestedSealedApi {
  SomeState echo(SomeState state);
}
