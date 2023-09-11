// ignore_for_file: file_names
import 'package:fine_merchant_mobile/Model/DAO/BaseDAO.dart';
import 'package:fine_merchant_mobile/Model/DTO/MetaDataDTO.dart';
import 'package:fine_merchant_mobile/Model/DTO/TimeSlotDTO.dart';
import 'package:fine_merchant_mobile/Utils/request.dart';

class TimeSlotDAO extends BaseDAO {
  Future<List<TimeSlotDTO>?> getTimeSlots(
      {required String destinationId}) async {
    final res = await request.get(
      '/admin/timeslot/destination/$destinationId',
      queryParameters: {
        // "order-status":
        //     filter == OrderFilter.NEW ? ORDER_NEW_STATUS : ORDER_DONE_STATUS,
        "PageSize": 20,
        // "page": DateTime.now().hour < 18 ? 1 : 2,
      },
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => TimeSlotDTO.fromJson(e)).toList();
    }
    return null;
  }
}
