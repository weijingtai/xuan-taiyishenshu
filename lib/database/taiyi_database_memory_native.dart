// Native-only implementation of the in-memory Drift executor used by the
// ZT-30 integration tests.

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

QueryExecutor createMemoryExecutor() => NativeDatabase.memory();
