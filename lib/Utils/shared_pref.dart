import 'dart:convert';

import 'package:fine_merchant_mobile/Model/DTO/index.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> setIsFirstOnboard(bool isFirstOnboard) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setBool('isFirstOnBoard', isFirstOnboard);
}

Future<bool?> getIsFirstOnboard() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isFirstOnBoard');
}

Future<void> setStore(DestinationDTO dto) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (dto != null) {
    print(dto.toJson().toString());
    prefs.setString('STORE', jsonEncode(dto.toJson()));
  }
}

Future<DestinationDTO?> getStore() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? encodedCart = prefs.getString('STORE');
  if (encodedCart != null) {
    return DestinationDTO.fromJson(jsonDecode(encodedCart));
  }
  return null;
}

// Future<void> setCart(Cart cart) async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.setString('CART', jsonEncode(cart.toJson()));
// }

// Future<void> setMart(Cart cart) async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.setString('MART', jsonEncode(cart.toJson()));
// }

// Future<bool> setPartyCode(String code) async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.setString('PARTY_CODE', code);
// }

// Future<Cart?> getCart() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? encodedCart = prefs.getString('CART');
//   if (encodedCart != null) {
//     Cart cart = Cart.fromJson(jsonDecode(encodedCart));
//     return cart;
//   }
//   return null;
// }

// Future<Cart?> getMart() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? encodedCart = prefs.getString('MART');
//   if (encodedCart != null) {
//     Cart cart = Cart.fromJson(jsonDecode(encodedCart));
//     return cart;
//   }
//   return null;
// }

// Future<String?> getPartyCode() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.getString('PARTY_CODE');
// }

// Future<void> addItemToCart(CartItem item, String timeSlotId) async {
//   Cart? cart = await getCart();
//   if (cart == null) {
//     cart = new Cart(timeSlotId: timeSlotId);
//   }
//   cart.addItem(item);
//   await setCart(cart);
// }

// Future<void> addItemToMart(CartItem item, String timeSlotId) async {
//   Cart? cart = await getMart();
//   if (cart == null) {
//     cart = new Cart(timeSlotId: timeSlotId);
//   }
//   cart.addItem(item);
//   await setMart(cart);
// }

// Future<bool> removeItemFromCart(CartItem item) async {
//   Cart? cart = await getCart();
//   if (cart == null) {
//     return false;
//   }
//   cart.removeItem(item);
//   print("Delete success!");
//   print("Items: ${cart.orderDetails?.length.toString()}");
//   if (cart.orderDetails?.length == 0) {
//     await deleteCart();
//     return true;
//   } else {
//     await setCart(cart);
//     return false;
//   }
// }

// Future<bool> removeItemFromMart(CartItem item) async {
//   Cart? cart = await getMart();
//   if (cart == null) {
//     return false;
//   }
//   cart.removeItem(item);

//   if (cart.orderDetails?.length == 0) {
//     await deleteMart();
//     return true;
//   } else {
//     await setMart(cart);
//     return false;
//   }
// }

Future<void> deleteCart() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove("CART");
}

Future<void> deleteMart() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("MART");
}

Future<void> deletePartyCode() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("PARTY_CODE");
}

// Future<void> updateItemFromCart(CartItem item) async {
//   Cart? cart = await getCart();
//   if (cart == null) {
//     return;
//   }
//   cart.updateQuantity(item);
//   await setCart(cart);
//   print("Save");
// }

// Future<void> updateItemFromMart(CartItem item) async {
//   Cart? cart = await getMart();
//   if (cart == null) {
//     return;
//   }
//   cart.updateQuantity(item);
//   print(
//       "Updated Quantity: ${cart.orderDetails?.firstWhere((element) => element.findCartItem(item)).quantity}");
//   await setMart(cart);
// }

Future<bool> setFCMToken(String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString('FCMToken', value);
}

Future<String?> getFCMToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('FCMToken');
}

Future<bool> setToken(String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String expireDate = DateFormat("yyyy-MM-dd hh:mm:ss")
      .format(DateTime.now().add(Duration(days: 30)));
  prefs.setString('expireDate', expireDate.toString());
  return prefs.setString('token', value);
}

Future<bool> expireToken() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime tempDate = new DateFormat("yyyy-MM-dd hh:mm:ss")
        .parse(prefs.getString('expireDate')!);
    return tempDate.compareTo(DateTime.now()) < 0;
  } catch (e) {
    return true;
  }
}

Future<String?> getToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<void> removeALL() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  // Get.reset(clearRouteBindings: true);
  // createRouteBindings();
  await setIsFirstOnboard(false);
}
// Future<bool> setUser(A value) async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.setString('token', value);
// }

// Future<String> getToken() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.getString('token');
// }
