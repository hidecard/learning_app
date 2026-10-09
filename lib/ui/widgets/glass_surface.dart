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

class GlassBackdrop extends StatelessWidget {
  final Widget child;

  const GlassBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: isDark ? .12 : .08),
            colors.surface,
            colors.secondary.withValues(alpha: isDark ? .10 : .07),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: CustomPaint(
              painter: _GlassOrbPainter(
                primary: colors.primary.withValues(alpha: isDark ? .12 : .08),
                secondary: colors.secondary.withValues(alpha: isDark ? .10 : .06),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlassOrbPainter extends CustomPainter {
  final Color primary;
  final Color secondary;

  const _GlassOrbPainter({required this.primary, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
    paint.color = primary;
    canvas.drawCircle(Offset(size.width * .82, size.height * .10), 120, paint);
    paint.color = secondary;
    canvas.drawCircle(Offset(size.width * .12, size.height * .76), 150, paint);
  }

  @override
  bool shouldRepaint(covariant _GlassOrbPainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.secondary != secondary;
}
