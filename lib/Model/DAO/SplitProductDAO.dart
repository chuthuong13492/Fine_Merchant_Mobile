// ignore_for_file: file_names
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fine_merchant_mobile/Model/DAO/BaseDAO.dart';
import 'package:fine_merchant_mobile/Model/DTO/MetaDataDTO.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';

import 'package:fine_merchant_mobile/Utils/request.dart';

class SplitProductDAO extends BaseDAO {
  Future<SplitOrderDTO?> getSplitProductsForStaff({String? timeSlotId}) async {
    final res = await request.get(
      'staff/package',
      queryParameters: {"timeSlotId": timeSlotId},
    );
    if (res.data['data'] != null) {
      var json = res.data['data'];
      return SplitOrderDTO.fromJson(json);
    }
    return null;
  }

  Future<int?> confirmSplitProduct(
      {required UpdateSplitProductRequestModel requestModel}) async {
    final res = await request.put('staff/package', data: requestModel.toJson());

    return res.statusCode;
  }

  Future<int?> reportBoxSplitProduct(
      {required ReportBoxRequestModel requestModel}) async {
    final res = await request.put('staff/package', data: requestModel.toJson());

    return res.statusCode;
  }

  Future<int?> reportUnsolvedProduct(
      {required String timeSlotId,
      required String productId,
      required int memType}) async {
    final res = await request.put('staff/package/reportProductCannotRepair',
        queryParameters: {
          "timeSlotId": timeSlotId,
          "productId": productId,
          "memType": memType
        });

    return res.statusCode;
  }

  Future<int?> confirmDeliveryProduct(
      {required String timeSlotId, required String stationId}) async {
    final res = await request.put('staff/package/cofirmDelivery',
        queryParameters: {"timeSlotId": timeSlotId, "stationId": stationId});

    return res.statusCode;
  }

  Future<List<StationSplitProductDTO>?> getStationSplitProductsForStaff(
      {String? timeSlotId}) async {
    final res = await request.get(
      'staff/package/station',
      queryParameters: {"timeSlotId": timeSlotId},
    );

    var listJson = res.data['data'] as List;
    if (listJson.isNotEmpty) {
      return listJson.map((e) => StationSplitProductDTO.fromJson(e)).toList();
    }

    return null;
  }

  Future<DeliveryPackageDTO?> getDeliveryPackageListForDriver({
    required String timeSlotId,
  }) async {
    final res = await request.get(
      'staff/package/deliveryPackage',
      queryParameters: {
        "timeSlotId": timeSlotId,

        // "size": size ?? DEFAULT_SIZE,
        // "page": page ?? 1,
      },
    );
    if (res.data['data'] != null) {
      final deliveryPackage = DeliveryPackageDTO.fromJson(res.data['data']);
      return deliveryPackage;
    }
    return null;
  }

  Future<int?> confirmTakenProduct(
      {required String timeSlotId, required String storeId}) async {
    final res = await request.put('staff/package/cofirmTaken',
        queryParameters: {"timeSlotId": timeSlotId, "storeId": storeId});

    return res.statusCode;
  }

  Future<int?> confirmAllInBoxes({required String timeSlotId}) async {
    final res = await request.put('staff/package/confirmAllBox',
        queryParameters: {"timeSlotId": timeSlotId});

    return res.statusCode;
  }
}
