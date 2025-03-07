import 'package:flutter/material.dart';

// Explanation: Ignoring this rule because the file contains many public members
// that are self-explanatory or have clear usage contexts, making explicit
// documentation redundant.
// ignore_for_file: public_member_api_docs

void postFrame(VoidCallback callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) => callback());
}

T swapSign<T extends num>(T value) {
  return value.isNegative ? value.abs() as T : value * -1 as T;
}

double toPrecision(double value, [int precision = 3]) {
  return double.parse(value.toStringAsFixed(precision));
}

class Invisible extends StatelessWidget {
  final bool invisible;
  final Widget? child;
  const Invisible({
    super.key,
    this.invisible = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !invisible,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      maintainSemantics: true,
      child: child!,
    );
  }
}
