import 'package:fine_merchant_mobile/Accessories/appbar.dart';
import 'package:fine_merchant_mobile/Accessories/loading.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:fine_merchant_mobile/ViewModel/deliveryList_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';
import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class PackageDetailScreen extends StatefulWidget {
  final PackageViewDTO package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FineTheme.palettes.primary100,
      appBar: DefaultAppBar(title: "Chi tiết gói hàng"),
      body: ScopedModel(
          model: Get.find<DeliveryListViewModel>(),
          child: ScopedModelDescendant<DeliveryListViewModel>(
            builder: (context, child, model) {
              TimeSlotDTO? timeSlot = model.timeSlotList.firstWhere(
                  (timeSlot) => timeSlot.id == widget.package.timeSlotId);
              String? stationName = model.stationList
                  .firstWhere(
                      (station) => station.id == widget.package.stationId)
                  .name;
              String? storeName = model.storeList
                  .firstWhere((store) => store.id == model.selectedStoreId)
                  .storeName;
              bool isDelivering = model.isDelivering;
              return Padding(
                padding: const EdgeInsets.only(right: 16, left: 16),
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    _buildPackageInfo(stationName, timeSlot, storeName),
                    const SizedBox(height: 16),
                    _buildDetailSection(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    // BorderRadius.only(
                                    //     bottomRight: Radius.circular(16),
                                    //     bottomLeft: Radius.circular(16))
                                    BorderRadius.all(Radius.circular(8))),
                          ),
                          onPressed: () async {
                            model.confirmDelivery(widget.package);
                          },
                          child: Text(
                            "${isDelivering ? "Xác nhận bỏ vào tủ" : "Xác nhận lấy hàng"}",
                            style: FineTheme.typograhpy.subtitle2
                                .copyWith(color: FineTheme.palettes.emerald25),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          )),
    );
  }

  Widget _buildPackageInfo(
      String? stationName, TimeSlotDTO? timeSlot, String? storeName) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: Get.width,
      height: 160,
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
              'Giao tại:',
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
                  '${timeSlot?.checkoutTime}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              'Mua tại:',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  color: FineTheme.palettes.shades200),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cửa hàng:',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    color: FineTheme.palettes.shades200),
              ),
              Text(
                '$storeName',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    List<ListProduct>? productList = widget.package.listProducts;
    return ScopedModel(
        model: Get.find<DeliveryListViewModel>(),
        child: ScopedModelDescendant<DeliveryListViewModel>(
          builder: (context, child, model) {
            if (model.status == ViewStatus.Loading) {
              return Container(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                width: Get.width,
                height: 500,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Column(
                  children: const [
                    LoadingFine(),
                    SizedBox(height: 50),
                  ],
                ),
              );
            }
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              width: Get.width,
              height: 500,
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
                          'Số món: ${productList?.length}',
                          style: FineTheme.typograhpy.h2,
                        ),
                        const SizedBox(height: 8),
                        ...?productList
                            ?.map((product) => _buildPackageProduct(product)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ));
  }

  Widget _buildPackageProduct(ListProduct product) {
    // var campus = Get.find<RootViewModel>().currentStore;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${product.productName}',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal),
          ),
          Text(
            'x ${product.quantity}',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal),
          ),
        ],
      ),
    );
  }
}
