import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// How long the object URL stays valid after the download is triggered. The
/// browser reads the blob asynchronously, so revoking immediately after the
/// click can cancel the download.
const _revokeAfter = Duration(seconds: 30);

Future<void> saveFile({
  required Uint8List bytes,
  required String filename,
  required String contentType,
}) async {
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: contentType),
  );
  final url = web.URL.createObjectURL(blob);

  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = filename
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  unawaited(
    Future<void>.delayed(_revokeAfter, () => web.URL.revokeObjectURL(url)),
  );
}
