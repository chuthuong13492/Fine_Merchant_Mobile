import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Model/DTO/AccountDTO.dart';

import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/base_model.dart';
import 'package:fine_merchant_mobile/ViewModel/home_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/orderList_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RootViewModel extends BaseModel {
  // Position? currentPosition;
  String? currentLocation;
  String? lat;
  String? long;
  AccountDTO? user;
  // DestinationDTO? currentStore;
  // List<DestinationDTO>? campusList;
  // TimeSlotDTO? selectedTimeSlot;
  // List<TimeSlotDTO>? listTimeSlot;
  // ProductDAO? _productDAO;
  // StationDAO? _stationDAO;
  // DestinationDAO? _destinationDAO;
  bool changeAddress = false;
  Uint8List? imageBytes;

  RootViewModel() {
    // _productDAO = ProductDAO();
    // _destinationDAO = DestinationDAO();
    // _stationDAO = StationDAO();
    // selectedTimeSlot = null;
  }
  Future refreshMenu() async {
    // fetchStore();

    // await Get.find<HomeViewModel>().getListSupplier();
    // await Get.find<HomeViewModel>().getMenus();
    // await Get.find<OrderViewModel>().getUpSellCollections();
    // await Get.find<GiftViewModel>().getGifts();
  }

  Future startUp() async {
    await Get.find<AccountViewModel>().fetchUser();
    AccountDTO? currentUser = Get.find<AccountViewModel>().currentUser;
    if (currentUser?.roleType == AccountTypeEnum.STAFF) {
      await Get.find<OrderListViewModel>().getTimeSlotList();
      await Get.find<OrderListViewModel>().getStationList();
      await Get.find<OrderListViewModel>().getStoreList();
      await Get.find<OrderListViewModel>().getOrders();
      await Get.find<OrderListViewModel>().getSplitOrders();
    } else {
      await Get.find<HomeViewModel>().getStationList();
      await Get.find<HomeViewModel>().getTimeSlotList();
      await Get.find<HomeViewModel>().getStoreList();
      await Get.find<HomeViewModel>().getDeliveredOrdersForDriver();
      await Get.find<HomeViewModel>().getSplitOrdersForDriver();
      // await Get.find<StationViewModel>().getShipperOrderBoxes();
    }
  }
}
