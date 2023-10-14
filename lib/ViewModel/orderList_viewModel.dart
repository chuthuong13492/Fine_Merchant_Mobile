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
  SplitOrderDTO? splitOrder;
  List<ProductTotalDetail>? pendingProductList = [];
  List<ProductTotalDetail>? confirmedProductList = [];
  List<ErrorProducts>? errorProductList = [];
  List<OrderDTO> orderList = [];
  List<OrderDTO> filteredOrderList = [];
  List<StationDTO> stationList = [];
  List<StoreDTO> storeList = [];
  List<TimeSlotDTO> timeSlotList = [];
  // Data Object Model
  SplitProductDAO? _splitProductDAO;
  OrderDAO? _orderDAO;
  StationDAO? _stationDAO;
  StoreDAO? _storeDAO;
  TimeSlotDAO? _timeSlotDAO;
  dynamic error;
  OrderDTO? orderDTO;
  // Widget
  ScrollController? scrollController;
  var numsOfCheck = 0;
  int currentMissing = 1;
  var isAllChecked = false;
  int selectedOrderStatus = OrderStatusEnum.PROCESSING;
  StationDTO? selectedStation;
  String selectedTimeSlotId = '';
  String selectedStoreId = '';
  List<bool> stationSelections = [];
  OrderDTO? newTodayOrders;
  StoreDTO? staffStore;
  final ValueNotifier<int> notifierPending = ValueNotifier(0);
  final ValueNotifier<int> notifierReady = ValueNotifier(0);
  final ValueNotifier<int> notifierError = ValueNotifier(0);

  OrderListViewModel() {
    _splitProductDAO = SplitProductDAO();
    _orderDAO = OrderDAO();
    _stationDAO = StationDAO();
    _storeDAO = StoreDAO();
    _timeSlotDAO = TimeSlotDAO();
    scrollController = ScrollController();

    scrollController!.addListener(() async {
      // if (scrollController!.position.pixels ==
      //     scrollController!.position.maxScrollExtent) {
      //   int total_page = (_orderDAO!.metaDataDTO.total! / DEFAULT_SIZE).ceil();
      //   if (total_page > _orderDAO!.metaDataDTO.page!) {
      //     await getMoreOrders();
      //   }
      // }
    });
  }

  void onChangeMissing(int index, int newValue) {
    List<ProductTotalDetail>? splitProductList =
        splitOrder?.productTotalDetailList;
    if (index >= 0 && splitProductList != null && splitProductList.isNotEmpty) {
      if (newValue > -1 &&
          (splitProductList[index].pendingQuantity! - newValue > 0)) {
        splitProductList[index].currentMissing = newValue;
      }
    }

    notifyListeners();
  }

  void onCheck(int index, bool isChecked) {
    List<ProductTotalDetail>? productList = pendingProductList;
    if (index > -1 && productList != null && productList.isNotEmpty) {
      productList[index].isChecked = isChecked;
      if (isChecked) {
        numsOfCheck++;
      } else {
        numsOfCheck--;
        productList[index].currentMissing = 0;
      }
    } else {
      print('No index found');
    }
    notifyListeners();
  }

  void onCheckAll(bool isCheckingAll) {
    List<ProductTotalDetail>? productList = pendingProductList;
    if (isCheckingAll && productList != null && productList.isNotEmpty) {
      for (final item in productList) {
        item.isChecked = true;
      }
      numsOfCheck = productList.length;
      isAllChecked = true;
    } else {
      for (final item in productList!) {
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

    notifyListeners();
  }

  Future<void> getTimeSlotList() async {
    try {
      setState(ViewStatus.Completed);
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
      setState(ViewStatus.Completed);
      print('selectedTimeSlotId: $selectedTimeSlotId');
      // var currentUser = Get.find<AccountViewModel>().currentUser;
      List<ProductTotalDetail>? newPendingProductList = [];
      List<ProductTotalDetail>? newConfirmedProductList = [];

      final data = await _splitProductDAO?.getSplitProductsForStaff(
        timeSlotId: selectedTimeSlotId,
      );
      if (data != null) {
        List<ProductTotalDetail>? newSplitProductList =
            data.productTotalDetailList;
        if (data.errorProducts != null && data.errorProducts!.isNotEmpty) {
          errorProductList = data.errorProducts;
        } else {
          errorProductList = [];
        }

        if (splitOrder != null) {
          List<ProductTotalDetail>? currentSplitProductList =
              splitOrder!.productTotalDetailList;

          if (currentSplitProductList != null) {
            for (ProductTotalDetail splitProduct in currentSplitProductList) {
              if (splitProduct.isChecked == true &&
                  splitProduct.pendingQuantity! > 0) {
                numsOfCheck = 0;
                final updateIndex = newSplitProductList!.indexWhere(
                    (e) => e.productName == splitProduct.productName);
                if (updateIndex > -1) {
                  newSplitProductList[updateIndex].isChecked = true;
                  newSplitProductList[updateIndex].currentMissing =
                      splitProduct.currentMissing;
                  numsOfCheck = numsOfCheck + 1;
                }
              }
            }
            if (numsOfCheck == newSplitProductList!.length) {
              isAllChecked = true;
            } else {
              isAllChecked = false;
            }
          }
        }
        if (newSplitProductList != null && newSplitProductList.isNotEmpty) {
          data.productTotalDetailList = newSplitProductList;
          splitOrder = data;
          notifierPending.value = splitOrder!.totalProductPending!;
          notifierReady.value = splitOrder!.totalProductReady!;
          notifierError.value = splitOrder!.totalProductError!;

          for (ProductTotalDetail product in newSplitProductList) {
            if (product.pendingQuantity! > 0) {
              newPendingProductList.add(product);
            }
          }
          for (ProductTotalDetail product in newSplitProductList) {
            if (product.readyQuantity! > 0) {
              newConfirmedProductList.add(product);
            }
          }
          // for (ProductTotalDetail product in newSplitProductList) {
          //   if (product.errorQuantity! > 0) {
          //     newReportedProductList.add(product);
          //   }
          // }
        }
        pendingProductList = newPendingProductList;
        confirmedProductList = newConfirmedProductList;

        notifyListeners();
      } else {
        splitOrder = data;
        notifierPending.value = splitOrder!.totalProductPending!;
        notifierReady.value = splitOrder!.totalProductReady!;
        notifierError.value = splitOrder!.totalProductError!;
        pendingProductList = null;
        confirmedProductList = null;
      }
      notifyListeners();
      setState(ViewStatus.Completed);
    } catch (e) {
      print(e);
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

  Future<void> updateSplitProductsStatus({required int statusType}) async {
    try {
      List<String> updatedProducts = [];
      int option = await showOptionDialog("Xác nhận những món này?");

      if (option == 1) {
        showLoadingDialog();
        List<ProductTotalDetail>? productList = pendingProductList;
        if (productList != null && productList.isNotEmpty) {
          for (final splitProduct in productList) {
            if (splitProduct.isChecked == true) {
              updatedProducts.add(splitProduct.productId!);
            }
          }
          UpdateSplitProductRequestModel requestModel =
              UpdateSplitProductRequestModel(
                  type: statusType,
                  timeSlotId: selectedTimeSlotId,
                  productsUpdate: updatedProducts,
                  quantity: 0);

          final statusCode = await _splitProductDAO?.confirmSplitProduct(
              requestModel: requestModel);
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
      }
    } catch (e) {
      await showStatusDialog(
        "assets/images/error.png",
        "Thất bại",
        "Có lỗi xảy ra, vui lòng thử lại sau 😓",
      );
    } finally {
      await getSplitOrders();
    }
  }

  Future<void> updateReportProduct(
      {required String productId,
      required int quantity,
      required int type}) async {
    try {
      List<String> updatedProducts = [];
      int option = await showOptionDialog(
          type == 2 ? "Báo cáo thiếu món này?" : "Đã xử lý món này?");

      if (option == 1) {
        showLoadingDialog();
        List<ProductTotalDetail>? currentSplitProductList =
            splitOrder!.productTotalDetailList;
        if (currentSplitProductList!.isNotEmpty) {
          updatedProducts.add(productId);
          UpdateSplitProductRequestModel requestModel =
              UpdateSplitProductRequestModel(
                  type: type,
                  timeSlotId: selectedTimeSlotId,
                  productsUpdate: updatedProducts,
                  quantity: quantity);

          final statusCode = await _splitProductDAO?.confirmSplitProduct(
              requestModel: requestModel);
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
      }
    } catch (e) {
      await showStatusDialog(
        "assets/images/error.png",
        "Thất bại",
        "Có lỗi xảy ra, vui lòng thử lại sau 😓",
      );
    } finally {
      await getSplitOrders();
    }
  }

  void clearNewOrder(int orderId) {
    newTodayOrders = null;
    notifyListeners();
  }

  Future<void> closeNewOrder(orderId) async {
    newTodayOrders = null;
    notifyListeners();
  }

  bool listsAreEqual(
      List<ProductTotalDetail> list1, List<ProductTotalDetail> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }

    return true;
  }
}
