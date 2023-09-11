// ignore: file_names
class StoreDTO {
  String? id;
  String? destinationId;
  String? storeName;
  String? imageUrl;
  String? contactPerson;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  StoreDTO(
      {this.id,
      this.destinationId,
      this.storeName,
      this.imageUrl,
      this.contactPerson,
      this.isActive,
      this.createdAt,
      this.updatedAt});

  StoreDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    destinationId = json['destinationId'];
    storeName = json['storeName'];
    imageUrl = json['imageUrl'];
    contactPerson = json['contactPerson'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['destinationId'] = destinationId;
    data['storeName'] = storeName;
    data['imageUrl'] = imageUrl;
    data['contactPerson'] = contactPerson;
    data['isActive'] = isActive;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
