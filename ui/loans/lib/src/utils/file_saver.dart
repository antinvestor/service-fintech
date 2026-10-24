import 'dart:typed_data';

import 'file_saver_io.dart'
    if (dart.library.js_interop) 'file_saver_web.dart'
    as platform;

/// Hands a generated file to the user.
///
/// On the web this triggers a browser download; on other platforms the bytes
/// are written to a temporary file and offered through the system share/save
/// sheet. Tests substitute a recording implementation.
abstract interface class FileSaver {
  Future<void> save({
    required Uint8List bytes,
    required String filename,
    required String contentType,
  });
}

/// The platform-default [FileSaver].
class PlatformFileSaver implements FileSaver {
  const PlatformFileSaver();

  @override
  Future<void> save({
    required Uint8List bytes,
    required String filename,
    required String contentType,
  }) => platform.saveFile(
    bytes: bytes,
    filename: filename,
    contentType: contentType,
  );
}
