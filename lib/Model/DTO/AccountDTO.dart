// ignore: file_names
class AccountDTO {
  String? id;
  String? name;
  String? username;
  int? roleType;
  String? storeId;
  String? stationId;
  bool? isActive;
  DateTime? createAt;
  DateTime? updateAt;

  AccountDTO(
      {this.id,
      this.name,
      this.username,
      this.roleType,
      this.storeId,
      this.isActive,
      // this.universityId,
      // this.uniInfoId,
      this.stationId,
      this.createAt,
      this.updateAt});

  AccountDTO.fromJson(Map<String, dynamic> json) {
    id = json["id"] as String;
    name = json["name"];
    username = json["username"];
    roleType = json["roleType"];
    storeId = json["storeId"] ?? null;
    stationId = json["stationId"];
    isActive = json["isActive"];
    createAt =
        json['createAt'] != null ? DateTime.parse(json['createAt']) : null;
    updateAt =
        json['updateAt'] != null ? DateTime.parse(json['updateAt']) : null;
  }

  static List<AccountDTO> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => AccountDTO.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["username"] = username;
    _data["roleType"] = roleType;
    _data["storeId"] = storeId;
    _data["stationId"] = stationId;
    _data["isActive"] = isActive;
    _data["createAt"] = createAt;
    _data["updateAt"] = updateAt;
    return _data;
  }
}
