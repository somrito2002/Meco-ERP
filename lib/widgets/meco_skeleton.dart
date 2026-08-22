import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme.dart';

/// A reusable skeletal loader widget that applies a sweeping shimmer effect
/// to any child widget, using the app's standard outline colors.
class MecoSkeleton extends StatelessWidget {
  final Widget child;

  const MecoSkeleton({super.key, required this.child});

  /// Creates a simple rectangular skeletal block.
  factory MecoSkeleton.box({
    Key? key,
    required double width,
    required double height,
    double borderRadius = 8.0,
  }) {
    return MecoSkeleton(
      key: key,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// Creates a simple circular skeletal block (e.g. for avatars).
  factory MecoSkeleton.circle({
    Key? key,
    required double size,
  }) {
    return MecoSkeleton(
      key: key,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Use subtle background and highlight colors based on theme.
    final Color baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final Color highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}
