import 'dart:typed_data';

import 'package:fine_merchant_mobile/Accessories/dialog.dart';
import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Utils/constrant.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/base_model.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Model/DAO/index.dart';
import '../Model/DTO/index.dart';

class HomeViewModel extends BaseModel {
  // constant

  // local properties
  static String selectedDestinationId = '70248C0D-C39F-468F-9A92-4A5A7F1FF6BB';
  List<DeliveryPackageDTO> packageList = [];
  List<PackageViewDTO> packageViewList = [];
  List<PackageViewDTO> deliveredPackageList = [];
  List<ShipperOrderBoxDTO> orderBoxList = [];
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
  Uint8List? imageBytes;
  // Widget
  ScrollController? scrollController;
  bool isDelivering = false;
  PackageViewDTO? currentDeliveryPackage;
  String selectedStationId = '';
  String selectedTimeSlotId = 'e8d529d4-6a51-4fdb-b9db-e29f54c0486e';
  String selectedStoreId = '';

  HomeViewModel() {
    _orderDAO = OrderDAO();
    _stationDAO = StationDAO();
    _storeDAO = StoreDAO();
    _timeSlotDAO = TimeSlotDAO();
    scrollController = ScrollController();
  }

  Future<void> onChangeStore(String value) async {
    selectedStoreId = value;
    // getOrders();
    await getSplitOrdersForDriver();
    notifyListeners();
  }

  Future<void> onChangeStation(String value) async {
    selectedStationId = value;
    await getDeliveredOrdersForDriver();
    await getSplitOrdersForDriver();
    notifyListeners();
  }

  Future<void> onChangeTimeSlot(String value) async {
    selectedTimeSlotId = value;
    await getDeliveredOrdersForDriver();
    await getSplitOrdersForDriver();
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
          timeSlotList.add(data.last);
        }
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
          destinationId: selectedDestinationId);
      if (data != null) {
        stationList = data;
        if (selectedStationId == '') {
          selectedStationId = data.first.id!;
        }
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
        if (selectedStoreId == '') {
          selectedStoreId = data.first.id!;
        }
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
      if (currentUser != null) {
        final data = await _orderDAO?.getSplitOrderListByStoreForDriver(
            orderStatus: OrderStatusEnum.PREPARED,
            timeSlotId: selectedTimeSlotId,
            stationId: selectedStationId);
        if (data != null) {
          packageList = data;
          for (TimeSlotDTO timeSlot in timeSlotList) {
            var groupByTimeSlot = packageList
                .where((item) => item.timeSlotId == timeSlot.id)
                .toList();
            for (StoreDTO store in storeList) {
              var groupByTimeSlotAndStore = groupByTimeSlot
                  .where((item) => item.storeId == store.id)
                  .toList();
              if (groupByTimeSlotAndStore.isNotEmpty) {
                List<ListProduct> products = [];
                for (DeliveryPackageDTO package in groupByTimeSlotAndStore) {
                  products.add(ListProduct(
                      productName: package.productName,
                      quantity: package.quantity));
                }
                newPackageList.add(PackageViewDTO(
                    listProducts: products,
                    storeId: store.id,
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
      {String? stationId,
      String? storeId,
      String? timeSlotId,
      int? orderStatus}) async {
    try {
      setState(ViewStatus.Loading);
      var currentUser = Get.find<AccountViewModel>().currentUser;
      if (currentUser != null) {
        final data = await _orderDAO?.getOrderListByStoreAndStation(
            storeId: storeId,
            stationId: stationId,
            timeSlotId: timeSlotId,
            orderStatus: orderStatus);
        if (data != null) {
          orderDetailList = data;
        }
      }
      notifyListeners();
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getOrderDetails();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }

  Future<void> getDeliveredOrdersForDriver() async {
    try {
      setState(ViewStatus.Loading);
      List<PackageViewDTO> newPackageList = [];
      var currentUser = Get.find<AccountViewModel>().currentUser;
      ;
      if (currentUser != null) {
        final data = await _orderDAO?.getSplitOrderListByStoreForDriver(
            orderStatus: OrderStatusEnum.DELIVERING,
            timeSlotId: selectedTimeSlotId,
            stationId: selectedStationId);
        if (data != null) {
          packageList = data;
          for (TimeSlotDTO timeSlot in timeSlotList) {
            var groupByTimeSlot = packageList
                .where((item) => item.timeSlotId == timeSlot.id)
                .toList();
            for (StoreDTO store in storeList) {
              var groupByTimeSlotAndStore = groupByTimeSlot
                  .where((item) => item.storeId == store.id)
                  .toList();
              if (groupByTimeSlotAndStore.isNotEmpty) {
                List<ListProduct> products = [];
                for (DeliveryPackageDTO package in groupByTimeSlotAndStore) {
                  products.add(ListProduct(
                      productName: package.productName,
                      quantity: package.quantity));
                }
                newPackageList.add(PackageViewDTO(
                    listProducts: products,
                    storeId: store.id,
                    timeSlotId: timeSlot.id));
              }
            }
          }
          deliveredPackageList = newPackageList;
          notifyListeners();
        }
      }
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getDeliveredOrdersForDriver();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }

  Future<void> confirmDelivery(PackageViewDTO package) async {
    try {
      List<ListStoreAndOrder> updateListStoreAndOrders = [];
      List<UpdateOrderStatusRequestModel> updatedOrders = [];

      int option = await showOptionDialog("Xác nhận đã lấy hàng này?");
      if (option == 1) {
        showLoadingDialog();
        int newOrderStatus = OrderStatusEnum.DELIVERING;
        await getOrderDetails(
            orderStatus: OrderStatusEnum.PREPARED,
            storeId: package.storeId,
            stationId: selectedStationId,
            timeSlotId: selectedTimeSlotId);

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
            await getSplitOrdersForDriver();

            // if (newOrderStatus == OrderStatusEnum.BOX_STORED) {
            //   isDelivering = false;
            // } else {
            //   currentDeliveryPackage = package;
            //   isDelivering = true;
            // }

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
    } finally {}
  }

  Future<void> getShipperOrderBoxes() async {
    try {
      setState(ViewStatus.Loading);
      imageBytes = null;
      var currentUser = Get.find<AccountViewModel>().currentUser;
      if (currentUser != null) {
        final data = await _orderDAO?.getShipperOrderBox(
          stationId: selectedStationId,
          timeSlotId: selectedTimeSlotId,
        );
        if (data != null) {
          orderBoxList = data;
          await getBoxQrCode();
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
        showLoadingDialog();
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
            await getDeliveredOrdersForDriver();
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
        "Có lỗi xảy ra, vui lòng thử lại sau 😓",
      );
    } finally {}
  }

  Future<void> getBoxQrCode() async {
    try {
      setState(ViewStatus.Loading);

      if (orderBoxList.isNotEmpty) {
        var requestData = [];
        for (ShipperOrderBoxDTO orderBox in orderBoxList) {
          List<OrderDetail>? orderDetails = orderBox.orderDetails;
          if (orderDetails!.isNotEmpty) {
            requestData.add(StationQrCodeRequestModel(
                    boxId: orderBox.boxId?.toUpperCase(),
                    orderId: orderDetails.first.orderId?.toUpperCase())
                .toJson());
          }
        }
        final qrCode =
            await _stationDAO!.getQrCodeForShipper(requestData: requestData);
        if (qrCode != null) {
          imageBytes = qrCode;
        }
      }

      await Future.delayed(const Duration(milliseconds: 200));
      notifyListeners();
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getBoxQrCode();
      } else {
        setState(ViewStatus.Error);
      }
    } finally {}
  }
}
