// ignore_for_file: file_names

class SplitOrderDTO {
  int? totalProductInDay;
  int? totalProductPending;
  int? totalProductReady;
  int? totalProductError;
  List<ProductTotalDetail>? productTotalDetailList;

  SplitOrderDTO(
      {this.totalProductInDay,
      this.totalProductPending,
      this.totalProductReady,
      this.totalProductError,
      this.productTotalDetailList});

  SplitOrderDTO.fromJson(Map<String, dynamic> json) {
    totalProductInDay = json['totalProductInDay'];
    totalProductPending = json['totalProductPending'];
    totalProductReady = json['totalProductReady'];
    totalProductError = json['totalProductError'];
    if (json['productTotalDetails'] != null) {
      productTotalDetailList = <ProductTotalDetail>[];
      json['productTotalDetails'].forEach((v) {
        productTotalDetailList!.add(ProductTotalDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalProductInDay'] = totalProductInDay;
    data['totalProductPending'] = totalProductPending;
    data['totalProductReady'] = totalProductReady;
    data['totalProductError'] = totalProductError;
    if (productTotalDetailList != null) {
      data['productTotalDetails'] =
          productTotalDetailList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductTotalDetail {
  String? productId;
  String? productInMenuId;
  String? productName;
  int? pendingQuantity;
  int? readyQuantity;
  int? errorQuantity;
  List<ProductDetails>? productDetails;
  bool? isChecked;
  int? currentMissing;

  ProductTotalDetail(
      {this.productId,
      this.productInMenuId,
      this.productName,
      this.pendingQuantity,
      this.readyQuantity,
      this.errorQuantity,
      this.productDetails,
      this.currentMissing,
      this.isChecked});

  ProductTotalDetail.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    productInMenuId = json['productInMenuId'];
    productName = json['productName'];
    pendingQuantity = json['pendingQuantity'];
    readyQuantity = json['readyQuantity'];
    errorQuantity = json['errorQuantity'];
    if (json['productDetails'] != null) {
      productDetails = <ProductDetails>[];
      json['productDetails'].forEach((v) {
        productDetails!.add(ProductDetails.fromJson(v));
      });
    }
    currentMissing = 1;
    isChecked = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = productId;
    data['productInMenuId'] = productInMenuId;
    data['productName'] = productName;
    data['pendingQuantity'] = pendingQuantity;
    data['readyQuantity'] = readyQuantity;
    data['errorQuantity'] = errorQuantity;
    if (productDetails != null) {
      data['productDetails'] = productDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductDetails {
  String? orderId;
  int? quantity;
  bool? isReady;

  ProductDetails({this.orderId, this.quantity, this.isReady});

  ProductDetails.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    quantity = json['quantity'];
    isReady = json['isReady'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = orderId;
    data['quantity'] = quantity;
    data['isReady'] = isReady;
    return data;
  }
}

class UpdateSplitProductRequestModel {
  String? timeSlotId;
  int? type;
  List<String>? productsUpdate;
  int? quantity;

  UpdateSplitProductRequestModel(
      {this.timeSlotId, this.type, this.productsUpdate, this.quantity});

  UpdateSplitProductRequestModel.fromJson(Map<String, dynamic> json) {
    timeSlotId = json['timeSlotId'];
    type = json['type'];
    productsUpdate = json['productsUpdate'].cast<String>();
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timeSlotId'] = timeSlotId;
    data['type'] = type;
    data['productsUpdate'] = productsUpdate;
    data['quantity'] = quantity;
    return data;
  }
}

class StationSplitProductDTO {
  String? stationId;
  String? stationName;
  List<PackageStationDetails>? packageStationDetails;

  StationSplitProductDTO(
      {this.stationId, this.stationName, this.packageStationDetails});

  StationSplitProductDTO.fromJson(Map<String, dynamic> json) {
    stationId = json['stationId'];
    stationName = json['stationName'];
    if (json['packageStationDetails'] != null) {
      packageStationDetails = <PackageStationDetails>[];
      json['packageStationDetails'].forEach((v) {
        packageStationDetails!.add(PackageStationDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stationId'] = stationId;
    data['stationName'] = stationName;
    if (packageStationDetails != null) {
      data['packageStationDetails'] =
          packageStationDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PackageStationDetails {
  String? productId;
  String? productName;
  int? quantity;

  PackageStationDetails({this.productId, this.productName, this.quantity});

  PackageStationDetails.fromJson(Map<String, dynamic> json) {
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
