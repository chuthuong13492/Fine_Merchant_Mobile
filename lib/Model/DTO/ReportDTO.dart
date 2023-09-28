class MissingProductReportDTO {
  String? reportId;
  String? timeSlotId;
  String? stationId;
  String? storeId;
  String? productName;
  List<ListBoxAndQuantity>? listBoxAndQuantity;

  MissingProductReportDTO(
      {this.reportId,
      this.timeSlotId,
      this.stationId,
      this.storeId,
      this.productName,
      this.listBoxAndQuantity});

  MissingProductReportDTO.fromJson(Map<String, dynamic> json) {
    reportId = json['reportId'];
    timeSlotId = json['timeSlotId'];
    stationId = json['stationId'];
    storeId = json['storeId'];
    productName = json['productName'];
    if (json['listBoxAndQuantity'] != null) {
      listBoxAndQuantity = <ListBoxAndQuantity>[];
      json['listBoxAndQuantity'].forEach((v) {
        listBoxAndQuantity!.add(new ListBoxAndQuantity.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reportId'] = reportId;
    data['timeSlotId'] = timeSlotId;
    data['stationId'] = stationId;
    data['storeId'] = storeId;
    data['productName'] = productName;
    if (listBoxAndQuantity != null) {
      data['listBoxAndQuantity'] =
          listBoxAndQuantity!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListBoxAndQuantity {
  String? boxId;
  int? quantity;

  ListBoxAndQuantity({this.boxId, this.quantity});

  ListBoxAndQuantity.fromJson(Map<String, dynamic> json) {
    boxId = json['boxId'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['boxId'] = boxId;
    data['quantity'] = quantity;
    return data;
  }
}

class MissingProductReportRequestModel {
  String? timeSlotId;
  String? stationId;
  String? productName;
  List<ListBoxAndQuantity>? listBoxAndQuantity;

  MissingProductReportRequestModel(
      {this.timeSlotId,
      this.stationId,
      this.productName,
      this.listBoxAndQuantity});

  MissingProductReportRequestModel.fromJson(Map<String, dynamic> json) {
    timeSlotId = json['timeSlotId'];
    stationId = json['stationId'];
    productName = json['productName'];
    if (json['listBoxAndQuantity'] != null) {
      listBoxAndQuantity = <ListBoxAndQuantity>[];
      json['listBoxAndQuantity'].forEach((v) {
        listBoxAndQuantity!.add(new ListBoxAndQuantity.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timeSlotId'] = timeSlotId;
    data['stationId'] = stationId;
    data['productName'] = productName;
    if (listBoxAndQuantity != null) {
      data['listBoxAndQuantity'] =
          listBoxAndQuantity!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
