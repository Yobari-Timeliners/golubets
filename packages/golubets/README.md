<div align="center">
  <- Innovation WelGot a spicy idea or a feature that could make Golubets soar? Open an issue or ping us in discussions. We're all ears!ome: Got a bold idea for improving Golubets? Bring it on! We're open to fresh perspectives and new features.mg src="art/golubets.jpg" alt="golubets" width="400">
</div>

## Golubets: A Community-Driven Fork of [Pigeon](https://pub.dev/packages/pigeon)

Welcome to Golubets, a fork of the Pigeon Flutter library. Our mission is to be a better, more open, and community-focused alternative—or at least give it a damn good try!

For usage examples, see the [Example README](./example/README.md).

## Why Golubets Exists

Pigeon is a great tool, but it's got some baggage. The community's voice often goes unheard, with a backlog of valuable issues left to gather dust. Features that make sense—logical, solid additions—are sometimes dismissed because they don't align with the maintainers' vision. That's not how open source should roll.

Contributing to Pigeon can feel like running into a buzzsaw. Expect endless code review cycles, nitpicky comments, and a vibe that's occasionally toxic. We've been there: maintainers forgetting their own codebase, clashing with each other, or demanding changes that don't hold up under scrutiny (only to later ask you to undo them). It's a frustrating loop of "do this, no wait, undo it, now do this instead." The result? A single pull request for a simple feature can spiral into an infinite, soul-crushing saga.

Golubets is here to change that. We're building a fork that's welcoming, collaborative, and free from the gatekeeping and "maintainer == god" mentality. No toxic reviews. No air-shaking nonsense. Just a focus on great ideas and clean code.

## Our Goals

- Community First: We listen to your issues, feature requests, and ideas. If it makes sense, we’ll work together to make it happen.

- Sane Contribution Process: Pull requests should be a conversation, not a battle. We aim for clear, constructive feedback without the endless back-and-forth.

- Innovation Welcome: Got a bold idea for improving Golub? Bring it on! We’re open to fresh perspectives and new features.

- Transparency: No hidden agendas. We’ll document decisions and keep the community in the loop.

## Contributing

We’re thrilled to have you on board! Whether you’re fixing bugs, adding features, or improving docs, your contributions matter. Here’s how to get started:

Check out our Contributing Guidelines for the nitty-gritty.

Browse open issues or submit your own.

Submit a pull request with clear descriptions and tests (where applicable).

Expect respectful, constructive feedback—no toxicity, no nonsense.

Got a spicy idea or a feature that could make Golub soar? Open an issue or ping us in discussions. We’re all ears!


## Features

### Supported Platforms

Currently Golubets supports generating:
* Kotlin and Java code for Android
* Swift and Objective-C code for iOS and macOS
* C++ code for Windows
* GObject code for Linux

### Supported Datatypes

Golubets uses the `StandardMessageCodec` so it supports
[any datatype platform channels support](https://flutter.dev/to/platform-channels-codec).

Custom classes, nested datatypes, and enums are also supported.

Basic inheritance with empty `sealed` parent classes is allowed only in the Swift, Kotlin, and Dart generators.

Nullable enums in Objective-C generated code will be wrapped in a class to allow for nullability.

By default, custom classes in Swift are defined as structs.
Structs don't support some features - recursive data, or Objective-C interop.
Use the @SwiftClass annotation when defining the class to generate the data
as a Swift class instead.

### Synchronous and Asynchronous methods

While all calls across platform channel APIs (such as Golubets methods) are asynchronous,
Golubets methods can be written on the native side as synchronous methods,
to make it simpler to always reply exactly once.

If asynchronous methods are needed, the `@async` annotation can be used. This will require
results or errors to be returned via a provided callback. [Example](./example/README.md#HostApi_Example). 

If preferred, Swift concurrency and Kotlin coroutines may be generated instead of callbacks by using `@Async`. Additionally, whether the Swift method can throw an exception can be specified using the `isSwiftThrows` parameter. [Example](./example/README.md#HostApi_Example).

### Error Handling

#### Kotlin, Java and Swift

All Host API exceptions are translated into Flutter `PlatformException`.
* For synchronous methods, thrown exceptions will be caught and translated.
* For asynchronous methods, there is no default exception handling; errors
should be returned via the provided callback.

To pass custom details into `PlatformException` for error handling,
use `FlutterError` in your Host API. [Example](./example/README.md#HostApi_Example).

For swift, use `GolubetsError` instead of `FlutterError` when throwing an error. See [Example#Swift](./example/README.md#Swift) for more details.

#### Objective-C and C++

Host API errors can be sent using the provided `FlutterError` class (translated into `PlatformException`).

For synchronous methods:
* Objective-C - Set the `error` argument to a `FlutterError` reference.
* C++ - Return a `FlutterError`.

For async methods:
* Return a `FlutterError` through the provided callback.


### Task Queue

When targeting a Flutter version that supports the
[TaskQueue API](https://docs.flutter.dev/development/platform-integration/platform-channels?tab=type-mappings-kotlin-tab#channels-and-platform-threading)
the threading model for handling HostApi methods can be selected with the
`TaskQueue` annotation.

### Multi-Instance Support

Host and Flutter APIs now support the ability to provide a unique message channel suffix string
to the api to allow for multiple instances to be created and operate in parallel.

### Default values

Default values are supported in class constructors for Swift and Kotlin platforms. This feature allows you to specify default parameter values that will be automatically generated in the native platform code, making your APIs more convenient to use.

[Example](./example/README.md#Dart_input)

**How it works:**
- Define default values directly in Dart class constructors using named parameters with default values
- Golubets generates native code that respects these defaults on Swift and Kotlin platforms
- Supported for all basic types (bool, int, double, String), enums, objects, and collections

### Generics

Generic types are fully supported for Swift and Kotlin platforms, allowing you to create type-safe collections and complex data structures. Golubets automatically translates Dart's generic syntax to the appropriate platform-specific equivalent.

**Supported generic types:**
- `List<T>` - Arrays/Lists with typed elements
- `Map<K, V>` - Dictionaries/Maps with typed keys and values  
- Nested generics like `List<Map<String, int>>` or `Map<String, List<User>>`
- Nullable generic types like `List<String?>` or `Map<String?, User?>`


## Usage

1) Add golubets as a `dev_dependency`.
1) Make a ".dart" file outside of your "lib" directory for defining the
   communication interface.
1) Run golubets on your ".dart" file to generate the required Dart and
   host-language code: `flutter pub get` then `dart run golubets`
   with suitable arguments. [Example](./example/README.md#Invocation).
1) Add the generated Dart code to `./lib` for compilation.
1) Implement the host-language code and add it to your build (see below).
1) Call the generated Dart methods.

### Rules for defining your communication interface
[Example](./example/README.md#HostApi_Example)

1) The file should contain no method or function definitions, only declarations.
1) Custom classes used by APIs are defined as classes with fields of the
   supported datatypes (see the supported Datatypes section).
1) APIs should be defined as an `abstract class` with either `@HostApi()` or
   `@FlutterApi()` as metadata.  `@HostApi()` being for procedures that are defined
   on the host platform and the `@FlutterApi()` for procedures that are defined in Dart.
1) Method declarations on the API classes should have arguments and a return
   value whose types are defined in the file, are supported datatypes, or are
   `void`.
1) Event channels are supported only on the Swift, Kotlin, and Dart generators.
1) Event channel methods should be wrapped in an `abstract class` with the metadata `@EventChannelApi`.
1) Event channel definitions should not include the `Stream` return type, just the type that is being streamed.
1) Objective-C and Swift have special naming conventions that can be utilized with the
   `@ObjCSelector` and `@SwiftFunction` respectively.

### Flutter calling into iOS steps

1) Add the generated Objective-C or Swift code to your Xcode project for compilation
   (e.g. `ios/Runner.xcworkspace` or `.podspec`).
1) Implement the generated protocol for handling the calls on iOS, set it up
   as the handler for the messages.

### Flutter calling into Android Steps

1) Add the generated Java or Kotlin code to your `./android/app/src/main/java` directory
   for compilation.
1) Implement the generated Java or Kotlin interface for handling the calls on Android, set
   it up as the handler for the messages.

### Flutter calling into Windows Steps

1) Add the generated C++ code to your `./windows` directory for compilation, and
   to your `windows/CMakeLists.txt` file.
1) Implement the generated C++ abstract class for handling the calls on Windows,
   set it up as the handler for the messages.

### Flutter calling into macOS steps

1) Add the generated Objective-C or Swift code to your Xcode project for compilation
   (e.g. `macos/Runner.xcworkspace` or `.podspec`).
1) Implement the generated protocol for handling the calls on macOS, set it up
   as the handler for the messages.

### Flutter calling into Linux steps

1) Add the generated GObject code to your `./linux` directory for compilation, and
   to your `linux/CMakeLists.txt` file.
1) Implement the generated protocol for handling the calls on Linux, set it up
   as the vtable for the API object.

### Calling into Flutter from the host platform

Golubets also supports calling in the opposite direction. The steps are similar
but reversed.  For more information look at the annotation `@FlutterApi()` which
denotes APIs that live in Flutter but are invoked from the host platform.
[Example](./example/README.md#FlutterApi_Example).

## Stability of generated code

Golubets is intended to replace direct use of method channels in the internal
implementation of plugins and applications. Because the expected use of Golubets
is as an internal implementation detail, its development strongly favors
improvements to generated code over consistency with previous generated code,
so breaking changes in generated code are common.

As a result, using Golubets-generated code in public APIs is
**strongy discouraged**, as doing so will likely create situations where you are
unable to update to a new version of Golubets without causing breaking changes
for your clients.

### Inter-version compatibility

The generated message channel code used for Golubets communication is an
internal implementation detail of Golubets that is subject to change without
warning, and changes to the communication are *not* considered breaking changes.
Both sides of the communication (the Dart code and the host-language code)
must be generated with the **same version** of Golubets. Using code generated with
different versions has undefined behavior, including potentially crashing the
application.

This means that Golubets-generated code **should not** be split across packages.
For example, putting the generated Dart code in a platform interface package
and the generated host-language code in a platform implementation package is
very likely to cause crashes for some plugin clients after updates.
