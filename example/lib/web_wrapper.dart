import 'package:flutter/material.dart';

class WebWrapper extends StatelessWidget {
  final Widget app;

  const WebWrapper({
    required this.app,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isAppInfoShown = constraints.maxWidth > 1250;
        final isPhoneWrapperShown =
            constraints.maxWidth > 500 && constraints.maxHeight > 600;
        return isPhoneWrapperShown
            ? Container(
                padding: const EdgeInsets.all(40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue,
                      Color.fromARGB(255, 136, 9, 187),
                    ],
                  ),
                ),
                child: Row(
                  textDirection: TextDirection.ltr,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _PhoneWrapper(
                      height: 800,
                      width: 400,
                      outerRadius: 60,
                      borderWidth: 16,
                      child: app,
                    ),
                    if (isAppInfoShown)
                      const _AppInfo(
                        title: 'WTF Sliding Sheet',
                        content: 'This Flutter package is a widget that can be '
                            'dragged and scrolled in a single gesture and '
                            'snapped to a list of extents.',
                      ),
                  ],
                ),
              )
            : app;
      },
    );
  }
}

class _PhoneWrapper extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  final double outerRadius;
  final double borderWidth;

  const _PhoneWrapper({
    required this.child,
    required this.height,
    required this.width,
    required this.outerRadius,
    required this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          outerRadius,
        ),
        border: Border.all(
          width: borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          outerRadius - borderWidth,
        ),
        child: child,
      ),
    );
  }
}

class _AppInfo extends StatelessWidget {
  final String title;
  final String content;

  const _AppInfo({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 700,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 70,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              content,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
