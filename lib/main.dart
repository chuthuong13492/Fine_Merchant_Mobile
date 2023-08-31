import 'dart:async';
import 'dart:io';

import 'package:fine_merchant_mobile/Accessories/theme_data.dart';
import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Utils/pageNavigation.dart';
import 'package:fine_merchant_mobile/Utils/request.dart';
import 'package:fine_merchant_mobile/View/nav_screen.dart';
import 'package:fine_merchant_mobile/View/notFoundScreen.dart';
import 'package:fine_merchant_mobile/View/onboard.dart';
import 'package:fine_merchant_mobile/View/sign_in.dart';
import 'package:fine_merchant_mobile/View/start_up.dart';
import 'package:fine_merchant_mobile/View/welcome_screen.dart';
import 'package:fine_merchant_mobile/setup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (!GetPlatform.isWeb) {
  //   HttpOverrides.global = MyHttpOverrides();
  // }
  HttpOverrides.global = MyHttpOverrides();

  await setup();
  createRouteBindings();
  // Timer.periodic(const Duration(milliseconds: 500), (_) {
  //   Get.find<RootViewModel>().liveLocation();
  // });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
      title: 'Fine Delivery',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RouteHandler.WELCOME_SCREEN:
            return ScaleRoute(page: const WelcomeScreen());
          case RouteHandler.LOGIN:
            return CupertinoPageRoute(
                builder: (context) => const SignIn(), settings: settings);
          case RouteHandler.ONBOARD:
            return ScaleRoute(page: const OnBoardScreen());
          case RouteHandler.LOADING:
            return CupertinoPageRoute<bool>(
                builder: (context) => LoadingScreen(
                      title: settings.arguments as String ?? "Đang xử lý...",
                    ),
                settings: settings);

          case RouteHandler.NAV:
            return CupertinoPageRoute(
                builder: (context) => RootScreen(
                      initScreenIndex: settings.arguments as int ?? 0,
                    ),
                settings: settings);
          default:
            return CupertinoPageRoute(
                builder: (context) => const NotFoundScreen(),
                settings: settings);
        }
      },
      theme: CustomTheme.lightTheme,
      home: const StartUpView(),
    );
  }
}
