import 'package:fine_merchant_mobile/Accessories/index.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../Constant/view_status.dart';
import '../Model/DTO/index.dart';
import '../ViewModel/stationPackage_viewModel.dart';
import '../theme/FineTheme/index.dart';

class StationPackageDetail extends StatefulWidget {
  final StationSplitProductDTO stationSplitProductDTO;
  const StationPackageDetail({super.key, required this.stationSplitProductDTO});

  @override
  State<StationPackageDetail> createState() => _StationPackageDetailState();
}

class _StationPackageDetailState extends State<StationPackageDetail> {
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: Get.find<StationPackageViewModel>(),
      child: Scaffold(
        appBar: StationPackageDetailAppBar(
            title: "Trạm ${widget.stationSplitProductDTO.stationName}"),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _detailStatusBar(),
            const SizedBox(height: 2),
            Expanded(
              child: Container(
                width: Get.width,
                // ignore: sort_child_properties_last
                padding: const EdgeInsets.all(10),
                child: _buildDetail(),
                color: const Color(0xffefefef),
              ),
            ),
            // const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  Widget _detailStatusBar() {
    return ScopedModelDescendant<StationPackageViewModel>(
      builder: (context, child, model) {
        return Center(
          child: Container(
            // color: Colors.amber,
            // padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
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
              child: ToggleButtons(
                renderBorder: false,
                selectedColor: FineTheme.palettes.primary100,
                onPressed: (int index) async {
                  await model.changeStatus(index);
                },
                // borderRadius: BorderRadius.circular(24),
                isSelected: model.selections,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      "Món đã chuẩn bị",
                      textAlign: TextAlign.center,
                      style: FineTheme.typograhpy.subtitle1,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      "Món còn thiếu",
                      textAlign: TextAlign.center,
                      style: FineTheme.typograhpy.subtitle1,
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

  Widget _buildDetail() {
    return ScopedModelDescendant<StationPackageViewModel>(
      builder: (context, child, model) {
        if (model.selections[0] == true) {
          return Container(
            height: Get.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
            ),
            // padding: const EdgeInsets.only(bottom: 30),
            child: widget.stationSplitProductDTO.packageStationDetails != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    children: [
                      ...widget.stationSplitProductDTO.packageStationDetails!
                          .map((product) =>
                              _buildPackageProducts(product: product)),
                    ],
                  )
                : const Center(
                    child: Text("Hiện chưa có món"),
                  ),
          );
        } else {
          return Container(
            width: Get.width,
            height: Get.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
            ),
            // padding: const EdgeInsets.only(bottom: 30),
            child: widget.stationSplitProductDTO.listPackageMissing?.length != 0
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    children: [
                      ...widget.stationSplitProductDTO.listPackageMissing!.map(
                          (missing) => _buildPackageProducts(missing: missing)),
                    ],
                  )
                : const Center(
                    child: Text("Hiện chưa có món"),
                  ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPackageProducts(
      {PackageStationDetails? product, PakageMissingList? missing}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            product != null
                ? '${product.productName}'
                : '${missing!.productName}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal),
          ),
          Text(
            product != null
                ? 'x ${product.quantity}'
                : 'x ${missing!.quantity}',
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal),
          ),
        ],
      ),
    );
  }
}
