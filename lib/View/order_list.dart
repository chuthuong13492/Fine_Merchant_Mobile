import 'dart:async';

import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:fine_merchant_mobile/Utils/format_price.dart';
import 'package:fine_merchant_mobile/Utils/format_time.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/orderList_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/root_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';
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

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  bool isStaff = false;
  bool isSelectAll = false;
  int numsOfChecked = 0;
  late Timer periodicTimer;
  OrderListViewModel model = Get.put(OrderListViewModel());
  AccountDTO? currentUser = Get.find<AccountViewModel>().currentUser;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> refreshFetchOrder() async {
    setState(() {
      isSelectAll = false;
      numsOfChecked = 0;
    });
    await model.getTimeSlotList();
    await model.getOrders();
    await model.getSplitOrders();
    // await model.getMoreOrders();
  }

  @override
  void initState() {
    super.initState();
    periodicTimer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      refreshFetchOrder();
    });
    model.filteredOrderList = model.orderList;
    isStaff = currentUser?.roleType == AccountTypeEnum.STAFF ? true : false;
    if (isStaff) {
      model.selectedOrderStatus = model.staffOrderStatuses.first;
    } else {
      model.selectedOrderStatus = model.driverOrderStatuses.first;
    }
  }

  @override
  void dispose() {
    super.dispose();
    periodicTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final status = model.status;
    return ScopedModel(
      model: Get.find<OrderListViewModel>(),
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
                        '${numsOfChecked == 0 ? "Chọn tất cả" : "Đã chọn " + numsOfChecked.toString() + " món"} ',
                        style: FineTheme.typograhpy.body2.copyWith(
                          color: FineTheme.palettes.neutral900,
                        ),
                      ),
                      Checkbox(
                        checkColor: Colors.white,
                        activeColor: FineTheme.palettes.emerald25,
                        value: isSelectAll,
                        onChanged: (bool? value) {
                          model.onCheckAll(value!);
                          setState(() {
                            isSelectAll = value;
                            numsOfChecked = model.numsOfChecked;
                          });
                        },
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
              onPressed: model.numsOfChecked < 1 || status == ViewStatus.Loading
                  ? null
                  : () async {
                      if (numsOfChecked == model.splitOrderList.length) {
                        if (model.selectedOrderStatus ==
                            OrderStatusEnum.PROCESSING) {
                          await model.confirmOrder(model.selectedOrderStatus);
                        } else {
                          await model
                              .shipperUpdateOrder(model.selectedOrderStatus);
                        }
                        setState(() {
                          numsOfChecked = model.numsOfChecked;
                          isSelectAll = false;
                        });
                      }
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
                          onChanged: (String? value) {
                            model.onChangeTimeSlot(value!);
                            setState(() {
                              numsOfChecked = 0;
                              isSelectAll = false;
                            });
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
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Trạng thái:",
                          style: FineTheme.typograhpy.h2.copyWith(
                            color: FineTheme.palettes.neutral900,
                          ),
                        ),
                        DropdownButton<int>(
                          value: model.selectedOrderStatus,
                          onChanged: (int? value) {
                            model.onChangeOrderStatus(value!);
                            setState(() {
                              numsOfChecked = 0;
                              isSelectAll = false;
                            });
                          },
                          items: isStaff
                              ? model.staffOrderStatuses
                                  .map<DropdownMenuItem<int>>((int status) {
                                  return DropdownMenuItem<int>(
                                    value: status,
                                    child: Text(
                                      OrderStatusEnum.getOrderStatusName(
                                          status),
                                      style:
                                          FineTheme.typograhpy.body1.copyWith(
                                        color: FineTheme.palettes.emerald25,
                                      ),
                                    ),
                                  );
                                }).toList()
                              : model.driverOrderStatuses
                                  .map<DropdownMenuItem<int>>((int status) {
                                  return DropdownMenuItem<int>(
                                    value: status,
                                    child: Text(
                                      OrderStatusEnum.getOrderStatusName(
                                          status),
                                      style:
                                          FineTheme.typograhpy.body1.copyWith(
                                        color: FineTheme.palettes.emerald25,
                                      ),
                                    ),
                                  );
                                }).toList(),
                        )
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: ToggleButtons(
                          renderBorder: false,
                          selectedColor: FineTheme.palettes.emerald25,
                          onPressed: (int index) {
                            model.onChangeSelectStation(index);
                            setState(() {
                              numsOfChecked = 0;
                              isSelectAll = false;
                            });
                          },
                          borderRadius: BorderRadius.circular(24),
                          isSelected: model.stationSelections,
                          children: [
                            ...model.stationList.map(
                              (e) => SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                child: Text("${e.name}",
                                    textAlign: TextAlign.center,
                                    style: FineTheme.typograhpy.caption1
                                        .copyWith(
                                            color:
                                                FineTheme.palettes.neutral900,
                                            fontWeight: FontWeight.bold)),
                              ),
                            )
                          ]),
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
    return ScopedModelDescendant<OrderListViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      List<OrderDTO> orderList = model.filteredOrderList;
      List<SplitOrderDTO> splitOrderList = model.splitOrderList;
      orderList.sort((a, b) {
        DateTime aDate = DateTime.parse(a.checkInDate!);
        DateTime bDate = DateTime.parse(b.checkInDate!);
        return bDate.compareTo(aDate);
      });
      if (status == ViewStatus.Loading) {
        return const Center(
          child: SkeletonListItem(itemCount: 8),
        );
      } else if (status == ViewStatus.Empty || splitOrderList.isEmpty) {
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
        key: _refreshIndicatorKey,
        onRefresh: refreshFetchOrder,
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
                        ...splitOrderList
                            .map((orderSummary) =>
                                _buildSplitOrderSummary(orderSummary))
                            .toList(),
                        loadMoreIcon(),
                      ],
                    ))),
          ],
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

  Widget _buildOrderSummary(OrderDTO orderSummary) {
    // final isToday = DateTime.parse(orderSummary.checkInDate!)
    //         .difference(DateTime.now())
    //         .inDays ==
    //     0;
    // var currentUser = Get.find<AccountViewModel>().currentUser;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text('${orderSummary.checkInDate?.substring(0, 16)}'),
                  // Text('${orderSummary.orderDetailStoreStatus}'),
                  // Text('${orderSummary.stationName}'),
                  ...orderSummary.orderDetails!
                      .toList()
                      .map((order) => _buildOrderItem(order)),
                ],
              ),
              Checkbox(
                checkColor: Colors.white,
                value: orderSummary.isChecked,
                onChanged: (bool? value) {
                  model.onCheck(
                      model.filteredOrderList.indexOf(orderSummary), value!);
                  setState(() {
                    numsOfChecked = model.numsOfChecked;
                  });
                },
              ),
            ],
          ),

          // ExpansionTile(
          //   title: Text("${orderSummary.orderDetails?.length} món"),
          //   children: [
          //     Container(
          //         color: FineTheme.palettes.neutral200,
          //         padding: EdgeInsets.all(16),
          //         width: double.infinity,
          //         child: Column(
          //           children: [
          //             ...orderSummary.orderDetails!
          //                 .toList()
          //                 .map((order) => _buildOrderItem(order))
          //                 .toList(),
          //           ],
          //         ))
          //   ],
          // ),

          // Text("Chi tiết", style: TextStyle(color: Colors.blue)),
          const SizedBox(
            height: 24,
          )
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderDetail orderDetail) {
    // var campus = Get.find<RootViewModel>().currentStore;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${orderDetail.productName}',
          style: FineTheme.typograhpy.subtitle2,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          " x ${orderDetail.quantity} ",
          style: FineTheme.typograhpy.caption1
              .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSplitOrderSummary(SplitOrderDTO splitOrderSummary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  model.onCheck(
                      model.splitOrderList.indexOf(splitOrderSummary), value!);
                  setState(() {
                    numsOfChecked = model.numsOfChecked;
                  });
                  if (numsOfChecked == model.splitOrderList.length) {
                    setState(() {
                      isSelectAll = true;
                    });
                  } else {
                    isSelectAll = false;
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
