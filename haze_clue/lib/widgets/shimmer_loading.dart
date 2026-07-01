import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'glass_widgets.dart';

class ShimmerSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxShape shape;
  final BorderRadius? borderRadius;

  const ShimmerSkeleton({
    super.key,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final baseColor = isLight ? Colors.grey[300]! : Colors.white24;
    final highlightColor = isLight ? Colors.grey[100]! : Colors.white38;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isLight ? Colors.white : Colors.black,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle 
            ? (borderRadius ?? BorderRadius.circular(12)) 
            : null,
        ),
      ),
    );
  }
}

class ShimmerFocusCard extends StatelessWidget {
  const ShimmerFocusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.topRight,
              child: ShimmerSkeleton(width: 24, height: 24),
            ),
            const ShimmerSkeleton(width: 120, height: 20),
            const SizedBox(height: 24),
            const ShimmerSkeleton(width: 160, height: 160, shape: BoxShape.circle),
            const SizedBox(height: 24),
            const ShimmerSkeleton(width: 200, height: 16),
            const SizedBox(height: 8),
            const ShimmerSkeleton(width: 150, height: 16),
          ],
        ),
      ),
    );
  }
}

class ShimmerActivityTile extends StatelessWidget {
  const ShimmerActivityTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const ShimmerSkeleton(width: 46, height: 46, shape: BoxShape.circle),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerSkeleton(width: 150, height: 16),
                SizedBox(height: 8),
                ShimmerSkeleton(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
