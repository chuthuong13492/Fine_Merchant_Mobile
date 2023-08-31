import 'package:flutter/material.dart';

class TouchOpacity extends StatefulWidget {
  final Function onTap;
  final Widget child;
  final double activeOpacity;

  const TouchOpacity(
      {Key? key,
      required this.onTap,
      required this.child,
      this.activeOpacity = 0.5})
      : super(key: key);
  @override
  TouchOpacityState createState() {
    return TouchOpacityState();
  }
}

class TouchOpacityState extends State<TouchOpacity> {
  bool isTappedDown = false;

  @override
  Widget build(BuildContext context) {
    var onTap = this.widget.onTap;
    var activeOpacity = this.widget.activeOpacity;
    return Listener(
      onPointerDown: (_) => setState(() => isTappedDown = true),
      onPointerUp: (_) => setState(() => isTappedDown = false),
      child: GestureDetector(
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 300),
          opacity: isTappedDown ? activeOpacity : 1,
          child: this.widget.child,
        ),
      ),
    );
  }
}
