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
}
