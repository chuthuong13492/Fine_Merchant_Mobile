import 'dart:async';

import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:fine_merchant_mobile/Utils/format_time.dart';
import 'package:fine_merchant_mobile/Utils/text_fields.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/orderList_viewModel.dart';
import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:fine_merchant_mobile/widgets/skeleton_list.dart';
import 'package:flutter/services.dart';
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

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey2 =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey3 =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    periodicTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      refreshFetchOrder();
    });
  }

  @override
  void dispose() {
    periodicTimer.cancel();
    super.dispose();
  }

  Future<void> refreshFetchOrder() async {
    await model.getTimeSlotList();
    await model.getSplitOrders();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = model.status;
    var staffStore = Get.find<AccountViewModel>().currentStore;
    return ScopedModel(
      model: Get.find<OrderListViewModel>(),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: DefaultAppBar(
              title: "Đơn hàng chờ duyệt",
              backButton: const SizedBox.shrink(),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(120),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${staffStore?.storeName}',
                      style: FineTheme.typograhpy.h2.copyWith(
                        color: FineTheme.palettes.emerald25,
                      ),
                    ),
                  ))),
          body: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
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
                                      style:
                                          FineTheme.typograhpy.body2.copyWith(
                                        color: FineTheme.palettes.neutral900,
                                      ),
                                    ),
                                    Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: FineTheme.palettes.emerald25,
                                      value: model.isAllChecked,
                                      onChanged: model.splitOrder != null &&
                                              model.splitOrder!
                                                      .productTotalDetailList !=
                                                  null
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
                              child: _buildPendingProducts(),
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
                                    await model.updateSplitProductsStatus(
                                        statusType:
                                            UpdateSplitProductTypeEnum.CONFIRM);
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
                          const SizedBox(height: 50),
                        ],
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12, bottom: 12),
                                  child: Text(
                                    'Sản phẩm',
                                    style: FineTheme.typograhpy.h2.copyWith(
                                      color: FineTheme.palettes.emerald50,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              // ignore: sort_child_properties_last
                              child: _buildConfirmedProducts(),
                              color: const Color(0xffefefef),
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12, bottom: 12),
                                  child: Text(
                                    'Sản phẩm',
                                    style: FineTheme.typograhpy.h2.copyWith(
                                      color: FineTheme.palettes.emerald50,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              // ignore: sort_child_properties_last
                              child: _buildReportedProducts(),
                              color: const Color(0xffefefef),
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

////////////////////

  Widget orderFilterSection() {
    // SplitOrderDTO? splitOrder = model.splitOrder;
    return ScopedModelDescendant<OrderListViewModel>(
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
                            model.notifierReady.value != null
                                ? Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Material(
                                      color: Colors.red,
                                      shape: const CircleBorder(
                                          side: BorderSide(
                                              color: Colors.red, width: 2)),
                                      child: SizedBox(
                                        width: model.notifierReady.value >= 10
                                            ? 24
                                            : 20,
                                        height: model.notifierReady.value >= 10
                                            ? 24
                                            : 20,
                                        child: Center(
                                          child: Text(
                                            '${model.notifierReady.value}',
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
                        Stack(
                          children: [
                            model.notifierError.value != 0
                                ? const Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Material(
                                      color: Colors.red,
                                      shape: CircleBorder(
                                          side: BorderSide(
                                              color: Colors.red, width: 2)),
                                      child: SizedBox(
                                        width: 10,
                                        height: 10,
                                      ),
                                    ))
                                : const SizedBox.shrink(),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 12, bottom: 12, right: 12),
                              child: Text("Báo cáo",
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

////////////////////
  Widget _buildPendingProducts() {
    List<ProductTotalDetail>? pendingProductList = model.pendingProductList;

    return ScopedModelDescendant<OrderListViewModel>(
        builder: (context, child, model) {
      final status = model.status;

      if (status == ViewStatus.Loading) {
        return const Center(
          child: SkeletonListItem(itemCount: 8),
        );
      } else if (status == ViewStatus.Empty || pendingProductList!.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Hiện tại chưa có món nào cần xử lý.'),
              // Padding(
              //   padding: const EdgeInsets.all(15),
              //   child: InkWell(
              //     onTap: () async {
              //       refreshFetchOrder();
              //     },
              //     child: Icon(
              //       Icons.replay,
              //       color: FineTheme.palettes.primary300,
              //       size: 26,
              //     ),
              //   ),
              // ),
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
                          ...pendingProductList
                              .map((splitProduct) =>
                                  _buildSplitProductWithCheckbox(splitProduct))
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

  Widget _buildConfirmedProducts() {
    List<ProductTotalDetail>? confirmedProductList = model.confirmedProductList;

    return ScopedModelDescendant<OrderListViewModel>(
        builder: (context, child, model) {
      final status = model.status;

      if (status == ViewStatus.Loading) {
        return const Center(
          child: SkeletonListItem(itemCount: 8),
        );
      } else if (status == ViewStatus.Empty || confirmedProductList!.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Hiện tại chưa có món nào đã xử lý'),
              // Padding(
              //   padding: const EdgeInsets.all(15),
              //   child: InkWell(
              //     onTap: () async {
              //       refreshFetchOrder();
              //     },
              //     child: Icon(
              //       Icons.replay,
              //       color: FineTheme.palettes.primary300,
              //       size: 26,
              //     ),
              //   ),
              // ),
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
                          ...confirmedProductList
                              .map((splitProduct) => _buildSplitProduct(
                                  splitProduct.productName!,
                                  splitProduct.readyQuantity!))
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

  Widget _buildReportedProducts() {
    List<ErrorProducts>? errorProductList = model.errorProductList;

    return ScopedModelDescendant<OrderListViewModel>(
        builder: (context, child, model) {
      final status = model.status;

      if (status == ViewStatus.Loading) {
        return const Center(
          child: SkeletonListItem(itemCount: 8),
        );
      } else if (status == ViewStatus.Empty || errorProductList!.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Hiện tại chưa có món nào được báo cáo'),
              // Padding(
              //   padding: const EdgeInsets.all(15),
              //   child: InkWell(
              //     onTap: () async {
              //       refreshFetchOrder();
              //     },
              //     child: Icon(
              //       Icons.replay,
              //       color: FineTheme.palettes.primary300,
              //       size: 26,
              //     ),
              //   ),
              // ),
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
        key: _refreshIndicatorKey3,
        onRefresh: refreshFetchOrder,
        child: Scrollbar(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: Get.find<OrderListViewModel>().scrollController,
            padding: const EdgeInsets.all(8),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...errorProductList
                      .map((product) => _buildReportedProduct(product))
                      .toList(),
                  loadMoreIcon(),
                ],
              ),
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

  Widget _buildSplitProductWithCheckbox(ProductTotalDetail product) {
    List<ProductTotalDetail>? splitProductList = model.pendingProductList;
    return InkWell(
      onLongPress: product.isChecked!
          ? () {
              setState(() {
                model.currentMissing = 1;
              });
              _dialogBuilder(context, product);
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 150,
                child: Text('${product.productName}',
                    style: FineTheme.typograhpy.caption1)),
            Row(
              children: [
                SizedBox(
                    child: Row(
                  children: [
                    Text('x ${product.pendingQuantity}',
                        style: FineTheme.typograhpy.caption1),
                  ],
                )),
                Checkbox(
                  activeColor: FineTheme.palettes.emerald25,
                  checkColor: Colors.white,
                  value: product.isChecked,
                  onChanged: (bool? value) {
                    int index = splitProductList!.indexOf(product);
                    model.onCheck(index, value!);
                    int numsOfPendingProducts = splitProductList!
                        .where((e) => e.pendingQuantity! > 0)
                        .length;
                    if (model.numsOfCheck == numsOfPendingProducts) {
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
      ),
    );
  }

  Widget _buildSplitProduct(String productName, int quantity) {
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
              child: Text('$productName'),
            ),
          ),
          SizedBox(child: Text('x $quantity')),
        ],
      ),
    );
  }

  Widget _buildReportedProduct(ErrorProducts product) {
    String? stationName = '';
    if (product.stationId != null) {
      stationName = model.stationList
          .firstWhere((station) => station.id == product.stationId)
          .name;
    }
    int productIndex = model.errorProductList!
        .indexWhere((e) => e.productId == product.productId);
    return Column(
      children: [
        Container(
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
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Món:',
                          style: FineTheme.typograhpy.subtitle2,
                        ),
                      ),
                      SizedBox(
                          child: Text('${product.productName}',
                              style: FineTheme.typograhpy.subtitle2)),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Số lượng:',
                          style: FineTheme.typograhpy.subtitle2,
                        ),
                      ),
                      SizedBox(
                          child: Text('${product.quantity}',
                              style: FineTheme.typograhpy.subtitle2)),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Số lượng đã xử lý:',
                          style: FineTheme.typograhpy.subtitle2,
                        ),
                      ),
                      SizedBox(
                          child: Text('${product.reConfirmQuantity}',
                              style: FineTheme.typograhpy.subtitle2)),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Bởi:',
                          style: FineTheme.typograhpy.subtitle2,
                        ),
                      ),
                      SizedBox(
                          child: Text(
                              '${product.reportMemType == 2 ? "Staff" : "Shipper"}',
                              style: FineTheme.typograhpy.subtitle2)),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  product.reportMemType == 3
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              child: Text(
                                'Tại trạm:',
                                style: FineTheme.typograhpy.subtitle2,
                              ),
                            ),
                            SizedBox(
                                child: Text('${stationName}',
                                    style: FineTheme.typograhpy.subtitle2)),
                          ],
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 40,
                        child: TextFormField(
                          initialValue: product.numsToSolve.toString(),
                          onChanged: (value) {
                            if (value != "") {
                              int? newValue = int.tryParse(value);
                              if (newValue != null && newValue >= 1) {
                                model.onChangeNumberToSolve(
                                    productIndex, newValue);
                              } else {
                                model.onChangeNumberToSolve(productIndex, 1);
                              }
                              setState(() {});
                            }
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            // FilteringTextInputFormatter.allow(digitValidator),
                            NumericalRangeFormatter(
                                min: 1, max: product.quantity!)
                          ],
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                          decoration: InputDecoration(
                            label: const Text('Số lượng xử lý'),
                            floatingLabelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: FineTheme.palettes.primary100),
                            focusColor: FineTheme.palettes.primary100,
                            fillColor: FineTheme.palettes.primary100,
                            hoverColor: FineTheme.palettes.primary100,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: FineTheme.palettes.primary100,
                                  width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: FineTheme.palettes.primary100,
                                  width: 1),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: product.numsToSolve! > 0
                            ? () async {
                                await model.updateReportProduct(
                                    productId: product.productId!,
                                    quantity: product.numsToSolve!,
                                    type: UpdateSplitProductTypeEnum.RECONFIRM);
                              }
                            : null,
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: product.numsToSolve! > 0
                                    ? FineTheme.palettes.primary100
                                    : FineTheme.palettes.neutral700),
                            boxShadow: [
                              BoxShadow(
                                color: product.numsToSolve! > 0
                                    ? FineTheme.palettes.primary100
                                    : FineTheme.palettes.neutral700,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Đã xử lý",
                              style: FineTheme.typograhpy.subtitle1.copyWith(
                                  color: product.numsToSolve! > 0
                                      ? FineTheme.palettes.primary100
                                      : FineTheme.palettes.neutral700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Future<void> _dialogBuilder(
      BuildContext context, ProductTotalDetail product) {
    // int productIndex = model.pendingProductList!
    //     .indexWhere((e) => e.productId == product.productId);
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
                      'Số lượng bị thiếu của món ${product.productName}',
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
                      product.pendingQuantity! > 1
                          ? IconButton(
                              splashRadius: 24,
                              icon: const Icon(
                                Icons.remove,
                                size: 32,
                              ),
                              onPressed: () {
                                if (model.currentMissing > 1) {
                                  // model.onChangeMissing(productIndex,
                                  //     product.currentMissing! - 1);
                                  model.currentMissing--;
                                  setState(() {});
                                }
                              },
                              color: FineTheme.palettes.emerald25,
                            )
                          : const SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Text(
                          '${model.currentMissing}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal),
                        ),
                      ),
                      product.pendingQuantity! > 1
                          ? IconButton(
                              splashRadius: 24,
                              icon: const Icon(Icons.add, size: 32),
                              onPressed: () {
                                if (model.currentMissing <
                                    product.pendingQuantity!) {
                                  // model.onChangeMissing(productIndex,
                                  //     product.currentMissing! + 1);
                                  model.currentMissing++;
                                  setState(() {});
                                }
                              },
                              color: FineTheme.palettes.emerald25,
                            )
                          : const SizedBox.shrink(),
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
                onPressed: () async {
                  // model.onChangeMissing(
                  //     splitProductIndex, model.currentMissing);
                  await model.updateReportProduct(
                      productId: product.productId!,
                      quantity: model.currentMissing,
                      type: UpdateSplitProductTypeEnum.ERROR);
                  // ignore: use_build_context_synchronously
                  // Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }
}

// Column(
//   children: [
//     Container(
//       color: Colors.white70,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
//           child: ToggleButtons(
//               renderBorder: false,
//               selectedColor: FineTheme.palettes.emerald25,
//               onPressed: (int index) async {
//                 await model.onChangeSelectStation(index);
//                 setState(() {});
//               },
//               borderRadius: BorderRadius.circular(24),
//               isSelected: model.stationSelections,
//               children: [
//                 ...model.stationList.map(
//                   (e) => Stack(
//                     children: [
//                       Container(
//                         margin: const EdgeInsets.only(
//                             top: 16, bottom: 16),
//                         width: MediaQuery.of(context)
//                                 .size
//                                 .width /
//                             3,
//                         child: Text("${e.name}",
//                             textAlign: TextAlign.center,
//                             style: FineTheme
//                                 .typograhpy.caption1
//                                 .copyWith(
//                                     color: FineTheme
//                                         .palettes
//                                         .neutral900,
//                                     fontWeight:
//                                         FontWeight.bold)),
//                       ),
//                     ],
//                   ),
//                 )
//               ]),
//         ),
//       ),
//     ),
//     Expanded(
//       child: Container(
//         // ignore: sort_child_properties_last
//         child: _buildOrdersByStation(),
//         color: const Color(0xffefefef),
//       ),
//     ),
//     const SizedBox(height: 50),
//   ],
// ),
