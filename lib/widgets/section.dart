import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const Section({Key? key, required this.child, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white,
      child: child,
      padding: padding ?? EdgeInsets.all(8),
    );
  }
}
