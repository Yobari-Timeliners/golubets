<div align="center">
  <img width="400" height="400" alt="Golubets Logo" src="https://github.com/user-attachments/assets/737f08b3-dfc6-4eee-8522-9df449c0e9d1" />
  
  **Enhanced Flutter Platform Communication**
  
  *The modern, feature-rich alternative to [Pigeon](https://pub.dev/packages/pigeon) that just works better.*

  [![Pub Version](https://img.shields.io/pub/v/golubets)](https://pub.dev/packages/golubets)
  [![License](https://img.shields.io/badge/license-BSD--3--Clause-blue)](LICENSE)
  [![Contributors Welcome](https://img.shields.io/badge/contributors-welcome-brightgreen)](CONTRIBUTING.md)
  [![Community](https://img.shields.io/badge/community-friendly-orange)](../../discussions)

</div>

Golubets is a powerful code generator for type-safe communication between Flutter and native platforms. Built as a community-driven fork of [Pigeon](https://pub.dev/packages/pigeon), it delivers the advanced features developers have been asking for, with a smoother development experience.

## ✨ Why Choose Golubets?

### 🎯 **Enhanced Features**
- **Default Parameters** - Cleaner APIs with optional parameters (Swift & Kotlin)
- **True Async Support** - Modern Swift concurrency & Kotlin coroutines 
- **Generics** - Type-safe collections like `List<T>`, `Map<K, V>`
- **Advanced Sealed classes** - Swift enums, Kotlin nested types
- **Rock Solid** - All the reliability of Pigeon, with bugs fixed

### 🤝 **Developer Experience** 
- **Community-First** - Your feedback shapes our roadmap
- **Quick Onboarding** - Get running in minutes, not hours
- **Clear Documentation** - Examples that actually work
- **Responsive Support** - Issues get attention, not ignored

### 🌟 **Feature Highlights**

| Feature | Golubets | Pigeon |
|---------|----------|---------|
| Default Parameters | ✅ | ❌ |
| Swift Async/Await | ✅ | ❌ |
| Kotlin Coroutines | ✅ | ❌ |
| Generics Support | ✅ | ❌ |
| Kotlin Nested Sealed Classes | ✅ | ❌ |
| Swift enums | ✅ | ❌ |
| Community Contributions | ✅ Welcome! | 😕 Challenging |



## 🚀 Quick Start

Get up and running with Golubets in under 5 minutes:

```bash
# 1. Add to your Flutter project
flutter pub add --dev golubets

# 2. Create your API definition (e.g., golubtsi/api.dart)
# 3. Generate platform code  
dart run golubets --input golubtsi/api.dart

# 4. Implement the generated interfaces in your native code
# 5. Start using type-safe platform communication!
```

👀 **Want to see it in action?** Check out our [complete example](./example/README.md) with working iOS, Android, and desktop implementations.

## 🌟 The Golubets Difference

While Pigeon pioneered type-safe Flutter platform communication, the ecosystem has evolved. Developers need modern language features, faster iteration cycles, and responsive community support.

**Golubets delivers exactly that:**

- **Modern Language Support** - Embrace Swift concurrency, Kotlin coroutines, and generics
- **Faster Development** - Default parameters reduce boilerplate
- **Community-Driven** - Features are prioritized based on real developer needs
- **Contributor-Friendly** - Clear guidelines, helpful reviews, and welcoming maintainers

We believe great tools should empower developers, not frustrate them. Golubets is built on the solid foundation of Pigeon while addressing the gaps that matter most to modern Flutter development.

## 🎯 Our Mission

**Building the Flutter platform communication tool developers actually want to be part of.**

- **🎧 Community First** - Your feedback directly shapes our roadmap. Real issues get real solutions.
- **⚡ Smooth Contributions** - PRs are collaborative conversations, not battles. Get helpful reviews, not gatekeeping.
- **🚀 Innovation Welcome** - Bold ideas and fresh perspectives drive us forward. Let's build something amazing together.
- **📖 Full Transparency** - Open decisions, clear documentation, and honest communication. Always.

## 🤝 Join the Community

Ready to contribute? We'd love to have you aboard! 

#### Quick Contribution Guide
1. 📋 **Browse [open issues](https://github.com/Yobari-Timeliners/golubets/issues)** or create your own
2. 💬 **Discuss your approach** - we're here to help plan it out  
3. 🔨 **Submit your PR** with clear descriptions and tests
4. ✅ **Get constructive feedback** - we're rooting for your success!

#### Ways to Help
- 🐛 **Fix bugs** - Every bug squashed makes Golubets better
- ✨ **Add features** - Implement those [missing pieces](https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+label%3A%22p%3A+pigeon%22) developers need
- 📝 **Improve docs** - Help others discover and use Golubets effectively
- 🗣️ **Share feedback** - Tell us what's working and what could be better

**Got a game-changing idea?** Don't hesitate to [start a discussion](https://github.com/Yobari-Timeliners/golubets/issues) - we're excited to explore new possibilities!


## 🛠️ Comprehensive Platform Support

**One API definition, native code for every platform.**

### 📱 **Mobile & Desktop Ready**
- **🤖 Android** - Kotlin & Java with modern language features
- **🍎 iOS/macOS** - Swift & Objective-C with async/await support  
- **🪟 Windows** - Native C++ integration
- **🐧 Linux** - GObject bindings

### 🎯 **Rich Type System**

**Express complex data structures with confidence.**

- **🔤 All Standard Types** - Strings, numbers, booleans, lists, maps - [full Flutter codec support](https://flutter.dev/to/platform-channels-codec)
- **🏗️ Custom Classes** - Define your own data types with automatic serialization
- **📊 Enums & Sealed Classes** - Type-safe state management (Swift/Kotlin) 
- **🔗 Generics** - `List<T>`, `Map<K, V>` - fully type-safe collections
- **❓ Nullability** - Proper null safety across all platforms
- **🧬 Inheritance** - Sealed parent classes for polymorphic APIs

**Pro Tips:**
- Use `@SwiftClass` for Objective-C interop when needed
- Nullable enums automatically wrapped for Objective-C compatibility

### ⚡ **Modern Async Support**

**Choose the concurrency model that fits your platform.**

- **🔄 Synchronous Methods** - Simple, straightforward APIs for immediate responses
- **📞 Callback-Based** - Traditional async with `@async` annotation  
- **🚀 Modern Concurrency** - Swift async/await and Kotlin coroutines with `@Async`
- **⚠️ Error Handling** - Configurable exception throwing with `isSwiftThrows`

```dart
// Choose your async style
@HostApi()
abstract class MyApi {
  String syncMethod(); // Immediate response

  @async 
  void callbackMethod(); // Traditional callbacks  

  @Async(type: AsyncType.await(isSwiftThrows: false))
  Future<String> modernMethod();  // Swift async and Kotlin coroutines
}
```

[📖 See complete examples](./example/README.md#HostApi_Example)

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


### ⚙️ **Advanced Features**

**Enterprise-grade capabilities for complex applications.**

#### **🧵 Task Queue Support**
Control threading behavior with the `TaskQueue` annotation for specifying [threading model](https://docs.flutter.dev/platform-integration/platform-channels?tab=type-mappings-kotlin-tab#channels-and-platform-threading):
```dart
@HostApi()
abstract class BackgroundApi {
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  @Async(type: AsyncType.await())
  void doStuffAtBackground();
}
```

#### **🔄 Multi-Instance APIs** 
Create multiple API instances with unique channels for independent operations:
```dart
final api1 = MyApi(messageChannelSuffix: 'instance1');
final api2 = MyApi(messageChannelSuffix: 'instance2');
// Both operate independently!
```

### 🎛️ **Default Parameters (Swift & Kotlin)**

**Cleaner APIs with sensible defaults - just like native code should be.**

dart:
```dart
class UserPreferences {
  const UserPreferences({
    required this.userId,
    this.theme = 'light', // Generated with default in Swift/Kotlin
    this.notifications = true, // No more verbose constructors!
    this.language = 'en',
  });

  final String userId;
  final String theme;
  final bool notifications;
  final String language;
}
```

swift:
```swift
public struct UserPreferences: Hashable {
  public init(
    userId: String,
    theme: String = "light",
    notifications: Bool = true,
    language: String = "en"
  ) {
    self.userId = userId
    self.theme = theme
    self.notifications = notifications
    self.language = language
  }
  let userId: String
  let theme: String
  let notifications: Bool
  let language: String
}
```

kotlin:
```kotlin
data class UserPreferences (
  val userId: String,
  val theme: String = "light",
  val notifications: Boolean = true,
  val language: String = "en"
)
```

**Benefits:**
- 📝 **Less Boilerplate** - Fewer required parameters in native calls
- 🎯 **Better APIs** - More intuitive, optional parameters where they make sense  
- 🔄 **Full Type Support** - Works with primitives, enums, objects, and collections

[📖 See working example](./example/README.md#Dart_input)

### 🧩 **Generics (Swift & Kotlin)**

**Type-safe collections that actually work across platforms.**

```dart
sealed class SomeResult<R, E> {
  const SomeResult();
}

class Success<R, E> extends SomeResult<R, E> {
  const Success(this.value);
  final R value;
}

class Error<R, E> extends SomeResult<R, E> {
  const Error(this.error);
  final E error;
}

@HostApi()
abstract class ExampleHostApi {
  SomeResult<List<int>, String> generateNumbers();
}
```

**Supported:**
- ✅ `List<T>`, `Map<K, V>` - Basic collections
- ✅ `List<Map<K, V>>` - Complex nested structures  
- ✅ `Map<K?, List<V?>>` - Nullable generics


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
