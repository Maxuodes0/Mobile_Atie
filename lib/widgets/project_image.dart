import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../theme/app_theme.dart';

class ProjectImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double iconSize;

  const ProjectImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    Widget placeholder(IconData icon) {
      return Container(
        width: width,
        height: height,
        color: const Color(0xFFF2F3F5),
        child: Center(
          child: Icon(icon, color: AppTheme.muted, size: iconSize),
        ),
      );
    }

    if (url == null || url!.trim().isEmpty) {
      final child = placeholder(Icons.image_outlined);
      if (borderRadius != null) {
        return ClipRRect(borderRadius: borderRadius!, child: child);
      }
      return child;
    } else {
      final image = CachedNetworkImage(
        imageUrl: url!.trim(),
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 150),
        fadeOutDuration: const Duration(milliseconds: 80),
        placeholder: (_, __) => placeholder(Icons.image_outlined),
        errorWidget: (_, __, ___) => placeholder(Icons.broken_image_outlined),
      );
      if (borderRadius != null) {
        return ClipRRect(borderRadius: borderRadius!, child: image);
      }
      return image;
    }
  }
}
