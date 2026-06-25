import 'package:flutter/material.dart';

class BentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const BentoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.width,
    this.height,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // shadow-[0_12px_32px_rgba(25,28,29,0.06)]
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4), // "surface-container-lowest" in HTML is white
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff191c1d).withOpacity(0.06),
            offset: const Offset(0, 12),
            blurRadius: 32,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
