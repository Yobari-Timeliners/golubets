// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include "pigeon/non_null_fields.gen.h"

namespace non_null_fields_golubetstest {

TEST(NonNullFields, Build) {
  NonNullFieldSearchRequest request("hello");

  EXPECT_EQ(request.query(), "hello");
}

<<<<<<< HEAD:packages/golubets/platform_tests/test_plugin/windows/test/non_null_fields_test.cpp
}  // namespace non_null_fields_golubetstest
=======
TEST(NonNullFields, Equality) {
  NonNullFieldSearchRequest request1("hello");
  NonNullFieldSearchRequest request2("hello");
  NonNullFieldSearchRequest request3("world");

  EXPECT_EQ(request1, request2);
  EXPECT_NE(request1, request3);
}

}  // namespace non_null_fields_pigeontest
>>>>>>> filtered-upstream/main:packages/pigeon/platform_tests/test_plugin/windows/test/non_null_fields_test.cpp
