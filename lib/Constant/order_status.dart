import 'package:fine_merchant_mobile/Model/DTO/OrderDTO.dart';

class OrderStatus {
  int? statusCode;
  String? code;
  String? message;
  OrderDTO? data;

  OrderStatus({
    this.statusCode,
    this.code,
    this.message,
    this.data,
  });
}

enum OrderFilter { NEW, ORDERING, DONE }
