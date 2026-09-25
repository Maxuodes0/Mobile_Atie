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
    _pulse = Tween<double>(begin: 0.48, end: 0.88).animate(
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
      color: AppTheme.dashboardCanvas,
      child: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _pulse,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 120),
            children: const [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBlock(height: 34, width: 238),
                        SizedBox(height: 7),
                        _SkeletonBlock(height: 34, width: 202),
                        SizedBox(height: 13),
                        _SkeletonBlock(height: 27, width: 112),
                      ],
                    ),
                  ),
                  _SkeletonCircle(size: 50),
                ],
              ),
              SizedBox(height: 38),
              _SkeletonCard(height: 112, color: AppTheme.dashboardInk),
              SizedBox(height: 22),
              Row(
                children: [
                  Expanded(child: _SkeletonCard(height: 50)),
                  SizedBox(width: 10),
                  Expanded(child: _SkeletonCard(height: 50)),
                ],
              ),
              SizedBox(height: 30),
              _SkeletonBlock(height: 28, width: 188),
              SizedBox(height: 14),
              _SkeletonCard(height: 202),
              SizedBox(height: 12),
              _SkeletonCard(
                height: 220,
                color: AppTheme.dashboardMint,
              ),
              SizedBox(height: 12),
              _SkeletonCard(
                height: 202,
                color: AppTheme.dashboardGraphite,
              ),
              SizedBox(height: 12),
              _SkeletonCard(height: 202, color: AppTheme.dashboardInk),
              SizedBox(height: 18),
              _SkeletonCard(height: 390),
              SizedBox(height: 12),
              _SkeletonCard(
                height: 218,
                color: AppTheme.dashboardMint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double height;
  final Color color;

  const _SkeletonCard({
    required this.height,
    this.color = AppTheme.dashboardPaper,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
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
        color: AppTheme.dashboardPaper,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double height;
  final double? width;

  const _SkeletonBlock({required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.dashboardGraphite.withOpacitySafe(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
