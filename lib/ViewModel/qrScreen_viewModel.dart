import 'dart:typed_data';

import 'package:fine_merchant_mobile/Accessories/dialog.dart';
import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Utils/constrant.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/base_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Model/DAO/index.dart';
import '../Model/DTO/index.dart';

class StationViewModel extends BaseModel {
  // constant

  // local properties
  StationDAO? _stationDAO;
  Uint8List? imageBytes;
  // Data Object Model

  // Widget

  StationViewModel() {
    _stationDAO = StationDAO();
  }

  Future<void> getBoxQrCode(String boxId) async {
    try {
      setState(ViewStatus.Loading);

      // final qrcode = await _stationDAO!.getQrCodeByListBoxId(boxId);
      // imageBytes = qrcode;
      await Future.delayed(const Duration(milliseconds: 200));
      setState(ViewStatus.Completed);
    } catch (e) {
      print(e.toString());
    }
  }
}
