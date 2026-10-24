import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:seed_ui/core/api/file_upload_helper.dart';

Uint8List bytesOf(int length) => Uint8List(length)..fillRange(0, length, 1);

void main() {
  group('validateImageUpload', () {
    test('accepts an image within the limit', () {
      expect(validateImageUpload(bytesOf(1024), 'logo.png'), isNull);
      expect(validateImageUpload(bytesOf(1024), 'LOGO.JPG'), isNull);
    });

    test('rejects an empty file', () {
      expect(validateImageUpload(Uint8List(0), 'logo.png'), isNotNull);
    });

    test('rejects anything past the byte cap', () {
      expect(validateImageUpload(bytesOf(maxUploadBytes), 'logo.png'), isNull);
      expect(
        validateImageUpload(bytesOf(maxUploadBytes + 1), 'logo.png'),
        contains('larger than'),
      );
    });

    test('rejects non-image types', () {
      for (final name in ['payload.svg', 'script.js', 'doc.pdf', 'logo']) {
        expect(
          validateImageUpload(bytesOf(16), name),
          isNotNull,
          reason: '$name must not be uploaded as an image',
        );
      }
    });

    test('rejects a name that ends in a dot', () {
      expect(validateImageUpload(bytesOf(16), 'logo.'), isNotNull);
    });
  });

  group('imageContentTypeFor', () {
    test('maps known extensions case-insensitively', () {
      expect(imageContentTypeFor('a.PNG'), 'image/png');
      expect(imageContentTypeFor('a.jpeg'), 'image/jpeg');
      expect(imageContentTypeFor('a.webp'), 'image/webp');
    });

    test('returns null for everything else', () {
      expect(imageContentTypeFor('a.txt'), isNull);
      expect(imageContentTypeFor('noextension'), isNull);
    });
  });

  group('mxcToHttpUrl', () {
    test('rewrites an mxc uri to a download url', () {
      expect(
        mxcToHttpUrl('mxc://files.test/abc123'),
        endsWith('/v1/media/download/files.test/abc123'),
      );
    });

    test('passes through anything that is already a url', () {
      const url = 'https://cdn.test/logo.png';
      expect(mxcToHttpUrl(url), url);
    });

    test('passes through a malformed mxc uri unchanged', () {
      expect(mxcToHttpUrl('mxc://onlyserver'), 'mxc://onlyserver');
    });
  });
}
