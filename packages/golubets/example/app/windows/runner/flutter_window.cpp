// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "flutter_window.h"

#include <flutter/binary_messenger.h>

#include <memory>
#include <optional>

#include "flutter/generated_plugin_registrant.h"
#include "messages.g.h"

namespace {
using golub_example::Code;
using golub_example::ErrorOr;
using golub_example::ExampleHostApi;
using golub_example::FlutterError;
using golub_example::MessageData;
using golub_example::MessageFlutterApi;

// #docregion cpp-class
class GolubApiImplementation : public ExampleHostApi {
 public:
  GolubApiImplementation() {}
  virtual ~GolubApiImplementation() {}

  ErrorOr<std::string> GetHostLanguage() override { return "C++"; }
  ErrorOr<int64_t> Add(int64_t a, int64_t b) {
    if (a < 0 || b < 0) {
      return FlutterError("code", "message", "details");
    }
    return a + b;
  }
  void SendMessage(const MessageData& message,
                   std::function<void(ErrorOr<bool> reply)> result) {
    if (message.code() == Code::kOne) {
      result(FlutterError("code", "message", "details"));
      return;
    }
    result(true);
  }
  // #enddocregion cpp-class

  void SendMessageModernAsync(const MessageData& message,
                              std::function<void(ErrorOr<bool> reply)> result) {
    if (message.code() == Code::kOne) {
      result(FlutterError("code", "message", "details"));
      return;
    }
    result(true);
  }

  void SendMessageModernAsyncThrows(
      const MessageData& message,
      std::function<void(ErrorOr<bool> reply)> result) {
    if (message.code() == Code::kOne) {
      result(true);
      return;
    }
    result(FlutterError("code", "message", "details"));
  }
};

// #docregion cpp-method-flutter
class GolubetsFlutterApi {
 public:
  GolubetsFlutterApi(flutter::BinaryMessenger* messenger)
      : flutterApi_(std::make_unique<MessageFlutterApi>(messenger)) {}

  void CallFlutterMethod(
      const std::string& a_string,
      std::function<void(ErrorOr<std::string> reply)> result) {
    flutterApi_->FlutterMethod(
        &a_string, [result](const std::string& echo) { result(echo); },
        [result](const FlutterError& error) { result(error); });
  }

 private:
  std::unique_ptr<MessageFlutterApi> flutterApi_;
};
// #enddocregion cpp-method-flutter

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  pigeonHostApi_ = std::make_unique<GolubApiImplementation>();
  ExampleHostApi::SetUp(flutter_controller_->engine()->messenger(),
                        pigeonHostApi_.get());

  flutter_controller_->engine()->SetNextFrameCallback([&]() { this->Show(); });

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
