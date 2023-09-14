// ignore_for_file: file_names

class SplitOrderDTO {
  String? productName;
  int? quantity;
  String? timeSlotId;
  bool? isChecked;

  SplitOrderDTO(
      {this.productName, this.quantity, this.timeSlotId, this.isChecked});

  SplitOrderDTO.fromJson(Map<String, dynamic> json) {
    productName = json['productName'];
    quantity = json['quantity'];
    timeSlotId = json['timeSlotId'];
    isChecked = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productName'] = productName;
    data['quantity'] = quantity;
    data['timeSlotId'] = timeSlotId;
    data['isChecked'] = isChecked;
    return data;
  }
}
