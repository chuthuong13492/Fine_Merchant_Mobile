// ignore_for_file: file_names

class SplitOrderDTO {
  List<String>? orderDetailIdList;
  String? productName;
  int? quantity;
  String? timeSlotId;
  bool? isChecked;

  SplitOrderDTO(
      {this.orderDetailIdList,
      this.productName,
      this.quantity,
      this.timeSlotId,
      this.isChecked});

  SplitOrderDTO.fromJson(Map<String, dynamic> json) {
    if (json['orderDetailId'] != null) {
      orderDetailIdList = <String>[];
      json['orderDetailId'].forEach((v) {
        orderDetailIdList!.add(v);
      });
    }
    productName = json['productName'];
    quantity = json['quantity'];
    timeSlotId = json['timeSlotId'];
    isChecked = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderDetailId'] = orderDetailIdList;
    data['productName'] = productName;
    data['quantity'] = quantity;
    data['timeSlotId'] = timeSlotId;
    data['isChecked'] = isChecked;
    return data;
  }
}

class UpdateSplitProductsRequestModel {
  int? productStatus;
  List<String>? orderDetailId;

  UpdateSplitProductsRequestModel({this.productStatus, this.orderDetailId});

  UpdateSplitProductsRequestModel.fromJson(Map<String, dynamic> json) {
    productStatus = json['productStatus'];
    orderDetailId = json['orderDetailId'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productStatus'] = productStatus;
    data['orderDetailId'] = orderDetailId;
    return data;
  }
}
