import 'package:fine_merchant_mobile/Accessories/dialog.dart';
import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Utils/constrant.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/base_model.dart';
import 'package:fine_merchant_mobile/ViewModel/home_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Model/DAO/index.dart';
import '../Model/DTO/index.dart';

class DeliveryListViewModel extends BaseModel {
  // constant

  // local properties
  List<DeliveryPackageDTO> packageList = [];
  List<PackageViewDTO> deliveredPackageList = [];
  List<OrderDTO> orderDetailList = [];
  List<StoreDTO> storeList = [];
  List<TimeSlotDTO> timeSlotList = [];
  List<StationDTO> stationList = [];
  // Data Object Model
  OrderDAO? _orderDAO;
  dynamic error;
  OrderDTO? orderDTO;
  // Widget
  ScrollController? scrollController;
  bool isDelivering = false;
  PackageViewDTO? currentDeliveryPackage;
  DeliveryListViewModel() {
    // orderDTO = dto;
    _orderDAO = OrderDAO();

    scrollController = ScrollController();
  }

  Future<void> confirmAllBoxStored({String? id}) async {
    try {
      setState(ViewStatus.Loading);
      await Get.find<StationViewModel>().confirmAllBoxStored();
      await Get.find<HomeViewModel>().getDeliveredOrdersForDriver();
      deliveredPackageList = Get.find<HomeViewModel>().deliveredPackageList;
      setState(ViewStatus.Completed);
      notifyListeners();
    } catch (e) {
      setState(ViewStatus.Error, e.toString());
    }
  }
}
