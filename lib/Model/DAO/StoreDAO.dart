// ignore_for_file: file_names
import 'package:fine_merchant_mobile/Model/DAO/BaseDAO.dart';
import 'package:fine_merchant_mobile/Model/DTO/MetaDataDTO.dart';
import 'package:fine_merchant_mobile/Model/DTO/StoreDTO.dart';
import 'package:fine_merchant_mobile/Utils/request.dart';

class StoreDAO extends BaseDAO {
  Future<List<StoreDTO>?> getStores() async {
    final res = await request.get(
      '/admin/store',
      queryParameters: {
        // "order-status":
        //     filter == OrderFilter.NEW ? ORDER_NEW_STATUS : ORDER_DONE_STATUS,
        // "size": size ?? DEFAULT_SIZE,
        // "page": page ?? 1,
      },
    );
    if (res.data['data'] != null) {
      var listJson = res.data['data'] as List;
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      // orderSummaryList = OrderDTO.fromList(res.data['data']);
      return listJson.map((e) => StoreDTO.fromJson(e)).toList();
    }
    return null;
  }

  Future<StoreDTO?> getStoreById({String? storeId}) async {
    final res = await request.get(
      '/admin/store/${storeId}',
      queryParameters: {
        // "order-status":
        //     filter == OrderFilter.NEW ? ORDER_NEW_STATUS : ORDER_DONE_STATUS,
        // "size": size ?? DEFAULT_SIZE,
        // "page": page ?? 1,
      },
    );
    if (res.data['data'] != null) {
      var json = res.data['data'];
      return StoreDTO.fromJson(json);
    }
    return null;
  }
}
