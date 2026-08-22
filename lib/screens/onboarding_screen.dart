import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'login_screen.dart';

class AiteOnboarding extends StatefulWidget {
  const AiteOnboarding({super.key});

  @override
  State<AiteOnboarding> createState() => _AiteOnboardingState();
}

class _AiteOnboardingState extends State<AiteOnboarding>
    with SingleTickerProviderStateMixin {
  static const _background = Color(0xFFF8E6D4);
  static const _transitionDuration = Duration(milliseconds: 1750);
  static const _welcomeTransitionDuration = Duration(milliseconds: 1500);

  late final AnimationController _controller;

  int _currentPage = -1;
  int _targetPage = 0;
  bool _isTransitioning = false;
  bool _verticalTransition = true;
  bool _assetsPrepared = false;

  static const _arabicPages = <_OnboardingContent>[
    _OnboardingContent(
      image: 'assets/images/New pics/AITE_projects.png',
      eyebrow: 'المشاريع',
      title: 'مشاريعك تحت السيطرة',
      description: 'تابع التقدم والمواعيد والميزانيات بوضوح من مكان واحد.',
    ),
    _OnboardingContent(
      image: 'assets/images/New pics/AITE_team_task.png',
      eyebrow: 'الفريق والمهام',
      title: 'فريقك دائمًا على نفس المسار',
      description: 'وزّع المهام، تابع الإنجاز واعرف مسؤولية كل شخص.',
    ),
    _OnboardingContent(
      image: 'assets/images/New pics/AITE_insights.png',
      eyebrow: 'الرؤى',
      title: 'قرارات أوضح بأرقام حقيقية',
      description: 'شاهد أداء مشاريعك وفريقك وأعمالك لحظة بلحظة.',
    ),
  ];

  static const _englishPages = <_OnboardingContent>[
    _OnboardingContent(
      image: 'assets/images/New pics/AITE_projects.png',
      eyebrow: 'PROJECTS',
      title: 'Your projects, under control',
      description: 'Track progress, schedules, and budgets with total clarity.',
    ),
    _OnboardingContent(
      image: 'assets/images/New pics/AITE_team_task.png',
      eyebrow: 'TEAM & TASKS',
      title: 'Keep your team aligned',
      description: 'Assign work, follow progress, and make ownership clear.',
    ),
    _OnboardingContent(
      image: 'assets/images/New pics/AITE_insights.png',
      eyebrow: 'INSIGHTS',
      title: 'Clearer decisions, real numbers',
      description: 'See project, team, and business performance as it happens.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _transitionDuration,
    )..addStatusListener(_handleAnimationStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_assetsPrepared) {
      _assetsPrepared = true;
      precacheImage(
        const AssetImage('assets/images/New pics/Saufi Guy.png'),
        context,
      );
      _precachePage(0);
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.dispose();
  }

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  List<_OnboardingContent> get _pages =>
      _isArabic ? _arabicPages : _englishPages;

  bool get _reducedMotion => MediaQuery.disableAnimationsOf(context);

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !_isTransitioning) return;

    setState(() {
      _currentPage = _targetPage;
      _isTransitioning = false;
    });
    _controller.reset();
    _precachePage(_currentPage + 1);
  }

  void _precachePage(int page) {
    if (page < 0 || page >= _pages.length) return;
    precacheImage(AssetImage(_pages[page].image), context);
  }

  void _transitionTo(int page, {bool vertical = false}) {
    if (_isTransitioning || page < 0 || page >= _pages.length) return;
    if (_currentPage == page) return;

    HapticFeedback.selectionClick();
    _controller.duration =
        vertical ? _welcomeTransitionDuration : _transitionDuration;
    setState(() {
      _targetPage = page;
      _verticalTransition = vertical;
      _isTransitioning = true;
    });
    _controller.forward(from: 0);
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _openLogin();
      return;
    }
    _transitionTo(_currentPage + 1);
  }

  void _previous() {
    if (_currentPage <= 0) return;
    _transitionTo(_currentPage - 1);
  }

  void _openLogin() {
    if (_isTransitioning) return;
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: const LoginScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _background,
        body: Stack(
          children: [
            const Positioned.fill(child: _WarmBackground()),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragEnd: (details) {
                              if (_currentPage < 0 || _isTransitioning) return;
                              final velocity = details.primaryVelocity ?? 0;
                              if (velocity < -220) {
                                _next();
                              } else if (velocity > 220) {
                                _previous();
                              }
                            },
                            child: _buildScene(),
                          ),
                        ),
                        if (_currentPage >= 0)
                          PositionedDirectional(
                            top: 10,
                            end: 18,
                            child: TextButton(
                              onPressed: _openLogin,
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.ink,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                              ),
                              child: Text(
                                _isArabic ? 'تخطي' : 'Skip',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      22,
                      0,
                      22,
                      20,
                    ),
                    child: Visibility(
                      visible: _currentPage >= 0,
                      maintainAnimation: true,
                      maintainSize: true,
                      maintainState: true,
                      child: _buildFooter(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScene() {
    if (!_isTransitioning) {
      if (_currentPage == -1) {
        return _WelcomeView(
          isArabic: _isArabic,
          onBegin: () => _transitionTo(0, vertical: true),
        );
      }
      return _StableOnboardingPage(
        content: _pages[_currentPage],
      );
    }

    final outgoing = _currentPage == -1
        ? _WelcomeView(isArabic: _isArabic, onBegin: () {})
        : _AnimatedOnboardingPage(
            content: _pages[_currentPage],
            controller: _controller,
            incoming: false,
            vertical: _verticalTransition,
            reducedMotion: _reducedMotion,
          );

    final incoming = _AnimatedOnboardingPage(
      content: _pages[_targetPage],
      controller: _controller,
      incoming: true,
      vertical: _verticalTransition,
      reducedMotion: _reducedMotion,
    );

    if (_currentPage == -1) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _VerticalPagePush(
            controller: _controller,
            incoming: false,
            child: _WelcomeView(isArabic: _isArabic, onBegin: () {}),
          ),
          _VerticalPagePush(
            controller: _controller,
            incoming: true,
            child: incoming,
          ),
        ],
      );
    }

    return Stack(fit: StackFit.expand, children: [outgoing, incoming]);
  }

  Widget _buildFooter() {
    return _OnboardingFooter(
      controller: _controller,
      pageCount: _pages.length,
      currentPage: _currentPage,
      targetPage: _targetPage,
      transitioning: _isTransitioning,
      onNext: _next,
      onPageSelected: (page) => _transitionTo(page),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  const _WelcomeView({required this.isArabic, required this.onBegin});

  final bool isArabic;
  final VoidCallback onBegin;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final compact = height < 720;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        28,
        compact ? 22 : 34,
        28,
        compact ? 12 : 22,
      ),
      child: Column(
        children: [
          Expanded(
            flex: compact ? 7 : 8,
            child: Image.asset(
              'assets/images/New pics/Saufi Guy.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              filterQuality: FilterQuality.medium,
            ),
          ),
          SizedBox(height: compact ? 14 : 22),
          Text(
            isArabic ? 'ابدأ رحلتك مع AITE' : 'Work smarter with AITE',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 330),
            child: Text(
              isArabic
                  ? 'نظّم مشاريعك وفريقك وأعمالك اليومية في مساحة واحدة واضحة.'
                  : 'Bring your projects, team, and daily work together in one clear space.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF5F5A55),
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: compact ? 22 : 30),
          SizedBox(
            width: 250,
            height: 58,
            child: FilledButton(
              onPressed: onBegin,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF111D2D),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 1,
                shadowColor: Colors.black26,
              ),
              child: Text(
                isArabic ? 'لنبدأ' : "Let's begin",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalPagePush extends StatelessWidget {
  const _VerticalPagePush({
    required this.controller,
    required this.incoming,
    required this.child,
  });

  final AnimationController controller;
  final bool incoming;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: IgnorePointer(child: child),
      builder: (context, animatedChild) {
        final progress = Curves.easeOutCubic.transform(controller.value);
        final offset = incoming ? 1 - progress : -progress;
        return FractionalTranslation(
          translation: Offset(0, offset),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _WarmBackground(),
              if (animatedChild != null) animatedChild,
            ],
          ),
        );
      },
    );
  }
}

class _StableOnboardingPage extends StatelessWidget {
  const _StableOnboardingPage({required this.content});

  final _OnboardingContent content;

  @override
  Widget build(BuildContext context) {
    return _OnboardingLayout(
      illustration: _Illustration(content: content),
      heading: _Heading(content: content),
      description: _Description(content: content),
    );
  }
}

class _AnimatedOnboardingPage extends StatelessWidget {
  const _AnimatedOnboardingPage({
    required this.content,
    required this.controller,
    required this.incoming,
    required this.vertical,
    required this.reducedMotion,
  });

  final _OnboardingContent content;
  final AnimationController controller;
  final bool incoming;
  final bool vertical;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!vertical) {
          final progress = Curves.easeOutCubic.transform(controller.value);
          final horizontalOffset = incoming ? 1 - progress : -progress;
          final page = _OnboardingLayout(
            illustration: _Illustration(content: content),
            heading: _Heading(content: content),
            description: _Description(content: content),
          );

          return FractionalTranslation(
            translation: Offset(horizontalOffset, 0),
            child: page,
          );
        }

        final illustrationProgress = const Interval(
          0,
          0.55,
          curve: Curves.easeOutCubic,
        ).transform(controller.value);
        final textProgress = const Interval(
          0.18,
          0.78,
          curve: Curves.easeOutCubic,
        ).transform(controller.value);
        return _OnboardingLayout(
          illustration: _motion(
            progress: illustrationProgress,
            child: _Illustration(content: content),
          ),
          heading: _motion(
            progress: textProgress,
            child: _Heading(content: content),
          ),
          description: _motion(
            progress: textProgress,
            child: _Description(content: content),
          ),
        );
      },
    );
  }

  Widget _motion({
    required double progress,
    required Widget child,
  }) {
    final offset = _offsetFor(progress);
    return FractionalTranslation(
      translation: reducedMotion ? Offset.zero : offset,
      child: child,
    );
  }

  Offset _offsetFor(double progress) {
    if (vertical) {
      return incoming ? Offset(0, 1 - progress) : Offset(0, -progress);
    }
    return incoming ? Offset(1 - progress, 0) : Offset(-progress, 0);
  }
}

class _OnboardingLayout extends StatelessWidget {
  const _OnboardingLayout({
    required this.illustration,
    required this.heading,
    required this.description,
  });

  final Widget illustration;
  final Widget heading;
  final Widget description;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final compact = height < 720;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        22,
        compact ? 58 : 72,
        22,
        compact ? 8 : 12,
      ),
      child: Column(
        children: [
          Expanded(flex: compact ? 6 : 7, child: illustration),
          SizedBox(height: compact ? 14 : 24),
          heading,
          SizedBox(height: compact ? 8 : 12),
          description,
          SizedBox(height: compact ? 8 : 14),
        ],
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.content});

  final _OnboardingContent content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: Image.asset(
        content.image,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.content});

  final _OnboardingContent content;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          content.eyebrow,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.accent,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.ink,
            fontSize: 29,
            height: 1.18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.content});

  final _OnboardingContent content;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Text(
        content.description,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF5F5A55),
          fontSize: 16,
          height: 1.55,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _OnboardingFooter extends StatelessWidget {
  const _OnboardingFooter({
    required this.controller,
    required this.pageCount,
    required this.currentPage,
    required this.targetPage,
    required this.transitioning,
    required this.onNext,
    required this.onPageSelected,
  });

  final AnimationController controller;
  final int pageCount;
  final int currentPage;
  final int targetPage;
  final bool transitioning;
  final VoidCallback onNext;
  final ValueChanged<int> onPageSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProgressivePageIndicator(
          controller: controller,
          pageCount: pageCount,
          currentPage: currentPage,
          targetPage: targetPage,
          transitioning: transitioning,
          onPageSelected: onPageSelected,
        ),
        const SizedBox(height: 18),
        SizedBox.square(
          dimension: 64,
          child: IgnorePointer(
            ignoring: transitioning,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: const Color(0xFF111D2D),
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                elevation: 2,
                shadowColor: Colors.black26,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 25,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressivePageIndicator extends StatelessWidget {
  const _ProgressivePageIndicator({
    required this.controller,
    required this.pageCount,
    required this.currentPage,
    required this.targetPage,
    required this.transitioning,
    required this.onPageSelected,
  });

  static const _cellWidth = 28.0;
  static const _pillWidth = 20.0;
  static const _dotSize = 8.0;

  final AnimationController controller;
  final int pageCount;
  final int currentPage;
  final int targetPage;
  final bool transitioning;
  final ValueChanged<int> onPageSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final fromPage = currentPage < 0 ? 0.0 : currentPage.toDouble();
        final progress = transitioning
            ? Curves.easeOutCubic.transform(controller.value)
            : 0.0;
        final visualPage = transitioning
            ? fromPage + (targetPage - fromPage) * progress
            : fromPage;
        final indicatorLeft =
            visualPage * _cellWidth + (_cellWidth - _pillWidth) / 2;

        return IgnorePointer(
          ignoring: transitioning,
          child: SizedBox(
            width: pageCount * _cellWidth,
            height: _dotSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: List.generate(pageCount, (index) {
                    return SizedBox(
                      width: _cellWidth,
                      height: _dotSize,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onPageSelected(index),
                        child: Center(
                          child: Container(
                            width: _dotSize,
                            height: _dotSize,
                            decoration: const BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Positioned(
                  left: indicatorLeft,
                  top: 0,
                  child: Container(
                    width: _pillWidth,
                    height: _dotSize,
                    decoration: BoxDecoration(
                      color: AppTheme.ink,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WarmBackground extends StatelessWidget {
  const _WarmBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _WarmBackgroundPainter());
  }
}

class _WarmBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x66FFFFFF), Color(0x00FFFFFF)],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.78, size.height * 0.22),
          radius: size.width * 0.75,
        ),
      );
    canvas.drawRect(Offset.zero & size, glowPaint);

    final linePaint = Paint()
      ..color = const Color(0x1FAF8164)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    for (var index = 0; index < 3; index++) {
      final y = size.height * (0.82 + index * 0.045);
      final path = Path()..moveTo(-20, y);
      path.cubicTo(
        size.width * 0.28,
        y - 34,
        size.width * 0.58,
        y + 42,
        size.width + 24,
        y - 10,
      );
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OnboardingContent {
  const _OnboardingContent({
    required this.image,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String image;
  final String eyebrow;
  final String title;
  final String description;
}
