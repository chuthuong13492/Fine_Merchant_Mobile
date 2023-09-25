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
      bool isDelivering = model.isDelivering;

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
                    await Get.find<HomeViewModel>()
                        .getDeliveredOrdersForDriver();
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
    return Column(
      children: [
        InkWell(
          onTap: () async {
            model.selectedStationId = report.stationId;
            await model.getBoxListByStation();
            currentReport = report;
            // ignore: use_build_context_synchronously
            _dialogBuilder(context);
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
                            Text('Số món thiếu:',
                                style: FineTheme.typograhpy.body1.copyWith(
                                    color: FineTheme.palettes.neutral900,
                                    fontWeight: FontWeight.bold)),
                            Text('${report.missingProducts!.length} món',
                                style: FineTheme.typograhpy.body1),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Text("Chi tiết",
                            style:
                                TextStyle(color: FineTheme.palettes.emerald25)),
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
          ...?currentReport?.missingProducts
              ?.map((product) => _buildReportProducts(product)),
        ],
      ),
    );
  }

  Widget _buildReportProducts(MissingProduct product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              '${product.productName}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal),
            ),
          ),
          Text(
            'x ${product.quantity}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    String? stationName = model.stationList
        .firstWhere((station) => station.id == currentReport?.stationId)
        .name;
    String? boxCode =
        model.boxList.firstWhere((box) => box.id == currentReport?.boxId).code;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chi tiết báo cáo', style: FineTheme.typograhpy.h2),
          content: SizedBox(
            height: 330,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trạm:',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal),
                    ),
                    Text(
                      '${stationName}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tủ:',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal),
                    ),
                    Text(
                      '${boxCode}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Center(
                  child: Text(
                    'Các món thiếu:',
                    style: FineTheme.typograhpy.body1
                        .copyWith(color: FineTheme.palettes.emerald25),
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
                    model.confirmReportSolved(
                        reportId: currentReport?.reportId);
                  },
                  child: Text(
                    "Đã xử lý",
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void _onTapDetail(PackageViewDTO package) async {
    // model.getOrders();
  }
}
