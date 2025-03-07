import 'dart:math';

import 'package:flutter/animation.dart';

// Explanation: Ignoring this rule because the class and its members are
// self-explanatory or have clear usage contexts, making explicit documentation
// redundant.
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
