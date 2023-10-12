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
      'staff',
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
    final res = await request.put('staff', data: requestModel.toJson());

    return res.statusCode;
  }

  Future<List<StationSplitProductDTO>?> getStationSplitProductsForStaff(
      {String? timeSlotId}) async {
    final res = await request.get(
      'staff/station',
      queryParameters: {"timeSlotId": timeSlotId},
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      // metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      return listJson.map((e) => StationSplitProductDTO.fromJson(e)).toList();
    }
    return null;
  }
}
