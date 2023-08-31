// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:fine_merchant_mobile/Accessories/dialog.dart';
import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DAO/AccountDAO.dart';
import 'package:fine_merchant_mobile/Model/DTO/AccountDTO.dart';
import 'package:fine_merchant_mobile/Service/analytic_service.dart';
import 'package:fine_merchant_mobile/ViewModel/base_model.dart';
import 'package:fine_merchant_mobile/ViewModel/root_viewModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginViewModel extends BaseModel {
  AccountDAO? _dao;
  late String verificationId;
  late AnalyticsService _analyticsService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AccountDTO? userInfo;

  LoginViewModel() {
    _dao = AccountDAO();
    _analyticsService = AnalyticsService.getInstance()!;
  }

  Future<void> signInWithGoogle() async {
    try {
      setState(ViewStatus.Loading);

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        await _auth.signInWithCredential(credential);

        User userToken = FirebaseAuth.instance.currentUser!;
        final idToken = await userToken.getIdToken();
        final fcmToken = await FirebaseMessaging.instance.getToken();
        // print('idToken: ' + idToken);
        log('idToken: ' + idToken!);
        log('fcmToken: ' + fcmToken.toString());

        userInfo = await _dao?.login(idToken, fcmToken!);
        if (userInfo == null) {
          await showStatusDialog("assets/images/error.png", 'Éc éc ⚠️',
              'Bạn vui lòng đăng nhập bằng mail trường nhé 🥰');
        } else {
          showLoadingDialog();
          await _analyticsService.setUserProperties(userInfo!);
          await Get.find<RootViewModel>().startUp();
          // Get.rawSnackbar(
          //     message: "Đăng nhập thành công!!",
          //     duration: Duration(seconds: 2),
          //     snackPosition: SnackPosition.BOTTOM,
          //     margin: EdgeInsets.only(left: 8, right: 8, bottom: 32),
          //     borderRadius: 8);
          hideDialog();
          await Get.offAllNamed(RouteHandler.NAV);
        }
        // AccountViewModel accountViewModel = Get.find<AccountViewModel>();
        // accountViewModel.currentUser = userInfo;

        // if (userInfo != null) {

        // }
        // await Get.offAllNamed(RoutHandler.NAV);
      }
      await Future.delayed(const Duration(microseconds: 500));
      setState(ViewStatus.Completed);
    } on FirebaseAuthException catch (e) {
      log(e.message!);
      // });
      setState(ViewStatus.Completed);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Get.offAllNamed(RouteHandler.LOGIN);
  }
}
