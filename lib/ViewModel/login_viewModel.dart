// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fine_merchant_mobile/Accessories/dialog.dart';
import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DAO/index.dart';
import 'package:fine_merchant_mobile/Model/DTO/AccountDTO.dart';
import 'package:fine_merchant_mobile/Service/analytic_service.dart';
import 'package:fine_merchant_mobile/ViewModel/base_model.dart';
import 'package:fine_merchant_mobile/ViewModel/root_viewModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class LoginViewModel extends BaseModel {
  AccountDAO? _dao;
  UtilsDAO? _utilsDAO;
  late String verificationId;
  late AnalyticsService _analyticsService;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  LoginViewModel() {
    _dao = AccountDAO();
    _utilsDAO = UtilsDAO();
    _analyticsService = AnalyticsService.getInstance()!;
  }

  Future<void> signInWithFireBase(String email, String password) async {
    try {
      setState(ViewStatus.Loading);

      final user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: email);
      await FirebaseAuth.instance.signInWithCredential(user.credential!);

      User userToken = FirebaseAuth.instance.currentUser!;
      final idToken = await userToken.getIdToken();
      final fcmToken = await FirebaseMessaging.instance.getToken();
      // print('idToken: ' + idToken);

      // userInfo = await _dao?.isUserLoggedIn(idToken, fcmToken!);
      // if (userInfo == null) {
      //   await showStatusDialog("assets/images/error.png", 'Éc éc ⚠️',
      //       'Bạn vui lòng đăng nhập bằng mail trường nhé 🥰');
      // } else {
      //   showLoadingDialog();
      //   await _analyticsService.setUserProperties(userInfo!);
      //   await Get.find<RootViewModel>().startUp();
      //   Get.rawSnackbar(
      //       message: "Đăng nhập thành công!!",
      //       duration: Duration(seconds: 2),
      //       snackPosition: SnackPosition.BOTTOM,
      //       margin: EdgeInsets.only(left: 8, right: 8, bottom: 32),
      //       borderRadius: 8);
      //   hideDialog();
      //   await Get.offAllNamed(RouteHandler.NAV);
      // }
      // AccountViewModel accountViewModel = Get.find<AccountViewModel>();
      // accountViewModel.currentUser = userInfo;
      await Future.delayed(const Duration(microseconds: 500));
      // await Get.find<RootViewModel>().startUp();
      // await Get.offAllNamed(RouteHandler.NAV);
      // print(user);
      setState(ViewStatus.Completed);
    } on FirebaseAuthException catch (e) {
      log(e.message!);
      // });
      setState(ViewStatus.Completed);
    }
  }

  Future<void> signInWithAccount(String userName, String password) async {
    try {
      setState(ViewStatus.Loading);

      if (userName != '' && password != '') {
        showLoadingDialog();
        var accessToken = await _dao?.loginByAccount(userName, password);
        if (accessToken == null) {
          await showStatusDialog("assets/images/error.png", '⚠️',
              'Sai tài khoản hoặc mật khẩu, bạn vui lòng kiểm tra lại!');
        } else {
          Get.rawSnackbar(
              message: "Đăng nhập thành công!!",
              duration: Duration(seconds: 2),
              snackPosition: SnackPosition.BOTTOM,
              margin: EdgeInsets.only(left: 8, right: 8, bottom: 32),
              borderRadius: 8);
          await Get.find<RootViewModel>().startUp();
          await Get.offAllNamed(RouteHandler.NAV);
        }
      } else {
        Get.rawSnackbar(
            message: "Vui lòng nhập tài khoản và mật khẩu!!",
            duration: Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
            margin: EdgeInsets.only(left: 8, right: 8, bottom: 32),
            borderRadius: 8);
      }
    } on DioException catch (e) {
      log('error: ${e.toString()}');

      if (e.response != null && e.response?.statusCode != null) {
        String messageBody =
            "${DateFormat.yMd().add_jm().format(DateTime.now())} | $e${e.response!.data}";
        print(messageBody);
        if (e.response!.statusCode! < 400 || e.response!.statusCode! > 405) {
          await _utilsDAO?.logError(messageBody: messageBody);
        }
      }
      await showStatusDialog("assets/images/error.png", '⚠️',
          'Có lỗi xảy ra, vui lòng thử lại sau!');
    } finally {
      hideDialog();
      setState(ViewStatus.Completed);
    }
  }

  Future<void> signOut() async {
    // await FirebaseAuth.instance.signOut();
    // await GoogleSignIn().signOut();
    // Get.offAllNamed(RouteHandler.LOGIN);
  }
}
