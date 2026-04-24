import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  final double height;
  final String title;

  const LoginHeader({
    super.key,
    required this.height,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: height,
        color: const Color(0xFFE7D7C0),
        child: Stack(
          children: [
            const Positioned(
              top: 0,
              left: 64,
              child: _HangingLamp(large: true),
            ),
            const Positioned(
              top: 0,
              right: 54,
              child: _HangingLamp(large: false),
            ),
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HangingLamp extends StatelessWidget {
  final bool large;

  const _HangingLamp({required this.large});

  @override
  Widget build(BuildContext context) {
    final lineHeight = large ? 150.0 : 112.0;
    final shadeWidth = large ? 108.0 : 74.0;
    final shadeHeight = large ? 50.0 : 34.0;

    return Column(
      children: [
        Container(
          width: 2,
          height: lineHeight,
          color: const Color(0xFFF4F4F4).withAlpha(210),
        ),
        Container(
          width: shadeWidth,
          height: shadeHeight,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F3F5),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(90),
              bottom: Radius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height * 0.74);

    path.cubicTo(
      size.width * 0.20,
      size.height * 0.81,
      size.width * 0.45,
      size.height * 0.67,
      size.width * 0.62,
      size.height * 0.63,
    );

    path.cubicTo(
      size.width * 0.82,
      size.height * 0.57,
      size.width,
      size.height * 0.60,
      size.width,
      size.height * 0.60,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
