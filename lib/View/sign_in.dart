// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers

import 'dart:ui';

import 'package:fine_merchant_mobile/ViewModel/login_viewModel.dart';
import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:scoped_model/scoped_model.dart';

class loginWithAccount extends StatefulWidget {
  loginWithAccount({Key? key}) : super(key: key);

  @override
  SignIn createState() => SignIn();
}

class SignIn extends State<loginWithAccount> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void submitForm() {
    var loginViewModel = Get.find<LoginViewModel>();
    String username = usernameController.text;
    String password = passwordController.text;
    loginViewModel.signInWithAccount(username, password);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ScopedModel(
      model: LoginViewModel(),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: screenHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/food2.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: screenHeight * 0.5,
                ),
                buildLoginButtons(screenHeight, context),
              ],
            ),
          )),
    );
  }

  Widget buildLoginButtons(double screenHeight, BuildContext context) {
    return ScopedModelDescendant<LoginViewModel>(
      builder: (context, child, model) {
        return Stack(
          children: [
            Container(
              height: screenHeight * 0.5,
              decoration: const BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(48),
                  topRight: Radius.circular(48),
                ),
              ),
              child: BackdropFilter(
                  filter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              )),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 8),
              height: screenHeight * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      'Vui lòng đăng nhập để tiếp tục',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.teal),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Tài khoản',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  InkWell(
                    onTap: () {
                      submitForm();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 56,
                      decoration: BoxDecoration(
                        color: FineTheme.palettes.shades100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Center(
                          //   child: Image.asset(
                          //     "assets/icons/google.png",
                          //     width: 32,
                          //     height: 32,
                          //   ),
                          // ),
                          // const SizedBox(
                          //   width: 8,
                          // ),
                          Center(
                            child: Text(
                              'Đăng nhập',
                              style: FineTheme.typograhpy.body1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       "Chưa có tài khoản?",
                  //       style: FineTheme.typograhpy.body2
                  //           .copyWith(color: Colors.white),
                  //     ),
                  //     const SizedBox(
                  //       width: 8,
                  //     ),
                  //     InkWell(
                  //       onTap: () {},
                  //       child: Text(
                  //         'Đăng ký ngay',
                  //         style: FineTheme.typograhpy.body1
                  //             .copyWith(color: Colors.white),
                  //       ),
                  //     )
                  //   ],
                  // ),
                  const SizedBox(
                    height: 24,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          "Bằng việc tiếp tục, bạn đã đồng ý với",
                          style: FineTheme.typograhpy.body2,
                        ),
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {},
                          child: Text(
                            // "Terms & Privacy Policy",
                            "Điều khoản và Chính sách",
                            style: FineTheme.typograhpy.buttonLg
                                .copyWith(color: Colors.black),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "của chúng tôi",
                          style: FineTheme.typograhpy.body2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
