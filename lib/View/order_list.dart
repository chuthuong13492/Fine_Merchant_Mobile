import 'dart:async';

import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:fine_merchant_mobile/Utils/format_time.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/orderList_viewModel.dart';
import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:fine_merchant_mobile/widgets/skeleton_list.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';
import '../Accessories/index.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  bool isStaff = false;

  late Timer periodicTimer;
  OrderListViewModel model = Get.put(OrderListViewModel());
  AccountDTO? currentUser = Get.find<AccountViewModel>().currentUser;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey1 =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey2 =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    periodicTimer = Timer.periodic(const Duration(seconds: 60), (Timer timer) {
      refreshFetchOrder();
    });
  }

  @override
  void dispose() {
    super.dispose();
    periodicTimer.cancel();
  }

  Future<void> refreshFetchOrder() async {
    await model.getTimeSlotList();
    await model.getSplitOrders();
    await model.getSplitOrdersByStation();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<SplitOrderDTO> splitOrderList = model.splitOrderList;
    final status = model.status;
    return ScopedModel(
      model: Get.find<OrderListViewModel>(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: DefaultAppBar(
              title: "Đơn hàng ${isStaff ? "Chờ duyệt" : "Chờ giao"}",
              backButton: const SizedBox.shrink(),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(120),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${model.staffStore?.storeName}',
                      style: FineTheme.typograhpy.h2.copyWith(
                        color: FineTheme.palettes.emerald25,
                      ),
                    ),
                  ))),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              orderFilterSection(),
              const SizedBox(height: 16),
              SizedBox(
                height: Get.height * 0.675,
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sản phẩm',
                                style: FineTheme.typograhpy.h2.copyWith(
                                  color: FineTheme.palettes.emerald50,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${model.numsOfCheck == 0 ? "Chọn tất cả" : "Đã chọn " + model.numsOfCheck.toString() + " món"} ',
                                    style: FineTheme.typograhpy.body2.copyWith(
                                      color: FineTheme.palettes.neutral900,
                                    ),
                                  ),
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: FineTheme.palettes.emerald25,
                                    value: model.isAllChecked,
                                    onChanged: model.splitOrderList.isNotEmpty
                                        ? (bool? value) {
                                            model.onCheckAll(value!);
                                            setState(() {});
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            // ignore: sort_child_properties_last
                            child: _buildOrders(),
                            color: const Color(0xffefefef),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                          onPressed: model.numsOfCheck < 1 ||
                                  status == ViewStatus.Loading
                              ? null
                              : () async {
                                  await model.confirmSplitProducts();
                                  setState(() {});
                                },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Text(
                              "Xác nhận",
                              style: FineTheme.typograhpy.subtitle2
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          color: Colors.white70,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: ToggleButtons(
                                  renderBorder: false,
                                  selectedColor: FineTheme.palettes.emerald25,
                                  onPressed: (int index) async {
                                    await model.onChangeSelectStation(index);
                                    setState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(24),
                                  isSelected: model.stationSelections,
                                  children: [
                                    ...model.stationList.map(
                                      (e) => Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 16, bottom: 16),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            child: Text("${e.name}",
                                                textAlign: TextAlign.center,
                                                style: FineTheme
                                                    .typograhpy.caption1
                                                    .copyWith(
                                                        color: FineTheme
                                                            .palettes
                                                            .neutral900,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                          ),
                                          // Positioned(
                                          //     top: 0,
                                          //     right: 8,
                                          //     child: Material(
                                          //       color: Colors.red,
                                          //       shape: const CircleBorder(
                                          //           side: BorderSide(
                                          //               color: Colors.red, width: 2)),
                                          //       child: SizedBox(
                                          //         width: 20,
                                          //         height: 20,
                                          //         child: Center(
                                          //           child: Text(
                                          //             '${}',
                                          //             style: FineTheme
                                          //                 .typograhpy.caption1
                                          //                 .copyWith(
                                          //                     color: Colors.white),
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     ))
                                        ],
                                      ),
                                    )
                                  ]),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            // ignore: sort_child_properties_last
                            child: _buildOrdersByStation(),
                            color: const Color(0xffefefef),
                          ),
                        ),
                        const SizedBox(height: 100),
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
  }

////////////////////

  Widget orderFilterSection() {
    return ScopedModelDescendant<OrderListViewModel>(
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
                    padding: const EdgeInsets.fromLTRB(32, 12, 32, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Trạng thái:",
                          style: FineTheme.typograhpy.h2.copyWith(
                            color: FineTheme.palettes.neutral900,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                              OrderStatusEnum.getOrderStatusName(
                                  model.selectedOrderStatus),
                              style: FineTheme.typograhpy.body1.copyWith(
                                color: FineTheme.palettes.emerald25,
                              )),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 12),
                          child: Text("Xác nhận",
                              style: FineTheme.typograhpy.body1.copyWith(
                                color: FineTheme.palettes.emerald25,
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 12),
                          child: Text("Gom theo trạm",
                              style: FineTheme.typograhpy.body1.copyWith(
                                color: FineTheme.palettes.emerald25,
                              )),
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
  Widget _buildOrders() {
    List<SplitOrderDTO> orderList = model.splitOrderList;
    return ScopedModelDescendant<OrderListViewModel>(
        builder: (context, child, model) {
      final status = model.status;

      // orderList.sort((a, b) {
      //   DateTime aDate = DateTime.parse(a.checkInDate!);
      //   DateTime bDate = DateTime.parse(b.checkInDate!);
      //   return bDate.compareTo(aDate);
      // });
      if (status == ViewStatus.Loading) {
        return const Center(
          child: SkeletonListItem(itemCount: 8),
        );
      } else if (status == ViewStatus.Empty || orderList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hiện tại chưa có đơn nào.'),
              Padding(
                padding: EdgeInsets.all(15),
                child: InkWell(
                  onTap: () async {
                    refreshFetchOrder();
                  },
                  child: Icon(
                    Icons.replay,
                    color: FineTheme.palettes.primary300,
                    size: 26,
                  ),
                ),
              ),
              // MaterialButton(
              //   onPressed: () {
              //     Get.offAndToNamed(RouteHandler.NAV);
              //   },
              //   child: Text(
              //     '🥡 Đặt ngay 🥡',
              //     style: FineTheme.typograhpy.subtitle2.copyWith(
              //       color: FineTheme.palettes.primary300,
              //     ),
              //   ),
              // )
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
        key: _refreshIndicatorKey1,
        onRefresh: refreshFetchOrder,
        child: Scrollbar(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: Get.find<OrderListViewModel>().scrollController,
            padding: const EdgeInsets.all(8),
            children: [
              Container(
                  // height: 80,
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Material(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        // side: BorderSide(color: Colors.red),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ...orderList
                              .map((orderSummary) =>
                                  _buildSplitProduct(orderSummary))
                              .toList(),
                          loadMoreIcon(),
                        ],
                      ))),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildOrdersByStation() {
    List<SplitOrderDTO> orderList = model.splitOrderListByStation;
    return ScopedModelDescendant<OrderListViewModel>(
        builder: (context, child, model) {
      final status = model.status;

      // orderList.sort((a, b) {
      //   DateTime aDate = DateTime.parse(a.checkInDate!);
      //   DateTime bDate = DateTime.parse(b.checkInDate!);
      //   return bDate.compareTo(aDate);
      // });
      if (status == ViewStatus.Loading) {
        return const Center(
          child: SkeletonListItem(itemCount: 8),
        );
      } else if (status == ViewStatus.Empty || orderList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hiện tại chưa có đơn nào ở ${model.selectedStation?.name}'),
              Padding(
                padding: EdgeInsets.all(15),
                child: InkWell(
                  onTap: () async {
                    refreshFetchOrder();
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
        key: _refreshIndicatorKey2,
        onRefresh: model.getSplitOrdersByStation,
        child: Scrollbar(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: Get.find<OrderListViewModel>().scrollController,
            padding: const EdgeInsets.all(8),
            children: [
              Container(
                  // height: 80,
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Material(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        // side: BorderSide(color: Colors.red),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ...orderList
                              .map((orderSummary) =>
                                  _buildSplitProductByStation(orderSummary))
                              .toList(),
                          loadMoreIcon(),
                        ],
                      ))),
            ],
          ),
        ),
      );
    });
  }

//////////////////
  Widget loadMoreIcon() {
    return ScopedModelDescendant<OrderListViewModel>(
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

  Widget _buildSplitProduct(SplitOrderDTO splitOrderSummary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 150, child: Text('${splitOrderSummary.productName}')),
          Row(
            children: [
              SizedBox(child: Text(' x ${splitOrderSummary.quantity}')),
              Checkbox(
                activeColor: FineTheme.palettes.emerald25,
                checkColor: Colors.white,
                value: splitOrderSummary.isChecked,
                onChanged: (bool? value) {
                  int index = model.splitOrderList.indexOf(splitOrderSummary);
                  model.onCheck(index, value!);

                  if (model.numsOfCheck == model.splitOrderList.length) {
                    model.isAllChecked = true;
                  } else {
                    model.isAllChecked = false;
                  }
                  setState(() {});
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSplitProductByStation(SplitOrderDTO splitOrderSummary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: SizedBox(
              width: 150,
              child: Text('${splitOrderSummary.productName}'),
            ),
          ),
          SizedBox(child: Text(' x ${splitOrderSummary.quantity}')),
        ],
      ),
    );
  }
}
