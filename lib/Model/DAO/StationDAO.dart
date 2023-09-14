// ignore_for_file: file_names
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fine_merchant_mobile/Model/DAO/BaseDAO.dart';
import 'package:fine_merchant_mobile/Model/DTO/MetaDataDTO.dart';
import 'package:fine_merchant_mobile/Model/DTO/index.dart';

import 'package:fine_merchant_mobile/Utils/request.dart';

class StationDAO extends BaseDAO {
  Future<List<StationDTO>?> getStationsByDestination(
      {required String destinationId}) async {
    final res = await request.get(
      '/admin/station/destination/$destinationId',
      // queryParameters: {"destinationId": destinationId},
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => StationDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<List<BoxDTO>?> getAllBoxByStation({String? stationId}) async {
    final res = await request.get(
      '/admin/box/station/$stationId',
      queryParameters: {},
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => BoxDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<Uint8List?> getQrCodeForShipper(
      {required List<dynamic> requestData}) async {
    final response = await request.post('/admin/staff/qrCode',
        data: requestData, options: Options(responseType: ResponseType.bytes));
    if (response.statusCode == 200) {
      Uint8List imageBytes = Uint8List.fromList(response.data);
      return imageBytes;
    }

    return null;
  }
}