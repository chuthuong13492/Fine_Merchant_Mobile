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
  // Data Object Model
  StationDAO? _stationDAO;
  OrderDAO? _orderDAO;
  dynamic error;
  OrderDTO? orderDTO;
  // Widget
  Uint8List? imageBytes;
  ScrollController? scrollController;
  int numsOfChecked = 0;
  int selectedOrderStatus = 4;

  StoreDTO? staffStore;

  StationViewModel() {
    _orderDAO = OrderDAO();
    _stationDAO = StationDAO();
    scrollController = ScrollController();
  }

  void onChangeStation(String value) {
    selectedStationId = value;
    getBoxListByStation();
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

  Future<void> getShipperOrderBoxes() async {
    try {
      setState(ViewStatus.Loading);
      var currentUser = Get.find<AccountViewModel>().currentUser;
      String selectedStationId = Get.find<HomeViewModel>().selectedStationId;
      String selectedTimeSlotId = Get.find<HomeViewModel>().selectedTimeSlotId;
      if (currentUser != null) {
        final data = await _orderDAO?.getShipperOrderBox(
          stationId: selectedStationId,
          timeSlotId: selectedTimeSlotId,
        );
        if (data != null) {
          orderBoxList = data;
        }
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getShipperOrderBoxes();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }

  Future<void> confirmAllBoxStored() async {
    try {
      List<ListStoreAndOrder> updateListStoreAndOrders = [];
      List<UpdateOrderStatusRequestModel> updatedOrders = [];

      int option = await showOptionDialog("Xác nhận đã bỏ đủ hàng vào các tủ?");
      if (option == 1) {
        // showLoadingDialog();
        int newOrderStatus = OrderStatusEnum.BOX_STORED;

        if (orderBoxList.isNotEmpty) {
          for (ShipperOrderBoxDTO orderBox in orderBoxList) {
            List<OrderDetail>? orderDetails = orderBox.orderDetails;
            for (OrderDetail detail in orderDetails!) {
              if (updateListStoreAndOrders.isEmpty) {
                ListStoreAndOrder updateListStoreAndOrder = ListStoreAndOrder(
                    orderId: detail.orderId, storeId: detail.storeId);
                updateListStoreAndOrders.add(updateListStoreAndOrder);
              } else {
                if (updateListStoreAndOrders.firstWhereOrNull((item) =>
                        item.storeId == detail.storeId &&
                        item.orderId == detail.orderId) ==
                    null) {
                  ListStoreAndOrder updateListStoreAndOrder = ListStoreAndOrder(
                      orderId: detail.orderId, storeId: detail.storeId);
                  updateListStoreAndOrders.add(updateListStoreAndOrder);
                }
              }
            }
          }
          UpdateOrderStatusRequestModel updatedOrders =
              UpdateOrderStatusRequestModel(
                  orderDetailStoreStatus: newOrderStatus,
                  listStoreAndOrder: updateListStoreAndOrders);

          final statusCode =
              await _orderDAO?.confirmStoreOrderDetail(orders: updatedOrders);
          if (statusCode == 200) {
            await getShipperOrderBoxes();

            notifyListeners();
            await showStatusDialog(
                "assets/images/icon-success.png", "Thành công", "");
            Get.back();
          } else {
            await showStatusDialog(
              "assets/images/error.png",
              "Thất bại",
              "",
            );
          }
        } else {
          Get.back();
        }
      }
    } catch (e) {
      await showStatusDialog(
        "assets/images/error.png",
        "Thất bại",
        "Có lỗi xảy ra, vui lòng liên hệ admin 😓",
      );
    } finally {}
  }
}
