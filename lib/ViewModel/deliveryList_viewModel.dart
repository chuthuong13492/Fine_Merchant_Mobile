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

class DeliveryListViewModel extends BaseModel {
  // constant

  // local properties
  List<DeliveryPackageDTO> packageList = [];
  List<PackageViewDTO> packageViewList = [];
  List<OrderDTO> orderDetailList = [];
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
  bool isDelivering = false;
  PackageViewDTO? currentDeliveryPackage;
  int selectedOrderStatus = 4;
  StationDTO? selectedStation;
  String selectedTimeSlotId = '';
  String selectedStoreId = '';
  List<bool> stationSelections = [];
  OrderDTO? newTodayOrders;
  StoreDTO? staffStore;

  DeliveryListViewModel() {
    // orderDTO = dto;
    _orderDAO = OrderDAO();
    _stationDAO = StationDAO();
    _storeDAO = StoreDAO();
    _timeSlotDAO = TimeSlotDAO();
    scrollController = ScrollController();
    // scrollController!.addListener(() async {
    //   if (scrollController!.position.pixels ==
    //       scrollController!.position.maxScrollExtent) {
    //     int total_page = (_orderDAO!.metaDataDTO.total! / DEFAULT_SIZE).ceil();
    //     if (total_page > _orderDAO!.metaDataDTO.page!) {

    //     }
    //   }
    // });
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

  void onChangeStore(String value) {
    selectedStoreId = value;
    // getOrders();
    getSplitOrdersForDriver();
    notifyListeners();
  }

  void onChangeSelectOrderStatus(int index) {
    stationSelections = stationSelections.map((e) => false).toList();
    stationSelections[index] = true;
    selectedStation = stationList[index];
    // getOrders();
    // getSplitOrders();
    notifyListeners();
  }

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
        stationList = data;
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

  Future<void> getSplitOrdersForDriver() async {
    try {
      setState(ViewStatus.Loading);
      List<PackageViewDTO> newPackageList = [];
      var currentUser = Get.find<AccountViewModel>().currentUser;
      staffStore = Get.find<AccountViewModel>().currentStore;
      if (currentUser != null) {
        final data = await _orderDAO?.getSplitOrderListByStoreForDriver(
          storeId: selectedStoreId,
        );
        if (data != null) {
          packageList = data;
          for (TimeSlotDTO timeSlot in timeSlotList) {
            var groupByTimeSlot =
                packageList.where((e) => e.timeSlotId == timeSlot.id).toList();
            for (StationDTO station in stationList) {
              var groupByTimeSlotAndStation = groupByTimeSlot
                  .where((e) => e.stationId == station.id)
                  .toList();
              if (groupByTimeSlotAndStation.isNotEmpty) {
                List<ListProduct> products = [];
                for (DeliveryPackageDTO package in groupByTimeSlotAndStation) {
                  products.add(ListProduct(
                      productName: package.productName,
                      quantity: package.quantity));
                }
                newPackageList.add(PackageViewDTO(
                    listProducts: products,
                    stationId: station.id,
                    timeSlotId: timeSlot.id));
              }
            }
          }
          packageViewList = newPackageList;
          // var newPackageList = data.map((e) {
          //   var newPackage = {}
          // });
        }
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getSplitOrdersForDriver();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }

  Future<void> getOrderDetails(
      {String? stationId, String? timeSlotId, int? orderStatus}) async {
    try {
      setState(ViewStatus.Loading);
      var currentUser = Get.find<AccountViewModel>().currentUser;
      staffStore = Get.find<AccountViewModel>().currentStore;
      if (currentUser != null) {
        final data = await _orderDAO?.getOrderListByStoreAndStation(
            storeId: selectedStoreId,
            stationId: stationId,
            timeSlotId: timeSlotId,
            orderStatus: orderStatus);
        if (data != null) {
          orderDetailList = data;
        }
      }
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getOrderDetails();
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

  Future<void> confirmDelivery(PackageViewDTO package) async {
    try {
      List<ListStoreAndOrder> updateListStoreAndOrders = [];

      List<UpdateOrderStatusRequestModel> updatedOrders = [];
      int option = await showOptionDialog(
          "${!isDelivering ? "Xác nhận lấy hàng này?" : "Xác nhận đã bỏ vào tủ?"}");
      if (option == 1) {
        // showLoadingDialog();
        getOrderDetails(
            orderStatus: OrderStatusEnum.PREPARED,
            stationId: package.stationId,
            timeSlotId: package.timeSlotId);
        int newOrderStatus = isDelivering == true
            ? OrderStatusEnum.BOX_STORED
            : OrderStatusEnum.DELIVERING;
        if (newOrderStatus == OrderStatusEnum.BOX_STORED) {
          isDelivering = false;
        } else {
          isDelivering = true;
        }
        currentDeliveryPackage = package;
        if (orderDetailList.isNotEmpty) {
          for (final order in orderDetailList) {
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
            getSplitOrdersForDriver();
            isDelivering = true;
            currentDeliveryPackage = package;
            notifyListeners();
            await showStatusDialog(
                "assets/images/icon-success.png", "Thành công", "");
            Get.back();
          } else {
            isDelivering = false;
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
}
