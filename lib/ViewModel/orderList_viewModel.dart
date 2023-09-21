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

class OrderListViewModel extends BaseModel {
  // constant
  List<int> staffOrderStatuses = [
    OrderStatusEnum.PROCESSING,
    // OrderStatusEnum.PREPARED,
    // OrderStatusEnum.DELIVERING,
  ];
  List<int> driverOrderStatuses = [
    OrderStatusEnum.PREPARED,
    OrderStatusEnum.DELIVERING,
  ];
  // local properties
  List<SplitOrderDTO> splitOrderList = [];
  List<OrderDTO> orderList = [];
  List<OrderDTO> filteredOrderList = [];
  List<StationDTO> stationList = [];
  List<StoreDTO> storeList = [];
  List<TimeSlotDTO> timeSlotList = [];
  // Data Object Model
  OrderDAO? _orderDAO;
  StationDAO? _stationDAO;
  StoreDAO? _storeDAO;
  TimeSlotDAO? _timeSlotDAO;
  dynamic error;
  OrderDTO? orderDTO;
  // Widget
  ScrollController? scrollController;
  int numsOfChecked = 0;
  int selectedOrderStatus = OrderStatusEnum.PROCESSING;
  StationDTO? selectedStation;
  String selectedTimeSlotId = '';
  String selectedStoreId = '';
  List<bool> stationSelections = [];
  OrderDTO? newTodayOrders;
  StoreDTO? staffStore;

  OrderListViewModel() {
    // orderDTO = dto;
    _orderDAO = OrderDAO();
    _stationDAO = StationDAO();
    _storeDAO = StoreDAO();
    _timeSlotDAO = TimeSlotDAO();
    scrollController = ScrollController();
    scrollController!.addListener(() async {
      if (scrollController!.position.pixels ==
          scrollController!.position.maxScrollExtent) {
        int total_page = (_orderDAO!.metaDataDTO.total! / DEFAULT_SIZE).ceil();
        if (total_page > _orderDAO!.metaDataDTO.page!) {
          await getMoreOrders();
        }
      }
    });
  }

  void onCheck(int index, bool isChecked) {
    splitOrderList[index].isChecked = isChecked;
    if (isChecked) {
      numsOfChecked++;
    } else {
      numsOfChecked--;
    }
    notifyListeners();
  }

  void onCheckAll(bool isSelectAll) {
    if (isSelectAll) {
      for (final item in splitOrderList) {
        item.isChecked = true;
      }
      numsOfChecked = splitOrderList.length;
    } else {
      for (final item in splitOrderList) {
        item.isChecked = false;
      }
      numsOfChecked = 0;
    }
    notifyListeners();
  }

  void onChangeTimeSlot(String value) {
    selectedTimeSlotId = value;
    getOrders();
    getSplitOrders();
    notifyListeners();
  }

  void onChangeStore(String value, int roleType) {
    selectedStoreId = value;
    getOrders();
    getSplitOrders();
    notifyListeners();
  }

  void onChangeOrderStatus(int value) {
    selectedOrderStatus = value;
    getOrders();
    getSplitOrders();
    notifyListeners();
  }

  void onChangeSelectStation(int index) {
    stationSelections = stationSelections.map((e) => false).toList();
    stationSelections[index] = true;
    selectedStation = stationList[index];

    getOrders();
    getSplitOrders();
    notifyListeners();
  }

  Future<void> getTimeSlotList() async {
    try {
      setState(ViewStatus.Loading);
      final data = await _timeSlotDAO?.getTimeSlots(
          destinationId: '70248C0D-C39F-468F-9A92-4A5A7F1FF6BB');
      if (data != null) {
        timeSlotList = data
            .where((slot) => (int.parse(slot.arriveTime!.substring(0, 2)) -
                    DateTime.now().hour >=
                1))
            .toList();
        selectedTimeSlotId = timeSlotList.first.id!;
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getTimeSlotList();
      } else {
        setState(ViewStatus.Error);
      }
    }
  }

  Future<void> getStationList() async {
    try {
      setState(ViewStatus.Loading);
      final data = await _stationDAO?.getStationsByDestination(
          destinationId: '70248C0D-C39F-468F-9A92-4A5A7F1FF6BB');
      if (data != null) {
        stationList =
            data.where((station) => station.isActive == true).toList();
        stationSelections = stationList
            .map((e) => e.name == stationList.first.name ? true : false)
            .toList();
        selectedStation = data.first;
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getStationList();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }

  Future<void> getStoreList() async {
    try {
      setState(ViewStatus.Loading);
      final data = await _storeDAO?.getStores();
      if (data != null) {
        storeList = data;
        selectedStoreId = data.first.id!;
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getStoreList();
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
            stationId: selectedStation?.id,
            timeSlotId: selectedTimeSlotId,
            orderStatus: selectedOrderStatus);
        if (data != null) {
          splitOrderList = data;
        }
      } else {
        final data = await _orderDAO?.getSplitOrderListByStoreAndStation(
            storeId: "751a2190-d06c-4d5e-9c5a-08c33c3db266",
            stationId: selectedStation?.id,
            timeSlotId: selectedTimeSlotId,
            orderStatus: selectedOrderStatus);
        if (data != null) {
          splitOrderList = data
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
        await getSplitOrders();
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
            storeId: currentUser.storeId!,
            stationId: selectedStation?.id,
            timeSlotId: selectedTimeSlotId,
            orderStatus: selectedOrderStatus);
        if (data != null) {
          orderList = data;
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

  Future<void> getOrderByOrderId({String? id}) async {
    try {
      setState(ViewStatus.Loading);
      orderDTO = await _orderDAO?.getOrderById(id);
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      setState(ViewStatus.Error, e.toString());
    }
  }

  Future<void> confirmOrder(int orderStatus) async {
    try {
      var currentUser = Get.find<AccountViewModel>().currentUser;
      List<ListStoreAndOrder> updateListStoreAndOrders = [];
      int option = await showOptionDialog(
          orderStatus == OrderStatusEnum.PROCESSING
              ? "Xác nhận những món này?"
              : "Đã chuẩn bị xong những món này?");
      if (option == 1) {
        showLoadingDialog();
        var newOrderStatus = OrderStatusEnum.PREPARED;
        if (orderList.isNotEmpty) {
          for (final order in orderList) {
            ListStoreAndOrder updateListStoreAndOrder = ListStoreAndOrder(
                orderId: order.orderId, storeId: order.storeId);
            updateListStoreAndOrders.add(updateListStoreAndOrder);
          }
          UpdateOrderStatusRequestModel updatedOrders =
              UpdateOrderStatusRequestModel(
                  orderDetailStoreStatus: newOrderStatus,
                  listStoreAndOrder: updateListStoreAndOrders);

          final statusCode =
              await _orderDAO?.confirmStoreOrderDetail(orders: updatedOrders);
          if (statusCode == 200) {
            // var newOrderList =
            //     orderList.where((e) => e.orderId != orderId).toList();
            // orderList = newOrderList;
            // Refresh
            await getOrders();
            await getSplitOrders();
            numsOfChecked = 0;
            notifyListeners();
            await showStatusDialog(
                "assets/images/icon-success.png", "Xác nhận thành công", "");
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

  Future<void> shipperUpdateOrder(int orderStatus) async {
    try {
      List<ListStoreAndOrder> updateListStoreAndOrders = [];
      int option = await showOptionDialog("Xác nhận lấy những món này?");
      if (option == 1) {
        showLoadingDialog();
        var newOrderStatus = orderStatus == OrderStatusEnum.PREPARED
            ? OrderStatusEnum.SHIPPER_ASSIGNED
            : orderStatus == OrderStatusEnum.SHIPPER_ASSIGNED
                ? OrderStatusEnum.DELIVERING
                : orderStatus == OrderStatusEnum.DELIVERING
                    ? OrderStatusEnum.BOX_STORED
                    : OrderStatusEnum.BOX_STORED;
        if (orderList.isNotEmpty) {
          for (final order in orderList) {
            ListStoreAndOrder updateListStoreAndOrder = ListStoreAndOrder(
                orderId: order.orderId, storeId: order.storeId);
            updateListStoreAndOrders.add(updateListStoreAndOrder);
          }
          UpdateOrderStatusRequestModel updatedOrders =
              UpdateOrderStatusRequestModel(
                  orderDetailStoreStatus: newOrderStatus,
                  listStoreAndOrder: updateListStoreAndOrders);

          final statusCode =
              await _orderDAO?.confirmStoreOrderDetail(orders: updatedOrders);
          if (statusCode == 200) {
            // var newOrderList =
            //     orderList.where((e) => e.orderId != orderId).toList();
            // orderList = newOrderList;
            // Refresh
            await getOrders();
            await getSplitOrders();
            numsOfChecked = 0;
            notifyListeners();
            await showStatusDialog("assets/images/icon-success.png",
                "Xác nhận giao thành công", "");
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

  void clearNewOrder(int orderId) {
    newTodayOrders = null;
    notifyListeners();
  }

  Future<void> getMoreOrders() async {
    // try {
    //   setState(ViewStatus.LoadMore);
    //   // OrderFilter filter =
    //   //     selections[0] ? OrderFilter.ORDERING : OrderFilter.DONE;

    //   final data =
    //       await _orderDAO?.getOrders(page: _orderDAO!.metaDataDTO.page! + 1);

    //   orderThumbnail += data!;

    //   await Future.delayed(const Duration(milliseconds: 1000));
    //   setState(ViewStatus.Completed);
    //   // notifyListeners();
    // } catch (e) {
    //   bool result = await showErrorDialog();
    //   if (result) {
    //     await getMoreOrders();
    //   } else {
    //     setState(ViewStatus.Error);
    //   }
    // }
  }

  Future<void> closeNewOrder(orderId) async {
    newTodayOrders = null;
    notifyListeners();
  }
}
