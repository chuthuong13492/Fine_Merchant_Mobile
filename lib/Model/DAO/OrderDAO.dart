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

  Future<List<SplitOrderDTO>?> getSplitOrderListByStoreForStaff(
      {required String storeId,
      String? stationId,
      String? timeSlotId,
      int? orderStatus}) async {
    final res = await request.get(
      '/admin/orderDetail/splitOrder/${storeId}',
      queryParameters: {
        "timeSlotId": timeSlotId,
        "productStatus": orderStatus,
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
      {String? storeId,
      required String stationId,
      required String timeSlotId,
      int? orderStatus}) async {
    final res = await request.get(
      '/admin/orderDetail/shipper/splitOrder/${timeSlotId}/${stationId}',
      queryParameters: {
        "status": orderStatus,
        "storeId": storeId,
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

  Future<List<OrderDTO>?> getOrderListForUpdating(
      {String? storeId,
      String? stationId,
      String? timeSlotId,
      int? orderStatus}) async {
    final res = await request.get(
      '/admin/orderDetail/staff/splitOrderDetail',
      queryParameters: {
        "timeSlotId": timeSlotId,
        "status": orderStatus,
        "storeId": storeId,
        "stationId": stationId,
        "PageSize": 100,
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

  Future<List<ShipperOrderBoxDTO>?> getShipperOrderBox({
    String? stationId,
    String? timeSlotId,
  }) async {
    final res = await request.get(
      '/admin/orderDetail/orderBox/${timeSlotId}/${stationId}',
      queryParameters: {
        // "timeSlotId": timeSlotId,
        // "size": size ?? DEFAULT_SIZE,
        // "page": page ?? 1,
      },
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => ShipperOrderBoxDTO.fromJson(e)).toList();
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
        data: orders.toJson());

    return res.statusCode;
  }

  Future<int?> confirmSplitProduct(
      {required UpdateSplitProductsRequestModel products}) async {
    final res = await request.put(
        'admin/orderDetail/status/storeId/orderDetailId',
        data: products.toJson());

    return res.statusCode;
  }

  Future<int?> finishParentOrder({String? orderId, int? orderStatus}) async {
    final res = await request.put('admin/order/status/${orderId}',
        data: {"orderStatus": orderStatus});

    return res.statusCode;
  }
}
