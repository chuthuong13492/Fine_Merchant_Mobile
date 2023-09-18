// ignore_for_file: avoid_unnecessary_containers

import 'dart:async';

import 'package:fine_merchant_mobile/Accessories/index.dart';
import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/home_viewModel.dart';

import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';

import 'package:fine_merchant_mobile/widgets/skeleton_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final double HEIGHT = 48;
  late Timer periodicTimer;
  bool isDelivering = false;
  PackageViewDTO? currentPackage;
  HomeViewModel model = Get.put(HomeViewModel());
  final ValueNotifier<double> notifier = ValueNotifier(0);
  final PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    periodicTimer = Timer.periodic(const Duration(seconds: 60), (Timer timer) {
      refreshFetchData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    periodicTimer.cancel();
  }

  Future<void> refreshFetchData() async {
    await model.getSplitOrdersForDriver();
  }

  @override
  Widget build(BuildContext context) {
    TimeSlotDTO currentTimeSlot = model.timeSlotList
        .firstWhere((slot) => slot.id == model.selectedTimeSlotId);
    return ScopedModel(
      model: Get.find<HomeViewModel>(),
      child: Scaffold(
        appBar: DefaultAppBar(
            title: "Gói hàng ${model.isDelivering ? "Đang giao" : "Chờ giao"}",
            backButton: const SizedBox.shrink(),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: model.isDelivering
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        DropdownButton<String>(
                          value: model.selectedStationId,
                          onChanged: (String? value) {
                            model.onChangeStation(value!);
                            setState(() {});
                          },
                          items: model.stationList
                              .map<DropdownMenuItem<String>>(
                                  (StationDTO station) {
                            return DropdownMenuItem<String>(
                              value: station.id,
                              child: Text(
                                "${station.name}",
                                style: FineTheme.typograhpy.h2.copyWith(
                                  color: FineTheme.palettes.emerald25,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
            )),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Khung giờ:', style: FineTheme.typograhpy.h2),
                  DropdownButton<String>(
                    value: model.selectedTimeSlotId,
                    onChanged: (String? value) {
                      model.onChangeTimeSlot(value!);
                      setState(() {});
                    },
                    items: model.timeSlotList
                        .map<DropdownMenuItem<String>>((TimeSlotDTO timeSlot) {
                      return DropdownMenuItem<String>(
                        value: timeSlot.id,
                        child: Text(
                            '${timeSlot.arriveTime?.substring(0, 5)} - ${timeSlot.checkoutTime?.substring(0, 5)}',
                            style: FineTheme.typograhpy.body1),
                      );
                    }).toList(),
                  ),
                  // Text(
                  // '${currentTimeSlot.arriveTime?.substring(0, 5)} - ${currentTimeSlot.checkoutTime?.substring(0, 5)}',
                  // style: FineTheme.typograhpy.body1)
                ],
              ),
            ),
            Expanded(
              child: Container(
                // ignore: sort_child_properties_last
                child: _buildPackageList(),
                color: const Color(0xffefefef),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageInfo(
      String? stationName, TimeSlotDTO? timeSlot, String? storeName) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: Get.width,
      height: 180,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Text(
              'Thông tin:',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  color: FineTheme.palettes.shades200),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trạm:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      color: FineTheme.palettes.shades200),
                ),
                Text(
                  '$stationName',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vào lúc:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      color: FineTheme.palettes.shades200),
                ),
                Text(
                  '${timeSlot?.checkoutTime}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildPackageList() {
    return ScopedModelDescendant<HomeViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      List<PackageViewDTO> packageList = model.packageViewList;
      List<PackageViewDTO> deliveredPackageList = model.deliveredPackageList;
      bool isDelivering = model.isDelivering;
      PackageViewDTO? currentPackage = model.currentDeliveryPackage;
      if (status == ViewStatus.Loading) {
        return const Center(
          // child: SkeletonListItem(itemCount: 8),
          child: LoadingFine(),
        );
      } else if (status == ViewStatus.Empty || packageList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: InkWell(
                  onTap: () async {
                    showLoadingDialog();
                    await model.getSplitOrdersForDriver();
                    await model.getDeliveredOrdersForDriver();
                    hideDialog();
                  },
                  child: Icon(
                    Icons.replay,
                    color: FineTheme.palettes.primary300,
                    size: 26,
                  ),
                ),
              ),
              Text(
                'Hiện tại các món cần lấy ở ${model.stationList.firstWhere((station) => station.id == model.selectedStationId).name} đã hết!',
                style: FineTheme.typograhpy.body1,
              ),
              deliveredPackageList.isNotEmpty
                  ? Column(
                      children: [
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                            '${deliveredPackageList.length} gói hàng đã được lấy ở trạm này!',
                            style: FineTheme.typograhpy.body1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        // BorderRadius.only(
                                        //     bottomRight: Radius.circular(16),
                                        //     bottomLeft: Radius.circular(16))
                                        BorderRadius.all(Radius.circular(8))),
                              ),
                              onPressed: () {
                                _onTapDetail();
                                // setState(() {
                                //   isDelivering = !isDelivering;
                                // });
                              },
                              child: Text(
                                "Xem thông tin giao hàng!",
                                style: FineTheme.typograhpy.subtitle2.copyWith(
                                    color: FineTheme.palettes.emerald25),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : SizedBox.shrink(),
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
        onRefresh: refreshFetchData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: Get.find<HomeViewModel>().scrollController,
          padding: const EdgeInsets.all(8),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Center(
                //   child: Text(
                //       'Số gói hàng đã lấy: ${deliveredPackageList.length}/${packageList.length} ',
                //       style: FineTheme.typograhpy.h2.copyWith(
                //         color: FineTheme.palettes.emerald25,
                //       )),
                // ),
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
    return Column(
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
                          Text('Số món:',
                              style: FineTheme.typograhpy.body1.copyWith(
                                  color: FineTheme.palettes.neutral900,
                                  fontWeight: FontWeight.bold)),
                          OutlinedButton(
                            onPressed: () => {
                              currentPackage = package,
                              _dialogBuilder(context)
                            },
                            child: Text(
                              'Xem chi tiết (${package.listProducts?.length})',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  color: FineTheme.palettes.emerald25),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                    ],
                  )),
            )),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        // BorderRadius.only(
                        //     bottomRight: Radius.circular(16),
                        //     bottomLeft: Radius.circular(16))
                        BorderRadius.all(Radius.circular(8))),
              ),
              onPressed: () async {
                await model.confirmDelivery(package);
                await model.getDeliveredOrdersForDriver();
                setState(() {});
              },
              child: Text(
                "${"Đã lấy hàng"}",
                style: FineTheme.typograhpy.subtitle2
                    .copyWith(color: FineTheme.palettes.emerald25),
              ),
            ),
          ),
        )
      ],
    );
  }

  void _onTapDetail() async {
    // get orderDetail
    await model.getShipperOrderBoxes();
    await Get.toNamed(RouteHandler.PACKAGE_DETAIL);
    // model.getOrders();
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chi tiết gói hàng', style: FineTheme.typograhpy.h2),
          content: SizedBox(
              height: 180,
              width: 200,
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  ...?currentPackage?.listProducts
                      ?.map((product) => _buildPackageProducts(product)),
                ],
              )),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                'Đóng',
                style: FineTheme.typograhpy.body1
                    .copyWith(color: FineTheme.palettes.emerald25),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPackageProducts(ListProduct product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${product.productName}',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal),
          ),
          Text(
            'x ${product.quantity}',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal),
          ),
        ],
      ),
    );
  }

  Widget loadMoreIcon() {
    return ScopedModelDescendant<HomeViewModel>(
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
}
