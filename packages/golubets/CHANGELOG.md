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