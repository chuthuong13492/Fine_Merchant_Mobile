import 'package:fine_merchant_mobile/Accessories/appbar.dart';
import 'package:fine_merchant_mobile/Accessories/loading.dart';
import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:fine_merchant_mobile/ViewModel/home_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';
import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class PackageDetailScreen extends StatefulWidget {
  const PackageDetailScreen({super.key});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  HomeViewModel model = Get.find<HomeViewModel>();

  @override
  void initState() {
    super.initState();
    model.imageBytes = Get.find<HomeViewModel>().imageBytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FineTheme.palettes.primary100,
      appBar: StationPackageDetailAppBar(
          title: "Thông tin giao hàng", backButton: const SizedBox.shrink()),
      body: ScopedModel(
          model: Get.find<HomeViewModel>(),
          child: ScopedModelDescendant<HomeViewModel>(
            builder: (context, child, model) {
              TimeSlotDTO? timeSlot = model.timeSlotList.firstWhere(
                  (timeSlot) => timeSlot.id == model.selectedTimeSlotId);
              String? stationName = model.stationList
                  .firstWhere(
                      (station) => station.id == model.selectedStationId)
                  .name;

              return Padding(
                padding: const EdgeInsets.only(right: 16, left: 16),
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    _buildPackageInfo(stationName, timeSlot),
                    const SizedBox(height: 8),
                    _buildDetailSection(),
                  ],
                ),
              );
            },
          )),
    );
  }

  Widget _buildPackageInfo(String? stationName, TimeSlotDTO? timeSlot) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: Get.width,
      height: Get.height * 0.275,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Text(
              'Thông tin:',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  color: FineTheme.palettes.shades200),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trạm:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      color: FineTheme.palettes.shades200),
                ),
                Text(
                  '$stationName',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vào lúc:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      color: FineTheme.palettes.shades200),
                ),
                Text(
                  '${timeSlot?.checkoutTime!.substring(0, 5)}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Số gói hàng:',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    color: FineTheme.palettes.shades200),
              ),
              OutlinedButton(
                onPressed: model.takenPackageList.isNotEmpty
                    ? () => _dialogBuilder(context)
                    : null,
                child: Text(
                  model.takenPackageList.isNotEmpty
                      ? 'Xem chi tiết (${model.takenPackageList.length})'
                      : 'Chưa lấy gói hàng nào',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      color: model.takenPackageList.isNotEmpty
                          ? FineTheme.palettes.emerald25
                          : FineTheme.palettes.neutral700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
              ),
              onPressed: model.takenPackageList.isNotEmpty
                  ? () {
                      _onTapToProductBoxes();
                    }
                  : null,
              child: Text(
                'Xem danh sách tủ theo món',
                style: FineTheme.typograhpy.body1.copyWith(
                  color: model.takenPackageList.isNotEmpty
                      ? FineTheme.palettes.emerald25
                      : FineTheme.palettes.neutral700,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    return ScopedModel(
        model: Get.find<HomeViewModel>(),
        child: ScopedModelDescendant<HomeViewModel>(
          builder: (context, child, model) {
            if (model.status == ViewStatus.Loading ||
                model.takenPackageList.isEmpty) {
              return Container(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                width: Get.width,
                height: Get.height * 0.6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      // padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Đang lấy mã QR...',
                            style: FineTheme.typograhpy.h2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return Container(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
              width: Get.width,
              height: Get.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    // padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'QR Code để mở tủ',
                          style: FineTheme.typograhpy.h2,
                        ),
                      ],
                    ),
                  ),
                  model.imageBytes != null
                      ? Container(
                          height: 300,
                          width: 300,
                          child: Image.memory(
                            model.imageBytes!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : const SizedBox(
                          height: 300,
                          width: 300,
                        ),
                  Column(
                    children: [
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
                        onPressed: () async {
                          await model.confirmAllBoxStored();
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Text(
                            "Đã đặt đủ hàng vào các tủ",
                            style: FineTheme.typograhpy.subtitle2
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ));
  }

  Widget _buildPackageSection(PackageStoreShipperResponses package) {
    String? storeName = model.storeList
        .firstWhere((store) => store.id == package.storeId)
        .storeName;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            child: Text(
              '${storeName}',
              style: TextStyle(
                  color: FineTheme.palettes.emerald25,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          ...?package.packStationDetailGroupByProducts
              ?.map((product) => _buildPackageProducts(product)),
        ],
      ),
    );
  }

  Widget _buildPackageProducts(PackStationDetailGroupByProducts product) {
    // var campus = Get.find<RootViewModel>().currentStore;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              '${product.productName}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              'x ${product.totalQuantity}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          List<PackageStoreShipperResponses>? packageList =
              model.takenPackageList;
          return AlertDialog(
            title: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 50,
                  width: 300,
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1))),
                  child: Text('Chi tiết các gói hàng',
                      style: FineTheme.typograhpy.h2
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
                height: 300,
                width: 300,
                child: Scrollbar(
                  child: ListView(
                    children: [
                      const SizedBox(height: 8),
                      ...packageList
                          .map((package) => _buildPackageSection(package)),
                    ],
                  ),
                )),
          );
        });
      },
    );
  }

  void _onTapToProductBoxes() async {
    bool isRouted = true;
    await Get.find<StationViewModel>().getBoxListByStation();
    await Future.delayed(const Duration(milliseconds: 300));
    await Get.toNamed(RouteHandler.STATION_SCREEN, arguments: isRouted);
  }
}
