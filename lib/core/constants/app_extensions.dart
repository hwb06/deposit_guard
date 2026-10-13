import 'package:flutter/material.dart';


extension ResponsiveContext on BuildContext {

  double get pagePad => w(20);

  Size get _size => MediaQuery.sizeOf(this);

  double get screenW => _size.width;
  double get screenH => _size.height;

  double w(double v) => v * (screenW / 375);

  double h(double v) => v * (screenH / 812);

  double sp(double v) => v * (screenW / 375).clamp(0.85, 1.3);

  bool get isTablet => screenW >= 600;
}

extension PriceFormat on double {
  String get priceLabel =>
      this == roundToDouble() ? toStringAsFixed(1) : toStringAsFixed(2);
}

extension SpaceNum on num {
  SizedBox get vGap => SizedBox(height: toDouble());
  SizedBox get hGap => SizedBox(width: toDouble());
}