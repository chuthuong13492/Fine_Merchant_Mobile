import 'dart:developer';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:fine_merchant_mobile/Accessories/dialog.dart';
import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Utils/constrant.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/base_model.dart';
import 'package:fine_merchant_mobile/ViewModel/home_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../Model/DAO/index.dart';
import '../Model/DTO/index.dart';

class StationViewModel extends BaseModel {
  // constant

  // local properties
  List<PackStationDetailGroupByProducts> productList = [];
  List<ProductBoxesDTO> productBoxes = [];
  List<StationDTO> stationList = [];
  List<BoxDTO> boxList = [];
  List<TimeSlotDTO> timeSlotList = [];
  String? selectedStationId = '';
  String? selectedStoreId = '';
  String? selectedTimeSlotId = '';
  String? selectedBoxId = '';
  Uint8List? imageBytes;
  // Data Object Model
  UtilsDAO? _utilsDAO;
  StationDAO? _stationDAO;
  dynamic error;
  SplitProductDAO? _splitProductDAO;
  // Widget
  ScrollController? scrollController;
  int numsOfChecked = 0;
  int currentMissing = 0;
  StationViewModel() {
    _stationDAO = StationDAO();
    _utilsDAO = UtilsDAO();
    _splitProductDAO = SplitProductDAO();
    scrollController = ScrollController();
  }

  void onSelectReportBox(String boxId) {
    // BoxDTO? foundBox = boxList.firstWhereOrNull((box) => box.id == boxId);
    // if (foundBox != null) {
    //   bool? isSelected = foundBox.isSelected;
    //   foundBox.isSelected = !isSelected!;
    // }
    selectedBoxId = boxId;
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

  void onChangeMissing(String boxId, int index, int newValue) {
    if (index >= 0) {
      ProductBoxesDTO? foundProduct =
          productBoxes.firstWhereOrNull((e) => e.boxId == boxId);
      if (foundProduct != null) {
        // BoxProducts? foundBoxProduct = foundProduct.boxProducts![index];
        if (newValue > 0 &&
            (foundProduct.listProduct![0].quantity! - newValue >= 0)) {
          foundProduct.isChecked = true;
          foundProduct.currentMissing = newValue;
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

        boxList.sort((a, b) {
          if (int.parse(a.code!.split('-')[1]) <
              int.parse(b.code!.split('-')[1])) {
            return 1;
          }
          return -1;
        });
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } on DioException catch (e) {
      log('error: ${e.toString()}');
      print(e);
      if (e.response!.statusCode! < 400 || e.response!.statusCode! > 405) {
        String messageBody =
            "${DateFormat.yMd().add_jm().format(DateTime.now())} | $e${e.response!.data}";
        await _utilsDAO?.logError(messageBody: messageBody);
      }
      // bool result = await showErrorDialog();
      // if (result) {
      //   await getBoxListByStation();
      // } else {
      //   setState(ViewStatus.Error);
      // }
    } finally {}
  }

  Future<void> getBoxListByProduct({String? productId}) async {
    try {
      setState(ViewStatus.Loading);
      selectedStationId = Get.find<HomeViewModel>().selectedStationId;
      final data = await _stationDAO?.getProductBoxesByProduct(
          timeSlotId: selectedTimeSlotId, productId: productId);
      if (data != null) {
        productBoxes = data;
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } on DioException catch (e) {
      log('error: ${e.toString()}');
      print(e);
      if (e.response!.statusCode! < 400 || e.response!.statusCode! > 405) {
        String messageBody =
            "${DateFormat.yMd().add_jm().format(DateTime.now())} | $e${e.response!.data}";
        await _utilsDAO?.logError(messageBody: messageBody);
      }
      // bool result = await showErrorDialog();
      // if (result) {

      // } else {
      //   setState(ViewStatus.Error);
      // }
      print(e);
    } finally {}
  }

  Future<void> reportMissingProduct(
      {String? productId, int? statusType, String? storeId}) async {
    try {
      List<String> updatedProducts = [];
      int missingQuantity = 0;
      ReportBoxRequestModel? requestModel;
      int option = await showOptionDialog("Xác nhận gửi báo cáo?");

      if (option == 1) {
        showLoadingDialog();
        ProductBoxesDTO? foundProduct = productBoxes
            .firstWhereOrNull((e) => e.listProduct![0].productId == productId);

        if (foundProduct != null) {
          updatedProducts.add(foundProduct.listProduct![0].productId!);
          // List<BoxProducts>? productBoxList = foundProduct.boxProducts;

          for (final productBox in productBoxes) {
            if (productBox.isChecked == true) {
              missingQuantity = productBox.currentMissing!;
            }
          }

          requestModel = ReportBoxRequestModel(
              type: statusType,
              timeSlotId: selectedTimeSlotId,
              storeId: storeId,
              productsUpdate: updatedProducts,
              boxId: selectedBoxId,
              quantity: missingQuantity);

          if (requestModel != null) {
            final statusCode = await _splitProductDAO?.reportBoxSplitProduct(
                requestModel: requestModel);
            if (statusCode == 200) {
              notifyListeners();
              await showStatusDialog(
                  "assets/images/icon-success.png", "Báo cáo thành công", "");
              Get.back();
              Future.delayed(const Duration(milliseconds: 2000));
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
    } on DioException catch (e) {
      log('error: ${e.toString()}');
      print(e);
      if (e.response!.statusCode! < 400 || e.response!.statusCode! > 405) {
        String messageBody =
            "${DateFormat.yMd().add_jm().format(DateTime.now())} | $e${e.response!.data}";
        await _utilsDAO?.logError(messageBody: messageBody);
      }
      await showStatusDialog(
        "assets/images/error.png",
        "Thất bại",
        "Có lỗi xảy ra, vui lòng thử lại sau 😓",
      );
    } finally {}
  }
}
