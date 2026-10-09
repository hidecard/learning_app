import 'package:flutter/material.dart';

class ContentShimmer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
