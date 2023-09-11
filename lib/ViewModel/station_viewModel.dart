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
  List<StationDTO> stationList = [];
  List<BoxDTO> boxList = [];
  List<TimeSlotDTO> timeSlotList = [];
  // Data Object Model
  OrderDAO? _orderDAO;
  StationDAO? _stationDAO;
  TimeSlotDAO? _timeSlotDAO;
  dynamic error;
  OrderDTO? orderDTO;
  // Widget
  Uint8List? imageBytes;
  ScrollController? scrollController;
  int numsOfChecked = 0;
  int selectedOrderStatus = 4;
  String selectedStationId = '';
  String selectedTimeSlotId = '';
  String selectedStoreId = '';
  List<bool> stationSelections = [];
  StoreDTO? staffStore;

  StationViewModel() {
    // orderDTO = dto;
    _orderDAO = OrderDAO();
    _stationDAO = StationDAO();
    _timeSlotDAO = TimeSlotDAO();
    scrollController = ScrollController();
  }

  void onCheck(int index, bool isChecked) {
    // splitOrderList[index].isChecked = isChecked;
    // if (isChecked) {
    //   numsOfChecked++;
    // } else {
    //   numsOfChecked--;
    // }
    notifyListeners();
  }

  void onCheckAll(bool isSelectAll) {
    // if (isSelectAll) {
    //   for (final item in splitOrderList) {
    //     item.isChecked = true;
    //   }
    //   numsOfChecked = splitOrderList.length;
    // } else {
    //   for (final item in splitOrderList) {
    //     item.isChecked = false;
    //   }
    //   numsOfChecked = 0;
    // }
    notifyListeners();
  }

  void onChangeStation(String value) {
    selectedStationId = value;
    getBoxListByStation();
    notifyListeners();
  }

  // void onChangeSelectStation(int index) {
  //   stationSelections = stationSelections.map((e) => false).toList();
  //   stationSelections[index] = true;
  //   selectedStation = stationList[index];

  //   getOrders();
  //   getSplitOrders();
  //   notifyListeners();
  // }

  Future<void> getTimeSlotList() async {
    try {
      setState(ViewStatus.Loading);
      final data = await _timeSlotDAO?.getTimeSlots(
          destinationId: '70248C0D-C39F-468F-9A92-4A5A7F1FF6BB');
      if (data != null) {
        timeSlotList = data;
        selectedTimeSlotId = data.first.id!;
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getOrders();
      } else {
        setState(ViewStatus.Error);
      }
    }
  }

  Future<void> getBoxQrCode(String? boxId) async {
    try {
      setState(ViewStatus.Loading);
      final qrcode = await _stationDAO!.getQrCodeByListBoxId(listBoxId: boxId);
      imageBytes = qrcode;
      await Future.delayed(const Duration(milliseconds: 200));
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getBoxQrCode(boxId);
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }

  Future<void> getBoxListByStation() async {
    try {
      setState(ViewStatus.Loading);
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

  Future<void> getStationList() async {
    try {
      setState(ViewStatus.Loading);
      final data = await _stationDAO?.getStationsByDestination(
          destinationId: '70248C0D-C39F-468F-9A92-4A5A7F1FF6BB');
      if (data != null) {
        stationList = data;
        stationSelections = stationList
            .map((e) => e.name == stationList.first.name ? true : false)
            .toList();
        selectedStationId = data.first.id!;
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getOrders();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }

  Future<void> getSplitOrders() async {
    try {
      setState(ViewStatus.Loading);
      numsOfChecked = 0;
      print('selectedTimeSlotId: $selectedTimeSlotId');
      var currentUser = Get.find<AccountViewModel>().currentUser;
      staffStore = Get.find<AccountViewModel>().currentStore;
      if (currentUser != null && currentUser.storeId != null) {
        final data = await _orderDAO?.getSplitOrderListByStoreAndStation(
            storeId: currentUser.storeId!,
            stationId: selectedStationId,
            timeSlotId: selectedTimeSlotId,
            orderStatus: selectedOrderStatus);
        if (data != null) {
          // splitOrderList = data;
        }
      } else {
        final data = await _orderDAO?.getSplitOrderListByStoreAndStation(
            storeId: "751a2190-d06c-4d5e-9c5a-08c33c3db266",
            stationId: selectedStationId,
            timeSlotId: selectedTimeSlotId,
            orderStatus: selectedOrderStatus);
        if (data != null) {
          // splitOrderList = data
          // .where((e) =>
          //     (e.orderDetailStoreStatus != OrderStatusEnum.PROCESSING &&
          //         e.orderDetailStoreStatus !=
          //             OrderStatusEnum.STAFF_CONFIRM) &&
          //     e.orderDetailStoreStatus != OrderStatusEnum.FINISHED)
          // .toList();
          ;
        }
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getOrders();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }

  Future<void> getOrders() async {
    try {
      setState(ViewStatus.Loading);
      var currentUser = Get.find<AccountViewModel>().currentUser;
      staffStore = Get.find<AccountViewModel>().currentStore;
      if (currentUser != null && currentUser.storeId != null) {
        final data = await _orderDAO?.getOrderListByStoreAndStation(
            storeId: currentUser.storeId!, stationId: selectedStationId);
        if (data != null) {
          // orderList = data;
        }
      } else {
        final data = await _orderDAO?.getOrderListByStoreAndStation(
            storeId: "751a2190-d06c-4d5e-9c5a-08c33c3db266",
            stationId: selectedStationId);
        if (data != null) {
          // orderList = data
          // .where((e) =>
          //     (e.orderDetailStoreStatus != OrderStatusEnum.PROCESSING &&
          //         e.orderDetailStoreStatus !=
          //             OrderStatusEnum.STAFF_CONFIRM) &&
          //     e.orderDetailStoreStatus != OrderStatusEnum.FINISHED)
          // .toList();
          ;
        }
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getOrders();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }

  Future<void> confirmOrder(int orderStatus) async {
    try {
      var currentUser = Get.find<AccountViewModel>().currentUser;
      int option = await showOptionDialog(
          orderStatus == OrderStatusEnum.PROCESSING
              ? "Xác nhận những món này?"
              : "Đã chuẩn bị xong những món này?");
      if (option == 1) {
        showLoadingDialog();
        var newOrderStatus = orderStatus == OrderStatusEnum.PROCESSING
            ? OrderStatusEnum.STAFF_CONFIRM
            : orderStatus == OrderStatusEnum.STAFF_CONFIRM
                ? OrderStatusEnum.PREPARED
                : OrderStatusEnum.PREPARED;
        // if (orderList.isNotEmpty) {
        // for (final order in orderList) {
        //   final statusCode = await _orderDAO?.confirmStoreOrderDetail(
        //       currentUser?.storeId, order.orderId, newOrderStatus);
        //   if (statusCode == 200) {
        //     // var newOrderList =
        //     //     orderList.where((e) => e.orderId != orderId).toList();
        //     // orderList = newOrderList;
        //     // Refresh
        //     getOrders();
        //     numsOfChecked = 0;
        //     notifyListeners();
        //     await showStatusDialog(
        //         "assets/images/icon-success.png", "Thành công", "");
        //     Get.back();
        //   } else {
        //     await showStatusDialog(
        //       "assets/images/error.png",
        //       "Thất bại",
        //       "",
        //     );
        //   }
        // }
        // } else {
        //   Get.back();
        // }
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
