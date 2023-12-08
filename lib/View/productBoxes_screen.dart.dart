// ignore_for_file: avoid_unnecessary_containers
import 'package:fine_merchant_mobile/Accessories/appbar.dart';
import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/home_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';
import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:fine_merchant_mobile/widgets/fixed_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductBoxesScreen extends StatefulWidget {
  final ProductBoxViewModelDTO productBoxViewModel;
  const ProductBoxesScreen({super.key, required this.productBoxViewModel});

  @override
  State<ProductBoxesScreen> createState() => _ProductBoxesScreenState();
}

class _ProductBoxesScreenState extends State<ProductBoxesScreen> {
  bool isReporting = false;
  List<ProductBoxesDTO>? productBoxes;
  PackStationDetailGroupByProducts? productPackage;
  StationViewModel model = Get.put(StationViewModel());

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  final double HEIGHT = 32;

  final ValueNotifier<double> notifier = ValueNotifier(0);
  final PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    productBoxes = widget.productBoxViewModel.productBoxes;
    productPackage = widget.productBoxViewModel.product;
    _refresh();
  }

  Future<void> _refresh() async {
    model.getBoxListByStation();
  }

  @override
  Widget build(BuildContext context) {
    String? stationName = model.stationList
        .firstWhere((station) => station.id == model.selectedStationId)
        .name;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: FineTheme.palettes.shades100,
      appBar: DefaultAppBar(
        title: "Danh sách tủ",
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${stationName}',
                style: FineTheme.typograhpy.h2
                    .copyWith(color: FineTheme.palettes.primary100),
              ),
            )),
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
                    SizedBox(
                      height: Get.height * 0.02,
                    ),
                    Column(
                      children: [
                        ...renderHomeSections().toList(),
                        SizedBox(
                          height: Get.height * 0.015,
                        ),
                        isReporting == false
                            ? Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: FineTheme.palettes.error200),
                                        borderRadius:
                                            // BorderRadius.only(
                                            //     bottomRight: Radius.circular(16),
                                            //     bottomLeft: Radius.circular(16))
                                            const BorderRadius.all(
                                                Radius.circular(8))),
                                  ),
                                  onPressed: () async {
                                    // _dialogBuilder(context);
                                    setState(() {
                                      isReporting = !isReporting;
                                    });
                                  },
                                  child: Text(
                                    "Báo cáo !",
                                    style: FineTheme.typograhpy.subtitle2
                                        .copyWith(
                                            color: FineTheme.palettes.error200),
                                  ),
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.only(left: 32, right: 32),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .labelLarge,
                                      ),
                                      child: Text(
                                        'Hủy',
                                        style: FineTheme.typograhpy.body1
                                            .copyWith(
                                                color: FineTheme
                                                    .palettes.emerald25),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isReporting = !isReporting;
                                        });
                                      },
                                    ),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor:
                                            FineTheme.palettes.emerald25,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        side: BorderSide(
                                          width: 1.0,
                                          color: FineTheme.palettes.emerald25,
                                        ),
                                      ),
                                      onPressed: () async {
                                        await model.reportMissingProduct(
                                            productId:
                                                productPackage!.productId,
                                            statusType: 2,
                                            storeId: productPackage!.storeId);
                                        setState(() {
                                          isReporting = !isReporting;
                                        });
                                      },
                                      child: Text(
                                        "Gửi",
                                        style: FineTheme.typograhpy.body1
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
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
            if (status == ViewStatus.Loading) {
              return const SizedBox.shrink();
            }
            return SizedBox(
              height: Get.height * 0.1,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Món: ',
                          style: FineTheme.typograhpy.body1.copyWith(
                              color: FineTheme.palettes.neutral900,
                              fontWeight: FontWeight.bold)),
                      Text(
                          productPackage != null
                              ? '${productPackage!.productName}'
                              : "",
                          style: FineTheme.typograhpy.body1),
                    ],
                  ),
                  SizedBox(
                    height: Get.height * 0.02,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        color: FineTheme.palettes.emerald25,
                        size: 15.0,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text('Cần đặt vào',
                          style: FineTheme.typograhpy.body1.copyWith(
                              color: FineTheme.palettes.neutral900,
                              fontWeight: FontWeight.bold)),
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
        padding: EdgeInsets.all(Get.height * 0.01),
        color: FineTheme.palettes.neutral600,
        height: Get.height * 0.675,
        child: GridView.count(
          crossAxisCount: 5,
          children: [...model.boxList.map((box) => _buildBoxes(box))],
        ));
  }

  Widget _buildBoxes(BoxDTO box) {
    ProductBoxesDTO? foundBoxProduct;
    var isStored = false;
    var quantity = 0;
    int index = 0;
    if (productBoxes != null && productBoxes!.isNotEmpty) {
      for (ProductBoxesDTO productBox in productBoxes!) {
        if (productBox.key!.value! == box.code) {
          foundBoxProduct = productBox;
          isStored = true;
          quantity = productBox.value!;
          index = productBoxes!.indexOf(productBox);
        }
      }
    }

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color:
                isStored == true ? FineTheme.palettes.emerald25 : Colors.white,
            child: InkWell(
              splashColor: FineTheme.palettes.emerald50,
              onTap: isStored && isReporting == true
                  ? () {
                      model.onSelectReportBox(box.id!);
                      model.onChangeMissing(
                          widget.productBoxViewModel.product!.productId!,
                          index,
                          1);
                      setState(() {});
                    }
                  : null,
              onLongPress: isStored &&
                      isReporting == true &&
                      box.id == model.selectedBoxId
                  ? () {
                      model.selectedBoxId = box.id;
                      _dialogBuilder(context, foundBoxProduct!, index);
                    }
                  : null,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: isStored
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              textAlign: TextAlign.center,
                              '${box.code?.split('_')[0]}',
                              style: FineTheme.typograhpy.subtitle2.copyWith(
                                  color: isStored == true
                                      ? Colors.white
                                      : FineTheme.palettes.emerald25),
                            ),
                            Text(
                              textAlign: TextAlign.center,
                              '(${quantity})',
                              style: FineTheme.typograhpy.subtitle3.copyWith(
                                  color: isStored == true
                                      ? Colors.white
                                      : FineTheme.palettes.emerald25),
                            ),
                          ],
                        )
                      : Text(
                          textAlign: TextAlign.center,
                          '${box.code?.split('_')[0]}',
                          style: FineTheme.typograhpy.subtitle2.copyWith(
                              color: isStored == true
                                  ? Colors.white
                                  : FineTheme.palettes.emerald25),
                        ),
                ),
              ),
            ),
          ),
        ),
        isStored && isReporting == true
            ? Positioned(
                top: 0,
                right: 0,
                child: Material(
                  color: box.id == model.selectedBoxId
                      ? Colors.red
                      : const Color.fromARGB(0, 58, 58, 58),
                  shape: const CircleBorder(
                      side: BorderSide(color: Colors.red, width: 2)),
                  child: box.id == model.selectedBoxId
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: Center(
                            child: Text(
                              '${foundBoxProduct!.currentMissing}',
                              style: FineTheme.typograhpy.caption1
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        )
                      : const SizedBox(
                          width: 20,
                          height: 20,
                        ),
                ))
            : const SizedBox.shrink(),
      ],
    );
  }

  // Widget _buildReportProducts(OrderDetail detail) {
  //   int detailIndex = model.orderBoxList
  //       .firstWhere((e) => e.boxId == model.selectedBoxId)
  //       .orderDetails!
  //       .indexOf(detail);
  //   return StatefulBuilder(builder: (context, setState) {
  //     return Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         SizedBox(
  //           width: 175,
  //           child: Text(
  //             '${detail.productName}',
  //             overflow: TextOverflow.ellipsis,
  //             style: const TextStyle(
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.w400,
  //                 fontStyle: FontStyle.normal),
  //           ),
  //         ),
  //         detail.isChecked == true
  //             ? Row(
  //                 children: [
  //                   IconButton(
  //                     splashRadius: 12,
  //                     icon: const Icon(Icons.remove),
  //                     onPressed: () {
  //                       model.onChangeMissing(detailIndex, detail.missing! - 1);
  //                       setState(() {});
  //                     },
  //                     color: FineTheme.palettes.emerald25,
  //                   ),
  //                   Text(
  //                     '${detail.missing}',
  //                     overflow: TextOverflow.ellipsis,
  //                     style: const TextStyle(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w400,
  //                         fontStyle: FontStyle.normal),
  //                   ),
  //                   IconButton(
  //                     splashRadius: 12,
  //                     icon: const Icon(Icons.add),
  //                     onPressed: () {
  //                       model.onChangeMissing(detailIndex, detail.missing! + 1);
  //                       setState(() {});
  //                     },
  //                     color: FineTheme.palettes.emerald25,
  //                   ),
  //                 ],
  //               )
  //             : TextButton(
  //                 style: TextButton.styleFrom(
  //                   textStyle: Theme.of(context).textTheme.labelLarge,
  //                 ),
  //                 child: Text(
  //                   'Chọn',
  //                   style: FineTheme.typograhpy.body1
  //                       .copyWith(color: FineTheme.palettes.emerald25),
  //                 ),
  //                 onPressed: () {
  //                   model.onSelectProductMissing(detailIndex, true);
  //                   setState(() {});
  //                 },
  //               ),
  //       ],
  //     );
  //   });
  // }

  Future<void> _dialogBuilder(
      BuildContext context, ProductBoxesDTO productBox, int? index) {
    int currentMissing = 1;
    String? boxCode =
        model.boxList.firstWhere((box) => box.id == model.selectedBoxId).code;
    currentMissing = productBox.currentMissing!;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                      'Số lượng bị thiếu của tủ ${boxCode?.split('_')[0]}',
                      textAlign: TextAlign.center,
                      style: FineTheme.typograhpy.h3
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
              height: 50,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        splashRadius: 24,
                        icon: const Icon(
                          Icons.remove,
                          size: 32,
                        ),
                        onPressed: () {
                          if (currentMissing > 1) {
                            currentMissing--;
                          }

                          setState(() {});
                        },
                        color: FineTheme.palettes.emerald25,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Text(
                          '${currentMissing}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal),
                        ),
                      ),
                      IconButton(
                        splashRadius: 24,
                        icon: const Icon(Icons.add, size: 32),
                        onPressed: () {
                          if (currentMissing < productBox.value!) {
                            currentMissing++;
                          }
                          setState(() {});
                        },
                        color: FineTheme.palettes.emerald25,
                      ),
                    ],
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text('Đồng ý',
                    textAlign: TextAlign.center,
                    style: FineTheme.typograhpy.body1
                        .copyWith(color: FineTheme.palettes.emerald25)),
                onPressed: () {
                  model.onChangeMissing(
                      productBox.key!.key!, index!, currentMissing);
                  this.setState(() {});
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  // Future<void> _dialogBuilder(BuildContext context) {
  //   return showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       List<ShipperOrderBoxDTO> orderBoxList = model.orderBoxList;
  //       return StatefulBuilder(builder: (context, setState) {
  //         return AlertDialog(
  //           title: Text('Báo cáo thiếu món', style: FineTheme.typograhpy.h2),
  //           content: SizedBox(
  //             height: 350,
  //             child: Column(
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Text('Tủ:', style: FineTheme.typograhpy.body1),
  //                     DropdownButton<String>(
  //                       value: model.selectedBoxId,
  //                       onChanged: (String? value) {
  //                         model.onChangeBox(value!);
  //                         setState(() {});
  //                       },
  //                       items: model.orderBoxList.map<DropdownMenuItem<String>>(
  //                           (ShipperOrderBoxDTO orderBox) {
  //                         return DropdownMenuItem<String>(
  //                           value: orderBox.boxId,
  //                           child: Text(
  //                               '${model.boxList.firstWhere((box) => box.id == orderBox.boxId).code}',
  //                               style: FineTheme.typograhpy.body1),
  //                         );
  //                       }).toList(),
  //                     ),
  //                     // Text(
  //                     // '${currentTimeSlot.arriveTime?.substring(0, 5)} - ${currentTimeSlot.checkoutTime?.substring(0, 5)}',
  //                     // style: FineTheme.typograhpy.body1)
  //                   ],
  //                 ),
  //                 SizedBox(
  //                     height: 300,
  //                     width: 300,
  //                     child: Scrollbar(
  //                       child: ListView(
  //                         children: [
  //                           const SizedBox(height: 8),
  //                           ...orderBoxList
  //                               .firstWhere(
  //                                   (e) => e.boxId == model.selectedBoxId)
  //                               .orderDetails!
  //                               .map((detail) => _buildReportProducts(detail)),
  //                         ],
  //                       ),
  //                     )),
  //               ],
  //             ),
  //           ),
  //           actions: <Widget>[
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 TextButton(
  //                   style: TextButton.styleFrom(
  //                     textStyle: Theme.of(context).textTheme.labelLarge,
  //                   ),
  //                   child: Text(
  //                     'Đóng',
  //                     style: FineTheme.typograhpy.body1
  //                         .copyWith(color: FineTheme.palettes.emerald25),
  //                   ),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                 ),
  //                 OutlinedButton(
  //                   style: OutlinedButton.styleFrom(
  //                     backgroundColor: FineTheme.palettes.emerald25,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8.0),
  //                     ),
  //                     side: BorderSide(
  //                       width: 1.0,
  //                       color: FineTheme.palettes.emerald25,
  //                     ),
  //                   ),
  //                   onPressed: () async {
  //                     model.reportMissingProduct(
  //                         productName: widget.detail.productName);
  //                   },
  //                   child: Text(
  //                     "Gửi",
  //                     style: FineTheme.typograhpy.subtitle2
  //                         .copyWith(color: Colors.white),
  //                   ),
  //                 ),
  //               ],
  //             )
  //           ],
  //         );
  //       });
  //     },
  //   );
  // }
}
