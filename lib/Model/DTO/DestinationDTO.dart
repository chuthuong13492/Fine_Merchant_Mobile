import 'index.dart';

// class CampusDTO extends StoreDTO {
//   List<LocationDTO>? locations;
//   // List<TimeSlot> timeSlots;
//   // TimeSlot selectedTimeSlot;

//   CampusDTO({
//     int? id,
//     String? name,
//     bool? available,
//     this.locations,
//   }) : super(name: name, id: id, available: available);

//   factory CampusDTO.fromJson(dynamic json) {
//     CampusDTO campusDTO = CampusDTO(
//         id: json['id'], name: json['name'], available: json['is_available']);

//     if (json['locations'] != null) {
//       var list = json['locations'] as List;
//       campusDTO.locations = list.map((e) => LocationDTO.fromJson(e)).toList();
//     }

//     // if (json['time_slots'] != null) {
//     //   var list = json['time_slots'] as List;
//     //   campusDTO.timeSlots = list.map((e) {
//     //     return TimeSlot.fromJson(e);
//     //   }).toList();
//     // }

//     // if (json['selected_time_slot'] != null) {
//     //   campusDTO.selectedTimeSlot =
//     //       TimeSlot.fromJson(json['selected_time_slot']);
//     // }

//     return campusDTO;
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     // TODO: implement toJson
//     return {
//       "id": id,
//       "name": name,
//       "locations": locations?.map((e) => e.toJson()).toList(),
//       "is_available": available,
//       // "time_slots": timeSlots.map((e) => e.toJson()).toList(),
//       // "selected_time_slot": selectedTimeSlot?.toJson()
//     };
//   }
// }
class DestinationDTO {
  String? id;
  // int? universityId;
  String? name;
  // String? address;
  String? code;
  bool? isActive;
  DateTime? createAt;
  DateTime? updateAt;
  // String? emailRoot;

  DestinationDTO({
    this.id,
    // this.universityId,
    this.name,
    // this.address,
    this.code,
    this.isActive,
    this.createAt,
    this.updateAt,
    // this.emailRoot,
  });

  factory DestinationDTO.fromJson(Map<String, dynamic> json) {
    return DestinationDTO(
      id: json['id'] as String,
      // universityId: json['universityId'],
      name: json['name'],
      // address: json['address'],
      code: json['code'],
      isActive: json['isActive'],
      createAt: json['createAt'] != null
          ? DateTime.parse(json['createAt'] as String)
          : null,
      updateAt: json['updateAt'] != null
          ? DateTime.parse(json['updateAt'] as String)
          : null,
      // emailRoot: json['emailRoot'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        // 'universityId': universityId,
        'name': name,
        // 'address': address,
        'code': code,
        'isActive': isActive,
        // 'createAt': createAt,
        // 'updateAt': updateAt,
        // 'emailRoot': emailRoot,
      };
}

// class LocationDTO {
//   int? id;
//   String? address;
//   String? lat;
//   String? long;
//   bool? isSelected;
//   List<DestinationDTO>? destinations;

//   LocationDTO(
//       {this.id,
//       this.address,
//       this.lat,
//       this.long,
//       this.isSelected,
//       this.destinations});

//   factory LocationDTO.fromJson(dynamic json) {
//     return LocationDTO(
//         id: json['location_id'] ?? json['destination_id'],
//         address: json['address'],
//         lat: json['lat'],
//         long: json['long'],
//         isSelected: json['isSelected'] ?? false,
//         destinations: (json['locations'] as List)
//             .map((e) => DestinationDTO.fromJson(e))
//             .toList());
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "location_id": id,
//       "address": address,
//       "lat": lat,
//       "long": long,
//       "isSelected": isSelected,
//       "locations": destinations?.map((e) => e.toJson()).toList()
//     };
//   }
// }

// class DestinationDTO {
//   int? id;
//   String? name;
//   String? description;
//   bool? isSelected;

//   DestinationDTO({this.id, this.name, this.description, this.isSelected});

//   factory DestinationDTO.fromJson(dynamic json) {
//     return DestinationDTO(
//         id: json['destination_location_id'],
//         name: json['name'],
//         description: json['description'],
//         isSelected: json['isSelected'] ?? false);
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "destination_location_id": id,
//       "name": name,
//       "description": description,
//       "isSelected": isSelected
//     };
//   }
// }


