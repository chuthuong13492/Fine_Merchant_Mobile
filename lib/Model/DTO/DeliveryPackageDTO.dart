class DeliveryPackageDTO {
  String? storeId;
  String? storeName;
  bool? isTaken;
  int? totalQuantity;
  List<PackageShipperDetails>? packageShipperDetails;

  DeliveryPackageDTO(
      {this.storeId, this.storeName, this.packageShipperDetails});

  DeliveryPackageDTO.fromJson(Map<String, dynamic> json) {
    storeId = json['storeId'];
    storeName = json['storeName'];
    isTaken = json['isTaken'];
    totalQuantity = json['totalQuantity'];
    if (json['packageShipperDetails'] != null) {
      packageShipperDetails = <PackageShipperDetails>[];
      json['packageShipperDetails'].forEach((v) {
        packageShipperDetails!.add(PackageShipperDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['storeId'] = storeId;
    data['storeName'] = storeName;
    if (packageShipperDetails != null) {
      data['packageShipperDetails'] =
          packageShipperDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PackageShipperDetails {
  String? productId;
  String? productName;
  int? quantity;

  PackageShipperDetails({this.productId, this.productName, this.quantity});

  PackageShipperDetails.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    productName = json['productName'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = productId;
    data['productName'] = productName;
    data['quantity'] = quantity;
    return data;
  }
}
