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
  final bool isRouted;

  const StationScreen({super.key, required this.isRouted});

  @override
  State<StationScreen> createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen> {
  StationViewModel model = Get.put(StationViewModel());

  int numsOfChecked = 0;

  List<OrderDetail> totalOrderDetailList = [];
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
    model.orderBoxList = Get.find<HomeViewModel>().orderBoxList;
    model.selectedStationId = Get.find<HomeViewModel>().selectedStationId;
    model.selectedStoreId = Get.find<HomeViewModel>().selectedStoreId;
    model.selectedTimeSlotId = Get.find<HomeViewModel>().selectedTimeSlotId;
    model.selectedBoxId = model.orderBoxList.first.boxId!;
  }

  Future<void> _refresh() async {
    model.getBoxListByStation();
  }

  void _onTapToBoxList(OrderDetail detail) async {
    await Get.find<StationViewModel>().getBoxListByStation();
    await Future.delayed(const Duration(milliseconds: 300));
    await Get.toNamed(RouteHandler.PRODUCT_BOXES_SCREEN, arguments: detail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: FineTheme.palettes.shades100,
      appBar: DefaultAppBar(
          title: "Danh sách món cần giao",
          backButton: widget.isRouted ? null : SizedBox.shrink()),
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
    var currentUser = Get.find<AccountViewModel>().currentUser;

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
              height: 50,
              child: Column(
                children: [
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

  Widget buildBoxListSection() {
    List<BoxDTO> boxList = model.boxList;
    return ScopedModel(
        model: Get.find<StationViewModel>(),
        child: ScopedModelDescendant<StationViewModel>(
          builder: (context, child, model) {
            ViewStatus status = model.status;
            if (status == ViewStatus.Loading) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              color: FineTheme.palettes.emerald25,
              height: 480,
              width: Get.width,
              child: Container(
                // height: 300,
                padding: const EdgeInsets.only(top: 17, bottom: 17),
                color: FineTheme.palettes.neutral200,
                child: Center(
                  child: Column(
                    children: model.orderBoxList.isNotEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: Text(
                                "Chọn tủ để xem những món cần đặt vào nhé!",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: FineTheme.typograhpy.body1.copyWith(
                                    color: FineTheme.palettes.neutral900),
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Expanded(
                              child: Container(
                                child: GridView.count(
                                    // Create a grid with 2 columns. If you change the scrollDirection to
                                    // horizontal, this produces 2 rows.
                                    crossAxisCount: 2,
                                    // Generate 100 widgets that display their index in the List.
                                    children: [
                                      ...model.orderBoxList.map(
                                        (orderBox) => Center(
                                          child: Material(
                                            child: InkWell(
                                              splashColor:
                                                  FineTheme.palettes.emerald50,
                                              onTap: () {
                                                Get.toNamed(
                                                  RouteHandler.QRCODE_SCREEN,
                                                  arguments: orderBox,
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(25.0),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: FineTheme
                                                            .palettes
                                                            .emerald25)),
                                                child: Text(
                                                  '${boxList.firstWhere((box) => box.id == orderBox.boxId).code}',
                                                  style: FineTheme
                                                      .typograhpy.body1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                          ]
                        : [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: Text(
                                "Hiện chưa có gói hàng nào cần đặt vào tủ!",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: FineTheme.typograhpy.body1.copyWith(
                                    color: FineTheme.palettes.neutral900),
                              ),
                            ),
                          ],
                  ),
                ),
              ),
            );
          },
        ));
  }

  Widget _buildBoxProductList() {
    List<ShipperOrderBoxDTO> orderBoxList = model.orderBoxList;
    for (ShipperOrderBoxDTO orderBox in orderBoxList) {
      List<OrderDetail>? orderDetails = orderBox.orderDetails;
      if (orderDetails != null) {
        for (OrderDetail detail in orderDetails) {
          if (totalOrderDetailList.isEmpty) {
            totalOrderDetailList.add(detail);
          } else if (totalOrderDetailList.firstWhereOrNull(
                  (e) => e.productInMenuId == detail.productInMenuId) ==
              null) {
            totalOrderDetailList.add(detail);
          }
        }
      }
    }
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      color: FineTheme.palettes.emerald25,
      height: 680,
      width: 600,
      child: Scrollbar(
        child: ListView(children: [
          ...totalOrderDetailList
              .map((detail) => _buildProducts(detail, orderBoxList)),
        ]),
      ),
    );
  }

  Widget _buildProducts(
      OrderDetail detail, List<ShipperOrderBoxDTO> orderBoxList) {
    int quantity = 0;
    for (ShipperOrderBoxDTO orderBox in orderBoxList) {
      var orderDetails = orderBox.orderDetails;
      var foundDetail = orderDetails
          ?.firstWhereOrNull((e) => e.productName == detail.productName);
      if (foundDetail != null) {
        quantity = quantity + foundDetail.quantity!;
      }
    }

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
                  Text('${detail.productName}',
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
                  Text('${quantity} món', style: FineTheme.typograhpy.body1),
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
                      _onTapToBoxList(detail);
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
