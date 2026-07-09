import 'package:flutter/material.dart';

extension HexColorParsing on String {
  Color? toColorOrNull() {
    try {
      var hex = trim().replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      if (hex.length != 8) return null;
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return null;
    }
  }
}


extension ColorContrast on Color {
  Color get contrastText {
    final luminance = (0.299 * red + 0.587 * green + 0.114 * blue) / 255;
    return luminance > 0.55 ? Colors.black : Colors.white;
  }
}