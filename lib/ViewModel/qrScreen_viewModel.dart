import 'dart:typed_data';

import 'package:fine_merchant_mobile/Accessories/dialog.dart';
import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Utils/constrant.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/base_model.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Model/DAO/index.dart';
import '../Model/DTO/index.dart';

class QrScreenViewModel extends BaseModel {
  // constant

  // local properties
  List<ShipperOrderBoxDTO> orderBoxList = [];
  List<BoxDTO> boxList = [];
  StationDAO? _stationDAO;
  Uint8List? imageBytes;
  // Data Object Model

  // Widget

  QrScreenViewModel() {
    _stationDAO = StationDAO();
  }

  Future<void> getBoxQrCode() async {
    try {
      setState(ViewStatus.Loading);
      imageBytes = null;

      List<StationQrCodeRequestModel> requestData = [];
      for (ShipperOrderBoxDTO orderBox in orderBoxList) {
        List<OrderDetail>? orderDetails = orderBox.orderDetails;
        if (orderDetails!.isNotEmpty) {
          requestData.add(StationQrCodeRequestModel(
              boxId: orderBox.boxId, orderId: orderDetails.first.orderId));
        }
      }
      print(requestData);
      final qrCode =
          await _stationDAO!.getQrCodeForShipper(requestData: requestData);
      if (qrCode != null) {
        imageBytes = qrCode;
      }

      await Future.delayed(const Duration(milliseconds: 200));
      notifyListeners();
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getBoxQrCode();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }
}
