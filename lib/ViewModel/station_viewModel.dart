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
  List<PackStationDetailGroupByProducts> productList = [];
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
  int currentMissing = 0;
  StationViewModel() {
    _stationDAO = StationDAO();
    scrollController = ScrollController();
  }

  void onSelectReportBox(String boxId) {
    BoxDTO? foundBox = boxList.firstWhereOrNull((box) => box.id == boxId);
    if (foundBox != null) {
      bool? isSelected = foundBox.isSelected;
      foundBox.isSelected = !isSelected!;
    }
    notifyListeners();
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

  void onChangeMissing(String productId, int index, int newValue) {
    if (index >= 0) {
      PackStationDetailGroupByProducts foundProduct =
          productList.firstWhere((e) => e.productId == productId);
      BoxProducts? foundBoxProduct = foundProduct.boxProducts![index];
      if (newValue > 0 && (foundBoxProduct.quantity! - newValue >= 0)) {
        foundBoxProduct.currentMissing = newValue;
      }
    }

    notifyListeners();
  }

  // void onSelectProductMissing(int index, bool isNewValue) {
  //   OrderDetail foundDetail = orderBoxList
  //       .firstWhere((e) => e.boxId == selectedBoxId)
  //       .orderDetails![index];
  //   if (isNewValue == true) {
  //     foundDetail.missing = 1;
  //   }
  //   foundDetail.isChecked = isNewValue;
  //   notifyListeners();
  // }

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

  Future<void> reportMissingProduct({String? productName}) async {
    try {
      int option = await showOptionDialog("Xác nhận gửi báo cáo?");
      if (option == 1) {
        showLoadingDialog();
        // List<ListBoxAndQuantity> listBoxAndQuantity = [];
        // for (BoxDTO box in boxList) {
        //   if (box.isSelected == true) {
        //     listBoxAndQuantity
        //         .add(ListBoxAndQuantity(boxId: box.id, quantity: 0));
        //   }
        // }

        // for (ListBoxAndQuantity reportBox in listBoxAndQuantity) {
        //   ShipperOrderBoxDTO? foundOrderBox = orderBoxList.firstWhereOrNull(
        //       (orderBox) => orderBox.boxId == reportBox.boxId);
        //   if (foundOrderBox != null) {
        //     var foundDetail = foundOrderBox.orderDetails?.firstWhereOrNull(
        //         (detail) => detail.productName == productName);
        //     if (foundDetail != null) {
        //       reportBox.quantity = foundDetail.quantity;
        //     }
        //   }
        // }

        // var requestModel = MissingProductReportRequestModel(
        //     stationId: selectedStationId,
        //     timeSlotId: selectedTimeSlotId,
        //     productName: productName,
        //     listBoxAndQuantity: listBoxAndQuantity);

        // final status =
        //     await _stationDAO?.reportMissingProduct(requestData: requestModel);
        // if (status == 200) {
        //   await showStatusDialog(
        //       "assets/images/icon-success.png", "Báo cáo thành công", "");
        // }
        setState(ViewStatus.Completed);
        notifyListeners();
      }
    } catch (e) {
      print(e);
      await showErrorDialog();
    } finally {}
  }
}
