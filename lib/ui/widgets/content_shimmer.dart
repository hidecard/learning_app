import 'package:flutter/material.dart';

class ContentShimmer extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius borderRadius;

  const ContentShimmer({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<ContentShimmer> createState() => _ContentShimmerState();
}

class _ContentShimmerState extends State<ContentShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        height: widget.height,
        width: widget.width ?? double.infinity,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          gradient: LinearGradient(
            begin: Alignment(-1.5 + _controller.value * 3, 0),
            end: Alignment(-.5 + _controller.value * 3, 0),
            colors: [
              colors.surfaceContainerHighest.withValues(alpha: .5),
              colors.surfaceContainerHighest.withValues(alpha: .95),
              colors.surfaceContainerHighest.withValues(alpha: .5),
            ],
          ),
        ),
      ),
    );
  }
}
