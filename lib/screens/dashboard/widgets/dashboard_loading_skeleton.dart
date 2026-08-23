import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class DashboardLoadingSkeleton extends StatefulWidget {
  const DashboardLoadingSkeleton({super.key});

  @override
  State<DashboardLoadingSkeleton> createState() =>
      _DashboardLoadingSkeletonState();
}

class _DashboardLoadingSkeletonState extends State<DashboardLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.48, end: 0.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.primary,
      child: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _pulse,
          child: ListView(
            padding: EdgeInsets.zero,
            children: const [
              _HeroSkeleton(),
              _FilterSkeleton(),
              _ContentSkeleton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 236,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBlock(height: 18, width: 118),
                    SizedBox(height: 7),
                    _SkeletonBlock(height: 11, width: 172),
                  ],
                ),
              ),
              _SkeletonCircle(size: 44),
              SizedBox(width: 8),
              _SkeletonCircle(size: 44),
            ],
          ),
          const Spacer(),
          const _SkeletonBlock(height: 11, width: 68),
          const SizedBox(height: 12),
          const _SkeletonBlock(height: 38, width: 210),
          const SizedBox(height: 14),
          Container(
            width: 104,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacitySafe(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSkeleton extends StatelessWidget {
  const _FilterSkeleton();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppTheme.primary,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 18, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBlock(
              height: 14,
              width: 98,
              color: Color(0x55FFFFFF),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SkeletonBlock(
                    height: 48,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _SkeletonBlock(
                    height: 48,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentSkeleton extends StatelessWidget {
  const _ContentSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
      decoration: const BoxDecoration(
        color: AppTheme.pageBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBlock(height: 20, width: 112),
          SizedBox(height: 7),
          _SkeletonBlock(height: 11, width: 196),
          SizedBox(height: 14),
          _SkeletonGrid(),
          SizedBox(height: 18),
          _SkeletonCard(height: 220),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SkeletonCard(height: 220)),
              SizedBox(width: 12),
              Expanded(child: _SkeletonCard(height: 220)),
            ],
          ),
          SizedBox(height: 18),
          _SkeletonBlock(height: 20, width: 120),
          SizedBox(height: 12),
          _SkeletonCard(height: 250),
        ],
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width * 0.72;
    return SizedBox(
      height: 158,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => SizedBox(
          width: cardWidth,
          child: const _SkeletonCard(),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double? height;

  const _SkeletonCard({this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F1115),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  final double size;

  const _SkeletonCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0x99FFFFFF),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double height;
  final double? width;
  final Color color;

  const _SkeletonBlock({
    required this.height,
    this.width,
    this.color = const Color(0xFFD9D7D3),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
