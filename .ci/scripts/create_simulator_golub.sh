#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e
# Ensure that the create/boot pipeline fails if `create` fails
set -o pipefail

# The name here must match remove_simulator.sh
readonly DEVICE_NAME="Flutter-iPhone"
# Use a fallback device type and runtime if the desired ones are unavailable
readonly DEFAULT_DEVICE="com.apple.CoreSimulator.SimDeviceType.iPhone-14"
readonly DEFAULT_OS="com.apple.CoreSimulator.SimRuntime.iOS-17-5"

# Function to check if a runtime is available
check_runtime() {
  local runtime="$1"
  if xcrun simctl list runtimes | grep -q "$runtime"; then
    echo "$runtime"
  else
    echo ""
  fi
}

# Function to check if a device type is available
check_device() {
  local device="$1"
  if xcrun simctl list devicetypes | grep -q "$device"; then
    echo "$device"
  else
    echo ""
  fi
}

# Select a valid runtime
OS=$(check_runtime "com.apple.CoreSimulator.SimRuntime.iOS-18-2")
if [[ -z "$OS" ]]; then
  echo "Warning: iOS-18-2 runtime not found. Falling back to $DEFAULT_OS."
  OS=$(check_runtime "$DEFAULT_OS")
  if [[ -z "$OS" ]]; then
    echo "Error: No valid iOS runtime found. Available runtimes:"
    xcrun simctl list runtimes
    exit 1
  fi
fi

# Select a valid device type
DEVICE=$(check_device "com.apple.CoreSimulator.SimDeviceType.iPhone-14")
if [[ -z "$DEVICE" ]]; then
  echo "Error: Device type iPhone-14 not found. Available device types:"
  xcrun simctl list devicetypes
  exit 1
fi

# Delete any existing devices named Flutter-iPhone
echo "Deleting any existing devices named $DEVICE_NAME..."
xcrun simctl list devices | grep "$DEVICE_NAME" | awk '{print $4}' | while read -r udid; do
  if [[ -n "$udid" ]]; then
    echo "Deleting $DEVICE_NAME with UDID $udid..."
    xcrun simctl delete "$udid" || echo "Failed to delete $udid, continuing..."
  fi
done

# Create and boot the simulator
echo "Creating $DEVICE_NAME with $DEVICE and $OS..."
UDID=$(xcrun simctl create "$DEVICE_NAME" "$DEVICE" "$OS")
if [[ -z "$UDID" ]]; then
  echo "Error: Failed to create simulator $DEVICE_NAME."
  exit 1
fi

echo "Booting $DEVICE_NAME with UDID $UDID..."
xcrun simctl boot "$UDID" || {
  echo "Warning: Failed to boot simulator $UDID. It may already be running."
}

# List all simulators for verification
echo "Listing all simulators..."
xcrun simctl list