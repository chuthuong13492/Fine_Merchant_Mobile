// ignore: file_names
import 'index.dart';

class OrderDTO {
  String? orderId;
  String? storeId;
  String? customerName;
  TimeSlotDTO? timeSlot;
  String? stationName;
  String? checkInDate;
  int? orderType;
  int? orderDetailStoreStatus;
  List<OrderDetail>? orderDetails;
  bool? isChecked;

  OrderDTO(
      {this.orderId,
      this.storeId,
      this.customerName,
      this.timeSlot,
      this.stationName,
      this.checkInDate,
      this.orderType,
      this.orderDetailStoreStatus,
      this.orderDetails,
      this.isChecked});

  OrderDTO.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    storeId = json['storeId'];
    customerName = json['customerName'];
    timeSlot = json['timeSlot'] != null
        ? TimeSlotDTO.fromJson(json['timeSlot'])
        : null;
    stationName = json['stationName'];
    checkInDate = json['checkInDate'];
    orderType = json['orderType'];
    orderDetailStoreStatus = json['orderDetailStoreStatus'];
    orderDetails = json["orderDetails"] == null
        ? null
        : (json["orderDetails"] as List)
            .map((e) => OrderDetail.fromJson(e))
            .toList();
    isChecked = false;
  }

  static List<OrderDTO> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => OrderDTO.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = orderId;
    data['storeId'] = storeId;
    data['customerName'] = customerName;
    if (timeSlot != null) {
      data['timeSlot'] = timeSlot!.toJson();
    }
    data['stationName'] = stationName;
    data['checkInDate'] = checkInDate;
    data['orderType'] = orderType;
    data['orderDetailStoreStatus'] = orderDetailStoreStatus;
    if (orderDetails != null) {
      data['orderDetails'] = orderDetails!.map((v) => v.toJson()).toList();
    }
    data["isChecked"] = isChecked;
    return data;
  }
}

class OtherAmounts {
  String? id;
  String? orderId;
  double? amount;
  int? type;

  OtherAmounts({
    this.id,
    this.orderId,
    this.amount,
    this.type,
  });

  OtherAmounts.fromJson(Map<String, dynamic> json) {
    id = json["id"] as String;
    orderId = json["orderId"] as String;
    amount = json["amount"];
    type = json["type"];
  }

  static List<OtherAmounts> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => OtherAmounts.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["orderId"] = orderId;
    _data["amount"] = amount;
    _data["type"] = type;
    return _data;
  }
}

class OrderDetail {
  String? id;
  String? orderId;
  String? productInMenuId;
  String? productId;
  String? storeId;
  String? productCode;
  String? productName;
  double? unitPrice;
  int? quantity;
  double? totalAmount;
  double? discount;
  double? finalAmount;
  String? note;
  bool? isChecked;
  int? missing;

  OrderDetail(
      {this.id,
      this.orderId,
      this.productInMenuId,
      this.productId,
      this.storeId,
      this.productCode,
      this.productName,
      this.unitPrice,
      this.quantity,
      this.totalAmount,
      this.discount,
      this.finalAmount,
      this.note,
      this.isChecked,
      this.missing});

  OrderDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['orderId'];
    productInMenuId = json['productInMenuId'];
    productId = json['productId'];
    storeId = json['storeId'];
    productCode = json['productCode'];
    productName = json['productName'];
    unitPrice = json['unitPrice'];
    quantity = json['quantity'];
    totalAmount = json['totalAmount'];
    discount = json['discount'];
    finalAmount = json['finalAmount'];
    note = json['note'];
    isChecked = false;
    missing = 0;
  }

  static List<OrderDetail> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => OrderDetail.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['orderId'] = orderId;
    data['productInMenuId'] = productInMenuId;
    data['productId'] = productId;
    data['storeId'] = storeId;
    data['productCode'] = productCode;
    data['productName'] = productName;
    data['unitPrice'] = unitPrice;
    data['quantity'] = quantity;
    data['totalAmount'] = totalAmount;
    data['discount'] = discount;
    data['finalAmount'] = finalAmount;
    data['note'] = note;

    return data;
  }
}

class OrderStatusDTO {
  int? orderStatus;
  String? boxId;
  String? stationName;

  OrderStatusDTO({
    this.orderStatus,
    this.boxId,
    this.stationName,
  });

  OrderStatusDTO.fromJson(Map<String, dynamic> json) {
    orderStatus = json["orderStatus"] as int;
    boxId = json["boxId"] as String;
    stationName = json["stationName"] as String;
  }

  static List<OrderStatusDTO> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => OrderStatusDTO.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["orderStatus"] = orderStatus;
    _data["boxId"] = boxId;
    _data["stationName"] = stationName;
    return _data;
  }
}

class UpdateOrderStatusRequestModel {
  int? orderDetailStoreStatus;
  List<ListStoreAndOrder>? listStoreAndOrder;

  UpdateOrderStatusRequestModel(
      {this.orderDetailStoreStatus, this.listStoreAndOrder});

  UpdateOrderStatusRequestModel.fromJson(Map<String, dynamic> json) {
    orderDetailStoreStatus = json['orderDetailStoreStatus'];
    if (json['listStoreAndOrder'] != null) {
      listStoreAndOrder = <ListStoreAndOrder>[];
      json['listStoreAndOrder'].forEach((v) {
        listStoreAndOrder!.add(ListStoreAndOrder.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderDetailStoreStatus'] = orderDetailStoreStatus;
    if (listStoreAndOrder != null) {
      data['listStoreAndOrder'] =
          listStoreAndOrder!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListStoreAndOrder {
  String? orderId;
  String? storeId;

  ListStoreAndOrder({this.orderId, this.storeId});

  ListStoreAndOrder.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    storeId = json['storeId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = orderId;
    data['storeId'] = storeId;
    return data;
  }
}

class ShipperOrderBoxDTO {
  String? boxId;
  List<OrderDetail>? orderDetails;

  ShipperOrderBoxDTO({this.boxId, this.orderDetails});

  ShipperOrderBoxDTO.fromJson(Map<String, dynamic> json) {
    boxId = json['boxId'];
    if (json['orderDetails'] != null) {
      orderDetails = <OrderDetail>[];
      json['orderDetails'].forEach((v) {
        orderDetails!.add(OrderDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['boxId'] = boxId;
    if (orderDetails != null) {
      data['orderDetails'] = orderDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
