import 'package:flutter/material.dart';

class InlineLoadingBar extends StatelessWidget {
  final bool visible;
  final double height;
  final EdgeInsetsGeometry padding;

  const InlineLoadingBar({
    super.key,
    required this.visible,
    this.height = 3,
    this.padding = const EdgeInsets.only(top: 10),
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(minHeight: height),
      ),
    );
  }
}
