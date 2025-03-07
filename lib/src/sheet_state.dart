part of 'sheet.dart';

/// A data class containing state information about the [SlidingSheet]
/// such as the extent and scroll offset.
class SheetState {
  /// The current extent the sheet covers.
  final double extent;

  /// The minimum extent that the sheet will cover.
  final double minExtent;

  /// The maximum extent that the sheet will cover
  /// until it begins scrolling.
  final double maxExtent;

  /// Whether the sheet has finished measuring its children and computed
  /// the correct extents. This takes until the first frame was drawn.
  final bool isLaidOut;

  /// The progress between [minExtent] and [maxExtent] of the current [extent].
  /// A progress of 1 means the sheet is fully expanded, while
  /// a progress of 0 means the sheet is fully collapsed.
  final double progress;

  /// Whether the [SlidingSheet] has reached its maximum extent.
  final bool isExpanded;

  /// Whether the [SlidingSheet] has reached its minimum extent.
  final bool isCollapsed;

  /// Whether the [SlidingSheet] has a [scrollOffset] of zero.
  final bool isAtTop;

  /// Whether the [SlidingSheet] has reached its maximum scroll extent.
  final bool isAtBottom;

  /// Whether the sheet is hidden to the user.
  final bool isHidden;

  /// Whether the sheet is visible to the user.
  final bool isShown;

  /// The scroll offset of the Scrollable inside the sheet
  /// at the time this [SheetState] was emitted.
  final double scrollOffset;

  final _SheetExtent? _extent;

  /// The current scroll offset of the [Scrollable] inside the sheet.
  double get currentScrollOffset => _extent?.scrollOffset ?? 0.0;

  /// The maximum amount the Scrollable inside the sheet can scroll.
  double get maxScrollExtent => _extent?.maxScrollExtent ?? 0.0;

  /// A data class containing state information about the [SlidingSheet]
  /// at the time this state was emitted.
  SheetState(
    // Explanation: Ignoring this rule because the private type needs to be
    // exposed in the public API for specific use cases, such as allowing
    // external customization or integration.
    // ignore: library_private_types_in_public_api
    this._extent, {
    required this.extent,
    required this.isLaidOut,
    required this.maxExtent,
    required double minExtent,
    // On Bottomsheets it is possible for min and maxExtents to be the same
    // (when you only set one snap). Thus we have to account for this and
    // set the minExtent to be zero.
  })  : minExtent = minExtent != maxExtent ? minExtent : 0.0,
        progress = isLaidOut
            ? ((extent - minExtent) / (maxExtent - minExtent)).clamp(0.0, 1.0)
            : 0.0,
        isExpanded = toPrecision(extent) >= toPrecision(maxExtent),
        isCollapsed = toPrecision(extent) <= toPrecision(minExtent),
        isAtTop = _extent?.isAtTop ?? false,
        isAtBottom = _extent?.isAtBottom ?? false,
        isHidden = extent <= 0.0,
        isShown = extent > 0.0,
        scrollOffset = _extent?.scrollOffset ?? 0.0;

  /// A default constructor which can be used to initial `ValueNotifers` for
  /// instance.
  SheetState.inital()
      : this(
          null,
          extent: 0,
          minExtent: 0,
          maxExtent: 1,
          isLaidOut: false,
        );

  /// private
  static ValueNotifier<SheetState> notifier(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedSheetState>()!
        .state;
  }

  @override
  String toString() {
    return 'SheetState(extent: $extent, minExtent: $minExtent, '
        'maxExtent: $maxExtent, isLaidOut: $isLaidOut, progress: $progress, '
        'scrollOffset: $scrollOffset, maxScrollExtent: $maxScrollExtent, '
        'isExpanded: $isExpanded, isCollapsed: $isCollapsed, isAtTop: $isAtTop,'
        ' isAtBottom: $isAtBottom, isHidden: $isHidden, isShown: $isShown)';
  }
}
