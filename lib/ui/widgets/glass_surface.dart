import 'dart:ui';

import 'package:flutter/material.dart';

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
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.tint,
    this.blur = 18,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: tint ??
                (isDark
                    ? colors.surface.withValues(alpha: .62)
                    : Colors.white.withValues(alpha: .68)),
            borderRadius: borderRadius,
            border: border ??
                Border.all(
                  color: Colors.white.withValues(alpha: isDark ? .16 : .72),
                  width: 1,
                ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: isDark ? .20 : .08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
