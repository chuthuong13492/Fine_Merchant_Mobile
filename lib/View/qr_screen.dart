import 'package:fine_merchant_mobile/Accessories/appbar.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DTO/BoxDTO.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';
import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class QRCodeScreen extends StatefulWidget {
  final BoxDTO box;

  const QRCodeScreen({super.key, required this.box});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FineTheme.palettes.primary100,
      appBar: DefaultAppBar(title: "Box QR Code"),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    'Các món hàng trong tủ:',
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cà phê',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontStyle: FontStyle.normal,
                                  color: FineTheme.palettes.shades200),
                            ),
                            Text(
                              'x 3',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal),
                              overflow: TextOverflow.ellipsis,
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
                              'Trà sữa',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontStyle: FontStyle.normal,
                                  color: FineTheme.palettes.shades200),
                            ),
                            Text(
                              'x 3',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal),
                              overflow: TextOverflow.ellipsis,
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
                              'Bánh mì',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontStyle: FontStyle.normal,
                                  color: FineTheme.palettes.shades200),
                            ),
                            Text(
                              'x 3',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
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
        model: Get.find<StationViewModel>(),
        child: ScopedModelDescendant<StationViewModel>(
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
                            'QR Code mở tủ',
                            style: FineTheme.typograhpy.h2,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Hãy quét mã QR code có tại station',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'FINE sẽ giúp bạn mở chiếc tủ bạn cần nha',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal),
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
                          'QR Code của tủ ${widget.box.code}',
                          style: FineTheme.typograhpy.h2,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Hãy quét mã QR Code để mở',
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  model.imageBytes != null
                      ? Container(
                          height: 300,
                          width: 300,
                          child: Image.memory(
                            model.imageBytes!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            );
          },
        ));
  }
}
