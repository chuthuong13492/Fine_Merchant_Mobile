import 'package:fine_merchant_mobile/Accessories/appbar.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DTO/BoxDTO.dart';
import 'package:fine_merchant_mobile/Model/DTO/OrderDTO.dart';
import 'package:fine_merchant_mobile/ViewModel/qrScreen_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';
import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class QRCodeScreen extends StatefulWidget {
  final ShipperOrderBoxDTO orderBox;

  const QRCodeScreen({super.key, required this.orderBox});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  QrScreenViewModel model = Get.put(QrScreenViewModel());
  List<OrderDetail> orderBoxDetails = [];

  @override
  void initState() {
    super.initState();
    model.boxList = Get.find<StationViewModel>().boxList;
    orderBoxDetails = widget.orderBox.orderDetails!;
    model.getBoxQrCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FineTheme.palettes.primary100,
      appBar: DefaultAppBar(
          title:
              "Chi tiết tủ ${model.boxList.firstWhere((box) => box.id == widget.orderBox.boxId).code}"),
      body: ScopedModel(
          model: Get.find<StationViewModel>(),
          child: ScopedModelDescendant<StationViewModel>(
            builder: (context, child, model) {
              return Padding(
                padding: const EdgeInsets.only(right: 16, left: 16),
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    _buildOrderInfo(),
                    const SizedBox(height: 16),
                    _buildQrCodeSection(),
                  ],
                ),
              );
            },
          )),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
        padding: const EdgeInsets.all(16),
        width: Get.width,
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: ScopedModelDescendant<StationViewModel>(
          builder: (context, child, model) {
            String? stationName = model.stationList
                .firstWhere((station) => station.id == model.selectedStationId)
                .name;

            return Column(
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
                Row(
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
                      '${stationName}',
                      style: TextStyle(
                          color: FineTheme.palettes.emerald25,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Center(
                  child: Text(
                    'Số món cần đặt: ${orderBoxDetails.length}',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontStyle: FontStyle.normal,
                        color: FineTheme.palettes.shades200),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ...orderBoxDetails
                          .map((detail) => buildOrderDetail(detail))
                    ],
                  ),
                )
              ],
            );
          },
        ));
  }

  Widget _buildQrCodeSection() {
    return ScopedModel(
        model: Get.find<QrScreenViewModel>(),
        child: ScopedModelDescendant<QrScreenViewModel>(
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
                    const SizedBox(height: 50),
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
                      : const SizedBox.shrink(),
                  const Text(
                    'Hãy đưa mã để mở tủ!',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal),
                  ),
                ],
              ),
            );
          },
        ));
  }

  Widget buildOrderDetail(OrderDetail orderDetail) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${orderDetail.productName}',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    color: FineTheme.palettes.shades200),
              ),
              Text(
                'x ${orderDetail.quantity}',
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
}
