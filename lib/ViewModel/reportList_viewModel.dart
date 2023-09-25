import 'package:fine_merchant_mobile/Accessories/dialog.dart';
import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Utils/constrant.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/base_model.dart';
import 'package:fine_merchant_mobile/ViewModel/home_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Model/DAO/index.dart';
import '../Model/DTO/index.dart';

class ReportListViewModel extends BaseModel {
  // constant

  // local properties
  List<MissingProductReportDTO> reportList = [];
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
  StationDAO? _stationDAO;
  dynamic error;
  OrderDTO? orderDTO;
  // Widget
  ScrollController? scrollController;
  bool isDelivering = false;
  PackageViewDTO? currentDeliveryPackage;
  ReportListViewModel() {
    _stationDAO = StationDAO();
    _orderDAO = OrderDAO();

    scrollController = ScrollController();
  }

  void onChangeTimeSlot(String value) {
    selectedTimeSlotId = value;

    notifyListeners();
  }

  Future<void> getReportList() async {
    try {
      setState(ViewStatus.Loading);
      final data = await _stationDAO?.getMissingProductReport(
          storeId: selectedStoreId, timeSlotId: selectedTimeSlotId);
      if (data != null) {
        reportList = data;
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getReportList();
      } else {
        setState(ViewStatus.Error);
      }
    }
  }

  Future<void> confirmReportSolved({String? reportId}) async {
    try {
      int option = await showOptionDialog("Xác nhận đã xử lí?");
      if (option == 1) {
        showLoadingDialog();
        final status =
            await _stationDAO?.confirmReportSolved(reportId: reportId);

        if (status == 200) {
          await showStatusDialog(
              "assets/images/icon-success.png", "Xử lí thành công", "");
        }
        await getReportList();
        Get.back();
        setState(ViewStatus.Completed);
        notifyListeners();
      }
    } catch (e) {
      setState(ViewStatus.Error, e.toString());
    }
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
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getBoxListByStation();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }
}
