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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey1 =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey2 =
      new GlobalKey<RefreshIndicatorState>();
  final double HEIGHT = 48;
  late Timer periodicTimer;
  bool isDelivering = false;
  DeliveryPackageDTO? currentPackage;
  HomeViewModel model = Get.put(HomeViewModel());
  final ValueNotifier<double> notifier = ValueNotifier(0);
  final PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    periodicTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      refreshFetchData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    periodicTimer.cancel();
  }

  Future<void> refreshFetchData() async {
    await model.getStationList();
    await model.getTimeSlotList();
    await model.getDeliveryPackageListForDriver();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    StationDTO? station;
    var stationList = model.stationList;
    if (stationList != null && stationList.isNotEmpty) {
      station = stationList
          .firstWhereOrNull((station) => station.id == model.selectedStationId);
    }

    return ScopedModel(
      model: Get.find<HomeViewModel>(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: DefaultAppBar(
              title: "Gói hàng Chờ giao",
              backButton: const SizedBox.shrink(),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(120),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "${station != null ? station.name : ""}",
                      style: FineTheme.typograhpy.h2.copyWith(
                        color: FineTheme.palettes.emerald25,
                      ),
                    ),
                  ))),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              filterSection(),
              SizedBox(
                height: Get.height * 0.675,
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: Container(
                            // ignore: sort_child_properties_last
                            child: _buildPendingPackageList(),
                            color: const Color(0xffefefef),
                          ),
                        ),
                        const SizedBox(height: 64),
                      ],
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: Container(
                            // ignore: sort_child_properties_last
                            child: _buildReadyPackageList(),
                            color: const Color(0xffefefef),
                          ),
                        ),
                        const SizedBox(height: 64),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget filterSection() {
    // SplitOrderDTO? splitOrder = model.splitOrder;
    return ScopedModelDescendant<HomeViewModel>(
      builder: (context, child, model) {
        return Center(
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Khung giờ:', style: FineTheme.typograhpy.h2),
                        DropdownButton<String>(
                          value: model.selectedTimeSlotId,
                          onChanged: (String? value) async {
                            await model.onChangeTimeSlot(value!);
                            setState(() {});
                          },
                          items: model.timeSlotList
                              .map<DropdownMenuItem<String>>(
                                  (TimeSlotDTO timeSlot) {
                            return DropdownMenuItem<String>(
                              value: timeSlot.id,
                              child: Text(
                                  '${timeSlot.arriveTime?.substring(0, 5)} - ${timeSlot.checkoutTime?.substring(0, 5)}',
                                  style: FineTheme.typograhpy.body1),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TabBar(
                      indicatorColor: FineTheme.palettes.emerald25,
                      overlayColor: MaterialStateColor.resolveWith(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.focused)) {
                          return FineTheme.palettes.emerald25;
                        }
                        if (states.contains(MaterialState.error)) {
                          return Colors.red;
                        }
                        return FineTheme.palettes.emerald25;
                      }),
                      tabs: [
                        Stack(
                          children: [
                            model.notifierPending.value != null
                                ? Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Material(
                                      color: Colors.red,
                                      shape: const CircleBorder(
                                          side: BorderSide(
                                              color: Colors.red, width: 2)),
                                      child: SizedBox(
                                        width: model.notifierPending.value >= 10
                                            ? 24
                                            : 20,
                                        height:
                                            model.notifierPending.value >= 10
                                                ? 24
                                                : 20,
                                        child: Center(
                                          child: Text(
                                            '${model.notifierPending.value}',
                                            style: FineTheme
                                                .typograhpy.subtitle2
                                                .copyWith(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ))
                                : const SizedBox.shrink(),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 18, bottom: 12, right: 18),
                              child: Text("Đang xử lý",
                                  style: FineTheme.typograhpy.body1.copyWith(
                                    color: FineTheme.palettes.emerald25,
                                  )),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            model.notifierTaken.value != null
                                ? Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Material(
                                      color: Colors.red,
                                      shape: const CircleBorder(
                                          side: BorderSide(
                                              color: Colors.red, width: 2)),
                                      child: SizedBox(
                                        width: model.notifierTaken.value >= 10
                                            ? 24
                                            : 20,
                                        height: model.notifierTaken.value >= 10
                                            ? 24
                                            : 20,
                                        child: Center(
                                          child: Text(
                                            '${model.notifierTaken.value}',
                                            style: FineTheme
                                                .typograhpy.subtitle2
                                                .copyWith(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ))
                                : const SizedBox.shrink(),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 18, bottom: 12, right: 18),
                              child: Text("Đã xử lý",
                                  style: FineTheme.typograhpy.body1.copyWith(
                                    color: FineTheme.palettes.emerald25,
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                  style: const TextStyle(
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
                  style: const TextStyle(
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

  Widget _buildPendingPackageList() {
    String? stationName = '';
    if (model.stationList.isNotEmpty) {
      stationName = model.stationList
          .firstWhereOrNull((station) => station.id == model.selectedStationId)!
          .name;
    }
    return ScopedModelDescendant<HomeViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      List<DeliveryPackageDTO> packageList = model.pendingPackageList;
      if (status == ViewStatus.Loading) {
        return const Center(
          // child: SkeletonListItem(itemCount: 8),
          child: LoadingFine(),
        );
      } else if (status == ViewStatus.Empty || packageList.isEmpty) {
        return RefreshIndicator(
          key: _refreshIndicatorKey1,
          onRefresh: refreshFetchData,
          child: ListView(children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(15),
                //   child: InkWell(
                //     onTap: () async {
                //       await refreshFetchData();
                //     },
                //     child: Icon(
                //       Icons.replay,
                //       color: FineTheme.palettes.primary300,
                //       size: 26,
                //     ),
                //   ),
                // ),
                const SizedBox(
                  height: 32,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 48, right: 48),
                  child: Text(
                    'Hiện tại chưa có cửa hàng nào có hàng cho trạm ${stationName}!',
                    style: FineTheme.typograhpy.body1,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                // takenPackageList.isNotEmpty
                //     ? Column(
                //         children: [
                //           const Image(
                //             image: AssetImage(
                //                 "assets/images/package_delivery.png"),
                //             width: 300,
                //             height: 300,
                //           ),
                //           const SizedBox(height: 16),
                //           Padding(
                //             padding: const EdgeInsets.only(left: 48, right: 48),
                //             child: Text(
                //               '${takenPackageList.length} gói hàng đã được lấy ở trạm này',
                //               style: FineTheme.typograhpy.body1,
                //               textAlign: TextAlign.center,
                //             ),
                //           ),
                //           Padding(
                //             padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                //             child: Center(
                //               child: ElevatedButton(
                //                 style: ElevatedButton.styleFrom(
                //                   backgroundColor: Colors.white,
                //                   shape: const RoundedRectangleBorder(
                //                       borderRadius:
                //                           // BorderRadius.only(
                //                           //     bottomRight: Radius.circular(16),
                //                           //     bottomLeft: Radius.circular(16))
                //                           BorderRadius.all(Radius.circular(8))),
                //                 ),
                //                 onPressed: () {
                //                   _onTapDetail();
                //                 },
                //                 child: Text(
                //                   "Xem thông tin giao hàng!",
                //                   style: FineTheme.typograhpy.subtitle2
                //                       .copyWith(
                //                           color: FineTheme.palettes.emerald25),
                //                 ),
                //               ),
                //             ),
                //           )
                //         ],
                //       )
                //     : const SizedBox.shrink(),
              ],
            ),
          ]),
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

      return RefreshIndicator(
        key: _refreshIndicatorKey1,
        onRefresh: refreshFetchData,
        child: Scrollbar(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 28.0),
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
                    //       'Số gói hàng đã lấy: ${takenPackageList.length}/${packageList.length} ',
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
          ),
        ),
      );
    });
  }

  Widget _buildReadyPackageList() {
    String? stationName = '';
    if (model.stationList.isNotEmpty) {
      stationName = model.stationList
          .firstWhere((station) => station.id == model.selectedStationId)
          .name;
    }

    return ScopedModelDescendant<HomeViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      List<DeliveryPackageDTO> packageList = model.takenPackageList;

      if (status == ViewStatus.Loading) {
        return const Center(
          // child: SkeletonListItem(itemCount: 8),
          child: LoadingFine(),
        );
      } else if (status == ViewStatus.Empty || packageList.isEmpty) {
        return RefreshIndicator(
          key: _refreshIndicatorKey2,
          onRefresh: refreshFetchData,
          child: ListView(children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(15),
                //   child: InkWell(
                //     onTap: () async {
                //       await refreshFetchData();
                //     },
                //     child: Icon(
                //       Icons.replay,
                //       color: FineTheme.palettes.primary300,
                //       size: 26,
                //     ),
                //   ),
                // ),
                const SizedBox(
                  height: 32,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 48, right: 48),
                  child: Text(
                    'Hiện tại chưa lấy hàng ở cửa hàng nào cho trạm ${stationName}!',
                    style: FineTheme.typograhpy.body1,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
              ],
            ),
          ]),
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

      return RefreshIndicator(
        key: _refreshIndicatorKey2,
        onRefresh: refreshFetchData,
        child: Scrollbar(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 28.0),
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
                    //       'Số gói hàng đã lấy: ${takenPackageList.length}/${packageList.length} ',
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
          ),
        ),
      );
    });
  }

  Widget _buildOrderPackage(DeliveryPackageDTO package) {
    TimeSlotDTO? timeSlot = model.timeSlotList
        .firstWhere((timeSlot) => timeSlot.id == model.selectedTimeSlotId);
    return Column(
      children: [
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${package.storeName}',
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
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
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
                                    'Xem chi tiết (${package.totalQuantity})',
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
                            // const SizedBox(
                            //   height: 8,
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text('Vào lúc:',
                            //         style: FineTheme.typograhpy.body1.copyWith(
                            //             color: FineTheme.palettes.neutral900,
                            //             fontWeight: FontWeight.bold)),
                            //     Text('${timeSlot.checkoutTime}',
                            //         style: FineTheme.typograhpy.body1),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Center(
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
                            await model.confirmTakenPackage(
                                storeId: package.storeId!);
                            setState(() {});
                          },
                          child: Text(
                            "${"Đã lấy hàng"}",
                            style: FineTheme.typograhpy.subtitle2
                                .copyWith(color: FineTheme.palettes.emerald25),
                          ),
                        ),
                      )
                    ],
                  )),
            )),
      ],
    );
  }

  void _onTapDetail() async {
    await model.getShipperOrderBoxes();
    await model.getBoxQrCode();
    if (model.orderBoxList.isNotEmpty) {
      await Get.toNamed(RouteHandler.PACKAGE_DETAIL);
    }
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 50,
                  width: 300,
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1))),
                  child: Text('Chi tiết các gói hàng',
                      style: FineTheme.typograhpy.h2
                          .copyWith(color: FineTheme.palettes.emerald25)),
                ),
                Positioned(
                  top: -20,
                  right: -15,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        textStyle: Theme.of(context).textTheme.labelLarge,
                        alignment: Alignment.centerRight),
                    child: Icon(Icons.close_outlined,
                        color: FineTheme.palettes.error300),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
            content: SizedBox(
                height: 300,
                width: 300,
                child: Scrollbar(
                  child: ListView(
                    children: [
                      const SizedBox(height: 8),
                      ...?currentPackage?.packageShipperDetails
                          ?.map((product) => _buildPackageProducts(product)),
                    ],
                  ),
                )),
          );
        });
      },
    );
  }

  Widget _buildPackageProducts(PackageShipperDetails product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              '${product.productName}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              'x ${product.quantity}',
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal),
            ),
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
