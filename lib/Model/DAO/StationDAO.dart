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
      'station/destination',
      queryParameters: {"destinationId": destinationId},
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
      queryParameters: {
        "PageSize": 100,
      },
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => BoxDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<List<ProductBoxesDTO>?> getProductBoxesByProduct(
      {String? timeSlotId, String? productId}) async {
    final res = await request.get(
      '/staff/package/listBox',
      queryParameters: {"timeSlotId": timeSlotId, "productId": productId},
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      // metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => ProductBoxesDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<List<MissingProductReportDTO>?> getMissingProductReport(
      {String? storeId, String? timeSlotId}) async {
    final res = await request.get(
      '/admin/staff/report',
      queryParameters: {"storeId": storeId, "timeSlotId": timeSlotId},
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => MissingProductReportDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<int?> confirmReportSolved({String? reportId}) async {
    final res = await request.put('admin/staff/report', data: [
      {"reportId": reportId}
    ]);
    return res.statusCode;
  }

  Future<Uint8List?> getQrCodeForShipper({required String timeSlotId}) async {
    final response = await request.get('/user-box/qrCodeShipper',
        queryParameters: {"timeSlotId": timeSlotId},
        options: Options(responseType: ResponseType.bytes));
    if (response.statusCode == 200) {
      Uint8List imageBytes = Uint8List.fromList(response.data);
      return imageBytes;
    }

    return null;
  }

  Future<int?> reportMissingProduct(
      {required MissingProductReportRequestModel requestData}) async {
    final response =
        await request.post('/admin/shipper/report', data: requestData);
    if (response.statusCode != null) {
      return response.statusCode;
    }
    return null;
  }

  Future<int?> addOrdersToBoxes(
      {required AddToBoxesRequestModel? requestData}) async {
    final response = await request.post('/admin/box', data: requestData);
    if (response.statusCode != null) {
      return response.statusCode;
    }
    return null;
  }
}
