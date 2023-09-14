class PackageViewDTO {
  String? timeSlotId;
  String? stationId;
  String? storeId;
  List<ListProduct>? listProducts;

  PackageViewDTO(
      {this.listProducts, this.timeSlotId, this.stationId, this.storeId});

  PackageViewDTO.fromJson(Map<String, dynamic> json) {
    storeId = json['storeId'];
    timeSlotId = json['timeSlotId'];
    stationId = json['stationId'];
    listProducts = json['listProducts'];
    if (json['ListProduct'] != null) {
      listProducts = <ListProduct>[];
      json['ListProduct'].forEach((v) {
        listProducts?.add(ListProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['listProducts'] = listProducts;
    if (ListProduct != null) {
      data['ListProduct'] = listProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListProduct {
  String? productName;
  int? quantity;

  ListProduct({this.productName, this.quantity});

  ListProduct.fromJson(Map<String, dynamic> json) {
    productName = json['productName'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productName'] = productName;
    data['quantity'] = quantity;
    return data;
  }
}
