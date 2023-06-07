import 'dart:math';

import 'package:flutter/animation.dart';

// ignore_for_file: public_member_api_docs
class SimpleBounceOut extends Curve {
  final double a;
  final double w;

  const SimpleBounceOut({this.a = 0.09, this.w = 8});

  @override
  double transformInternal(double t) {
    return -(pow(e, -t / a) * cos(t * 1.5 * w)) + 1;
  }
}
