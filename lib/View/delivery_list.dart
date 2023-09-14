import 'dart:async';

import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:fine_merchant_mobile/Utils/format_price.dart';
import 'package:fine_merchant_mobile/Utils/format_time.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/deliveryList_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/home_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/orderList_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/root_viewModel.dart';
import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:fine_merchant_mobile/widgets/cache_image.dart';
import 'package:fine_merchant_mobile/widgets/skeleton_list.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';
import '../Accessories/index.dart';

class DeliveryListScreen extends StatefulWidget {
  const DeliveryListScreen({super.key});

  @override
  State<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends State<DeliveryListScreen> {
  late Timer periodicTimer;
  bool isDelivering = false;
  DeliveryListViewModel model = Get.put(DeliveryListViewModel());
  AccountDTO? currentUser = Get.find<AccountViewModel>().currentUser;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    model.stationList = Get.find<HomeViewModel>().stationList;
    model.timeSlotList = Get.find<HomeViewModel>().timeSlotList;
    model.storeList = Get.find<HomeViewModel>().storeList;
    model.deliveredPackageList = Get.find<HomeViewModel>().deliveredPackageList;
  }

  Future<void> refreshFetchOrder() async {}

  @override
  Widget build(BuildContext context) {
    List<PackageViewDTO> deliveredPackageList = model.deliveredPackageList;
    String selectedStationId = Get.find<HomeViewModel>().selectedStationId;
    return ScopedModel(
      model: Get.find<DeliveryListViewModel>(),
      child: Scaffold(
        appBar: DefaultAppBar(
          title: "Gói hàng đã lấy",
          backButton: const SizedBox.shrink(),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Tại ${model.stationList.firstWhere((station) => station.id == selectedStationId).name}',
                  style: FineTheme.typograhpy.h2
                      .copyWith(color: FineTheme.palettes.emerald25),
                ),
              )),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // orderFilterSection(),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         'Danh sách gói hàng',
            //         style: FineTheme.typograhpy.h2.copyWith(
            //           color: FineTheme.palettes.emerald50,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Expanded(
              child: Container(
                // ignore: sort_child_properties_last
                child: _buildPackageList(),
                color: const Color(0xffefefef),
              ),
            ),
            deliveredPackageList.isNotEmpty
                ? Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FineTheme.palettes.emerald25,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  // BorderRadius.only(
                                  //     bottomRight: Radius.circular(16),
                                  //     bottomLeft: Radius.circular(16))
                                  BorderRadius.all(Radius.circular(8))),
                        ),
                        onPressed: () async {
                          await model.confirmAllBoxStored();

                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Text(
                            "Đã đặt đủ hàng vào tủ",
                            style: FineTheme.typograhpy.subtitle2
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

////////////////////
  Widget _buildPackageList() {
    return ScopedModelDescendant<DeliveryListViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      List<PackageViewDTO> packageList = model.deliveredPackageList;
      bool isDelivering = model.isDelivering;
      PackageViewDTO? currentPackage = model.currentDeliveryPackage;
      if (status == ViewStatus.Loading) {
        return const Center(
          child: SkeletonListItem(itemCount: 8),
        );
      } else if (status == ViewStatus.Empty || packageList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hiện tại chưa lấy gói hàng nào!'),
              Padding(
                padding: EdgeInsets.all(15),
                child: InkWell(
                  onTap: () async {
                    showLoadingDialog();
                    await Get.find<HomeViewModel>()
                        .getDeliveredOrdersForDriver();
                    hideDialog();
                  },
                  child: Icon(
                    Icons.replay,
                    color: FineTheme.palettes.primary300,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (status == ViewStatus.Error) {
        return Center(
          child: AspectRatio(
            aspectRatio: 1 / 4,
            child: Image.asset(
              'assets/images/error.png',
              width: 24,
            ),
          ),
        );
      }

      if (isDelivering && currentPackage != null) {
        return Column(
          children: [
            Center(
              child: _buildOrderPackage(currentPackage),
            ),
            Image.asset(
              "assets/images/package_delivery.png",
              width: 400,
              height: 400,
            ),
          ],
        );
      }

      return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: refreshFetchOrder,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: Get.find<DeliveryListViewModel>().scrollController,
          padding: const EdgeInsets.all(8),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ...packageList
                    .map((package) => _buildOrderPackage(package))
                    .toList(),
                loadMoreIcon(),
                const SizedBox(
                  height: 80,
                ),
              ],
            )
          ],
        ),
      );
    });
  }

//////////////////
  Widget loadMoreIcon() {
    return ScopedModelDescendant<DeliveryListViewModel>(
      builder: (context, child, model) {
        switch (model.status) {
          case ViewStatus.LoadMore:
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildOrderPackage(PackageViewDTO package) {
    // final isToday = DateTime.parse(orderSummary.checkInDate!)
    //         .difference(DateTime.now())
    //         .inDays ==
    //     0;
    TimeSlotDTO? timeSlot = model.timeSlotList
        .firstWhere((timeSlot) => timeSlot.id == package.timeSlotId);
    String? storeName = model.storeList
        .firstWhere((store) => store.id == package.storeId)
        .storeName;
    return InkWell(
      onTap: () {
        _onTapDetail(package);
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${storeName}',
                    style: FineTheme.typograhpy.h2.copyWith(
                      color: FineTheme.palettes.emerald25,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
              // height: 80,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      // side: BorderSide(color: Colors.red),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Số lượng:',
                                style: FineTheme.typograhpy.body1.copyWith(
                                    color: FineTheme.palettes.neutral900,
                                    fontWeight: FontWeight.bold)),
                            Text('${package.listProducts?.length} món',
                                style: FineTheme.typograhpy.body1),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Vào lúc:',
                                style: FineTheme.typograhpy.body1.copyWith(
                                    color: FineTheme.palettes.neutral900,
                                    fontWeight: FontWeight.bold)),
                            Text('${timeSlot.checkoutTime}',
                                style: FineTheme.typograhpy.body1),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Text("Chi tiết",
                            style:
                                TextStyle(color: FineTheme.palettes.emerald25)),
                      ],
                    )),
              )),
        ],
      ),
    );
  }

  void _onTapDetail(PackageViewDTO package) async {
    // get orderDetail
    await Get.toNamed(RouteHandler.PACKAGE_DETAIL, arguments: package);
    // model.getOrders();
  }
}
