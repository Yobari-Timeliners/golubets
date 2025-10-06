// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation
import XCTest

@testable import test_plugin

final class InstanceManagerTests: XCTestCase {
  func testAddDartCreatedInstance() {
    let finalizerDelegate = EmptyFinalizerDelegate()
    let instanceManager = ProxyApiTestsGolubetsInstanceManager(finalizerDelegate: finalizerDelegate)
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)
    XCTAssertEqual(instanceManager.instance(forIdentifier: 0), object)
    XCTAssertEqual(instanceManager.identifierWithStrongReference(forInstance: object), 0)
  }

  func testAddHostCreatedInstance() {
    let finalizerDelegate = EmptyFinalizerDelegate()
    let instanceManager = ProxyApiTestsGolubetsInstanceManager(finalizerDelegate: finalizerDelegate)
    let object = NSObject()
    _ = instanceManager.addHostCreatedInstance(object)

    let identifier = instanceManager.identifierWithStrongReference(forInstance: object)
    XCTAssertEqual(instanceManager.instance(forIdentifier: try XCTUnwrap(identifier)), object)
  }

  func testRemoveInstance() {
    let finalizerDelegate = EmptyFinalizerDelegate()
    let instanceManager = ProxyApiTestsGolubetsInstanceManager(finalizerDelegate: finalizerDelegate)
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)

    XCTAssertEqual(try! instanceManager.removeInstance(withIdentifier: 0), object)
    XCTAssertEqual(instanceManager.strongInstanceCount, 0)
  }

  func testFinalizerCallsDelegateMethod() {
    let finalizerDelegate = TestFinalizerDelegate()

    var object: NSObject? = NSObject()
    ProxyApiTestsGolubetsInternalFinalizer.attach(
      to: object!, identifier: 0, delegate: finalizerDelegate)

    object = nil
    XCTAssertEqual(finalizerDelegate.lastHandledIdentifier, 0)
  }

  func testRemoveAllObjects() {
    let finalizerDelegate = EmptyFinalizerDelegate()
    let instanceManager = ProxyApiTestsGolubetsInstanceManager(finalizerDelegate: finalizerDelegate)
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)
    try? instanceManager.removeAllObjects()

    XCTAssertEqual(instanceManager.strongInstanceCount, 0)
    XCTAssertEqual(instanceManager.weakInstanceCount, 0)
  }

  func testCanAddSameObjectWithAddDartCreatedInstance() {
    let finalizerDelegate = EmptyFinalizerDelegate()
    let instanceManager = ProxyApiTestsGolubetsInstanceManager(finalizerDelegate: finalizerDelegate)
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)
    instanceManager.addDartCreatedInstance(object, withIdentifier: 1)

    let instance1: NSObject? = instanceManager.instance(forIdentifier: 0)
    let instance2: NSObject? = instanceManager.instance(forIdentifier: 1)

    XCTAssertEqual(instance1, instance2)
  }

  func testObjectsAreStoredWithPointerHashcode() {
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
    XCTAssertTrue(instance1 == instance2)

    _ = instanceManager.addHostCreatedInstance(instance1)
    _ = instanceManager.addHostCreatedInstance(instance2)

    XCTAssertNotEqual(
      instanceManager.identifierWithStrongReference(forInstance: instance1),
      instanceManager.identifierWithStrongReference(forInstance: instance2))
  }

  func testInstanceManagerCanBeDeallocated() {
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
    XCTAssertEqual(finalizerDelegate.lastHandledIdentifier, 0)
  }

  func testRemoveAllObjectsRemovesFinalizersFromWeakInstances() {
    let finalizerDelegate = TestFinalizerDelegate()
    let instanceManager = ProxyApiTestsGolubetsInstanceManager(finalizerDelegate: finalizerDelegate)

    let object: NSObject? = NSObject()
    let identifier = instanceManager.addHostCreatedInstance(object!)
    let finalizer =
      objc_getAssociatedObject(object!, ProxyApiTestsGolubetsInternalFinalizer.associatedObjectKey)
      as! ProxyApiTestsGolubetsInternalFinalizer

    let _: AnyObject? = try! instanceManager.removeInstance(withIdentifier: identifier)
    try? instanceManager.removeAllObjects()

    XCTAssertNil(finalizer.delegate)
    XCTAssertNil(
      objc_getAssociatedObject(object!, ProxyApiTestsGolubetsInternalFinalizer.associatedObjectKey))
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
