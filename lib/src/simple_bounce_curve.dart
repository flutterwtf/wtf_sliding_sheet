import 'dart:math';

import 'package:flutter/animation.dart';

// ignore_for_file: public_member_api_docs
class SimpleBounceOut extends Curve {
  const SimpleBounceOut({this.a = 0.09, this.w = 8});

  final double a;
  final double w;

  @override
  double transformInternal(double t) {
    return -(pow(e, -t / a) * cos(1.5 * t * w)) + 1;
  }
}
