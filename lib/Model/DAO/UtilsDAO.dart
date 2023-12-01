// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:fine_merchant_mobile/Model/DAO/BaseDAO.dart';
import 'package:fine_merchant_mobile/Utils/request.dart';

class UtilsDAO extends BaseDAO {
  Future<int?> logError({required String messageBody}) async {
    try {
      const STAFF_MOBILE = 5;
      final response = await request.post('/log',
          data: jsonEncode(messageBody),
          queryParameters: {'appCatch': STAFF_MOBILE});
      if (response.statusCode != null) {
        return response.statusCode;
      }
      return null;
    } catch (e) {
      log(e.toString());
    }
  }
}
