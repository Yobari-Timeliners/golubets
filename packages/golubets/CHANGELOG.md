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