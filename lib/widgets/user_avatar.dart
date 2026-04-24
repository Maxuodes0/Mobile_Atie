import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double radius;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    required this.initials,
    this.radius = 26,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFF2F3F5),
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppTheme.muted,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFF2F3F5),
      child: ClipOval(
        child: Image.network(
          url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Center(
              child: Text(
                initials.isEmpty ? '?' : initials,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.muted,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

