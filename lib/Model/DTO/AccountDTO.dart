class AccountDTO {
  String? id;
  String? name;
  String? customerCode;
  String? email;
  String? phone;
  DateTime? dateOfBirth;
  String? imageUrl;
  // int? universityId;
  // int? uniInfoId;
  DateTime? createAt;
  DateTime? updateAt;

  AccountDTO(
      {this.id,
      this.name,
      this.customerCode,
      this.email,
      this.phone,
      this.dateOfBirth,
      this.imageUrl,
      // this.universityId,
      // this.uniInfoId,
      this.createAt,
      this.updateAt});

  AccountDTO.fromJson(Map<String, dynamic> json) {
    id = json["id"] as String;
    name = json["name"];
    customerCode = json["customerCode"];
    email = json["email"];
    phone = json["phone"] ?? null;
    dateOfBirth = json['dateOfBirth'] as String != null
        ? DateTime.parse(json['dateOfBirth'] as String)
        : null;
    imageUrl = json["imageUrl"];
    // universityId = json["universityId"];
    // uniInfoId = json["uniInfoId"];
    createAt = json['createAt'] as String != null
        ? DateTime.parse(json['createAt'] as String)
        : null;
    updateAt = json['updateAt'] as String != null
        ? DateTime.parse(json['updateAt'] as String)
        : null;
  }

  static List<AccountDTO> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => AccountDTO.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["customerCode"] = customerCode;
    _data["email"] = email;
    _data["phone"] = phone;
    _data["dateOfBirth"] = dateOfBirth;
    _data["imageUrl"] = imageUrl;
    // _data["universityId"] = universityId;
    // _data["uniInfoId"] = uniInfoId;
    _data["createAt"] = createAt;
    _data["updateAt"] = updateAt;
    return _data;
  }
}
