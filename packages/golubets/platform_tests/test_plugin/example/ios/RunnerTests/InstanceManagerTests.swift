// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation
import Testing

@testable import test_plugin

@MainActor
struct InstanceManagerTests {
  @Test
  func addDartCreatedInstance() {
    let finalizerDelegate = EmptyFinalizerDelegate()
    let instanceManager = ProxyApiTestsGolubetsInstanceManager(finalizerDelegate: finalizerDelegate)
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)
    #expect(instanceManager.instance(forIdentifier: 0) === object)
    #expect(instanceManager.identifierWithStrongReference(forInstance: object) == 0)
  }

  @Test
  func addHostCreatedInstance() throws {
    let finalizerDelegate = EmptyFinalizerDelegate()
    let instanceManager = ProxyApiTestsGolubetsInstanceManager(finalizerDelegate: finalizerDelegate)
    let object = NSObject()
    _ = instanceManager.addHostCreatedInstance(object)

    let identifier = instanceManager.identifierWithStrongReference(forInstance: object)
    let unwrappedIdentifier = try #require(identifier)
    #expect(instanceManager.instance(forIdentifier: unwrappedIdentifier) === object)
  }

  @Test
  func removeInstance() {
    let finalizerDelegate = EmptyFinalizerDelegate()
    let instanceManager = ProxyApiTestsGolubetsInstanceManager(finalizerDelegate: finalizerDelegate)
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)

    #expect(try! instanceManager.removeInstance(withIdentifier: 0) === object)
    #expect(instanceManager.strongInstanceCount == 0)
  }

  @Test
  func finalizerCallsDelegateMethod() {
    let finalizerDelegate = TestFinalizerDelegate()

    var object: NSObject? = NSObject()
    ProxyApiTestsGolubetsInternalFinalizer.attach(
      to: object!, identifier: 0, delegate: finalizerDelegate)

    object = nil
    #expect(finalizerDelegate.lastHandledIdentifier == 0)
  }

  @Test
  func removeAllObjects() {
    let finalizerDelegate = EmptyFinalizerDelegate()
    let instanceManager = ProxyApiTestsGolubetsInstanceManager(finalizerDelegate: finalizerDelegate)
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)
    try? instanceManager.removeAllObjects()

    #expect(instanceManager.strongInstanceCount == 0)
    #expect(instanceManager.weakInstanceCount == 0)
  }

  @Test
  func canAddSameObjectWithAddDartCreatedInstance() {
    let finalizerDelegate = EmptyFinalizerDelegate()
    let instanceManager = ProxyApiTestsGolubetsInstanceManager(finalizerDelegate: finalizerDelegate)
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)
    instanceManager.addDartCreatedInstance(object, withIdentifier: 1)

    let instance1: NSObject? = instanceManager.instance(forIdentifier: 0)
    let instance2: NSObject? = instanceManager.instance(forIdentifier: 1)

    #expect(instance1 === instance2)
  }

  @Test
  func objectsAreStoredWithPointerHashcode() {
    let finalizerDelegate = EmptyFinalizerDelegate()
    let instanceManager = ProxyApiTestsGolubetsInstanceManager(finalizerDelegate: finalizerDelegate)

    class EquatableClass: Equatable {
      static func == (lhs: EquatableClass, rhs: EquatableClass) -> Bool {
        return true
      }
    }

    let instance1 = EquatableClass()
    let instance2 = EquatableClass()

    // Ensure instances are considered equal.
    #expect(instance1 == instance2)

    _ = instanceManager.addHostCreatedInstance(instance1)
    _ = instanceManager.addHostCreatedInstance(instance2)

    #expect(
      instanceManager.identifierWithStrongReference(forInstance: instance1)
        != instanceManager.identifierWithStrongReference(forInstance: instance2))
  }

  @Test
  func instanceManagerCanBeDeallocated() {
    let binaryMessenger = MockBinaryMessenger<String>(
      codec: FlutterStandardMessageCodec.sharedInstance())

    var registrar: ProxyApiTestsGolubetsProxyApiRegistrar? = ProxyApiTestsGolubetsProxyApiRegistrar(
      binaryMessenger: binaryMessenger, apiDelegate: ProxyApiDelegate())

    // Add the scenario where the InstanceManager contains an instance that contains a ProxyApi implementation
    class TestClass {
      let api: GolubetsApiProxyApiTestClass

      init(_ api: GolubetsApiProxyApiTestClass) {
        self.api = api
      }
    }
    _ = registrar!.instanceManager.addHostCreatedInstance(
      TestClass(registrar!.apiDelegate.golubetsApiProxyApiTestClass(registrar!)))

    registrar!.setUp()
    registrar!.tearDown()

    let finalizerDelegate = TestFinalizerDelegate()

    ProxyApiTestsGolubetsInternalFinalizer.attach(
      to: registrar!.instanceManager, identifier: 0, delegate: finalizerDelegate)
    registrar = nil
    #expect(finalizerDelegate.lastHandledIdentifier == 0)
  }

  @Test
  func removeAllObjectsRemovesFinalizersFromWeakInstances() {
    let finalizerDelegate = TestFinalizerDelegate()
    let instanceManager = ProxyApiTestsGolubetsInstanceManager(finalizerDelegate: finalizerDelegate)

    let object: NSObject? = NSObject()
    let identifier = instanceManager.addHostCreatedInstance(object!)
    let finalizer =
      objc_getAssociatedObject(object!, ProxyApiTestsGolubetsInternalFinalizer.associatedObjectKey)
      as! ProxyApiTestsGolubetsInternalFinalizer

    let _: AnyObject? = try! instanceManager.removeInstance(withIdentifier: identifier)
    try? instanceManager.removeAllObjects()

    #expect(finalizer.delegate == nil)
    #expect(
      objc_getAssociatedObject(object!, ProxyApiTestsGolubetsInternalFinalizer.associatedObjectKey)
        == nil)
  }
}

class EmptyFinalizerDelegate: ProxyApiTestsGolubetsInternalFinalizerDelegate {
  func onDeinit(identifier: Int64) {}
}

class TestFinalizerDelegate: ProxyApiTestsGolubetsInternalFinalizerDelegate {
  var lastHandledIdentifier: Int64?

  func onDeinit(identifier: Int64) {
    lastHandledIdentifier = identifier
  }
}
