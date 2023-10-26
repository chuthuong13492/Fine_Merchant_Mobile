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
  SplitProductDAO? _splitProductDAO;
  // Widget
  ScrollController? scrollController;
  int numsOfChecked = 0;
  int currentMissing = 0;
  StationViewModel() {
    _stationDAO = StationDAO();
    _splitProductDAO = SplitProductDAO();
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
      PackStationDetailGroupByProducts? foundProduct =
          productList.firstWhereOrNull((e) => e.productId == productId);
      if (foundProduct != null) {
        BoxProducts? foundBoxProduct = foundProduct.boxProducts![index];
        if (newValue > 0 && (foundBoxProduct.quantity! - newValue >= 0)) {
          foundBoxProduct.isChecked = true;
          foundBoxProduct.currentMissing = newValue;
        }
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

  Future<void> reportMissingProduct(
      {String? productId, int? statusType}) async {
    try {
      List<String> updatedProducts = [];
      List<String> updatedBoxes = [];
      int missingQuantity = 0;
      UpdateSplitProductRequestModel? requestModel;
      int option = await showOptionDialog("Xác nhận gửi báo cáo?");

      if (option == 1) {
        showLoadingDialog();
        PackStationDetailGroupByProducts? foundProduct =
            productList.firstWhereOrNull((e) => e.productId == productId);

        if (foundProduct != null) {
          updatedProducts.add(foundProduct.productId!);
          List<BoxProducts>? productBoxList = foundProduct.boxProducts;
          if (productBoxList != null) {
            for (final productBox in productBoxList) {
              if (productBox.isChecked == true) {
                updatedBoxes.add(productBox.boxId!);
                missingQuantity = productBox.currentMissing!;
              }
            }

            requestModel = UpdateSplitProductRequestModel(
                type: statusType,
                timeSlotId: selectedTimeSlotId,
                productsUpdate: updatedProducts,
                listBox: updatedBoxes,
                quantity: missingQuantity);
          }
          if (requestModel != null) {
            final statusCode = await _splitProductDAO?.confirmSplitProduct(
                requestModel: requestModel);
            if (statusCode == 200) {
              notifyListeners();
              await showStatusDialog(
                  "assets/images/icon-success.png", "Báo cáo thành công", "");
              Get.back();
            } else {
              await showStatusDialog(
                "assets/images/error.png",
                "Thất bại",
                "",
              );
            }
          }
        } else {
          Get.back();
        }
      }
    } catch (e) {
      await showStatusDialog(
        "assets/images/error.png",
        "Thất bại",
        "Có lỗi xảy ra, vui lòng thử lại sau 😓",
      );
    } finally {}
  }
}
