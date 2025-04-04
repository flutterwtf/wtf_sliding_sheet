// Explanation:
// - no_default_cases: Ignoring this rule because the switch statements in this
// file are exhaustive and do not require a default case.
// - library_private_types_in_public_api: Ignoring this rule because the private
// types are intentionally exposed as part of the public API for specific use
// cases.
// ignore_for_file: no_default_cases, library_private_types_in_public_api
// ignore_for_file: parameter_assignments

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:wtf_sliding_sheet/src/sheet_container.dart';
import 'package:wtf_sliding_sheet/src/simple_bounce_curve.dart';
import 'package:wtf_sliding_sheet/src/specs.dart';
import 'package:wtf_sliding_sheet/src/util.dart';

part 'scrolling.dart';
part 'sheet_controller.dart';
part 'sheet_dialog.dart';
part 'sheet_state.dart';

/// Widget for building sheet.
typedef SheetBuilder = Widget Function(BuildContext context, SheetState state);

/// Widget for building sheet with custom scroll view.
typedef CustomSheetBuilder = Widget Function(
  BuildContext context,
  ScrollController controller,
  SheetState state,
);

/// Callback for changing state of the sheet.
typedef SheetListener = void Function(SheetState state);

/// Callback prevented dismiss the dialog
typedef OnDismissPreventedCallback = void Function({
  required bool backButton,
  required bool backDrop,
});

/// Callback for opening sheet.
typedef OnOpenCallback = void Function();

/// A widget that can be dragged and scrolled in a single gesture and snapped
/// to a list of extents.
///
/// The [builder] parameter must not be null.
class SlidingSheet extends StatefulWidget {
  /// {@template sliding_sheet.builder}
  /// The builder for the main content of the sheet that will be scrolled if
  /// the content is bigger than the height that the sheet can expand to.
  /// {@endtemplate}
  final SheetBuilder? builder;

  /// {@template sliding_sheet.customBuilder}
  /// Allows you to supply your own custom sroll view. Useful for infinite lists
  /// that cannot be shrinkWrapped like long lists.
  /// {@endtemplate}
  final CustomSheetBuilder? customBuilder;

  /// {@template sliding_sheet.headerBuilder}
  /// The builder for a header that will be displayed at the top of the sheet
  /// that wont be scrolled.
  /// {@endtemplate}
  final SheetBuilder? headerBuilder;

  /// {@template sliding_sheet.footerBuilder}
  /// The builder for a footer that will be displayed at the bottom of the sheet
  /// that wont be scrolled.
  /// {@endtemplate}
  final SheetBuilder? footerBuilder;

  /// {@template sliding_sheet.snapSpec}
  /// The [SnapSpec] that defines how the sheet should snap or if it should at
  /// all.
  /// {@endtemplate}
  final SnapSpec snapSpec;

  /// {@template sliding_sheet.duration}
  /// The base animation duration for the sheet. Swipes and flings may have a
  /// different duration.
  /// {@endtemplate}
  final Duration openDuration;

  /// {@template sliding_sheet.color}
  /// The background color of the sheet.
  ///
  /// When not specified, the sheet will use `theme.cardColor`.
  /// {@endtemplate}
  final Color? color;

  /// {@template sliding_sheet.backdropColor}
  /// The color of the shadow that is displayed behind the sheet.
  /// {@endtemplate}
  final Color? backdropColor;

  /// {@template sliding_sheet.shadowColor}
  /// The color of the drop shadow of the sheet when [elevation] is > 0.
  /// {@endtemplate}
  final Color? shadowColor;

  /// {@template sliding_sheet.elevation}
  /// The elevation of the sheet.
  /// {@endtemplate}
  final double elevation;

  /// {@template sliding_sheet.padding}
  /// The amount to inset the children of the sheet.
  /// {@endtemplate}
  final EdgeInsets? padding;

  /// {@template sliding_sheet.avoidStatusBar}
  /// If true, adds the top padding returned by
  /// `MediaQuery.of(context).viewPadding.top` to the [padding] when taking
  /// up the full screen.
  ///
  /// This can be used to easily avoid the content of the sheet from being
  /// under the status bar, which is especially useful when having a header.
  /// {@endtemplate}
  final bool avoidStatusBar;

  /// {@template sliding_sheet.margin}
  /// The amount of the empty space surrounding the sheet.
  /// {@endtemplate}
  final EdgeInsets? margin;

  /// {@template sliding_sheet.border}
  /// A border that will be drawn around the sheet.
  /// {@endtemplate}
  final Border? border;

  /// {@template sliding_sheet.cornerRadius}
  /// The radius of the top corners of this sheet.
  /// {@endtemplate}
  final double cornerRadius;

  /// {@template sliding_sheet.cornerRadiusOnFullscreen}
  /// The radius of the top corners of this sheet when expanded to fullscreen.
  ///
  /// This parameter can be used to easily implement the common Material
  /// behaviour of sheets to go from rounded corners to sharp corners when
  /// taking up the full screen.
  /// {@endtemplate}
  final double? cornerRadiusOnFullscreen;

  /// If true, will collapse the sheet when the sheets backdrop was tapped.
  final bool closeOnBackdropTap;

  /// {@template sliding_sheet.listener}
  /// A callback that will be invoked when the sheet gets dragged or scrolled
  /// with current state information.
  /// {@endtemplate}
  final SheetListener? listener;

  /// {@template sliding_sheet.controller}
  /// A controller to control the state of the sheet.
  /// {@endtemplate}
  final SheetController? controller;

  /// {@template sliding_sheet.scrollSpec}
  /// The [ScrollSpec] of the containing ScrollView.
  /// {@endtemplate}
  final ScrollSpec scrollSpec;

  /// {@template sliding_sheet.maxWidth}
  /// The maximum width of the sheet.
  ///
  /// Usually set for large screens. By default the [SlidingSheet]
  /// expands to the total available width.
  /// {@endtemplate}
  final double maxWidth;

  /// {@template sliding_sheet.maxWidth}
  /// The minimum height of the sheet the child return by the `builder`.
  ///
  /// By default, the sheet sizes itself as big as its child.
  /// {@endtemplate}
  final double? minHeight;

  /// {@template sliding_sheet.closeSheetOnBackButtonPressed}
  /// If true, closes the sheet when it is open and prevents the route
  /// from being popped.
  /// {@endtemplate}
  final bool closeSheetOnBackButtonPressed;

  /// {@template sliding_sheet.isBackDropInteractable}
  /// If true, the backDrop will also be interactable so any gesture
  /// that is applied to the backDrop will be delegated to the sheet
  /// itself.
  /// {@endtemplate}
  final bool isBackdropInteractable;

  /// A widget that is placed behind the sheet.
  ///
  /// You can apply a parallax effect to this widget by
  /// setting the [parallaxSpec] parameter.
  final Widget? body;

  /// {@template sliding_sheet.parallaxSpec}
  /// A [ParallaxSpec] to create a parallax effect.
  ///
  /// The parallax effect is an effect that appears when different layers of
  /// backgrounds are moved at different speeds and thereby create the effect of
  /// motion and depth. By moving the [SlidingSheet] faster than the [body] the
  /// depth effect is achieved.
  /// {@endtemplate}
  final ParallaxSpec? parallaxSpec;

  /// {@template sliding_sheet.axisAlignment}
  /// How to align the sheet on the horizontal axis when the available width is
  /// bigger than the `maxWidth` of the sheet.
  ///
  /// The value must be in the range from `-1.0` (far left) and `1.0`
  /// (far right).
  ///
  /// Defaults to `0.0` (center).
  /// {@endtemplate}
  final double axisAlignment;

  /// {@template sliding_sheet.extendBody}
  /// Whether to extend the scrollable body of the sheet under
  /// header and/or footer.
  /// {@endtemplate}
  final bool extendBody;

  /// {@template sliding_sheet.liftOnScrollHeaderElevation}
  /// The elevation of the header when the content scrolls under it.
  /// {@endtemplate}
  final double liftOnScrollHeaderElevation;

  /// {@template sliding_sheet.liftOnScrollFooterElevation}
  /// The elevation of the footer when there content scrolls under it.
  /// {@endtemplate}
  final double liftOnScrollFooterElevation;

  // * SlidingSheetDialog fields

  /// private, do not use!
  final _SlidingSheetRoute? route;

  /// {@template sliding_sheet.isDismissable}
  /// If false, the `SlidingSheetDialog` will not be dismissable.
  ///
  /// That means that the user wont be able to close the sheet using gestures or
  /// back button.
  /// {@endtemplate}
  final bool isDismissable;

  /// {@template sliding_sheet.onDismissPrevented}
  /// A callback that gets invoked when a user tried to dismiss the dialog
  /// while [isDismissable] is set to `true`.
  ///
  /// The `backButton` flag indicates whether the user tried to dismiss the
  /// sheet using the backButton, while the `backDrop` flag indicates whether
  /// the user tried to dismiss the sheet by tapping the backdrop.
  /// {@endtemplate}
  final OnDismissPreventedCallback? onDismissPrevented;

  /// {@template sliding_sheet.onOpen}
  /// A callback that gets invoked when a user opening sheet
  /// {@endtemplate}
  final OnOpenCallback? onOpen;

  /// {@template sliding_sheet.openBouncing}
  /// A flag to control sheet open animation.
  /// If `true` SimpleBounceOut curve is used, otherwise Curves.ease is used.
  ///
  /// Defaults to `false` (Curves.ease).
  /// {@endtemplate}
  final bool openBouncing;

  /// Creates a sheet than can be dragged and scrolled in a single gesture to be
  /// placed inside you widget tree.
  ///
  /// The `builder` callback is used to build the main content of the sheet that
  /// will be scrolled if the content is bigger than the height that the sheet
  /// can expand to.
  ///
  /// The `customBuilder` callback is used to build such the main content like
  /// infinite lists that cannot be shrinkWrapped.
  ///
  /// Either the `builder` or the `customBuilder` must be specified.
  ///
  /// The `headerBuilder` and `footerBuilder` can be used to build persistent
  /// widget on top and bottom respectively, that wont be scrolled but will
  /// delegate the interactions on them to the sheet.
  ///
  /// The `listener` callback is being invoked when the sheet gets dragged or
  /// scrolled with current state information.
  ///
  /// The `snapSpec` can be used to customize the snapping behavior. There you
  /// can custom snap extents, whether the sheet should snap at all, and how to
  /// position those snaps.
  ///
  /// If `addTopViewPaddingOnFullscreen` is set to true, the sheet will add the
  /// status bar height as a top padding to it in order to avoid the status bar
  /// if it is translucent.
  ///
  /// The `cornerRadiusOnFullscreen` parameter can be used to easily implement
  /// the common Material behaviour of sheets to go from rounded corners to
  /// sharp corners when taking up the full screen.
  ///
  /// The `body` parameter can be used to place a widget behind the sheet and a
  /// parallax effect can be applied to it using the `parallaxSpec` parameter.
  ///
  /// The `axisAlignment` parameter can be used to align the sheet on the
  /// horizontal axis when the available width is bigger than the `maxWidth` of
  /// the sheet.
  SlidingSheet({
    Key? key,
    SheetBuilder? builder,
    CustomSheetBuilder? customBuilder,
    SheetBuilder? headerBuilder,
    SheetBuilder? footerBuilder,
    SnapSpec snapSpec = const SnapSpec(),
    Duration openDuration = const Duration(milliseconds: 1000),
    Color? color,
    Color? backdropColor,
    Color shadowColor = Colors.black54,
    double elevation = 0.0,
    EdgeInsets? padding,
    bool addTopViewPaddingOnFullscreen = false,
    EdgeInsets? margin,
    Border? border,
    double cornerRadius = 0.0,
    double? cornerRadiusOnFullscreen,
    bool closeOnBackdropTap = false,
    SheetListener? listener,
    SheetController? controller,
    ScrollSpec scrollSpec = const ScrollSpec(overscroll: false),
    double maxWidth = double.infinity,
    double? minHeight,
    bool closeOnBackButtonPressed = false,
    bool isBackdropInteractable = false,
    Widget? body,
    ParallaxSpec? parallaxSpec,
    double axisAlignment = 0.0,
    bool extendBody = false,
    double liftOnScrollHeaderElevation = 0.0,
    double liftOnScrollFooterElevation = 0.0,
    OnDismissPreventedCallback? onDismissPrevented,
    OnOpenCallback? onOpen,
    bool openBouncing = false,
  }) : this._(
          key: key,
          builder: builder,
          customBuilder: customBuilder,
          headerBuilder: headerBuilder,
          footerBuilder: footerBuilder,
          snapSpec: snapSpec,
          openDuration: openDuration,
          color: color,
          backdropColor: backdropColor,
          shadowColor: shadowColor,
          elevation: elevation,
          padding: padding,
          avoidStatusBar: addTopViewPaddingOnFullscreen,
          margin: margin,
          border: border,
          cornerRadius: cornerRadius,
          cornerRadiusOnFullscreen: cornerRadiusOnFullscreen,
          closeOnBackdropTap: closeOnBackdropTap,
          listener: listener,
          controller: controller,
          scrollSpec: scrollSpec,
          maxWidth: maxWidth,
          minHeight: minHeight,
          closeSheetOnBackButtonPressed: closeOnBackButtonPressed,
          isBackdropInteractable: isBackdropInteractable,
          body: body,
          parallaxSpec: parallaxSpec,
          axisAlignment: axisAlignment,
          extendBody: extendBody,
          liftOnScrollHeaderElevation: liftOnScrollHeaderElevation,
          liftOnScrollFooterElevation: liftOnScrollFooterElevation,
          onDismissPrevented: onDismissPrevented,
          onOpen: onOpen,
          openBouncing: openBouncing,
        );

  SlidingSheet._({
    required this.builder,
    required this.customBuilder,
    required this.headerBuilder,
    required this.footerBuilder,
    required this.snapSpec,
    required this.openDuration,
    required this.color,
    required this.backdropColor,
    required this.shadowColor,
    required this.elevation,
    required this.padding,
    required this.avoidStatusBar,
    required this.margin,
    required this.border,
    required this.cornerRadius,
    required this.cornerRadiusOnFullscreen,
    required this.closeOnBackdropTap,
    required this.listener,
    required this.controller,
    required this.scrollSpec,
    required this.maxWidth,
    required this.minHeight,
    required this.closeSheetOnBackButtonPressed,
    required this.isBackdropInteractable,
    required this.axisAlignment,
    required this.extendBody,
    required this.liftOnScrollHeaderElevation,
    required this.liftOnScrollFooterElevation,
    required this.openBouncing,
    super.key,
    this.body,
    this.parallaxSpec,
    this.route,
    this.isDismissable = true,
    this.onDismissPrevented,
    this.onOpen,
  })  :

        /// Checking whether one of the `builder` and `customBuilder` is
        /// specified.
        assert(
          builder != null || customBuilder != null,
          'Either the `builder` or the `customBuilder` must be specified.',
        ),
        assert(
          builder == null || customBuilder == null,
          'Either the `builder` or the `customBuilder` must be specified.',
        ),
        assert(
          snapSpec.snappings.length >= 2,
          'There must be at least two snapping extents to snap in between.',
        ),
        assert(
          snapSpec.minSnap != snapSpec.maxSnap || route != null,
          'The min and max snaps cannot be equal.',
        ),
        assert(
          axisAlignment >= -1.0 && axisAlignment <= 1.0,
          'The axisAlignment must be in the range from -1.0 and 1.0.',
        ),
        assert(
          liftOnScrollHeaderElevation >= 0.0,
          'The liftOnScrollHeaderElevation must be greater than or equal 0.',
        ),
        assert(
          liftOnScrollFooterElevation >= 0.0,
          'The liftOnScrollFooterElevation must be greater than or equal 0.',
        );

  @override
  _SlidingSheetState createState() => _SlidingSheetState();
}

class _SlidingSheetState extends State<SlidingSheet>
    with TickerProviderStateMixin {
  final GlobalKey childKey = GlobalKey();
  final GlobalKey headerKey = GlobalKey();
  final GlobalKey footerKey = GlobalKey();

  bool get hasHeader => widget.headerBuilder != null;

  bool get hasFooter => widget.footerBuilder != null;

  late List<double> snappings;

  double childHeight = 0;
  double headerHeight = 0;
  double footerHeight = 0;
  double availableHeight = 0;

  // Whether the dialog completed its initial fly in
  bool didCompleteInitialRoute = false;

  // Whether a dismiss was already triggered by the sheet itself
  // and thus further route pops can be safely ignored
  bool dismissUnderway = false;

  // Whether the drag on a delegating widget (such as the backdrop)
  // did start, when the sheet was not fully collapsed
  bool didStartDragWhenNotCollapsed = false;
  _SheetExtent? extent;
  SheetController? sheetController;
  late _SlidingSheetScrollController controller;

  bool get isCustom => widget.customBuilder != null;

  // Whether the sheet has drawn its first frame.
  bool isLaidOut = false;

  // The total height of all sheet components.
  double get sheetHeight =>
      childHeight +
      headerHeight +
      footerHeight +
      padding.vertical +
      borderHeight;

  // The maxiumum height that this sheet will cover.
  double get maxHeight => math.min(sheetHeight, availableHeight);

  bool get isScrollable => sheetHeight >= availableHeight;

  double get currentExtent =>
      (extent?.currentExtent ?? minExtent).clamp(0.0, 1.0);

  set currentExtent(double value) => extent?.currentExtent = value;

  double get headerExtent =>
      isLaidOut ? (headerHeight + (borderHeight / 2)) / availableHeight : 0.0;

  double get footerExtent =>
      isLaidOut ? (footerHeight + (borderHeight / 2)) / availableHeight : 0.0;

  double get headerFooterExtent => headerExtent + footerExtent;

  double get minExtent => snappings[isDialog ? 1 : 0].clamp(0.0, 1.0);

  double get maxExtent => snappings.last.clamp(0.0, 1.0);

  double get initialExtent => snapSpec.initialSnap != null
      ? _normalizeSnap(snapSpec.initialSnap!)
      : minExtent;

  bool get isDialog => widget.route != null;

  ScrollSpec get scrollSpec => widget.scrollSpec;

  SnapSpec get snapSpec => widget.snapSpec;

  SnapPositioning get snapPositioning => snapSpec.positioning;

  double get borderHeight => (widget.border?.top.width ?? 0) * 2;

  EdgeInsets get padding {
    final begin = widget.padding ?? EdgeInsets.zero;

    if (!widget.avoidStatusBar || !isLaidOut) {
      return begin;
    }

    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    final end = begin.copyWith(top: begin.top + statusBarHeight);
    return EdgeInsets.lerp(begin, end, lerpFactor)!;
  }

  double? get cornerRadius {
    if (widget.cornerRadiusOnFullscreen == null) return widget.cornerRadius;
    return lerpDouble(
      widget.cornerRadius,
      widget.cornerRadiusOnFullscreen,
      lerpFactor,
    );
  }

  double get lerpFactor {
    if (maxExtent != 1.0 && isLaidOut) return 0;

    final snap = snappings[math.max(snappings.length - 2, 0)];
    return Interval(
      snap >= 0.7 ? snap : 0.85,
      1,
    ).transform(currentExtent);
  }

  // The current state of this sheet.
  SheetState get state => SheetState(
        extent,
        extent: _reverseSnap(currentExtent),
        isLaidOut: isLaidOut,
        maxExtent: _reverseSnap(maxExtent),
        minExtent: _reverseSnap(minExtent),
      );

  // A notifier that a child SheetListenableBuilder can inherit to
  final ValueNotifier<SheetState> stateNotifier =
      ValueNotifier(SheetState.inital());

  @override
  void initState() {
    super.initState();

    _updateSnappingsAndExtent();

    controller = _SlidingSheetScrollController(
      this,
    )..addListener(_listener);

    extent = _SheetExtent(
      controller,
      isDialog: isDialog,
      snappings: snappings,
      listener: (extent) => _listener(),
    );

    _assignSheetController();
    _measure();

    if (isDialog) {
      _flyInDialog();
    } else {
      didCompleteInitialRoute = true;
      // Set the inital extent after the first frame.
      postFrame(
        () async {
          await snapToExtent(initialExtent);
          if (mounted) {
            setState(() => currentExtent = initialExtent);
          }
          widget.onOpen?.call();
        },
      );
    }
  }

  void _flyInDialog() {
    postFrame(() async {
      // Snap to the initial snap with a one frame delay when the
      // extents have been correctly calculated.
      await snapToExtent(initialExtent);
      if (mounted) {
        setState(() => didCompleteInitialRoute = true);
      }
    });

    // ignore: prefer-async-await
    widget.route!.popped.then(
      (_) {
        if (!dismissUnderway) {
          dismissUnderway = true;
          controller
            ..jumpTo(controller.offset)
            // When the route gets popped we animate fully out - not just
            // to the minExtent.
            ..snapToExtent(0, this, clamp: false);
        }
      },
    );
  }

  void _listener() {
    if (isLaidOut) {
      final state = this.state;

      stateNotifier.value = state;
      widget.listener?.call(state);
      sheetController?._state = state;
    }
  }

  // Measure the height of all sheet components.
  void _measure() {
    postFrame(() {
      final child = childKey.currentContext?.findRenderObject() as RenderBox?;
      final header = headerKey.currentContext?.findRenderObject() as RenderBox?;
      final footer = footerKey.currentContext?.findRenderObject() as RenderBox?;

      final previousMaxExtent =
          isLaidOut ? (sheetHeight / availableHeight).clamp(0.0, 1.0) : 1.0;

      final isChildLaidOut = child?.hasSize ?? false;
      final prevChildHeight = childHeight;
      childHeight = isChildLaidOut ? child!.size.height : 0;

      final isHeaderLaidOut = header?.hasSize ?? false;
      final prevHeaderHeight = headerHeight;
      headerHeight = isHeaderLaidOut ? header!.size.height : 0;

      final isFooterLaidOut = footer?.hasSize ?? false;
      final prevFooterHeight = footerHeight;
      footerHeight = isFooterLaidOut ? footer!.size.height : 0;

      isLaidOut = true;

      if (mounted &&
          (childHeight != prevChildHeight ||
              headerHeight != prevHeaderHeight ||
              footerHeight != prevFooterHeight)) {
        _updateSnappingsAndExtent(previousMaxExtent: previousMaxExtent);
        setState(() {});
      }
    });
  }

  // A snap is defined relative to its availableHeight.
  // Here we handle all available snap positions and normalize them
  // to the availableHeight.
  double _normalizeSnap(double snap) {
    void isValidRelativeSnap([String? message]) {
      assert(
        SnapSpec.isSnap(snap) || (snap >= 0.0 && snap <= 1.0),
        message ?? 'Relative snap $snap is not in the range [0..1].',
      );
    }

    if (availableHeight > 0) {
      final num maxPossibleExtent = () {
        return isCustom
            ? 1.0
            : isLaidOut
                ? (sheetHeight / availableHeight).clamp(0.0, 1.0)
                : 1.0;
      }();

      var extent = snap;
      switch (snapPositioning) {
        case SnapPositioning.relativeToAvailableSpace:
          isValidRelativeSnap();
        case SnapPositioning.relativeToSheetHeight:
          isValidRelativeSnap();
          extent = (snap * maxHeight) / availableHeight;
        case SnapPositioning.pixelOffset:
          extent = snap / availableHeight;
      }

      if (snap == SnapSpec.headerSnap) {
        assert(hasHeader, 'There is no available header to snap to!');
        extent = headerExtent;
      } else if (snap == SnapSpec.footerSnap) {
        assert(hasFooter, 'There is no available footer to snap to!');
        extent = footerExtent;
      } else if (snap == SnapSpec.headerFooterSnap) {
        assert(
          hasHeader || hasFooter,
          'There is neither a header nor a footer to snap to!',
        );
        extent = headerFooterExtent;
      } else if (snap == double.infinity) {
        extent = maxPossibleExtent as double;
      }

      return math.min(extent, maxPossibleExtent).clamp(0.0, 1.0) as double;
    } else {
      return snap.clamp(0.0, 1.0);
    }
  }

  // Reverse a normalized snap.
  double _reverseSnap(double snap) {
    if (isLaidOut && childHeight > 0) {
      switch (snapPositioning) {
        case SnapPositioning.relativeToAvailableSpace:
          return snap;
        case SnapPositioning.relativeToSheetHeight:
          return snap * (availableHeight / sheetHeight);
        case SnapPositioning.pixelOffset:
          return snap * availableHeight;
      }
    } else {
      return snap.clamp(0.0, 1.0);
    }
  }

  void _updateSnappingsAndExtent({num? previousMaxExtent}) {
    snappings = snapSpec.snappings.map(_normalizeSnap).toList()..sort();

    if (extent != null) {
      extent!
        ..snappings = snappings
        ..targetHeight = maxHeight
        ..childHeight = childHeight
        ..headerHeight = headerHeight
        ..footerHeight = footerHeight
        ..availableHeight = availableHeight
        ..maxExtent = maxExtent
        ..minExtent = minExtent;

      final isCurrentPreviousMaxExtent = previousMaxExtent != null &&
          (currentExtent - previousMaxExtent).abs() < 0.01;

      if (currentExtent > maxExtent || isCurrentPreviousMaxExtent) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          currentExtent = maxExtent;
        });
      }
    }
  }

  // Assign the controller functions to actual methods.
  void _assignSheetController() {
    if (sheetController != null) return;

    // Always assing a SheetController to be able to inherit from it
    sheetController = widget.controller ?? SheetController();

    // Assign the controller functions to the state functions.
    sheetController!._scrollTo = scrollTo;
    sheetController!._snapToExtent = (
      snap, {
      duration,
      clamp,
    }) {
      return snapToExtent(
        _normalizeSnap(snap),
        duration: duration,
        clamp: clamp,
      );
    };
    sheetController!._expand = () => snapToExtent(maxExtent);
    sheetController!._collapse = () => snapToExtent(minExtent);

    if (!isDialog) {
      sheetController!._rebuild = () {
        setState(() {});
        _measure();
      };

      sheetController!._show = () async {
        if (state.isHidden) return snapToExtent(minExtent, clamp: false);
      };

      sheetController!._hide = () async {
        if (state.isShown) return snapToExtent(0, clamp: false);
      };
    }
  }

  void _nudgeToNextSnap() {
    if (!controller.inInteraction && state.isShown) {
      controller.delegateFling();
    }
  }

  void _pop({
    required double velocity,
    required bool isBackDrop,
    required bool isBackButton,
  }) {
    if (isDialog && !dismissUnderway && Navigator.canPop(context)) {
      dismissUnderway = true;
      Navigator.pop(context);
      snapToExtent(0, velocity: velocity);
    } else if (!isDialog) {
      final num fractionCovered =
          ((currentExtent - minExtent) / (maxExtent - minExtent))
              .clamp(0.0, 1.0);
      final timeFraction = 1.0 - (fractionCovered * 0.5);
      snapToExtent(
        minExtent,
        duration: widget.openDuration * timeFraction,
      );
    }
    _onDismissPrevented(backButton: isBackButton, backDrop: isBackDrop);
  }

  // Ensure that the sheet sizes itself correctly when the
  // constraints change.
  void _adjustSnapForIncomingConstraints(double previousHeight) {
    if (previousHeight > 0.0 &&
        previousHeight != availableHeight &&
        state.isShown) {
      _updateSnappingsAndExtent();

      final num changeAdjustedExtent =
          ((currentExtent * previousHeight) / availableHeight)
              .clamp(minExtent, maxExtent);

      final isAroundFixedSnap = snappings.any(
        (snap) => (snap - changeAdjustedExtent).abs() < 0.01,
      );

      // Only update the currentExtent when its sitting at an extent that
      // is depenent on a fixed height, such as SnapSpec.headerSnap or absolute
      // snap values.
      if (isAroundFixedSnap) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          currentExtent = changeAdjustedExtent as double;
        });
      }
    }
  }

  void _onDismissPrevented({bool backButton = false, bool backDrop = false}) {
    widget.onDismissPrevented?.call(backButton: backButton, backDrop: backDrop);
  }

  void _handleNonDismissableSnapBack() {
    // didEndScroll doesn't work reliably in ScrollPosition. There
    // should be a better solution to this problem.
    if (isDialog && !widget.isDismissable && currentExtent < minExtent) {
      _onDismissPrevented();
    }
  }

  Future<void> snapToExtent(
    double snap, {
    Duration? duration,
    double velocity = 0,
    bool? clamp,
  }) async {
    if (!isLaidOut) return;
    duration ??= widget.openDuration;

    if (!state.isAtTop) {
      duration *= 0.5;
      await controller.animateTo(
        0,
        duration: duration,
        curve: Curves.easeInCubic,
      );
    }

    await controller.snapToExtent(
      snap,
      this,
      duration: duration,
      velocity: velocity,
      clamp: clamp ?? (!isDialog || (isDialog && snap != 0.0)),
    );
  }

  Future<void> scrollTo(
    double offset, {
    Duration? duration,
    Curve? curve,
  }) async {
    if (!isLaidOut) return;
    duration ??= widget.openDuration;

    final isExtentAtMax = extent!.isAtMax;

    if (!isExtentAtMax) {
      duration *= 0.5;
      await snapToExtent(
        maxExtent,
        duration: duration,
      );
    }

    await controller.animateTo(
      offset,
      duration: duration,
      curve: curve ?? (!isExtentAtMax ? Curves.easeOutCirc : Curves.ease),
    );
  }

  Widget _buildSheet() {
    final sheet = Builder(
      builder: (context) => Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              if (!widget.extendBody) SizedBox(height: headerHeight),
              Expanded(child: _buildScrollView()),
              if (!widget.extendBody) SizedBox(height: footerHeight),
            ],
          ),
          if (hasHeader)
            Align(
              alignment: Alignment.topCenter,
              child: ElevatedContainer(
                shadowColor: widget.shadowColor,
                elevation: widget.liftOnScrollHeaderElevation,
                elevateWhen: (state) => isScrollable && !state.isAtTop,
                child: SizeChangedLayoutNotifier(
                  key: headerKey,
                  child: _delegateInteractions(
                    widget.headerBuilder!(context, state),
                  ),
                ),
              ),
            ),
          if (hasFooter)
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedContainer(
                shadowColor: widget.shadowColor,
                elevation: widget.liftOnScrollFooterElevation,
                elevateWhen: (state) => !state.isCollapsed && !state.isAtBottom,
                child: SizeChangedLayoutNotifier(
                  key: footerKey,
                  child: _delegateInteractions(
                    widget.footerBuilder!(context, state),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return Align(
      alignment: Alignment(widget.axisAlignment, -1),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: SizedBox.expand(
          child: ValueListenableBuilder(
            valueListenable: extent!._currentExtent,
            builder: (context, dynamic extent, sheet) {
              final translation = () {
                return headerFooterExtent > 0.0
                    ? 1.0 -
                        (currentExtent.clamp(0.0, headerFooterExtent) /
                            headerFooterExtent)
                    : 0.0;
              }();
              return Invisible(
                invisible: !isLaidOut || currentExtent == 0.0,
                child: FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: isLaidOut
                      ? currentExtent.clamp(headerFooterExtent, 1.0)
                      : 1.0,
                  child: FractionalTranslation(
                    translation: Offset(0, translation),
                    child: SheetContainer(
                      elevation: widget.elevation,
                      border: widget.border,
                      customBorders: BorderRadius.vertical(
                        top: Radius.circular(cornerRadius!),
                      ),
                      margin: widget.margin,
                      padding: EdgeInsets.fromLTRB(
                        padding.left,
                        hasHeader ? padding.top : 0.0,
                        padding.right,
                        hasFooter ? padding.bottom : 0.0,
                      ),
                      color: widget.color ?? Theme.of(context).cardColor,
                      shadowColor: widget.shadowColor,
                      child: sheet,
                    ),
                  ),
                ),
              );
            },
            child: sheet,
          ),
        ),
      ),
    );
  }

  Widget _buildScrollView() {
    Widget scrollView = Listener(
      onPointerUp: (_) => _handleNonDismissableSnapBack(),
      child: widget.customBuilder != null
          ? Container(
              key: childKey,
              child: widget.customBuilder!(context, controller, state),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                top: !hasHeader ? padding.top : 0.0,
                bottom: !hasFooter ? padding.bottom : 0.0,
              ),
              physics: scrollSpec.physics,
              controller: controller,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: widget.minHeight ?? 0.0),
                child: SizeChangedLayoutNotifier(
                  key: childKey,
                  child: widget.builder!(context, state),
                ),
              ),
            ),
    );

    if (scrollSpec.showScrollbar) {
      scrollView = Scrollbar(
        controller: controller,
        child: scrollView,
      );
    }

    // Add the overscroll if required again if required
    if (scrollSpec.overscroll) {
      scrollView = GlowingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        color: scrollSpec.overscrollColor ??
            Theme.of(context).colorScheme.secondary,
        child: scrollView,
      );
    }

    return scrollView;
  }

  Widget _buildBody() {
    final spec = widget.parallaxSpec;

    if (spec == null || !spec.enabled || spec.amount <= 0.0) {
      return widget.body ?? const SizedBox();
    }

    // ignore: arguments-ordering
    return ValueListenableBuilder(
      valueListenable: extent!._currentExtent,
      // Explanation: The 'child' property is placed before 'builder' for
      // readability and logical grouping of related properties.
      // ignore: sort_child_properties_last
      child: widget.body,
      builder: (context, dynamic _, body) {
        final amount = spec.amount;
        final defaultMaxExtent = snappings.length > 2
            ? snappings[snappings.length - 2]
            : this.maxExtent;
        final maxExtent = spec.endExtent != null
            ? _normalizeSnap(spec.endExtent!)
            : defaultMaxExtent;
        assert(
          maxExtent > minExtent,
          'The endExtent must be greater than the min snap extent you set on '
          'the SnapSpec',
        );
        final maxOffset = (maxExtent - minExtent) * availableHeight;
        final num fraction =
            ((currentExtent - minExtent) / (maxExtent - minExtent))
                .clamp(0.0, 1.0);

        return Padding(
          padding: EdgeInsets.only(bottom: (amount * maxOffset) * fraction),
          child: body,
        );
      },
    );
  }

  Widget _buildBackdrop() {
    return ValueListenableBuilder(
      valueListenable: extent!._currentExtent,
      builder: (context, dynamic value, child) {
        final opacity = () {
          if (!widget.isDismissable &&
              !dismissUnderway &&
              didCompleteInitialRoute) {
            return 1.0;
          } else if (currentExtent != 0.0) {
            if (isDialog) {
              return (currentExtent / minExtent).clamp(0.0, 1.0);
            } else {
              final secondarySnap =
                  snappings.length > 2 ? snappings[1] : maxExtent;
              return ((currentExtent - minExtent) / (secondarySnap - minExtent))
                  .clamp(0.0, 1.0);
            }
          } else {
            return 0.0;
          }
        }();

        final backDrop = IgnorePointer(
          ignoring: opacity < 0.05,
          child: Opacity(
            opacity: opacity,
            child: Container(
              color: widget.backdropColor,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        );

        void onTap() => widget.isDismissable
            ? _pop(velocity: 0, isBackDrop: true, isBackButton: false)
            : _onDismissPrevented(backDrop: true);

        // see: https://github.com/BendixMa/sliding-sheet/issues/30
        if (opacity >= 0.05 || didStartDragWhenNotCollapsed) {
          if (widget.isBackdropInteractable) {
            return _delegateInteractions(
              backDrop,
              onTap: widget.closeOnBackdropTap ? onTap : null,
            );
          } else if (widget.closeOnBackdropTap) {
            // ignore: arguments-ordering
            return GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.translucent,
              child: backDrop,
            );
          }
        }

        return backDrop;
      },
    );
  }

  Widget _delegateInteractions(Widget child, {VoidCallback? onTap}) {
    var start = 0.0;
    var end = 0.0;

    void onDragEnd([double velocity = 0.0]) {
      controller.delegateFling(velocity);

      // If a header was dragged, but the scroll view is not at the top
      // animate to the top when the drag has ended.
      if (!state.isAtTop && (start - end).abs() > 15.0) {
        controller.animateTo(
          0,
          duration: widget.openDuration * 0.5,
          curve: Curves.ease,
        );
      }

      _handleNonDismissableSnapBack();
    }

    // ignore: arguments-ordering
    return GestureDetector(
      onTap: onTap,
      onVerticalDragStart: (details) {
        start = details.localPosition.dy;
        end = start;
        didStartDragWhenNotCollapsed = currentExtent > snappings.first;
      },
      onVerticalDragUpdate: (details) {
        end = details.localPosition.dy;
        final delta = details.delta.dy;

        // Do not delegate upward drag when the sheet is fully expanded
        // because headers or backdrops should not be able to scroll the
        // sheet, only to drag it between min and max extent.
        final shouldDelegate = !delta.isNegative || currentExtent < maxExtent;
        if (shouldDelegate) {
          controller.delegateDrag(delta);
        }
      },
      onVerticalDragEnd: (details) {
        final deltaY = details.velocity.pixelsPerSecond.dy;
        final velocity = swapSign(deltaY);

        final shouldDelegate = !deltaY.isNegative || currentExtent < maxExtent;
        if (shouldDelegate) {
          onDragEnd(velocity);
        }

        setState(() => didStartDragWhenNotCollapsed = false);
      },
      onVerticalDragCancel: onDragEnd,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }

  @override
  void didUpdateWidget(SlidingSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    _assignSheetController();

    // Animate to the next snap if the SnapSpec changed and the sheet
    // is currently not interacted with.
    if (oldWidget.snapSpec != snapSpec) {
      _updateSnappingsAndExtent();
      _nudgeToNextSnap();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = LayoutBuilder(
      builder: (context, constrainst) {
        _measure();

        final previousHeight = availableHeight;
        availableHeight = constrainst.biggest.height;
        _adjustSnapForIncomingConstraints(previousHeight);

        final sheet = NotificationListener<SizeChangedLayoutNotification>(
          child: Stack(children: <Widget>[_buildBackdrop(), _buildSheet()]),
          onNotification: (notification) {
            _measure();
            return true;
          },
        );

        return widget.body == null
            ? sheet
            : Stack(
                children: <Widget>[
                  _buildBody(),
                  sheet,
                ],
              );
      },
    );

    result = _InheritedSheetState(stateNotifier, result);

    if (!widget.closeSheetOnBackButtonPressed && !isDialog) {
      return result;
    }

    return PopScope(
      canPop: state.isCollapsed && widget.isDismissable,
      onPopInvokedWithResult: (_, __) {
        if (isDialog) {
          if (!widget.isDismissable) {
            _onDismissPrevented(backButton: true);
          }
        } else {
          if (!state.isCollapsed) {
            if (widget.onDismissPrevented != null) {
              _onDismissPrevented(backButton: true);
            } else {
              _pop(velocity: 0, isBackDrop: false, isBackButton: true);
            }
          }
        }
      },
      child: result,
    );
  }
}

class _InheritedSheetState extends InheritedWidget {
  final ValueNotifier<SheetState> state;

  const _InheritedSheetState(
    this.state,
    Widget child,
  ) : super(child: child);

  @override
  bool updateShouldNotify(_InheritedSheetState oldWidget) =>
      state != oldWidget.state;
}
