import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:fine_merchant_mobile/Accessories/dialog.dart';
import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Utils/constrant.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/base_model.dart';
import 'package:fine_merchant_mobile/ViewModel/home_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Model/DAO/index.dart';
import '../Model/DTO/index.dart';

class StationViewModel extends BaseModel {
  // constant

  // local properties
  List<ShipperOrderBoxDTO> orderBoxList = [];
  List<StationDTO> stationList = [];
  List<BoxDTO> boxList = [];
  List<TimeSlotDTO> timeSlotList = [];
  String? selectedStationId = '';
  String? selectedStoreId = '';
  String? selectedTimeSlotId = '';
  String? selectedBoxId = '';
  // Data Object Model
  StationDAO? _stationDAO;
  dynamic error;
  OrderDTO? orderDTO;
  // Widget
  ScrollController? scrollController;
  int numsOfChecked = 0;
  StationViewModel() {
    _stationDAO = StationDAO();
    scrollController = ScrollController();
  }

  void onChangeStation(String value) {
    selectedStationId = value;
    getBoxListByStation();
    notifyListeners();
  }

  void onChangeBox(String value) {
    selectedBoxId = value;
    notifyListeners();
  }

  void onChangeMissing(int index, int newValue) {
    OrderDetail foundDetail = orderBoxList
        .firstWhere((e) => e.boxId == selectedBoxId)
        .orderDetails![index];
    if (newValue > 0 && (foundDetail.quantity! - newValue >= 0)) {
      foundDetail.missing = newValue;
    }
    if (newValue == 0) {
      onSelectProductMissing(index, false);
    }

    notifyListeners();
  }

  void onSelectProductMissing(int index, bool newValue) {
    OrderDetail foundDetail = orderBoxList
        .firstWhere((e) => e.boxId == selectedBoxId)
        .orderDetails![index];
    if (newValue == true) {
      foundDetail.missing = 1;
    }
    foundDetail.isChecked = newValue;
    notifyListeners();
  }

  Future<void> getBoxListByStation() async {
    try {
      setState(ViewStatus.Loading);
      selectedStationId = Get.find<HomeViewModel>().selectedStationId;
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

  Future<void> reportMissingProduct() async {
    try {
      int option = await showOptionDialog("Xác nhận gửi báo cáo?");
      if (option == 1) {
        showLoadingDialog();
        List<MissingProduct> missingProducts = [];
        List<OrderDetail>? foundOrderDetails = orderBoxList
            .firstWhere((e) => e.boxId == selectedBoxId)
            .orderDetails;
        if (foundOrderDetails!.isNotEmpty) {
          for (OrderDetail detail in foundOrderDetails) {
            if (detail.isChecked == true) {
              missingProducts.add(MissingProduct(
                  productName: detail.productName, quantity: detail.missing
                  // ,storeId: detail.storeId
                  ));
            }
          }
        }

        var requestModel = MissingProductReportRequestModel(
            boxId: selectedBoxId,
            stationId: selectedStationId,
            storeId: selectedStoreId,
            timeSlotId: selectedTimeSlotId,
            missingProducts: missingProducts);

        final status =
            await _stationDAO?.reportMissingProduct(requestData: requestModel);
        if (status == 200) {
          await showStatusDialog(
              "assets/images/icon-success.png", "Gửi thành công", "");
        }
        Get.back();
        setState(ViewStatus.Completed);
        notifyListeners();
      }
    } catch (e) {
      print(e);
      bool result = await showErrorDialog();
      if (result) {
        await reportMissingProduct();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }
}
