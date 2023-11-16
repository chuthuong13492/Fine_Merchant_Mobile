import 'package:fine_merchant_mobile/Model/DTO/DeliveryPackageDTO.dart';

class ProductBoxViewModelDTO {
  PackStationDetailGroupByProducts? product;
  List<ProductBoxesDTO>? productBoxes;

  ProductBoxViewModelDTO({this.product, this.productBoxes});
}
