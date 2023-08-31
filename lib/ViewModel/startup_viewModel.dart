import 'dart:async';

import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Model/DAO/AccountDAO.dart';
import 'package:fine_merchant_mobile/Utils/shared_pref.dart';
import 'package:fine_merchant_mobile/ViewModel/base_model.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'root_viewModel.dart';

class StartUpViewModel extends BaseModel {
  StartUpViewModel() {
    handleStartUpLogic();
  }
  Future handleStartUpLogic() async {
    AccountDAO _accountDAO = AccountDAO();
    await Future.delayed(const Duration(seconds: 3));
    var hasLoggedInUser = await _accountDAO.isUserLoggedIn();
    bool isFirstOnBoard = await getIsFirstOnboard() ?? true;
    if (isFirstOnBoard) {
      // await Get.find<RootViewModel>().startUp();
      Get.offAndToNamed(RouteHandler.ONBOARD);
    } else if (hasLoggedInUser) {
      await Get.find<RootViewModel>().startUp();
      Get.offAndToNamed(RouteHandler.NAV);
    } else {
      Get.offAndToNamed(RouteHandler.WELCOME_SCREEN);
    }
  }
}
