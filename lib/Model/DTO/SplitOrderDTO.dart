// ignore_for_file: file_names

class SplitOrderDTO {
  int? totalProductInDay;
  int? totalProductPending;
  int? totalProductReady;
  int? totalProductError;
  List<ProductTotalDetail>? productTotalDetailList;
  List<ErrorProducts>? errorProducts;

  SplitOrderDTO({
    this.totalProductInDay,
    this.totalProductPending,
    this.totalProductReady,
    this.totalProductError,
    this.productTotalDetailList,
    this.errorProducts,
  });

  SplitOrderDTO.fromJson(Map<String, dynamic> json) {
    totalProductInDay = json['totalProductInDay'];
    totalProductPending = json['totalProductPending'];
    totalProductReady = json['totalProductReady'];
    totalProductError = json['totalProductError'];
    productTotalDetailList = json["productTotalDetails"] == null
        ? null
        : (json["productTotalDetails"] as List)
            .map((e) => ProductTotalDetail.fromJson(e))
            .toList();
    errorProducts = json["errorProducts"] == null
        ? null
        : (json["errorProducts"] as List)
            .map((e) => ErrorProducts.fromJson(e))
            .toList();
    // if (json['productTotalDetails'] != null) {
    //   productTotalDetailList = <ProductTotalDetail>[];
    //   json['productTotalDetails'].forEach((v) {
    //     productTotalDetailList!.add(ProductTotalDetail.fromJson(v));
    //   });
    // }
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
      this.isChecked,
      this.currentMissing});

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
      currentMissing = 1;
    }

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

class ErrorProducts {
  String? productId;
  String? productInMenuId;
  String? productName;
  int? quantity;
  int? reConfirmQuantity;
  String? stationId;
  int? reportMemType;
  int? numsToSolve;
  bool? isRefuse;

  ErrorProducts(
      {this.productId,
      this.productInMenuId,
      this.productName,
      this.quantity,
      this.stationId,
      this.reportMemType,
      this.numsToSolve,
      this.isRefuse});

  ErrorProducts.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    productInMenuId = json['productInMenuId'];
    productName = json['productName'];
    quantity = json['quantity'];
    reConfirmQuantity = json['reConfirmQuantity'];
    stationId = json['stationId'];
    reportMemType = json['reportMemType'];
    isRefuse = json['isRefuse'];
    numsToSolve = quantity! - reConfirmQuantity!;
  }
}

class UpdateSplitProductRequestModel {
  String? timeSlotId;
  int? type;
  List<String>? productsUpdate;
  int? quantity;
  String? boxId;
  String? storeId;

  UpdateSplitProductRequestModel(
      {this.timeSlotId,
      this.type,
      this.productsUpdate,
      this.quantity,
      this.boxId,
      this.storeId});

  UpdateSplitProductRequestModel.fromJson(Map<String, dynamic> json) {
    timeSlotId = json['timeSlotId'];
    type = json['type'];
    productsUpdate = json['productsUpdate'].cast<String>();
    quantity = json['quantity'];
    boxId = json['boxId'];
    storeId = json['storeId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timeSlotId'] = timeSlotId;
    data['type'] = type;
    data['productsUpdate'] = productsUpdate;
    data['quantity'] = quantity;
    data['boxId'] = boxId;
    return data;
  }
}

class StationSplitProductDTO {
  String? stationId;
  String? stationName;
  int? totalQuantity;
  int? readyQuantity;
  bool? isShipperAssign;
  List<PackageStationDetails>? packageStationDetails;
  List<PakageMissingList>? listPackageMissing;

  StationSplitProductDTO(
      {this.stationId,
      this.stationName,
      this.isShipperAssign,
      this.readyQuantity,
      this.totalQuantity,
      this.packageStationDetails,
      this.listPackageMissing});

  StationSplitProductDTO.fromJson(Map<String, dynamic> json) {
    stationId = json['stationId'];
    stationName = json['stationName'];
    totalQuantity = json["totalQuantity"];
    readyQuantity = json["readyQuantity"];
    isShipperAssign = json["isShipperAssign"];
    packageStationDetails = json["packageStationDetails"] == null
        ? null
        : (json["packageStationDetails"] as List)
            .map((e) => PackageStationDetails.fromJson(e))
            .toList();
    listPackageMissing = json["listPackageMissing"] == null
        ? null
        : (json["listPackageMissing"] as List)
            .map((e) => PakageMissingList.fromJson(e))
            .toList();
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

class PakageMissingList {
  String? productId;
  String? productName;
  int? quantity;

  PakageMissingList({
    this.productId,
    this.productName,
    this.quantity,
  });

  PakageMissingList.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    productName = json['productName'];
    quantity = json['quantity'];
  }
}
