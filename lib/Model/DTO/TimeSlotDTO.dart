class TimeSlotDTO {
  String? id;
  String? destinationId;
  String? closeTime;
  String? arriveTime;
  String? checkoutTime;
  bool? isActive;
  String? createAt;
  String? updateAt;

  TimeSlotDTO(
      {this.id,
      this.destinationId,
      this.closeTime,
      this.arriveTime,
      this.checkoutTime,
      this.isActive,
      this.createAt,
      this.updateAt});

  TimeSlotDTO.fromJson(Map<String, dynamic> json) {
    id = json["id"] as String;
    destinationId = json["destinationId"] ?? json["destination_id"];
    closeTime = json["closeTime"] ?? json["close_time"];
    arriveTime = json["arriveTime"] ?? json["arrive_time"];
    checkoutTime = json["checkoutTime"] ?? json["checkout_time"];
    isActive = json["isActive"] ?? json["is_active"];
    createAt = json["createAt"] ?? json["create_at"];
    updateAt = json["updateAt"] ?? json["update_at"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["destinationId"] = destinationId;
    _data["closeTime"] = closeTime;
    _data["arriveTime"] = arriveTime;
    _data["checkoutTime"] = checkoutTime;
    _data["isActive"] = isActive;
    _data["createAt"] = createAt;
    _data["updateAt"] = updateAt;
    return _data;
  }
}
