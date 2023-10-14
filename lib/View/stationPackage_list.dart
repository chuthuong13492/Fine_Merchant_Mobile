import 'dart:async';
import 'dart:math';
import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:fine_merchant_mobile/Utils/format_price.dart';
import 'package:fine_merchant_mobile/Utils/format_time.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/stationPackage_viewModel.dart';
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

class StationPackagesScreen extends StatefulWidget {
  const StationPackagesScreen({super.key});

  @override
  State<StationPackagesScreen> createState() => _StationPackagesScreenState();
}

class _StationPackagesScreenState extends State<StationPackagesScreen> {
  late Timer periodicTimer;
  bool isDelivering = false;
  MissingProductReportDTO? currentReport;
  StationPackageViewModel model = Get.find<StationPackageViewModel>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    model.stationList = Get.find<OrderListViewModel>().stationList;
    model.timeSlotList = Get.find<OrderListViewModel>().timeSlotList;
    model.storeList = Get.find<OrderListViewModel>().storeList;
    model.selectedStoreId = Get.find<OrderListViewModel>().staffStore?.id;
    periodicTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      refreshFetchApi();
    });
  }

  @override
  void dispose() {
    super.dispose();
    periodicTimer.cancel();
  }

  Future<void> refreshFetchApi() async {
    await model.getSplitOrdersByStation();
  }

  @override
  Widget build(BuildContext context) {
    String? storeName = Get.find<AccountViewModel>().currentStore!.storeName;
    return ScopedModel(
      model: Get.find<StationPackageViewModel>(),
      child: Scaffold(
        appBar: DefaultAppBar(
          title: "Gói hàng theo trạm",
          backButton: const SizedBox.shrink(),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${storeName}',
                  style: FineTheme.typograhpy.h2.copyWith(
                    color: FineTheme.palettes.emerald25,
                  ),
                ),
              )),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            filterSection(),
            Expanded(
              child: Container(
                // ignore: sort_child_properties_last
                child: _buildStationPackageList(),
                color: const Color(0xffefefef),
              ),
            ),
          ],
        ),
      ),
    );
  }

////////////////////
  Widget filterSection() {
    return ScopedModelDescendant<StationPackageViewModel>(
      builder: (context, child, model) {
        return Center(
          child: Container(
            // color: Colors.amber,
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
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatDateType(DateTime.now().toString()),
                            style: FineTheme.typograhpy.h2),
                        DropdownButton<String>(
                          value: model.selectedTimeSlotId,
                          onChanged: (String? value) {
                            model.onChangeTimeSlot(value!);
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

////////////////////
  Widget _buildStationPackageList() {
    return ScopedModelDescendant<StationPackageViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      List<StationSplitProductDTO>? splitProductsByStation =
          model.splitProductsByStation;

      if (status == ViewStatus.Loading) {
        return const Center(
          child: SkeletonListItem(itemCount: 8),
        );
      } else if (status == ViewStatus.Empty || splitProductsByStation.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Hiện tại chưa có trạm nào có gói hàng!'),
              Padding(
                padding: const EdgeInsets.all(15),
                child: InkWell(
                  onTap: () async {
                    refreshFetchApi();
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
      return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: refreshFetchApi,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: Get.find<StationPackageViewModel>().scrollController,
          padding: const EdgeInsets.all(8),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ...model.splitProductsByStation
                    .map((stationPackage) =>
                        _buildStationPackage(stationPackage))
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
    return ScopedModelDescendant<StationPackageViewModel>(
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

  Widget _buildStationPackage(StationSplitProductDTO stationPackage) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            // _dialogBuilder(context, stationPackage);
            Get.toNamed(RouteHandler.STATION_PACKAGE_DETAIL,
                arguments: stationPackage);
          },
          child: Container(
              // height: 80,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                child: Material(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      // side: BorderSide(color: Colors.red),
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: Text('Xem chi tiết',
                              style: FineTheme.typograhpy.subtitle2.copyWith(
                                  color: FineTheme.palettes.emerald25,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Trạm:',
                                style: FineTheme.typograhpy.body1.copyWith(
                                    color: FineTheme.palettes.neutral900,
                                    fontWeight: FontWeight.bold)),
                            Text('${stationPackage.stationName}',
                                style: FineTheme.typograhpy.body1),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Đã chuẩn bị:',
                                style: FineTheme.typograhpy.body1.copyWith(
                                    color: FineTheme.palettes.neutral900,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                '${stationPackage.readyQuantity}/${stationPackage.totalQuantity} Món',
                                overflow: TextOverflow.ellipsis,
                                style: FineTheme.typograhpy.body1),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        InkWell(
                          onTap: stationPackage.isShipperAssign == true
                              ? null
                              : () async {
                                  await model.confirmDeliveryPackage(
                                      stationId: stationPackage.stationId!);
                                },
                          child: Container(
                            width: 200,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: stationPackage.isShipperAssign == true
                                      ? FineTheme.palettes.neutral700
                                      : FineTheme.palettes.primary100),
                              boxShadow: [
                                BoxShadow(
                                  color: stationPackage.isShipperAssign == true
                                      ? FineTheme.palettes.neutral700
                                      : FineTheme.palettes.primary100,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                stationPackage.isShipperAssign == true
                                    ? "Đã giao cho shipper"
                                    : "Sẵn sàng để giao",
                                style: FineTheme.typograhpy.subtitle1.copyWith(
                                    color:
                                        stationPackage.isShipperAssign == true
                                            ? FineTheme.palettes.neutral700
                                            : FineTheme.palettes.primary100),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              )),
        ),
      ],
    );
  }

  Widget _buildPackageProducts(PackageStationDetails product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${product.productName}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal),
          ),
          Text(
            'x ${product.quantity}',
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogBuilder(
      BuildContext context, StationSplitProductDTO stationPackage) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    height: 70,
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(width: 1))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Gói hàng cho ${stationPackage.stationName}',
                          style: FineTheme.typograhpy.h2
                              .copyWith(color: FineTheme.palettes.emerald25)),
                    ),
                  ),
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
                      ...stationPackage.packageStationDetails!
                          .map((product) => _buildPackageProducts(product)),
                    ],
                  ),
                )),
          );
        });
      },
    );
  }

  void _onTapDetail(PackageViewDTO package) async {
    // model.getOrders();
  }
}
