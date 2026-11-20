## 3.0.0
* Merges upstream Pigeon changes up to 30.0.4.
* **BREAKING CHANGE**: [kotlin] [swift] Native Interop registration now supports multiple engines:
  * `register` and `unregister` take the engine the instance belongs to (a plugin binding or `FlutterEngine` in Kotlin, a registrar in Swift). Use `unregister` instead of `register(null)`.
  * Native `@FlutterApi` lookups take the engine (`getInstance(binding)` / `getInstance(registrar:)`) instead of a name, and the native `@HostApi` `getInstance(name)` is removed.
  * Swift FFI `@HostApi` implementations must be classes.
  * See the [Native Interop migration guide](./native_interop_migration_guide.md) for details.
* [dart] [kotlin] [swift] Fixes detaching one engine clearing Native Interop APIs for all other engines, and routes Native Interop calls to the calling engine's instance where possible.
* [kotlin] [swift] Calling a Native Interop API whose instance was unregistered now throws a `PlatformException` instead of crashing.
* [dart] [kotlin] [swift] Passes data class, `List`, `Map` and `Object` values of Kotlin JNI and Swift FFI calls in one buffer per call, making calls with large data classes and collections many times faster.
* [swift] [kotlin] Allows sealed classes in Native Interop files. In Swift FFI, sealed classes keep their Golubets enum representation, and each subclass case crosses as its own bridge class.
* [swift] Adds Native Interop FFI codec serialization of `Data`, `NSData`, `NSArray`, and `NSDictionary` values.
* [kotlin] [swift] Adds support for removing event channel handler registration via a new event channel object returned from `register`.
* [dart] Separates generated Dart Native Interop bindings into a conditionally imported companion file (`*.native_interop.g.dart`), so the main generated Dart file can be imported on Web.
* [kotlin] Stops generating unused JNI bindings for host API interfaces, and adds `@Keep` to generated classes that JNI reaches by name, fixing minified Android release builds.
* [kotlin] [swift] Warns after code generation if the `jni` or `objective_c` version constraint in `pubspec.yaml` doesn't match the generated code.
* [kotlin] [swift] Adds validation errors for Native Interop features that aren't supported (event channels, ProxyApis, reserved names) instead of generating code that doesn't compile.
* [dart] Fixes JNI and FFI typed data memory lifetime bugs.
* [kotlin] Makes enum `ofRaw` constant time.
* Stops silently skipping `jnigen` when `ANDROID_HOME` / `ANDROID_SDK_ROOT` or `JAVA_HOME` are unset, and surfaces `jnigen` errors and troubleshooting hints.
* Fixes `basePath` resolution when an output or directory path shares a string prefix with `basePath`.
* Removes remaining `dart:mirrors` usage, including the unused `configureGolubets` lookup.
* Updates `jni` dependency to `^1.1.1` and pins code generation `dev_dependencies` (`ffigen`, `jnigen`, `swift2objc`, and `swiftgen`).
* Updates minimum supported SDK version to Flutter 3.44/Dart 3.12.
* Updates Native Interop guides and migration skill.

## 2.1.0
* Merges upstream Pigeon changes up to 29.0.4.
* [swift] [kotlin] Adds experimental support for FFI and JNI (native interop).
* Exposes missing GolubetsOptions and language-specific configurations as command-line arguments.
* [swift] Adds support for multiple output locations in `swiftOut` and `--swift_out`.
* [swift] [kotlin] Adds support for `@Async(type: AsyncType.await())` on `@FlutterApi` methods, generating `async throws`/`suspend` signatures. Callback style remains the default.
* [swift] Annotates await-style `FlutterApi` methods with `@MainActor`.
* Adds the `asyncCallback` annotation as an alias of `async` for compatibility with Pigeon definitions.
* [swift] Uses `isNullish` to check for null and `NSNull` in non-null Flutter API returns.
* [swift] Fixes the generated error class `localizedDescription` missing a closing parenthesis.
* [kotlin] [swift] Derives the default file-specific class name component in UpperCamelCase from the output file name.

## 2.0.0
* [dart] Fixes lint warning from unused codec variable in Dart proxy classes.
* Updates analyzer dependency to support versions 13 and 14.
* Updates minimum Dart SDK constraint to 3.11.0.
* Adds support for sharing constants across platforms.
* Reports a clear error when an input file uses an enhanced enum (one with a constructor, fields, methods, or arguments on its values), instead of silently generating incorrect output.
* [dart] Adds usage documentation to generated event channel methods, and emits the user's documentation comments on them.
* [swift] Adds CaseIterable conformance to generated enums.
* Updates minimum supported SDK version to Flutter 3.38/Dart 3.10.
* Breaking Change Overrides toString (or equivalent) methods on generated data classes
  * This can conflict with custom description implementations in Swift.
* [swift] Updates isNullish to handle double nested Any? values.
* [kotlin] Updates generated error class to inherit from RuntimeException instead of Throwable, for better Java interoperability.

## 1.3.4
* [kotlin] Updates generated error class to inherit from RuntimeException instead of Throwable, for better Java interoperability.
* Updates analyzer dependency to support versions 10 through 12.
* Updates analyzer dependency to support version 10.
* Fixes dartdoc comments that accidentally used HTML.
* Optimizes and improves data class equality and hashing.
* Changes hashing and equality methods to behave consistently across platforms.
* Adds equality methods to previously unsupported languages.

## 1.3.3
* [dart] Fix incorrect type cast for generic List (Map) type parameter in generated decode method

## 1.3.2
* [swift] Adds opportunity to generate swift public fields

## 1.3.1
* [dart] Adds opportunity to generate interface of HostApi
* [dart][kotlin][swift] Adds opportunity to generate "pure" sealed subclasses names

## 1.3.0
* Produces a helpful error message when a method return type is missing or an unsupported type, such as a function type or record type.
* [dart] Ignores all lint rules in generated code.
* [dart] In generated code, imports the meta package for annotations, instead of the Flutter foundation library.
* [dart] In generated code, no longer imports Uint8List.
Bumps minimum version of the args package to 2.5.0.
* [dart] Improves nullability-handling in generated code.
* [kotlin] Adds option to add javax.annotation.Generated annotation.
* [dart] Reduces much duplication in reply-handling code.
* Dramatically reduces the number of File write operations sent to the operating system during code-generation. This improves performance of IDEs and the Dart analysis server.
* Makes some internal class constructors constant

## 1.2.0
* [objc] Updates to use module imports.
* Bumps kotlin_version to 2.3.0.
* [kotlin] Fixes a "bridge method" warning when implementing an event stream handler.
* [swift][kotlin] Fixes crash that occurs when an object that is removed from the instance manager
  calls to Dart.
* [dart] Fixes error from constructor parameter sharing name with attached field for a ProxyApi.
* Updates minimum supported SDK version to Flutter 3.35/Dart 3.9.
* [kotlin] Fixes compilation error with unbounded type parameter for InstanceManager.

## 1.1.1
* [kotlin] Fixes generating suspend for AsyncType void method

## 1.1.0
* Updates supported analyzer versions to 8.x or 9.x.
* Updates minimum supported SDK version to Flutter 3.32/Dart 3.8.
* Deprecates `dartHostTestHandler` and `dartTestOut`.
  * If you have a use case where this cannot easily be replaced with a mock or
    fake of the generated Dart API, please provide details in
    https://github.com/flutter/flutter/issues/178322.
* [kotlin] Serialize custom enums as Long instead of Int to avoid ClassCastException on decoding.
* Adds compatibility with analyzer 8.x.
* [kotlin] Removes all containsKey and replaces with contains.
* [kotlin] Fixes support for classes that override equals and hashCode for ProxyApis.
* [kotlin] Adds error message log when a new Dart proxy instance fails to be created.
* Updates minimum supported SDK version to Flutter 3.29/Dart 3.7.

## 1.0.0

* [kotlin] Adds support for nested sealed classes
* [swift] Adds support for enum-sealed classes
* [swift, kotlin] Adds support for Swift concurrency and Kotlin coroutines.
* [dart, swift, kotlin] Adds support for default values
* [dart, swift, kotlin] Adds support for generics
* [dart, swift, kotlin] Adds support for const/immutable classes