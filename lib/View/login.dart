import 'dart:ui';

import 'package:fine_merchant_mobile/Model/DAO/index.dart';
import 'package:fine_merchant_mobile/ViewModel/login_viewModel.dart';
import 'package:fine_merchant_mobile/theme/color.dart';
import 'package:fine_merchant_mobile/widgets/custom_image2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isObscureText = true;
  bool isLoading = false;
  AccountDAO? dao;
  String error = '';
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: LoginViewModel(),
      child: Scaffold(
        body: getBody(),
      ),
    );
  }

  getBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.fromLTRB(0, 150, 0, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              width: 180,
              height: 180,
              child: const CustomImage2(
                "https://cdn-icons-png.flaticon.com/512/3820/3820331.png",
                bgColor: appBgColor,
                isSVG: false,
                radius: 5,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Center(
            child: Text(
              "Fine Delivery",
              style: TextStyle(color: secondary, fontSize: 28),
            ),
          ),
          const SizedBox(
            height: 28,
          ),
          ScopedModelDescendant<LoginViewModel>(
              builder: (context, child, model) {
            return Container(
              height: 30,
              padding: EdgeInsets.all(8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? Container(
                        color: Colors.grey[200],
                        height: 60,
                        width: 240,
                      )
                    : const SizedBox(
                        width: 240,
                        height: 60,
                        // child: SignInButton(
                        //   Buttons.Google,
                        //   onPressed: () {
                        //     model.signInWithGoogle();
                        //   },
                        // ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
