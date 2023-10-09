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
  static String selectedDestinationId = '70248C0D-C39F-468F-9A92-4A5A7F1FF6BB';
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
  List<SplitOrderDTO> splitOrderListByStation = [];
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
  var numsOfCheck = 0;
  var isAllChecked = false;
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
    if (index > -1) {
      splitOrderList[index].isChecked = isChecked;
      if (isChecked) {
        numsOfCheck++;
      } else {
        numsOfCheck--;
      }
    } else {
      print('No index found');
    }
    notifyListeners();
  }

  void onCheckAll(bool isCheckingAll) {
    if (isCheckingAll) {
      for (final item in splitOrderList) {
        item.isChecked = true;
      }
      numsOfCheck = splitOrderList.length;
      isAllChecked = true;
    } else {
      for (final item in splitOrderList) {
        item.isChecked = false;
      }
      numsOfCheck = 0;
      isAllChecked = false;
    }
    notifyListeners();
  }

  Future<void> onChangeTimeSlot(String value) async {
    selectedTimeSlotId = value;

    await getSplitOrders();
    await getSplitOrdersByStation();
    notifyListeners();
  }

  Future<void> onChangeStore(String value, int roleType) async {
    selectedStoreId = value;

    await getSplitOrders();
    notifyListeners();
  }

  Future<void> onChangeOrderStatus(int value) async {
    selectedOrderStatus = value;

    await getSplitOrders();
    notifyListeners();
  }

  Future<void> onChangeSelectStation(int index) async {
    stationSelections = stationSelections.map((e) => false).toList();
    stationSelections[index] = true;
    selectedStation = stationList[index];

    await getSplitOrdersByStation();
    notifyListeners();
  }

  Future<void> getTimeSlotList() async {
    try {
      setState(ViewStatus.Loading);
      final data = await _timeSlotDAO?.getTimeSlots(
          destinationId: selectedDestinationId);
      if (data != null) {
        timeSlotList = data
            .where((slot) => (int.parse(slot.arriveTime!.substring(0, 2)) -
                    DateTime.now().hour >=
                1))
            .toList();
        if (timeSlotList.isEmpty) {
          var lastTimeSlot = data.last;
          timeSlotList.add(lastTimeSlot);
          selectedTimeSlotId = lastTimeSlot.id!;
        } else if (selectedTimeSlotId == '' ||
            timeSlotList.firstWhereOrNull((e) => e.id == selectedTimeSlotId) ==
                null) {
          selectedTimeSlotId = timeSlotList.first.id!;
        }
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
          destinationId: selectedDestinationId);
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
      print('selectedTimeSlotId: $selectedTimeSlotId');
      var currentUser = Get.find<AccountViewModel>().currentUser;
      staffStore = Get.find<AccountViewModel>().currentStore;
      if (currentUser != null && currentUser.storeId != null) {
        final data = await _orderDAO?.getSplitOrderListByStoreForStaff(
            storeId: currentUser.storeId!,
            timeSlotId: selectedTimeSlotId,
            orderStatus: selectedOrderStatus);
        if (data != null) {
          var newSplitOrderList = data;
          numsOfCheck = 0;
          for (SplitOrderDTO splitOrder in splitOrderList) {
            if (splitOrder.isChecked == true) {
              var foundSplitOrder = newSplitOrderList.firstWhereOrNull(
                  (e) => e.productName == splitOrder.productName);
              if (foundSplitOrder != null) {
                final updateIndex = newSplitOrderList.indexWhere(
                    (e) => e.productName == foundSplitOrder.productName);
                newSplitOrderList[updateIndex].isChecked = true;
                numsOfCheck = numsOfCheck + 1;
              }
            }
          }
          if (newSplitOrderList.isNotEmpty &&
              numsOfCheck == newSplitOrderList.length) {
            isAllChecked = true;
            numsOfCheck = newSplitOrderList.length;
          } else {
            isAllChecked = false;
          }
          splitOrderList = newSplitOrderList;
          notifyListeners();
        }
      } else {
        final data = await _orderDAO?.getSplitOrderListByStoreForStaff(
            storeId: "751a2190-d06c-4d5e-9c5a-08c33c3db266",
            timeSlotId: selectedTimeSlotId,
            orderStatus: selectedOrderStatus);
        if (data != null) {
          splitOrderList = data;
        }
      }

      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getSplitOrders();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }

  Future<void> getSplitOrdersByStation() async {
    try {
      setState(ViewStatus.Loading);
      print('selectedTimeSlotId: $selectedTimeSlotId');
      var currentUser = Get.find<AccountViewModel>().currentUser;
      staffStore = Get.find<AccountViewModel>().currentStore;
      int orderByStationStatus = OrderStatusEnum.PREPARED;
      if (currentUser != null && currentUser.storeId != null) {
        final data = await _orderDAO?.getSplitOrderListByStoreForStaff(
            storeId: currentUser.storeId!,
            stationId: selectedStation?.id,
            timeSlotId: selectedTimeSlotId,
            orderStatus: orderByStationStatus);
        if (data != null) {
          splitOrderListByStation = data;
        }
      } else {
        final data = await _orderDAO?.getSplitOrderListByStoreForStaff(
            storeId: "751a2190-d06c-4d5e-9c5a-08c33c3db266",
            stationId: selectedStation?.id,
            timeSlotId: selectedTimeSlotId,
            orderStatus: orderByStationStatus);
        if (data != null) {
          splitOrderListByStation = data;
        }
      }
      notifyListeners();
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getSplitOrdersByStation();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }

  Future<void> getOrders() async {
    try {
      var currentUser = Get.find<AccountViewModel>().currentUser;
      staffStore = Get.find<AccountViewModel>().currentStore;
      if (currentUser != null && currentUser.storeId != null) {
        final data = await _orderDAO?.getOrderListForUpdating(
            storeId: currentUser.storeId!,
            stationId: selectedStation?.id,
            timeSlotId: selectedTimeSlotId,
            orderStatus: selectedOrderStatus);
        if (data != null) {
          orderList = data;
        }
      }

      notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getOrders();
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

  Future<void> confirmOrder() async {
    try {
      var currentUser = Get.find<AccountViewModel>().currentUser;
      List<ListStoreAndOrder> updateListStoreAndOrders = [];
      int option = await showOptionDialog("Xác nhận những món này?");

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

            numsOfCheck = 0;
            isAllChecked = false;
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
        "Có lỗi xảy ra, vui lòng thử lại sau 😓",
      );
    } finally {
      await getSplitOrders();
      await getSplitOrdersByStation();
    }
  }

  Future<void> confirmSplitProducts() async {
    int option = await showOptionDialog("Xác nhận những món này?");
    if (option == 1) {
      try {
        List<String> updatedOrderDetailIdList = [];

        showLoadingDialog();
        var newOrderStatus = OrderStatusEnum.PREPARED;
        if (splitOrderList.isNotEmpty) {
          for (SplitOrderDTO splitOrder in splitOrderList) {
            if (splitOrder.isChecked == true) {
              List<String>? orderDetailIdList = splitOrder.orderDetailIdList;
              for (final orderDetailId in orderDetailIdList!) {
                if (updatedOrderDetailIdList
                        .firstWhereOrNull((e) => e == orderDetailId) ==
                    null) {
                  updatedOrderDetailIdList.add(orderDetailId);
                }
              }
            }
          }
          UpdateSplitProductsRequestModel updatedProducts =
              UpdateSplitProductsRequestModel(
                  productStatus: newOrderStatus,
                  orderDetailId: updatedOrderDetailIdList);

          final statusCode =
              await _orderDAO?.confirmSplitProduct(products: updatedProducts);
          if (statusCode == 200) {
            numsOfCheck = 0;
            isAllChecked = false;
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
      } catch (e) {
        await showStatusDialog(
          "assets/images/error.png",
          "Thất bại",
          "Có lỗi xảy ra, vui lòng thử lại sau 😓",
        );
        print(e);
      } finally {
        await getSplitOrders();
        await getSplitOrdersByStation();
        notifyListeners();
      }
    } else {
      notifyListeners();
    }
  }

  void clearCheckList() {
    for (SplitOrderDTO splitOrder in splitOrderList) {
      splitOrder.isChecked = false;
    }
    notifyListeners();
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
