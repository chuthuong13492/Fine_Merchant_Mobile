import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Model/DAO/AccountDAO.dart';
import 'package:fine_merchant_mobile/Utils/shared_pref.dart';
import 'package:fine_merchant_mobile/ViewModel/root_viewModel.dart';
import 'package:fine_merchant_mobile/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OnBoardScreenState createState() => _OnBoardScreenState();
}

PageDecoration pageDecoration = const PageDecoration(
  titleTextStyle: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
  bodyTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
  // descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
  bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
  imagePadding: EdgeInsets.zero,
);

class _OnBoardScreenState extends State<OnBoardScreen> {
  @override
  Widget build(BuildContext context) {
    final pages = [
      PageViewModel(
        title: "Chọn món từ nhiều cửa hàng",
        body:
            "Đặt được nhiều đơn hàng từ nhiều cửa hàng khác nhau mà chi phí lại rẻ đến bất ngờ.",
        image: _buildImage('onboard-welcome-bg.png'),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: "Ăn đúng bữa",
        body:
            "Đặt hàng theo khung giờ và Bean sẽ nhắc bạn ăn cơm đúng bữa để tránh chiếc bụng đói.",
        image: _buildImage('onboard-earn-points-bg.png'),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: "Tích thật nhiều điểm",
        body: "Tích góp thật nhiều điểm và đổi được những phần quà hay ho nhá.",
        image: _buildImage('onboard_rewards_bg.png'),
        decoration: pageDecoration,
      ),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: IntroductionScreen(
          globalBackgroundColor: Colors.white,
          pages: pages,
          onDone: () => _onIntroEnd(),
          onSkip: () => _onIntroEnd(), // You can override onSkip callback
          showSkipButton: true,
          next: const Icon(
            Icons.arrow_forward,
            color: primary,
          ),
          skip: const Text(
            'Bỏ qua',
            style: TextStyle(
                fontSize: 24.0, fontWeight: FontWeight.bold, color: primary),
          ),
          done: const Text('Xong',
              style: TextStyle(
                  fontSize: 24.0, fontWeight: FontWeight.bold, color: primary)),
          dotsDecorator: const DotsDecorator(
            size: Size(10.0, 10.0),
            color: Colors.grey,
            activeColor: primary,
            activeSize: Size(22.0, 10.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
        ),
      ),
    );
  }

  void _onIntroEnd() async {
    // set pref that first onboard is false
    AccountDAO _accountDAO = AccountDAO();
    var hasLoggedInUser = await _accountDAO.isUserLoggedIn();
    await setIsFirstOnboard(false);
    if (hasLoggedInUser) {
      await Get.find<RootViewModel>().startUp();
      Get.offAndToNamed(RouteHandler.NAV);
    } else {
      Get.offAndToNamed(RouteHandler.WELCOME_SCREEN);
    }
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/images/$assetName', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }
}
