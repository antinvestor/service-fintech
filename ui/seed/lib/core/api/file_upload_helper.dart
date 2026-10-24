import 'dart:convert';
import 'dart:typed_data';

import 'package:antinvestor_ui_core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/data/auth_repository.dart';
import '../config/app_config.dart';

/// Result of a public image upload containing both URI formats.
class UploadResult {
  const UploadResult({required this.mxcUri, required this.httpUrl});

  /// The mxc:// content URI from the files service (canonical reference).
  final String mxcUri;

  /// The HTTP download URL (for display in web browsers / NetworkImage).
  final String httpUrl;
}

/// Raised when an upload is rejected before or after it reaches the server.
///
/// Carries only a caller-facing message: the raw server body can contain
/// storage paths and internal identifiers and never reaches the UI.
class UploadException implements Exception {
  const UploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Largest image the files service accepts for a logo or avatar.
const maxUploadBytes = 5 * 1024 * 1024;

/// How long an upload may take before it is abandoned.
const uploadTimeout = Duration(seconds: 60);

/// Image types the files service will serve back as an image.
const allowedImageExtensions = <String, String>{
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'gif': 'image/gif',
  'webp': 'image/webp',
};

/// Resolves [filename] to an allowed image content type.
///
/// Returns null when the extension is missing or not an image type, so the
/// caller can reject the file without spending bandwidth on it.
String? imageContentTypeFor(String filename) {
  final dot = filename.lastIndexOf('.');
  if (dot < 0 || dot == filename.length - 1) return null;
  return allowedImageExtensions[filename.substring(dot + 1).toLowerCase()];
}

/// Validates image bytes against the upload limits.
///
/// Returns null when the upload may proceed, or a caller-facing reason.
String? validateImageUpload(Uint8List bytes, String filename) {
  if (bytes.isEmpty) return 'The selected file is empty.';
  if (bytes.length > maxUploadBytes) {
    final limitMb = maxUploadBytes ~/ (1024 * 1024);
    return 'Image is larger than the ${limitMb}MB limit.';
  }
  if (imageContentTypeFor(filename) == null) {
    return 'Only ${allowedImageExtensions.keys.join(', ')} images are accepted.';
  }
  return null;
}

/// Upload image bytes and return both the mxc:// content URI and HTTP URL.
///
/// Callers should store both:
/// - `logo_content_uri` = mxc:// URI (canonical, stable reference)
/// - `logo_http_url` = HTTP download URL (for direct browser display)
Future<UploadResult> uploadPublicImageFull(
  WidgetRef ref,
  Uint8List bytes,
  String filename,
) async {
  final rejection = validateImageUpload(bytes, filename);
  if (rejection != null) throw UploadException(rejection);

  final authRepo = ref.read(authRepositoryProvider);
  final token = await authRepo.ensureValidAccessToken();
  if (token == null || token.isEmpty) {
    throw const UploadException('Your session has expired. Sign in again.');
  }

  final uri = Uri.parse(
    '${AppConfig.filesBaseUrl}/v1/media/upload'
    '?filename=${Uri.encodeComponent(filename)}',
  );

  final request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $token'
    ..files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

  final streamedResponse = await request.send().timeout(uploadTimeout);
  final body = await streamedResponse.stream.bytesToString().timeout(
    uploadTimeout,
  );

  if (streamedResponse.statusCode != 200) {
    AppLogger.warning(
      'Public image upload failed with status ${streamedResponse.statusCode}',
    );
    throw UploadException(
      'Upload failed (${streamedResponse.statusCode}). Please try again.',
    );
  }

  final contentUri = _contentUriFrom(body);
  if (contentUri == null) {
    throw const UploadException('Upload succeeded but returned no file id.');
  }

  return UploadResult(mxcUri: contentUri, httpUrl: mxcToHttpUrl(contentUri));
}

String? _contentUriFrom(String body) {
  try {
    final data = jsonDecode(body) as Map<String, dynamic>;
    final contentUri = data['content_uri'] as String?;
    if (contentUri == null || contentUri.isEmpty) return null;
    return contentUri;
  } on FormatException {
    return null;
  }
}

/// Convert an mxc:// content URI to an HTTP download URL.
///
/// Format: mxc://server_name/media_id
/// Result: {filesBaseUrl}/v1/media/download/server_name/media_id
String mxcToHttpUrl(String mxcUri) {
  if (!mxcUri.startsWith('mxc://')) return mxcUri; // already HTTP
  final parts = mxcUri.substring(6).split('/'); // remove "mxc://"
  if (parts.length < 2) return mxcUri;
  final serverName = parts[0];
  final mediaId = parts[1];
  return '${AppConfig.filesBaseUrl}/v1/media/download/$serverName/$mediaId';
}
