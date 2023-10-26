// ignore_for_file: avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fine_merchant_mobile/Accessories/appbar.dart';
import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DTO/StationDTO.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/home_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';
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

class StationScreen extends StatefulWidget {
  final List<PackageStoreShipperResponses> takenPackageList;

  const StationScreen({super.key, required this.takenPackageList});

  @override
  State<StationScreen> createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen> {
  StationViewModel model = Get.put(StationViewModel());

  int numsOfChecked = 0;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  final double HEIGHT = 48;
  final ValueNotifier<double> notifier = ValueNotifier(0);
  final PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    model.stationList = Get.find<HomeViewModel>().stationList;
    model.timeSlotList = Get.find<HomeViewModel>().timeSlotList;
    model.selectedStationId = Get.find<HomeViewModel>().selectedStationId;
    model.selectedStoreId = Get.find<HomeViewModel>().selectedStoreId;
    model.selectedTimeSlotId = Get.find<HomeViewModel>().selectedTimeSlotId;
    for (PackageStoreShipperResponses package in widget.takenPackageList) {
      model.productList = [];
      List<PackStationDetailGroupByProducts>? newProductList =
          package.packStationDetailGroupByProducts;
      if (newProductList != null && newProductList.isNotEmpty) {
        for (PackStationDetailGroupByProducts product in newProductList) {
          model.productList.add(product);
        }
      }
    }
    setState(() {});
  }

  Future<void> _refresh() async {
    model.getBoxListByStation();
  }

  void _onTapToBoxList(PackStationDetailGroupByProducts product) async {
    // await Get.find<StationViewModel>().getBoxListByStation();
    // await Future.delayed(const Duration(milliseconds: 300));
    await Get.toNamed(RouteHandler.PRODUCT_BOXES_SCREEN, arguments: product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: FineTheme.palettes.shades100,
      appBar: StationPackageDetailAppBar(
        title: "Danh sách món cần giao",
      ),
      body: SafeArea(
        // ignore: sized_box_for_whitespace
        child: Container(
          // color: FineTheme.palettes.primary100,
          height: Get.height,
          child: ScopedModel(
            model: Get.find<StationViewModel>(),
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(top: 0),
                        child: RefreshIndicator(
                          key: _refreshIndicatorKey,
                          onRefresh: _refresh,
                          child: ScopedModelDescendant<StationViewModel>(
                              builder: (context, child, model) {
                            if (model.status == ViewStatus.Error) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Center(
                                    child: Text(
                                      "Có lỗi xảy ra!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(height: 8),
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
                                      children: [
                                        ...renderHomeSections().toList(),
                                        const SizedBox(
                                          height: 12,
                                        ),
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
    return [
      _buildStationSection(),
      _buildBoxProductList(),
    ];
  }

  Widget _buildStationSection() {
    TimeSlotDTO? timeSlot = model.timeSlotList
        .firstWhere((timeSlot) => timeSlot.id == model.selectedTimeSlotId);
    String? stationName = model.stationList
        .firstWhere((station) => station.id == model.selectedStationId)
        .name;

    return ScopedModel(
        model: Get.find<StationViewModel>(),
        child: ScopedModelDescendant<StationViewModel>(
          builder: (context, child, model) {
            ViewStatus status = model.status;

            return SizedBox(
              height: 65,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Số món: ',
                          style: FineTheme.typograhpy.body1.copyWith(
                              color: FineTheme.palettes.neutral900,
                              fontWeight: FontWeight.bold)),
                      Text('${model.productList.length}',
                          style: FineTheme.typograhpy.body1),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Tại trạm: ",
                        style: FineTheme.typograhpy.subtitle1.copyWith(
                            color: FineTheme.palettes.neutral900,
                            fontWeight: FontWeight.bold),
                      ),

                      // DropdownButton<String>(
                      //   value: model.selectedStationId,
                      //   onChanged: (String? value) {
                      //     model.onChangeStation(value!);
                      //   },
                      //   items: model.stationList
                      //       .map<DropdownMenuItem<String>>((StationDTO station) {
                      //     return DropdownMenuItem<String>(
                      //       value: station.id,
                      //       child: Text(
                      //         '${station.name}',
                      //         style: FineTheme.typograhpy.subtitle2
                      //             .copyWith(color: FineTheme.palettes.neutral900),
                      //       ),
                      //     );
                      //   }).toList(),
                      // ),
                      Text(
                        "$stationName",
                        style: FineTheme.typograhpy.subtitle1
                            .copyWith(color: FineTheme.palettes.neutral900),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Vào lúc: ',
                          style: FineTheme.typograhpy.body1.copyWith(
                              color: FineTheme.palettes.neutral900,
                              fontWeight: FontWeight.bold)),
                      Text('${timeSlot.checkoutTime?.substring(0, 5)}',
                          style: FineTheme.typograhpy.body1),
                    ],
                  ),
                ],
              ),
            );
          },
        ));
  }

  Widget _buildBoxProductList() {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      color: FineTheme.palettes.emerald25,
      height: 700,
      width: 600,
      child: Scrollbar(
        child: ListView(children: [
          ...model.productList.map((package) => _buildProducts(package)),
        ]),
      ),
    );
  }

  Widget _buildProducts(PackStationDetailGroupByProducts package) {
    return Container(
      margin: const EdgeInsets.all(16),
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
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tên món:',
                      style: FineTheme.typograhpy.body1.copyWith(
                          color: FineTheme.palettes.neutral900,
                          fontWeight: FontWeight.bold)),
                  Text('${package.productName}',
                      style: FineTheme.typograhpy.body1),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Số lượng:',
                      style: FineTheme.typograhpy.body1.copyWith(
                          color: FineTheme.palettes.neutral900,
                          fontWeight: FontWeight.bold)),
                  Text('${package.totalQuantity}',
                      style: FineTheme.typograhpy.body1),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      // backgroundColor: FineTheme.palettes.emerald25,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      side: BorderSide(
                        width: 1.0,
                        color: FineTheme.palettes.emerald25,
                      ),
                    ),
                    onPressed: () async {
                      _onTapToBoxList(package);
                    },
                    child: Text(
                      "Xem danh sách tủ",
                      style: FineTheme.typograhpy.subtitle2
                          .copyWith(color: FineTheme.palettes.emerald25),
                    ),
                  ),
                  // Column(
                  //   children: [
                  //     ...orderBoxList.map(
                  //         (orderBox) => _buildBoxProducts(orderBox, detail)),
                  //   ],
                  // )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
