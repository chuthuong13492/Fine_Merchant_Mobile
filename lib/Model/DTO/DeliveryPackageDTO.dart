class DeliveryPackageDTO {
  String? productName;
  int? quantity;
  String? timeSlotId;
  String? storeId;
  String? stationId;

  DeliveryPackageDTO(
      {this.timeSlotId, this.stationId, this.productName, this.quantity});

  DeliveryPackageDTO.fromJson(Map<String, dynamic> json) {
    productName = json['productName'];
    quantity = json['quantity'];
    storeId = json['storeId'];
    stationId = json['stationId'];
    timeSlotId = json['timeSlotId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productName'] = productName;
    data['quantity'] = quantity;
    data['storeId'] = storeId;
    data['stationId'] = stationId;
    data['timeSlotId'] = timeSlotId;
    return data;
  }
}
