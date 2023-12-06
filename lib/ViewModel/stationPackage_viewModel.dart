import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'dart:developer';

import 'package:fine_merchant_mobile/Accessories/dialog.dart';
import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Utils/constrant.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/base_model.dart';
import 'package:fine_merchant_mobile/ViewModel/home_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/orderList_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../Model/DAO/index.dart';
import '../Model/DTO/index.dart';

class StationPackageViewModel extends BaseModel {
  // constant

  // local properties
  List<StationSplitProductDTO> splitProductsByStation = [];
  List<StoreDTO> storeList = [];
  List<TimeSlotDTO> timeSlotList = [];
  List<StationDTO> stationList = [];
  List<BoxDTO> boxList = [];
  String? selectedStoreId = '';
  String? selectedTimeSlotId = '';
  String? selectedBoxId = '';
  String? selectedStationId = '';
  // Data Object Model
  OrderDAO? _orderDAO;
  UtilsDAO? _utilsDAO;
  StationDAO? _stationDAO;
  SplitProductDAO? _splitProductDAO;
  dynamic error;
  OrderDTO? orderDTO;

  // Widget
  ScrollController? scrollController;
  bool isDelivering = false;

  List<bool> selections = [true, false];

  StationPackageViewModel() {
    _stationDAO = StationDAO();
    _orderDAO = OrderDAO();
    _utilsDAO = UtilsDAO();
    _splitProductDAO = SplitProductDAO();
    scrollController = ScrollController();
  }

  void onChangeTimeSlot(String value) {
    selectedTimeSlotId = value;
    getSplitOrdersByStation();
    notifyListeners();
  }

  Future<void> changeStatus(int index) async {
    selections = selections.map((e) => false).toList();
    selections[index] = true;
    notifyListeners();
  }

  Future<void> confirmDeliveryPackage(
      {required String stationId, required bool isEnoughProduct}) async {
    try {
      int option = await showOptionDialog(isEnoughProduct
          ? "Sẵn sàng giao cho trạm này?"
          : "Gói hàng này vẫn chưa đủ món và bạn sẽ chịu trách nhiệm cho việc thiếu món, vẫn giao cho trạm này?");

      if (option == 1) {
        showLoadingDialog();

        final statusCode = await _splitProductDAO?.confirmDeliveryProduct(
            stationId: stationId, timeSlotId: selectedTimeSlotId!);
        if (statusCode == 200) {
          notifyListeners();
          await showStatusDialog(
              "assets/images/icon-success.png", "Chuẩn bị thành công", "");
          Get.back();
        } else {
          await showStatusDialog(
            "assets/images/error.png",
            "Thất bại",
            "",
          );
        }
      }
    } on DioException catch (e) {
      log('error: ${e.toString()}');
      if (e.response != null && e.response?.statusCode != null) {
        String messageBody =
            "${DateFormat.yMd().add_jm().format(DateTime.now())} | $e${e.response!.data}";
        print(messageBody);
        if (e.response!.statusCode! < 400 || e.response!.statusCode! > 405) {
          await _utilsDAO?.logError(messageBody: messageBody);
        }
      }
      await showStatusDialog(
        "assets/images/error.png",
        "Thất bại",
        "Có lỗi xảy ra, vui lòng thử lại sau 😓",
      );
    } finally {
      await getSplitOrdersByStation();
    }
  }

  Future<void> getSplitOrdersByStation() async {
    try {
      setState(ViewStatus.Completed);
      selectedTimeSlotId = Get.find<OrderListViewModel>().selectedTimeSlotId;
      print('selectedTimeSlotId: $selectedTimeSlotId');

      final data = await _splitProductDAO?.getStationSplitProductsForStaff(
        timeSlotId: selectedTimeSlotId,
      );
      if (data != null) {
        splitProductsByStation = data;
        splitProductsByStation.sort((a, b) => a.isShipperAssign
            .toString()
            .compareTo(b.isShipperAssign.toString()));
      } else {
        splitProductsByStation = [];
      }

      notifyListeners();
      setState(ViewStatus.Completed);
    } on DioException catch (e) {
      log('error: ${e.toString()}');
      print(e);
      if (e.response != null && e.response?.statusCode != null) {
        String messageBody =
            "${DateFormat.yMd().add_jm().format(DateTime.now())} | $e${e.response!.data}";
        print(messageBody);
        if (e.response!.statusCode! < 400 || e.response!.statusCode! > 405) {
          await _utilsDAO?.logError(messageBody: messageBody);
        }
      }
      // bool result = await showErrorDialog();
      // if (result) {
      //   await getSplitOrdersByStation();
      // } else {
      //   setState(ViewStatus.Error);
      // }
    } finally {}
  }

  Future<void> getBoxListByStation() async {
    try {
      final data =
          await _stationDAO?.getAllBoxByStation(stationId: selectedStationId);
      if (data != null) {
        boxList = data;
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } on DioException catch (e) {
      log('error: ${e.toString()}');
      if (e.response != null && e.response?.statusCode != null) {
        String messageBody =
            "${DateFormat.yMd().add_jm().format(DateTime.now())} | $e${e.response!.data}";
        print(messageBody);
        if (e.response!.statusCode! < 400 || e.response!.statusCode! > 405) {
          await _utilsDAO?.logError(messageBody: messageBody);
        }
      }
      // bool result = await showErrorDialog();
      // if (result) {
      //   await getBoxListByStation();
      // } else {
      //   setState(ViewStatus.Error);
      // }
    } finally {}
  }
}
