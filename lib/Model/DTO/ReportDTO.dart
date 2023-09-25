class MissingProductReportDTO {
  String? reportId;
  String? timeSlotId;
  String? stationId;
  String? storeId;
  String? boxId;
  List<MissingProduct>? missingProducts;

  MissingProductReportDTO(
      {this.reportId,
      this.timeSlotId,
      this.stationId,
      this.storeId,
      this.boxId,
      this.missingProducts});

  MissingProductReportDTO.fromJson(Map<String, dynamic> json) {
    reportId = json['reportId'];
    timeSlotId = json['timeSlotId'];
    stationId = json['stationId'];
    storeId = json['storeId'];
    boxId = json['boxId'];
    if (json['missingProducts'] != null) {
      missingProducts = <MissingProduct>[];
      json['missingProducts'].forEach((v) {
        missingProducts!.add(new MissingProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reportId'] = reportId;
    data['timeSlotId'] = timeSlotId;
    data['stationId'] = stationId;
    data['storeId'] = storeId;
    data['boxId'] = boxId;
    if (missingProducts != null) {
      data['missingProducts'] =
          missingProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MissingProduct {
  String? productName;
  int? quantity;
  String? storeId;

  MissingProduct({this.productName, this.quantity, this.storeId});

  MissingProduct.fromJson(Map<String, dynamic> json) {
    productName = json['productName'];
    quantity = json['quantity'];
    storeId = json['storeId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productName'] = productName;
    data['quantity'] = quantity;
    data['storeId'] = storeId;
    return data;
  }
}

class MissingProductReportRequestModel {
  String? timeSlotId;
  String? stationId;
  String? storeId;
  String? boxId;
  List<MissingProduct>? missingProducts;

  MissingProductReportRequestModel(
      {this.timeSlotId,
      this.stationId,
      this.storeId,
      this.boxId,
      this.missingProducts});

  MissingProductReportRequestModel.fromJson(Map<String, dynamic> json) {
    timeSlotId = json['timeSlotId'];
    stationId = json['stationId'];
    storeId = json['storeId'];
    boxId = json['boxId'];
    if (json['missingProducts'] != null) {
      missingProducts = <MissingProduct>[];
      json['missingProducts'].forEach((v) {
        missingProducts!.add(new MissingProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timeSlotId'] = timeSlotId;
    data['stationId'] = stationId;
    data['storeId'] = storeId;
    data['boxId'] = boxId;
    if (missingProducts != null) {
      data['missingProducts'] =
          missingProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
