import 'dart:typed_data';

import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Entry types whose value is a stored document rather than typed text.
const kycDocumentValueTypes = {'photo', 'file', 'signature'};

bool isKycDocument(String valueType) =>
    kycDocumentValueTypes.contains(valueType);

/// A picked image, ready to upload.
class PickedDocument {
  const PickedDocument({
    required this.bytes,
    required this.filename,
    required this.contentType,
  });

  final Uint8List bytes;
  final String filename;
  final String contentType;
}

/// Picks a document image from the camera or the gallery.
typedef DocumentPicker = Future<PickedDocument?> Function(ImageSource source);

/// Largest document the service accepts.
const maxDocumentBytes = 5 * 1024 * 1024;

String _imageType(String name, String? mime) {
  if (mime != null && mime.startsWith('image/')) return mime;
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

/// Picks with image_picker, scaled down so a phone photo stays well under
/// the upload limit.
Future<PickedDocument?> pickDocumentImage(ImageSource source) async {
  final picked = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1600,
    maxHeight: 1600,
    imageQuality: 80,
  );
  if (picked == null) return null;
  return PickedDocument(
    bytes: await picked.readAsBytes(),
    filename: picked.name,
    contentType: _imageType(picked.name, picked.mimeType),
  );
}

/// The picker the KYC tab uses; tests replace it.
final documentPickerProvider = Provider<DocumentPicker>(
  (ref) => pickDocumentImage,
);

/// What the upload dialog returns.
typedef DocumentUpload = ({
  String fieldKey,
  String valueType,
  PickedDocument document,
});

/// Collects one KYC document: which field it is, its kind, and the image.
class KycDocumentDialog extends ConsumerStatefulWidget {
  const KycDocumentDialog({super.key, this.fieldKey});

  /// Pre-fills the field, e.g. from a missing requirement.
  final String? fieldKey;

  @override
  ConsumerState<KycDocumentDialog> createState() => _KycDocumentDialogState();
}

class _KycDocumentDialogState extends ConsumerState<KycDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _keyCtrl;
  String _valueType = 'photo';
  PickedDocument? _document;
  String? _error;

  static const _suggestedKeys = [
    'id_front_photo',
    'id_back_photo',
    'passport_photo',
    'proof_of_address',
    'signature',
  ];

  @override
  void initState() {
    super.initState();
    _keyCtrl = TextEditingController(text: widget.fieldKey ?? '');
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final doc = await ref.read(documentPickerProvider)(source);
    if (doc == null || !mounted) return;
    setState(() {
      if (doc.bytes.length > maxDocumentBytes) {
        _document = null;
        _error = 'The image is larger than 5 MB; take it again.';
      } else {
        _document = doc;
        _error = null;
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_document == null) {
      setState(() => _error = 'Take or choose the image first.');
      return;
    }
    Navigator.pop<DocumentUpload>(context, (
      fieldKey: _keyCtrl.text.trim(),
      valueType: _valueType,
      document: _document!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Upload KYC document'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormFieldCard(
                  label: 'Field',
                  isRequired: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        key: const Key('kyc-doc-key'),
                        controller: _keyCtrl,
                        decoration: const InputDecoration(
                          hintText: 'e.g. id_front_photo',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Field is required'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final key in _suggestedKeys)
                            ActionChip(
                              label: Text(key),
                              onPressed: () => _keyCtrl.text = key,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                FormFieldCard(
                  label: 'Kind',
                  isRequired: true,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'photo', label: Text('Photo')),
                      ButtonSegment(value: 'file', label: Text('Document')),
                      ButtonSegment(
                        value: 'signature',
                        label: Text('Signature'),
                      ),
                    ],
                    selected: {_valueType},
                    onSelectionChanged: (v) =>
                        setState(() => _valueType = v.first),
                  ),
                ),
                FormFieldCard(
                  label: 'Image',
                  isRequired: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            key: const Key('kyc-doc-camera'),
                            onPressed: () => _pick(ImageSource.camera),
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: const Text('Take photo'),
                          ),
                          OutlinedButton.icon(
                            key: const Key('kyc-doc-gallery'),
                            onPressed: () => _pick(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Choose image'),
                          ),
                        ],
                      ),
                      if (_document != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _document!.bytes,
                            key: const Key('kyc-doc-preview'),
                            height: 160,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('kyc-doc-submit'),
          onPressed: _submit,
          child: const Text('Upload'),
        ),
      ],
    );
  }
}

/// Shows a stored document through a short-lived link.
class KycDocumentViewer extends StatelessWidget {
  const KycDocumentViewer({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 560,
        child: InteractiveViewer(
          child: Image.network(
            url,
            key: const Key('kyc-doc-image'),
            fit: BoxFit.contain,
            errorBuilder: (context, _, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'This document cannot be shown here. Open the link, '
                  'which works for five minutes:',
                ),
                const SizedBox(height: 8),
                SelectableText(url),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
