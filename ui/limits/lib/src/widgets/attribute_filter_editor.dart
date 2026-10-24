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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:antinvestor_api_limits/antinvestor_api_limits.dart'
    show Struct, Value, ListValue, NullValue;

class AttributeFilterEditor extends StatefulWidget {
  final Struct? initial;
  final ValueChanged<Struct?> onChanged;
  const AttributeFilterEditor({
    super.key,
    this.initial,
    required this.onChanged,
  });

  @override
  State<AttributeFilterEditor> createState() => _AttributeFilterEditorState();
}

class _AttributeFilterEditorState extends State<AttributeFilterEditor> {
  late TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _structToJson(widget.initial));
  }

  String _structToJson(Struct? s) {
    if (s == null || s.fields.isEmpty) return '';
    // Best-effort: render the Struct as JSON for editing.
    // Each Value is a tagged union; we extract the inner type.
    return jsonEncode({
      for (final e in s.fields.entries) e.key: _valueToDart(e.value),
    });
  }

  dynamic _valueToDart(Value v) {
    if (v.hasStringValue()) return v.stringValue;
    if (v.hasNumberValue()) return v.numberValue;
    if (v.hasBoolValue()) return v.boolValue;
    if (v.hasListValue()) return v.listValue.values.map(_valueToDart).toList();
    if (v.hasStructValue()) {
      return {
        for (final e in v.structValue.fields.entries)
          e.key: _valueToDart(e.value),
      };
    }
    return null;
  }

  Value _dartToValue(dynamic v) {
    if (v is String) return Value()..stringValue = v;
    if (v is num) return Value()..numberValue = v.toDouble();
    if (v is bool) return Value()..boolValue = v;
    if (v is List) {
      final lv = ListValue();
      for (final item in v) {
        lv.values.add(_dartToValue(item));
      }
      return Value()..listValue = lv;
    }
    if (v is Map) {
      final s = Struct();
      v.forEach((k, val) => s.fields[k.toString()] = _dartToValue(val));
      return Value()..structValue = s;
    }
    return Value()..nullValue = NullValue.NULL_VALUE;
  }

  void _emit() {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty) {
      setState(() => _error = null);
      widget.onChanged(null);
      return;
    }
    try {
      final parsed = jsonDecode(txt);
      if (parsed is! Map) throw const FormatException('expected JSON object');
      final s = Struct();
      parsed.forEach((k, v) {
        s.fields[k.toString()] = _dartToValue(v);
      });
      setState(() => _error = null);
      widget.onChanged(s);
    } on FormatException catch (e) {
      setState(() => _error = 'Invalid JSON: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attribute filter (JSON)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _ctrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '{"kyc_tier": {"in": ["silver", "gold"]}}',
            errorText: _error,
            border: const OutlineInputBorder(),
          ),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          onChanged: (_) => _emit(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
