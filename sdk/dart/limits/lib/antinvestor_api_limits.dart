// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Dart client library for Ant Investor Limits Service.
///
/// Provides Limits service functionality using Connect RPC protocol.
library;

export 'src/limits/v1/limits.connect.client.dart';
export 'src/limits/v1/limits.connect.spec.dart';
export 'src/limits/v1/limits.pb.dart';
export 'src/limits/v1/limits.pbenum.dart';
export 'src/limits/v1/limits.pbjson.dart';
export 'src/limits/v1/limits.pbserver.dart';

// Common types
export 'src/common/v1/common.pb.dart';
export 'src/common/v1/common.pbenum.dart';
export 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';
export 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
