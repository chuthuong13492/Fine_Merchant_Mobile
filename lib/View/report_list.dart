import 'dart:async';
import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:fine_merchant_mobile/Utils/format_price.dart';
import 'package:fine_merchant_mobile/Utils/format_time.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/reportList_viewModel.dart';
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

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  late Timer periodicTimer;
  bool isDelivering = false;
  MissingProductReportDTO? currentReport;
  ReportListViewModel model = Get.put(ReportListViewModel());
  AccountDTO? currentUser = Get.find<AccountViewModel>().currentUser;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    model.stationList = Get.find<OrderListViewModel>().stationList;
    model.timeSlotList = Get.find<OrderListViewModel>().timeSlotList;
    model.selectedTimeSlotId =
        Get.find<OrderListViewModel>().selectedTimeSlotId;
    model.storeList = Get.find<OrderListViewModel>().storeList;
    model.selectedStoreId = Get.find<OrderListViewModel>().staffStore?.id;
    model.getReportList();
    if (model.reportList.isNotEmpty) {
      currentReport = model.reportList.first;
    }
    periodicTimer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      refreshFetchApi();
    });
  }

  @override
  void dispose() {
    super.dispose();
    periodicTimer.cancel();
  }

  Future<void> refreshFetchApi() async {
    model.getReportList();
  }

  @override
  Widget build(BuildContext context) {
    String? storeName = Get.find<OrderListViewModel>().staffStore!.storeName;
    return ScopedModel(
      model: Get.find<ReportListViewModel>(),
      child: Scaffold(
        appBar: DefaultAppBar(
          title: "Danh sách báo cáo",
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
                child: _buildReportList(),
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
    return ScopedModelDescendant<ReportListViewModel>(
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
  Widget _buildReportList() {
    return ScopedModelDescendant<ReportListViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      List<MissingProductReportDTO> reportList = model.reportList;

      if (status == ViewStatus.Loading) {
        return const Center(
          child: SkeletonListItem(itemCount: 8),
        );
      } else if (status == ViewStatus.Empty || reportList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Hiện tại chưa có báo cáo nào!'),
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
          controller: Get.find<ReportListViewModel>().scrollController,
          padding: const EdgeInsets.all(8),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ...reportList
                    .map((report) => _buildReportDetail(report))
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
    return ScopedModelDescendant<ReportListViewModel>(
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

  Widget _buildReportDetail(MissingProductReportDTO report) {
    String? stationName = model.stationList
        .firstWhere((station) => station.id == report.stationId)
        .name;
    int quantity = 0;
    List<ListBoxAndQuantity>? reportBoxes = report.listBoxAndQuantity;
    if (reportBoxes != null) {
      for (ListBoxAndQuantity reportBox in reportBoxes) {
        quantity = quantity + reportBox.quantity!;
      }
    }

    return Column(
      children: [
        InkWell(
          onTap: () async {
            // model.selectedStationId = report.stationId;
            // await model.getBoxListByStation();
            // currentReport = report;
            // // ignore: use_build_context_synchronously
            // _dialogBuilder(context);
          },
          child: Container(
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
                            Text('Trạm:',
                                style: FineTheme.typograhpy.body1.copyWith(
                                    color: FineTheme.palettes.neutral900,
                                    fontWeight: FontWeight.bold)),
                            Text('${stationName}',
                                style: FineTheme.typograhpy.body1),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Món thiếu:',
                                style: FineTheme.typograhpy.body1.copyWith(
                                    color: FineTheme.palettes.neutral900,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: 200,
                              child: Text('${report.productName}',
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: FineTheme.typograhpy.body1),
                            ),
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
                            Text('${quantity}',
                                overflow: TextOverflow.ellipsis,
                                style: FineTheme.typograhpy.body1),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        // Text("Chi tiết",
                        //     style:
                        //         TextStyle(color: FineTheme.palettes.emerald25)),
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
                            model.confirmReportSolved(
                                reportId: report.reportId);
                          },
                          child: Text(
                            "Đã xử lý",
                            style: FineTheme.typograhpy.subtitle2
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    )),
              )),
        ),
      ],
    );
  }

  Widget _buildReportSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ...?currentReport?.listBoxAndQuantity
              ?.map((reportBox) => _buildReportProducts(reportBox)),
        ],
      ),
    );
  }

  Widget _buildReportProducts(ListBoxAndQuantity? reportBox) {
    String? boxCode =
        model.boxList.firstWhere((box) => box.id == reportBox?.boxId).code;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$boxCode',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal),
          ),
          Text(
            '${reportBox?.quantity}',
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned(
                top: -20,
                right: -15,
                child: TextButton(
                  style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                      alignment: Alignment.topRight),
                  child: Icon(Icons.close_outlined,
                      color: FineTheme.palettes.emerald25),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  height: 350,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        width: 300,
                        decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(width: 1))),
                        child: Text('Chi tiết báo cáo',
                            style: FineTheme.typograhpy.h2),
                      ),
                      SizedBox(
                        height: 330,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Món đang thiếu:',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    '${currentReport?.productName}',
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Center(
                              child: Text(
                                'Các tủ đang thiếu:',
                                style: FineTheme.typograhpy.body1.copyWith(
                                    color: FineTheme.palettes.emerald25),
                              ),
                            ),
                            SizedBox(
                                height: 240,
                                width: 300,
                                child: Scrollbar(
                                  child: ListView(
                                    children: [
                                      _buildReportSection(),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ]),
          ),
        );
      },
    );
  }

  void _onTapDetail(PackageViewDTO package) async {
    // model.getOrders();
  }
}
