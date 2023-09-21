import 'package:fine_merchant_mobile/ViewModel/startup_viewModel.dart';
import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../Accessories/index.dart';

class StartUpView extends StatelessWidget {
  const StartUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<StartUpViewModel>(
      model: StartUpViewModel(),
      child: ScopedModelDescendant<StartUpViewModel>(
          builder: (context, child, model) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Center(
                child: Container(
                  width: 250.0,
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "FINE",
                          style: FineTheme.typograhpy.h1
                              .copyWith(color: FineTheme.palettes.primary100),
                        ),
                        const SizedBox(height: 16),
                        const LoadingFine(),
                      ],
                    ),
                  ),
                ),
              ),
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: Padding(
              //     padding: const EdgeInsets.all(16.0),
              //     child: Text(
              //       'Đặt ngay chờ chi 😎',
              //       style: FineTheme.typograhpy.buttonLg
              //           .copyWith(color: Colors.black),
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      }),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  final String? title;
  const LoadingScreen({Key? key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // width: 250.0,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LoadingFine(),
              const SizedBox(height: 16),
              Text(
                this.title!,
                style: FineTheme.typograhpy.h1,
              )
            ],
          ),
        ),
      ),
    );
  }
}
