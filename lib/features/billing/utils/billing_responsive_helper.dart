import 'package:flutter/material.dart';

class BillingResponsiveHelper {
  final double screenWidth;

  BillingResponsiveHelper(this.screenWidth);

  bool get isTablet => screenWidth >= 768 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  EdgeInsets get pagePadding =>
      EdgeInsets.all(isDesktop ? 24.0 : (isTablet ? 16.0 : 12.0));

  double get sectionSpacing => isDesktop ? 24 : 16;

  double get headerFontSize {
    if (isTablet) return 24;
    return 28;
  }

  double get controlsPadding => isTablet ? 16.0 : 20.0;

  double get tableColumnSpacing => isTablet ? 20 : 30;
}
