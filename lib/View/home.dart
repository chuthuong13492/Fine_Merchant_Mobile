// ignore_for_file: avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/home_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/orderList_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/root_viewModel.dart';
import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:fine_merchant_mobile/widgets/fixed_app_bar.dart';
import 'package:fine_merchant_mobile/widgets/shimmer_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final double HEIGHT = 48;
  final ValueNotifier<double> notifier = ValueNotifier(0);
  final PageController controller = PageController();
  Future<void> _refresh() async {
    await Get.find<RootViewModel>().startUp();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: FineTheme.palettes.shades100,
      body: SafeArea(
        // ignore: sized_box_for_whitespace
        child: Container(
          // color: FineTheme.palettes.primary100,
          height: Get.height,
          child: ScopedModel(
            model: Get.find<HomeViewModel>(),
            child: Stack(
              children: [
                Column(
                  children: [
                    FixedAppBar(
                      // notifier: notifier,
                      height: HEIGHT,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(top: 0),
                        child: RefreshIndicator(
                          key: _refreshIndicatorKey,
                          onRefresh: _refresh,
                          child: ScopedModelDescendant<HomeViewModel>(
                              builder: (context, child, model) {
                            if (model.status == ViewStatus.Error) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Center(
                                    child: Text(
                                      "Fine đã cố gắng hết sức ..\nNhưng vẫn bị con quỷ Bug đánh bại.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // ignore: sized_box_for_whitespace
                                  Container(
                                    width: 300,
                                    height: 300,
                                    child: Image.asset(
                                      'assets/images/error.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Center(
                                    child: Text(
                                      "Bạn vui lòng thử một số cách sau nhé!",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Center(
                                    child: Text(
                                      "1. Tắt ứng dụng và mở lại",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Center(
                                    child: InkWell(
                                      child: Text(
                                        "2. Đặt hàng qua Fanpage ",
                                        textAlign: TextAlign.center,
                                      ),
                                      // onTap: () =>
                                      //     launch('fb://page/103238875095890'),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Container(
                                // color: FineTheme.palettes.neutral200,
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: (n) {
                                    if (n.metrics.pixels <= HEIGHT) {
                                      notifier.value = n.metrics.pixels;
                                    }
                                    return false;
                                  },
                                  child: SingleChildScrollView(
                                    child: Column(
                                      // addAutomaticKeepAlives: true,
                                      children: [
                                        ...renderHomeSections().toList(),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                // Positioned(
                //   left: 0,
                //   bottom: 0,
                //   child: buildNewOrder(),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> renderHomeSections() {
    var currentUser = Get.find<AccountViewModel>().currentUser;

    return [
      // banner(),
      const SizedBox(height: 18),
      buildWelcomeSection(),
      buildStatisticSection(),
      const SizedBox(height: 18),
      Image(
        image: AssetImage(currentUser?.roleType == 2
            ? "assets/images/check_task.png"
            : "assets/images/shipper.png"),
        width: 350,
        height: 350,
      )
    ];
  }

  Widget buildWelcomeSection() {
    var currentUser = Get.find<AccountViewModel>().currentUser;

    return ScopedModel(
        model: Get.find<HomeViewModel>(),
        child: ScopedModelDescendant<HomeViewModel>(
          builder: (context, child, model) {
            ViewStatus status = model.status;
            if (status == ViewStatus.Loading) {
              return const SizedBox.shrink();
            }
            return InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                color: FineTheme.palettes.primary50,
                height: 78,
                width: Get.width,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.only(top: 17, bottom: 17),
                  color: FineTheme.palettes.primary100,
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Xin chào ${currentUser?.name}, một ngày làm việc vui vẻ!",
                          style: FineTheme.typograhpy.subtitle2
                              .copyWith(color: FineTheme.palettes.shades100),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }

  Widget buildStatisticSection() {
    var currentUser = Get.find<AccountViewModel>().currentUser;
    var currentOrderList = Get.find<OrderListViewModel>().orderList;
    return ScopedModel(
        model: Get.find<HomeViewModel>(),
        child: ScopedModelDescendant<HomeViewModel>(
          builder: (context, child, model) {
            ViewStatus status = model.status;
            if (status == ViewStatus.Loading) {
              return const SizedBox.shrink();
            }
            return InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                color: FineTheme.palettes.emerald100,
                height: 200,
                width: Get.width,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.only(top: 17, bottom: 17),
                  color: FineTheme.palettes.neutral200,
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tình hình hôm nay",
                              style: FineTheme.typograhpy.h2.copyWith(
                                  color: FineTheme.palettes.neutral900),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/icons/box_icon.png",
                              width: 20,
                              height: 16,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              "Đang có",
                              style: FineTheme.typograhpy.subtitle2.copyWith(
                                  color: FineTheme.palettes.neutral900),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              "${currentOrderList.length} đơn",
                              style: FineTheme.typograhpy.subtitle2.copyWith(
                                  color: FineTheme.palettes.emerald25),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              "đang chờ bạn ${currentUser?.roleType == 2 ? 'duyệt' : 'giao'} đó!",
                              style: FineTheme.typograhpy.subtitle2.copyWith(
                                  color: FineTheme.palettes.neutral900),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }

  void _onTapOrderHistory(order) async {
    // get orderDetail
    // await Get.find<OrderHistoryViewModel>().getOrders();
    // await Get.toNamed(RouteHandler.ORDER_HISTORY_DETAIL, arguments: order);
  }
}
