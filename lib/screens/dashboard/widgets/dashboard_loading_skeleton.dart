import 'package:flutter/material.dart';

class DashboardLoadingSkeleton extends StatelessWidget {
  const DashboardLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SkeletonBlock(height: 26, widthFactor: 0.44),
          SizedBox(height: 8),
          _SkeletonBlock(height: 14, widthFactor: 0.62),
          SizedBox(height: 18),
          _SkeletonBlock(height: 50),
          SizedBox(height: 16),
          _SkeletonGrid(),
          SizedBox(height: 16),
          _SkeletonBlock(height: 220),
          SizedBox(height: 12),
          _SkeletonBlock(height: 220),
          SizedBox(height: 12),
          _SkeletonBlock(height: 250),
        ],
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: const [
        _SkeletonBlock(height: 140),
        _SkeletonBlock(height: 140),
        _SkeletonBlock(height: 140),
        _SkeletonBlock(height: 140),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double height;
  final double widthFactor;

  const _SkeletonBlock({
    required this.height,
    this.widthFactor = 1,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      width: width * widthFactor,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAEE),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
