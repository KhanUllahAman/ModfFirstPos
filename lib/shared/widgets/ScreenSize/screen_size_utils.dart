import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get screenWidth => MediaQuery.of(this).size.width;
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;
  double responsiveHeight(double percentage) => screenHeight * percentage;
  double responsiveWidth(double percentage) => screenWidth * percentage;

  bool get isTablet => MediaQuery.of(this).size.shortestSide > 600;
  bool get isMobile => MediaQuery.of(this).size.shortestSide < 600;

  double get posContentWidth => screenWidth * 0.88;
  double get posCardRadius => isTablet ? 20.0 : 16.0;

  double get fontXS => isTablet ? 12.0 : 10.0;
  double get fontSM => isTablet ? 14.0 : 12.0;
  double get fontMD => isTablet ? 16.0 : 14.0;
  double get fontLG => isTablet ? 20.0 : 17.0;
  double get fontXL => isTablet ? 24.0 : 20.0;
  double get fontXXL => isTablet ? 30.0 : 26.0;

  double get spacingXS => isTablet ? 6.0 : 4.0;
  double get spacingSM => isTablet ? 12.0 : 8.0;
  double get spacingMD => isTablet ? 20.0 : 16.0;
  double get spacingLG => isTablet ? 28.0 : 22.0;
  double get spacingXL => isTablet ? 36.0 : 28.0;
}

class PosResponsive extends StatelessWidget {
  final Widget Function(BuildContext context, bool isTablet) builder;

  const PosResponsive({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    return builder(context, isTablet);
  }
}
