import 'package:flutter/material.dart';

/// A container with a retro 8-bit style "stepped" border.
class PixelContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double pixelSize;
  final EdgeInsetsGeometry? padding;

  const PixelContainer({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.black,
    this.pixelSize = 4.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: borderColor,
        // The jagged "pixel" effect is created by the inner background being slightly smaller
        // and using a custom shape or just simple padding arithmetic.
      ),
      padding: EdgeInsets.all(pixelSize),
      child: Container(
        padding: padding ?? const EdgeInsets.all(12.0),
        decoration: BoxDecoration(color: backgroundColor),
        child: child,
      ),
    );
  }
}

/// A retro-style pixel button.
class PixelButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget label;
  final Color color;
  final EdgeInsetsGeometry? padding;

  const PixelButton({
    super.key,
    this.onPressed,
    required this.label,
    required this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: PixelContainer(
        pixelSize: 3,
        backgroundColor: color,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: label,
      ),
    );
  }
}
