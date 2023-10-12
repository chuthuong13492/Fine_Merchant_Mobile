class OrderStatusEnum {
  static const int PROCESSING = 4;
  static const int STAFF_CONFIRM = 5;
  static const int PREPARED = 6;
  static const int SHIPPER_ASSIGNED = 7;
  static const int DELIVERING = 9;
  static const int BOX_STORED = 10;
  static const int FINISHED = 11;

  static Map<int, String> options = {
    OrderStatusEnum.PROCESSING: "Đang xử lý",
    OrderStatusEnum.STAFF_CONFIRM: "Đã xác nhận",
    OrderStatusEnum.PREPARED: "Đã chuẩn bị",
    OrderStatusEnum.SHIPPER_ASSIGNED: "Shipper đã nhận",
    OrderStatusEnum.DELIVERING: "Đang giao",
    OrderStatusEnum.BOX_STORED: "Đã vào Box",
    OrderStatusEnum.FINISHED: "Đã hoàn thành"
  };

  static String getOrderStatusName(int? type) {
    return options[type] ?? "N/A";
  }
}

class AccountTypeEnum {
  static const int STAFF = 2;
  static const int DRIVER = 3;

  static Map<int, String> options = {
    AccountTypeEnum.STAFF: "Nhân viên cửa hàng",
    AccountTypeEnum.DRIVER: "Nhân viên giao hàng",
  };

  static String getAccountTypeName(int? type) {
    return options[type] ?? "N/A";
  }
}

class UpdateSplitProductTypeEnum {
  static const int CONFIRM = 1;
  static const int ERROR = 2;
  static const int RECONFIRM = 3;

  static Map<int, String> options = {
    UpdateSplitProductTypeEnum.CONFIRM: "Xử lý",
    UpdateSplitProductTypeEnum.ERROR: "Cần xử lý lại",
    UpdateSplitProductTypeEnum.RECONFIRM: "Xử lý lại",
  };

  static String getAccountTypeName(int? type) {
    return options[type] ?? "N/A";
  }
}
