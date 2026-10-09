import 'package:flutter/material.dart';

/// A regular, opaque surface used throughout the app.
///
/// The legacy class name is kept for source compatibility, but this widget
/// intentionally does not use blur, transparency, gradients, or background
/// effects.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? tint;
  final double blur;
  final Border? border;

  const GlassSurface({
    super.key,
    required this.child,
    this.height,
    this.padding = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.tint,
    this.blur = 0,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: tint ?? colors.surface,
        borderRadius: borderRadius,
        border: border ?? Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: .07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// App-wide plain background wrapper retained for compatibility.
class GlassBackdrop extends StatelessWidget {
  final Widget child;

  const GlassBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }
}
