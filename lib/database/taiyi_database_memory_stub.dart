// Stub for non-FFI platforms (web). Calling `createMemoryExecutor()` on web
// is unsupported because the in-memory test executor relies on native
// SQLite via dart:ffi.

import 'package:drift/drift.dart';

QueryExecutor createMemoryExecutor() {
  throw UnsupportedError(
      'TaiYiDatabase.memory() is only available on native platforms. '
      'On the web, construct a real TaiYiDatabase() which uses the Drift web '
      'worker backend.');
}
