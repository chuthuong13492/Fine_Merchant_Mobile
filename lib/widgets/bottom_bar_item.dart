import 'package:fine_merchant_mobile/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomBarItem extends StatelessWidget {
  const BottomBarItem(
    this.activeIcon,
    this.icon, {
    this.onTap,
    this.color = primary,
    this.activeColor = primary,
    this.isActive = false,
    this.isNotified = false,
  });
  final String icon;
  final String activeIcon;
  final Color color;
  final Color activeColor;
  final bool isNotified;
  final bool isActive;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: EdgeInsets.all(7),
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(32),
        //   color: bottomBarColor,
        //   // boxShadow: [
        //   //   if (isActive)
        //   //     BoxShadow(
        //   //       color: shadowColor.withOpacity(0.2),
        //   //       spreadRadius: 2,
        //   //       blurRadius: 2,
        //   //       offset: Offset(0, 0), // changes position of shadow
        //   //     ),
        //   // ],
        // ),
        child: SvgPicture.asset(
          isActive ? activeIcon : icon,
          color: isActive ? activeColor : color,
          width: 48,
          height: 48,
        ),
      ),
    );
  }
}
