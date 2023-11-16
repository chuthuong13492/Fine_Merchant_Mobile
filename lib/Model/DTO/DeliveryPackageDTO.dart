class DeliveryPackageDTO {
  List<PackStationDetailGroupByBoxes>? packStationDetailGroupByBoxes;
  List<PackageStoreShipperResponses>? packageStoreShipperResponses;

  DeliveryPackageDTO(
      {this.packStationDetailGroupByBoxes, this.packageStoreShipperResponses});

  DeliveryPackageDTO.fromJson(Map<String, dynamic> json) {
    if (json['packStationDetailGroupByBoxes'] != null) {
      packStationDetailGroupByBoxes = <PackStationDetailGroupByBoxes>[];
      json['packStationDetailGroupByBoxes'].forEach((v) {
        packStationDetailGroupByBoxes!
            .add(PackStationDetailGroupByBoxes.fromJson(v));
      });
    }
    if (json['packageStoreShipperResponses'] != null) {
      packageStoreShipperResponses = <PackageStoreShipperResponses>[];
      json['packageStoreShipperResponses'].forEach((v) {
        packageStoreShipperResponses!
            .add(PackageStoreShipperResponses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (packStationDetailGroupByBoxes != null) {
      data['packStationDetailGroupByBoxes'] =
          packStationDetailGroupByBoxes!.map((v) => v.toJson()).toList();
    }
    if (packageStoreShipperResponses != null) {
      data['packageStoreShipperResponses'] =
          packageStoreShipperResponses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PackStationDetailGroupByBoxes {
  String? boxId;
  String? boxCode;
  bool? isInBox;
  List<ListProduct>? listProduct;

  PackStationDetailGroupByBoxes(
      {this.boxId, this.boxCode, this.isInBox, this.listProduct});

  PackStationDetailGroupByBoxes.fromJson(Map<String, dynamic> json) {
    boxId = json['boxId'];
    boxCode = json['boxCode'];
    isInBox = json['isInBox'];
    if (json['listProduct'] != null) {
      listProduct = <ListProduct>[];
      json['listProduct'].forEach((v) {
        listProduct!.add(ListProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['boxId'] = boxId;
    data['boxCode'] = boxCode;
    data['isInBox'] = isInBox;
    if (listProduct != null) {
      data['listProduct'] = listProduct!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BoxProducts {
  String? boxId;
  String? boxCode;
  bool? isChecked;
  int? currentMissing;

  BoxProducts({this.boxId, this.boxCode, this.currentMissing});

  BoxProducts.fromJson(Map<String, dynamic> json) {
    boxId = json['boxId'];
    boxCode = json['boxCode'];
    isChecked = false;
    currentMissing = 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['boxId'] = boxId;
    data['boxCode'] = boxCode;
    return data;
  }
}

class PackageStoreShipperResponses {
  String? storeId;
  String? storeName;
  int? totalQuantity;
  bool? isTaken;
  bool? isInBox;
  List<PackStationDetailGroupByProducts>? packStationDetailGroupByProducts;
  List<String>? listOrderId;

  PackageStoreShipperResponses(
      {this.storeId,
      this.storeName,
      this.totalQuantity,
      this.isTaken,
      this.isInBox,
      this.packStationDetailGroupByProducts,
      this.listOrderId});

  PackageStoreShipperResponses.fromJson(Map<String, dynamic> json) {
    storeId = json['storeId'];
    storeName = json['storeName'];
    totalQuantity = json['totalQuantity'];
    isTaken = json['isTaken'];
    isInBox = json['isInBox'];
    if (json['packStationDetailGroupByProducts'] != null) {
      packStationDetailGroupByProducts = <PackStationDetailGroupByProducts>[];
      json['packStationDetailGroupByProducts'].forEach((v) {
        packStationDetailGroupByProducts!
            .add(PackStationDetailGroupByProducts.fromJson(v));
      });
    }
    listOrderId = json['listOrderId'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['storeId'] = storeId;
    data['storeName'] = storeName;
    data['totalQuantity'] = totalQuantity;
    data['isTaken'] = isTaken;
    data['isInBox'] = isInBox;
    if (packStationDetailGroupByProducts != null) {
      data['packStationDetailGroupByProducts'] =
          packStationDetailGroupByProducts!.map((v) => v.toJson()).toList();
    }
    data['listOrderId'] = listOrderId;
    return data;
  }
}

class PackStationDetailGroupByProducts {
  String? productId;
  String? productName;
  int? totalQuantity;
  int? errorQuantity;
  String? storeId;

  PackStationDetailGroupByProducts(
      {this.productId,
      this.productName,
      this.totalQuantity,
      this.errorQuantity,
      this.storeId});

  PackStationDetailGroupByProducts.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    productName = json['productName'];
    totalQuantity = json['totalQuantity'];
    errorQuantity = json['errorQuantity'];
    storeId = '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = productId;
    data['productName'] = productName;
    data['totalQuantity'] = totalQuantity;

    return data;
  }
}

class ProductBoxesDTO {
  String? boxId;
  String? boxCode;
  bool? isChecked;
  int? currentMissing;
  List<ListProduct>? listProduct;

  ProductBoxesDTO({this.boxId, this.boxCode, this.listProduct});

  ProductBoxesDTO.fromJson(Map<String, dynamic> json) {
    boxId = json['boxId'];
    boxCode = json['boxCode'];
    isChecked = false;
    currentMissing = 1;
    if (json['listProduct'] != null) {
      listProduct = <ListProduct>[];
      json['listProduct'].forEach((v) {
        listProduct!.add(ListProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['boxId'] = boxId;
    data['boxCode'] = boxCode;
    if (listProduct != null) {
      data['listProduct'] = listProduct!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListProduct {
  String? productId;
  String? productName;
  int? quantity;
  List<BoxProducts>? boxProducts;

  ListProduct(
      {this.productId, this.productName, this.quantity, this.boxProducts});

  ListProduct.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    productName = json['productName'];
    quantity = json['quantity'];
    if (json['boxProducts'] != null) {
      boxProducts = <BoxProducts>[];
      json['boxProducts'].forEach((v) {
        boxProducts!.add(BoxProducts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = productId;
    data['productName'] = productName;
    data['quantity'] = quantity;
    if (boxProducts != null) {
      data['boxProducts'] = boxProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
