import 'package:fine_merchant_mobile/Accessories/dialog.dart';
import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DAO/index.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:fine_merchant_mobile/Utils/shared_pref.dart';
import 'package:fine_merchant_mobile/ViewModel/base_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'root_viewModel.dart';

class AccountViewModel extends BaseModel {
  late AccountDAO _dao;
  late StoreDAO storeDAO;
  AccountDTO? currentUser;
  StoreDTO? currentStore;
  AccountViewModel() {
    _dao = AccountDAO();
    storeDAO = StoreDAO();
  }

  Future<void> fetchUser({bool isRefetch = false}) async {
    try {
      if (isRefetch) {
        setState(ViewStatus.Refreshing);
      } else if (status != ViewStatus.Loading) {
        setState(ViewStatus.Loading);
      }

      final user = await _dao.getUser();
      currentUser = user;
      var storeId = currentUser?.storeId;
      if (storeId != null) {
        final store = await storeDAO.getStoreById(storeId: storeId);
        currentStore = store;
      } else {
        final store = await storeDAO.getStoreById(
            storeId: "751a2190-d06c-4d5e-9c5a-08c33c3db266");
        currentStore = store;
      }
      setState(ViewStatus.Completed);
    } catch (e, stacktrace) {
      print(e.toString() + stacktrace.toString());
      currentUser = null;
      setState(ViewStatus.Error);
      // bool result = await showErrorDialog();
      // if (result) {
      //   await fetchUser();
      // } else {
      //   setState(ViewStatus.Error);
      // }
    }
  }

  Future<void> signOut() async {
    try {
      int option = await showOptionDialog("Bạn có chắc muốn đăng xuất?");
      if (option == 1) {
        showLoadingDialog();
        await _dao.logOut();
        await removeALL();
        // await FirebaseAuth.instance.signOut();
        // await GoogleSignIn().signOut();
        // Get.testMode = true;
        // if (Get.testMode == false) {
        //   // TestWidgetsFlutterBinding.ensureInitialized();
        //   Get.testMode = true;
        //   Get.testMode = true;
        //   Get.offAll(RoutHandler.LOGIN);
        // }
        // await Get.find<RootViewModel>().startUp();
        hideDialog();
        Get.toNamed(RouteHandler.LOGIN);
      }
    } catch (e) {
      print(e);
      // setState(ViewStatus.Error);
    }
  }
}
