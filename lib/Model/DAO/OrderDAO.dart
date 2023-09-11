import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/Model/DAO/BaseDAO.dart';
import 'package:fine_merchant_mobile/Model/DTO/MetaDataDTO.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:fine_merchant_mobile/Utils/request.dart';

class OrderDAO extends BaseDAO {
  Future<OrderDTO?> getOrderById(String? orderId) async {
    // data["destination_location_id"] = destinationId;
    final res = await request.get('/order/$orderId');
    if (res.data['data'] != null) {
      return OrderDTO.fromJson(res.data['data']);
    }
    return null;
  }

  Future<List<SplitOrderDTO>?> getSplitOrderListByStoreAndStation(
      {required String storeId,
      String? stationId,
      String? timeSlotId,
      int? orderStatus}) async {
    final res = await request.get(
      '/admin/orderDetail/splitOrder/${storeId}',
      queryParameters: {
        "timeSlotId": timeSlotId,
        "status": orderStatus,
        "stationId": stationId,
        // "size": size ?? DEFAULT_SIZE,
        // "page": page ?? 1,
      },
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => SplitOrderDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<List<DeliveryPackageDTO>?> getSplitOrderListByStoreForDriver(
      {required String storeId,
      String? stationId,
      String? timeSlotId,
      int? orderStatus}) async {
    final res = await request.get(
      '/admin/orderDetail/shipper/splitOrder/${storeId}',
      queryParameters: {
        // "timeSlotId": timeSlotId,
        // "status": orderStatus,
        // "stationId": stationId,
        // "size": size ?? DEFAULT_SIZE,
        // "page": page ?? 1,
      },
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => DeliveryPackageDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<List<OrderDTO>?> getOrderListByStoreAndStation(
      {String? storeId,
      String? stationId,
      String? timeSlotId,
      int? orderStatus}) async {
    final res = await request.get(
      '/admin/orderDetail/staff/${storeId}/${stationId}',
      queryParameters: {
        "timeSlotId": timeSlotId,
        "status": orderStatus,
        // "size": size ?? DEFAULT_SIZE,
        // "page": page ?? 1,
      },
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => OrderDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<List<OrderDTO>?> getParentOrderList({String? orderId}) async {
    final res = await request.get(
      '/admin/orderDetail/${orderId}',
      queryParameters: {
        // "order-status":
        //     filter == OrderFilter.NEW ? ORDER_NEW_STATUS : ORDER_DONE_STATUS,
        // "size": size ?? DEFAULT_SIZE,
        // "page": page ?? 1,
      },
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => OrderDTO.fromJson(e)).toList();
    }
    return null;
  }
  // Future<List<OrderDTO>?> getMoreOrders({int? page, int? size}) async {
  //   final res = await request.get(
  //     '/customer/orders?Page=$page',
  //     queryParameters: {
  //       // "order-status":
  //       //     filter == OrderFilter.NEW ? ORDER_NEW_STATUS : ORDER_DONE_STATUS,
  //       // "size": size ?? DEFAULT_SIZE,
  //       // "page": page ?? 1,
  //     },
  //   );
  //   List<OrderDTO>? orderSummaryList;
  //   if (res.statusCode == 200) {
  //     var listJson = res.data['data'] as List;
  //     metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
  //     // orderSummaryList = OrderDTO.fromList(res.data['data']);
  //     return listJson.map((e) => OrderDTO.fromJson(e)).toList();
  //   }
  //   return null;
  // }

  Future<OrderStatusDTO?> fetchOrderStatus(String orderId) async {
    final res = await request.get(
      'order/status/$orderId',
    );
    if (res.statusCode == 200) {
      return OrderStatusDTO.fromJson(res.data['data']);
    }
    return null;
  }

  Future<int?> confirmStoreOrderDetail(
      {required UpdateOrderStatusRequestModel orders}) async {
    final res = await request.put('admin/orderDetail/status/storeId/orderId',
        data: orders);

    return res.statusCode;
  }

  Future<int?> finishParentOrder({String? orderId, int? orderStatus}) async {
    final res = await request.put('admin/order/status/${orderId}',
        data: {"orderStatus": orderStatus});

    return res.statusCode;
  }
}
