import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Centers and constrains child content to a maximum width.
///
/// On screens narrower than [maxWidth], the child fills the available
/// space normally. On wider screens, the child is centered with the
/// specified maximum width, preventing content from stretching across
/// ultra-wide displays.
///
/// Use [ContentConstraint] for page-level content (lists, detail views).
/// Use [ContentConstraint.form] for form containers.
/// Use [ContentConstraint.narrow] for single-column reading content.
class ContentConstraint extends StatelessWidget {
  const ContentConstraint({
    super.key,
    required this.child,
    this.maxWidth = DesignTokens.maxContentWidth,
    this.padding,
  });

  /// Constraint sized for form containers.
  const ContentConstraint.form({super.key, required this.child, this.padding})
    : maxWidth = DesignTokens.maxFormWidth;

  /// Constraint sized for narrow reading content.
  const ContentConstraint.narrow({super.key, required this.child, this.padding})
    : maxWidth = DesignTokens.maxFieldWidth;

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      ),
    );
  }
}
