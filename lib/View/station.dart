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
                                          height: 8,
                                        ),
                                        Center(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: FineTheme
                                                          .palettes.error200),
                                                  borderRadius:
                                                      // BorderRadius.only(
                                                      //     bottomRight: Radius.circular(16),
                                                      //     bottomLeft: Radius.circular(16))
                                                      const BorderRadius.all(
                                                          Radius.circular(8))),
                                            ),
                                            onPressed: () async {
                                              _dialogBuilder(context);
                                              setState(() {});
                                            },
                                            child: Text(
                                              "Báo cáo !",
                                              style: FineTheme
                                                  .typograhpy.subtitle2
                                                  .copyWith(
                                                      color: FineTheme
                                                          .palettes.error200),
                                            ),
                                          ),
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
            if (status == ViewStatus.Loading) {
              return const SizedBox.shrink();
            }
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
      height: 600,
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
    return Container(
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
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('Số lượng:',
              //         style: FineTheme.typograhpy.body1.copyWith(
              //             color: FineTheme.palettes.neutral900,
              //             fontWeight: FontWeight.bold)),
              //     Text('${detail.quantity}', style: FineTheme.typograhpy.body1),
              //   ],
              // ),
              // const SizedBox(
              //   height: 8,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Đặt vào:',
                      style: FineTheme.typograhpy.body1.copyWith(
                          color: FineTheme.palettes.neutral900,
                          fontWeight: FontWeight.bold)),
                  Column(
                    children: [
                      ...orderBoxList.map(
                          (orderBox) => _buildBoxProducts(orderBox, detail)),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 8,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoxProducts(ShipperOrderBoxDTO orderBox, OrderDetail detail) {
    String? boxCode =
        model.boxList.firstWhere((box) => box.id == orderBox.boxId).code;
    if (orderBox.orderDetails?.firstWhereOrNull(
            (e) => e.productInMenuId == detail.productInMenuId) !=
        null) {
      return Text(
        'Tủ $boxCode (${detail.quantity} món)',
        style: FineTheme.typograhpy.body1,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildReportProducts(OrderDetail detail) {
    int detailIndex = model.orderBoxList
        .firstWhere((e) => e.boxId == model.selectedBoxId)
        .orderDetails!
        .indexOf(detail);
    return StatefulBuilder(builder: (context, setState) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 175,
            child: Text(
              '${detail.productName}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal),
            ),
          ),
          detail.isChecked == true
              ? Row(
                  children: [
                    IconButton(
                      splashRadius: 12,
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        model.onChangeMissing(detailIndex, detail.missing! - 1);
                        setState(() {});
                      },
                      color: FineTheme.palettes.emerald25,
                    ),
                    Text(
                      '${detail.missing}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal),
                    ),
                    IconButton(
                      splashRadius: 12,
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        model.onChangeMissing(detailIndex, detail.missing! + 1);
                        setState(() {});
                      },
                      color: FineTheme.palettes.emerald25,
                    ),
                  ],
                )
              : TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: Text(
                    'Chọn',
                    style: FineTheme.typograhpy.body1
                        .copyWith(color: FineTheme.palettes.emerald25),
                  ),
                  onPressed: () {
                    model.onSelectProductMissing(detailIndex, true);
                    setState(() {});
                  },
                ),
        ],
      );
    });
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        List<ShipperOrderBoxDTO> orderBoxList = model.orderBoxList;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Báo cáo thiếu món', style: FineTheme.typograhpy.h2),
            content: SizedBox(
              height: 350,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tủ:', style: FineTheme.typograhpy.body1),
                      DropdownButton<String>(
                        value: model.selectedBoxId,
                        onChanged: (String? value) {
                          model.onChangeBox(value!);
                          setState(() {});
                        },
                        items: model.orderBoxList.map<DropdownMenuItem<String>>(
                            (ShipperOrderBoxDTO orderBox) {
                          return DropdownMenuItem<String>(
                            value: orderBox.boxId,
                            child: Text(
                                '${model.boxList.firstWhere((box) => box.id == orderBox.boxId).code}',
                                style: FineTheme.typograhpy.body1),
                          );
                        }).toList(),
                      ),
                      // Text(
                      // '${currentTimeSlot.arriveTime?.substring(0, 5)} - ${currentTimeSlot.checkoutTime?.substring(0, 5)}',
                      // style: FineTheme.typograhpy.body1)
                    ],
                  ),
                  SizedBox(
                      height: 300,
                      width: 300,
                      child: Scrollbar(
                        child: ListView(
                          children: [
                            const SizedBox(height: 8),
                            ...orderBoxList
                                .firstWhere(
                                    (e) => e.boxId == model.selectedBoxId)
                                .orderDetails!
                                .map((detail) => _buildReportProducts(detail)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: FineTheme.palettes.emerald25,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      side: BorderSide(
                        width: 1.0,
                        color: FineTheme.palettes.emerald25,
                      ),
                    ),
                    onPressed: () async {
                      model.reportMissingProduct();
                    },
                    child: Text(
                      "Gửi",
                      style: FineTheme.typograhpy.subtitle2
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          );
        });
      },
    );
  }
}
