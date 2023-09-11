// ignore_for_file: file_names

class BoxDTO {
  String? id;
  String? stationId;
  String? code;
  bool? isActive;
  bool? isHeat;
  String? createAt;
  String? updateAt;

  BoxDTO(
      {this.id,
      this.stationId,
      this.code,
      this.isActive,
      this.isHeat,
      this.createAt,
      this.updateAt});

  BoxDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    stationId = json['stationId'];
    code = json['code'];
    isActive = json['isActive'];
    isHeat = json['isHeat'];
    createAt = json['createAt'];
    updateAt = json['updateAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['stationId'] = stationId;
    data['code'] = code;
    data['isActive'] = isActive;
    data['isHeat'] = isHeat;
    data['createAt'] = createAt;
    data['updateAt'] = updateAt;
    return data;
  }
}
