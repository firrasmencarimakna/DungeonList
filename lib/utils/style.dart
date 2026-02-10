import 'package:flutter/material.dart';

/// Mengembalikan daftar bayangan untuk memberikan efek outline/border pada teks.
/// Offset dikurangi agar teks lebih tajam (tidak blur).
List<Shadow> createTextOutline({
  Color color = Colors.black,
  double offset = 0.8, // Nilai lebih kecil agar lebih tajam
}) {
  return [
    Shadow(color: color, offset: Offset(-offset, -offset)),
    Shadow(color: color, offset: Offset(offset, -offset)),
    Shadow(color: color, offset: Offset(offset, offset)),
    Shadow(color: color, offset: Offset(-offset, offset)),
  ];
}

/// Helper untuk menerapkan border pada TextStyle.
TextStyle withBorder(
  TextStyle baseStyle, {
  Color outlineColor = Colors.black,
  double outlineWidth = 0.8,
}) {
  return baseStyle.copyWith(
    shadows: createTextOutline(color: outlineColor, offset: outlineWidth),
  );
}
