import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FineTheme.palettes.shades100,
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                "assets/images/Welcome-img.png",
                width: Get.width,
              )),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            width: Get.width,
            height: Get.height,
            child: Padding(
              padding: const EdgeInsets.only(top: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Chào mừng bạn đến với",
                      style: FineTheme.typograhpy.h1.copyWith(
                          color: FineTheme.palettes.primary100, fontSize: 30),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Fine Merchant",
                      style: FineTheme.typograhpy.h1.copyWith(
                          color: FineTheme.palettes.primary100, fontSize: 30),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              right: 0,
              child: Image.asset(
                "assets/images/Welcome-img2.png",
                width: 160,
              )),
          Positioned(
              bottom: 40,
              right: 18,
              child: InkWell(
                onTap: () {
                  Get.toNamed(RouteHandler.LOGIN);
                },
                child: Image.asset(
                  "assets/icons/icon_right.png",
                  width: 45,
                  height: 45,
                ),
              )),
        ],
      ),
    );
  }
}
