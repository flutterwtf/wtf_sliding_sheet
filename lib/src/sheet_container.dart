import 'package:flutter/material.dart';
import 'package:wtf_sliding_sheet/src/sheet.dart';
import 'package:wtf_sliding_sheet/src/sheet_listener_builder.dart';

// ignore_for_file: public_member_api_docs

class SheetContainer extends StatelessWidget {
  final Duration? duration;
  final double borderRadius;
  final double elevation;
  final Border? border;
  final BorderRadius? customBorders;
  final EdgeInsets? margin;
  final EdgeInsets padding;
  final Widget? child;
  final Color color;
  final Color? shadowColor;
  final List<BoxShadow>? boxShadows;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;

  const SheetContainer({
    super.key,
    this.duration,
    this.borderRadius = 0.0,
    this.elevation = 0.0,
    this.border,
    this.customBorders,
    this.margin,
    this.padding = EdgeInsets.zero,
    this.color = Colors.transparent,
    this.shadowColor = Colors.black12,
    this.boxShadows,
    this.alignment,
    this.constraints,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final br = customBorders ?? BorderRadius.circular(borderRadius);

    final decoration = BoxDecoration(
      color: color,
      border: border,
      borderRadius: br,
      boxShadow: boxShadows ??
          (elevation > 0.0
              ? [
                  BoxShadow(
                    color: shadowColor ?? Colors.black12,
                    blurRadius: elevation,
                  ),
                ]
              : const []),
    );

    final child = ClipRRect(borderRadius: br, child: this.child);

    return duration == null || duration == Duration.zero
        ? Container(
            alignment: alignment,
            padding: padding,
            decoration: decoration,
            constraints: constraints,
            margin: margin,
            child: child,
          )
        : AnimatedContainer(
            alignment: alignment,
            padding: padding,
            decoration: decoration,
            constraints: constraints,
            // ignore: sort_child_properties_last
            child: child,
            duration: duration!,
          );
  }
}

class ElevatedContainer extends StatelessWidget {
  final Color? shadowColor;
  final double elevation;
  final bool Function(SheetState state) elevateWhen;
  final Widget child;

  const ElevatedContainer({
    required this.shadowColor,
    required this.elevation,
    required this.elevateWhen,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (elevation == 0) return child;

    return SheetListenerBuilder(
      builder: (context, state) {
        return SheetContainer(
          duration: const Duration(milliseconds: 400),
          elevation: elevateWhen(state) ? elevation : 0.0,
          shadowColor: shadowColor,
          child: child,
        );
      },
      buildWhen: (oldState, newState) =>
          elevateWhen(oldState) != elevateWhen(newState),
    );
  }
}
