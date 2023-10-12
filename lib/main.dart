import 'dart:async';
import 'dart:io';

import 'package:fine_merchant_mobile/Accessories/theme_data.dart';
import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Model/DTO/AccountDTO.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:fine_merchant_mobile/Utils/pageNavigation.dart';
import 'package:fine_merchant_mobile/Utils/request.dart';
import 'package:fine_merchant_mobile/View/productBoxes_screen.dart.dart';
import 'package:fine_merchant_mobile/View/stationPackage_list.dart';
import 'package:fine_merchant_mobile/View/nav_screen.dart';
import 'package:fine_merchant_mobile/View/notFoundScreen.dart';
import 'package:fine_merchant_mobile/View/onboard.dart';
import 'package:fine_merchant_mobile/View/order_list.dart';
import 'package:fine_merchant_mobile/View/packageDetail_screen.dart';
import 'package:fine_merchant_mobile/View/profile.dart';
import 'package:fine_merchant_mobile/View/qr_screen.dart';
import 'package:fine_merchant_mobile/View/sign_in.dart';
import 'package:fine_merchant_mobile/View/start_up.dart';
import 'package:fine_merchant_mobile/View/station.dart';
import 'package:fine_merchant_mobile/View/welcome_screen.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
      title: 'Fine Merchant',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RouteHandler.WELCOME_SCREEN:
            return ScaleRoute(page: const WelcomeScreen());
          case RouteHandler.LOGIN:
            return CupertinoPageRoute(
                builder: (context) => loginWithAccount(), settings: settings);
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
                      initScreenIndex: settings.arguments != null
                          ? settings.arguments as int
                          : 0,
                    ),
                settings: settings);
          case RouteHandler.PROFILE:
            return CupertinoPageRoute(
                builder: (context) => const ProfileScreen(),
                settings: settings);
          case RouteHandler.ORDER_LIST:
            return CupertinoPageRoute(
                builder: (context) => const OrderListScreen(),
                settings: settings);
          case RouteHandler.REPORT_LIST:
            return CupertinoPageRoute(
                builder: (context) => const StationPackagesScreen(),
                settings: settings);
          case RouteHandler.STATION_SCREEN:
            return CupertinoPageRoute(
                builder: (context) =>
                    StationScreen(isRouted: settings.arguments as bool),
                settings: settings);
          case RouteHandler.QRCODE_SCREEN:
            return CupertinoPageRoute<bool>(
                builder: (context) => QRCodeScreen(
                    orderBox: settings.arguments as ShipperOrderBoxDTO),
                settings: settings);
          case RouteHandler.PACKAGE_DETAIL:
            return CupertinoPageRoute<bool>(
                builder: (context) => const PackageDetailScreen(),
                settings: settings);
          case RouteHandler.PRODUCT_BOXES_SCREEN:
            return CupertinoPageRoute<bool>(
                builder: (context) => ProductBoxesScreen(
                    detail: settings.arguments as OrderDetail),
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
