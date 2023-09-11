class StationDTO {
  String? id;
  String? name;
  String? code;
  String? areaCode;
  String? floorId;
  bool? isActive;
  String? createAt;
  String? updateAt;

  StationDTO(
      {this.id,
      this.name,
      this.code,
      this.areaCode,
      this.floorId,
      this.isActive,
      this.createAt,
      this.updateAt});

  StationDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    areaCode = json['areaCode'];
    floorId = json['floorId'];
    isActive = json['isActive'];
    createAt = json['createAt'];
    updateAt = json['updateAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['areaCode'] = areaCode;
    data['floorId'] = floorId;
    data['isActive'] = isActive;
    data['createAt'] = createAt;
    data['updateAt'] = updateAt;
    return data;
  }
}
