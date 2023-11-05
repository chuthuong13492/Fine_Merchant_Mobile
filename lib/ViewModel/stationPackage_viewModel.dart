import 'package:collection/collection.dart';
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
    } catch (e) {
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
        splitProductsByStation.sort((a, b) {
          if (a.isShipperAssign == true) {
            return 1;
          }
          return -1;
        });
      } else {
        splitProductsByStation = [];
      }

      notifyListeners();
      setState(ViewStatus.Completed);
    } catch (e) {
      print(e);
      bool result = await showErrorDialog();
      if (result) {
        await getSplitOrdersByStation();
      } else {
        setState(ViewStatus.Error);
      }
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
