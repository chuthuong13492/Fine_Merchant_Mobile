import 'package:fine_merchant_mobile/Service/push_notification_service.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/deliveryList_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/home_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/login_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/orderList_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/root_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';
import 'package:fine_merchant_mobile/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

Future setup() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  PushNotificationService? ps = PushNotificationService.getInstance();
  await ps!.init();
}

void createRouteBindings() async {
  Get.put(RootViewModel());
  Get.put(HomeViewModel());
  Get.put(LoginViewModel());
  Get.put(AccountViewModel());
  Get.put(StationViewModel());
  Get.put(DeliveryListViewModel());
  Get.put(OrderListViewModel());
}
