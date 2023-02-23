part of 'sheet.dart';

/// A controller for a [SlidingSheet].
class SheetController {
  /// Inherit the [SheetController] from the closest [SlidingSheet].
  ///
  /// Every [SlidingSheet] has a [SheetController], even if you didn't assign
  /// one explicitly. This allows you to call functions on the controller from child
  /// widgets without having to pass a [SheetController] around.
  static SheetController? of(BuildContext context) {
    return context
        .findAncestorStateOfType<_SlidingSheetState>()
        ?.sheetController;
  }

  /// Animates the sheet to the [extent].
  ///
  /// The [extent] will be clamped to the minimum and maximum extent.
  /// If the scrolling child is not at the top, it will scroll to the top
  /// first and then animate to the specified extent.
  Future<void>? snapToExtent(
    double extent, {
    Duration? duration,
    bool clamp = true,
  }) =>
      _snapToExtent?.call(
        extent,
        duration: duration,
        clamp: clamp,
      );
  Future<void> Function(
    double extent, {
    Duration? duration,
    bool? clamp,
  })? _snapToExtent;

  /// Animates the scrolling child to a specified offset.
  ///
  /// If the sheet is not fully expanded it will expand first and then
  /// animate to the given [offset].
  Future<void>? scrollTo(
    double offset, {
    Duration? duration,
    Curve? curve,
  }) =>
      _scrollTo?.call(
        offset,
        duration: duration,
        curve: curve,
      );
  Future<void> Function(
    double offset, {
    Duration? duration,
    Curve? curve,
  })? _scrollTo;

  /// Calls every builder function of the sheet to rebuild the widgets with
  /// the current [SheetState].
  ///
  /// This function can be used to reflect changes on the [SlidingSheet]
  /// without calling `setState(() {})` on the parent widget if that would be
  /// too expensive.
  void rebuild() => _rebuild?.call();
  VoidCallback? _rebuild;

  /// Fully collapses the sheet.
  ///
  /// Short-hand for calling `snapToExtent(minExtent)`.
  Future<void>? collapse() => _collapse?.call();
  Future<void> Function()? _collapse;

  /// Fully expands the sheet.
  ///
  /// Short-hand for calling `snapToExtent(maxExtent)`.
  Future<void>? expand() => _expand?.call();
  Future<void> Function()? _expand;

  /// Reveals the [SlidingSheet] if it is currently hidden.
  Future<void>? show() => _show?.call();
  Future<void> Function()? _show;

  /// Slides the sheet off to the bottom and hides it.
  Future<void>? hide() => _hide?.call();
  Future<void> Function()? _hide;

  /// The current [SheetState] of this [SlidingSheet].
  SheetState? get state => _state;
  SheetState? _state;
}
