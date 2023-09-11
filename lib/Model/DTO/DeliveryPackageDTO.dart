class DeliveryPackageDTO {
  String? timeSlotId;
  String? stationId;
  String? productName;
  int? quantity;

  DeliveryPackageDTO(
      {this.timeSlotId, this.stationId, this.productName, this.quantity});

  DeliveryPackageDTO.fromJson(Map<String, dynamic> json) {
    timeSlotId = json['timeSlotId'];
    stationId = json['stationId'];
    productName = json['productName'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timeSlotId'] = timeSlotId;
    data['stationId'] = stationId;
    data['productName'] = productName;
    data['quantity'] = quantity;
    return data;
  }
}
