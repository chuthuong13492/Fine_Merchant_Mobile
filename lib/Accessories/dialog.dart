import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showStatusDialog(
    String imageUrl, String status, String content) async {
  bool shouldPop = false;
  hideDialog();
  await Get.dialog(WillPopScope(
    onWillPop: () async {
      return shouldPop;
    },
    child: Dialog(
      backgroundColor: Colors.white,
      elevation: 8.0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 8,
            ),
            Image(
              image: AssetImage(imageUrl),
              width: 96,
              height: 96,
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Text(
                status ?? "",
                style: FineTheme.typograhpy.h2,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                content,
                style: FineTheme.typograhpy.subtitle2,
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FineTheme.palettes.primary100,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16))),
                ),
                // color: FineTheme.palettes.primary300,
                // shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.only(
                //         bottomRight: Radius.circular(16),
                //         bottomLeft: Radius.circular(16))),
                onPressed: () {
                  hideDialog();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(
                    "Đóng",
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ));
}

void showLoadingDialog() {
  bool shouldPop = false;
  hideDialog();
  Get.defaultDialog(
    barrierDismissible: true,
    title: "Đang xử lý...",
    content: WillPopScope(
      onWillPop: () async {
        return shouldPop;
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Image(
              width: 120,
              height: 120,
              image: AssetImage("assets/images/loading_fine.gif"),
            ),
          ],
        ),
      ),
    ),
    titleStyle: FineTheme.typograhpy.h2,
  );
}

Future<bool> showErrorDialog(
    {String errorTitle = "Có một chút trục trặc nhỏ!!"}) async {
  hideDialog();
  bool result = false;
  await Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 8.0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Align(
            //   alignment: Alignment.topRight,
            //   child: IconButton(
            //     icon: const Icon(
            //       AntDesign.closecircleo,
            //       color: Colors.red,
            //     ),
            //     onPressed: () {
            //       hideDialog();
            //     },
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Text(
                errorTitle,
                textAlign: TextAlign.center,
                style: FineTheme.typograhpy.body1,
              ),
            ),
            const Image(
              width: 64,
              height: 64,
              image: AssetImage("assets/images/error.png"),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FineTheme.palettes.primary100,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16))),
                ),
                onPressed: () {
                  result = true;
                  hideDialog();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(
                    "Thử lại",
                    style: FineTheme.typograhpy.subtitle2
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true);
  return result;
}

Future<int> showOptionDialog(String text,
    {String? firstOption, String? secondOption}) async {
  // hideDialog();
  int? option;
  bool shouldPop = false;
  await Get.dialog(
    WillPopScope(
      onWillPop: () async {
        return shouldPop;
      },
      child: Dialog(
        backgroundColor: Colors.white,
        elevation: 8.0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Align(
                //   alignment: Alignment.topLeft,
                //   child: IconButton(
                //     icon: const Icon(
                //       AntDesign.closecircleo,
                //       color: Colors.red,
                //     ),
                //     onPressed: () {
                //       option = 0;
                //       hideDialog();
                //     },
                //   ),
                // ),
                const SizedBox(
                  height: 54,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    text,
                    style: FineTheme.typograhpy.body2
                        .copyWith(color: FineTheme.palettes.neutral600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border(
                    top: BorderSide(
                      color: FineTheme.palettes.neutral500,
                    ),
                  )),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          // color: Colors.grey,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              // bottomRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            )),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 16.0, bottom: 16.0),
                            child: Center(
                              child: Text(
                                firstOption ?? "Hủy",
                                style: FineTheme.typograhpy.body2.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            option = 0;
                            hideDialog();
                          },
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          // color: kPrimary,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FineTheme.palettes.primary200,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(16),
                                // bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 16.0, bottom: 16.0),
                            child: Center(
                              child: Text(
                                secondOption ?? "Đồng ý",
                                style: FineTheme.typograhpy.body2.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            option = 1;
                            hideDialog();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Positioned(
              top: -50,
              right: 75,
              child: Image(
                image: AssetImage("assets/images/logo.png"),
                width: 130,
                height: 130,
              ),
            )
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
  return option!;
}

// Future<int> showPartyDialog(String? partyCode) async {
//   PartyOrderViewModel model = Get.find<PartyOrderViewModel>();
//   TextEditingController controller = TextEditingController(text: '');
//   bool isErrorInput = false;
//   // hideDialog();
//   int? option;
//   bool shouldPop = false;

//   await Get.dialog(
//     WillPopScope(
//       onWillPop: () async {
//         return shouldPop;
//       },
//       child: Dialog(
//         backgroundColor: Colors.white,
//         elevation: 8.0,
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(16.0))),
//         child: SizedBox(
//           height: Get.height * 0.50,
//           child: Column(
//             children: [
//               Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   Expanded(
//                     child: Container(
//                       height: Get.height * 0.12,
//                       decoration: const BoxDecoration(
//                           image: DecorationImage(
//                               image: AssetImage('assets/images/party_img.png'),
//                               fit: BoxFit.fill),
//                           borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(16.0),
//                               topRight: Radius.circular(16.0))),
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: IconButton(
//                       icon: const Icon(
//                         AntDesign.closecircleo,
//                         color: Colors.white,
//                         size: 24,
//                       ),
//                       onPressed: () {
//                         option = 0;
//                         hideDialog();
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 height: Get.height * 0.35,
//                 padding: const EdgeInsets.fromLTRB(16, 20, 16, 27),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Mời tham gia đơn nhóm',
//                       style: TextStyle(
//                         fontFamily: 'Montserrat',
//                         fontWeight: FontWeight.w700,
//                         fontSize: 24,
//                         fontStyle: FontStyle.normal,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       width: Get.width,
//                       padding: const EdgeInsets.only(left: 16, right: 16),
//                       child: Text(
//                         'Chia sẻ link tham gia đơn nhóm đến người bạn muốn mời nhé',
//                         style: TextStyle(
//                           fontFamily: 'Montserrat',
//                           fontWeight: FontWeight.w400,
//                           fontSize: 16,
//                           fontStyle: FontStyle.normal,
//                           color: FineTheme.palettes.neutral500,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             'Đơn liên kết',
//                             style: FineTheme.typograhpy.subtitle1,
//                           ),
//                         ),
//                         CustomCupertinoSwitch(
//                           value: model.isLinked!,
//                           onChanged: (value) {
//                             model.isLinkedParty(value);
//                           },
//                         )
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Expanded(
//                         child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Flexible(
//                               flex: 7,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     borderRadius: const BorderRadius.all(
//                                         Radius.circular(8)),
//                                     border: Border.all(
//                                         color: FineTheme.palettes.primary100)),
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.fromLTRB(8, 0, 0, 0),
//                                   child: TextField(
//                                     onChanged: (input) {},
//                                     controller: controller,
//                                     decoration: InputDecoration(
//                                         hintText: 'Nhập code party',
//                                         border: InputBorder.none,
//                                         suffixIcon: IconButton(
//                                           icon: const Icon(
//                                             Icons.clear,
//                                             size: 16,
//                                             color: Colors.grey,
//                                           ),
//                                           onPressed: () {
//                                             controller.clear();
//                                           },
//                                         )),
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 16,
//                                       fontStyle: FontStyle.normal,
//                                       color: FineTheme.palettes.neutral500,
//                                     ),
//                                     keyboardType: TextInputType.multiline,
//                                     maxLines: 1,
//                                     autofocus: true,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Flexible(
//                               flex: 3,
//                               fit: FlexFit.tight,
//                               child: Padding(
//                                 padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                       borderRadius: const BorderRadius.all(
//                                           Radius.circular(8)),
//                                       color: FineTheme.palettes.primary100,
//                                       border: Border.all(
//                                         color: FineTheme.palettes.primary100,
//                                       )),
//                                   child: TextButton(
//                                       onPressed: () async {
//                                         PartyOrderViewModel party =
//                                             Get.find<PartyOrderViewModel>();
//                                         option = 1;
//                                         await party.joinPartyOrder(
//                                             code: controller.text);
//                                       },
//                                       child: const Text('Tham gia',
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 15))),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         InkWell(
//                           onTap: () async {
//                             model.partyCode = await getPartyCode();
//                             if (model.partyCode == null) {
//                               await model.coOrder();
//                               if (model.partyOrderDTO!.partyOrder != null) {
//                                 option = 1;
//                                 hideDialog();
//                                 Get.offNamed(RouteHandler.PARTY_ORDER_SCREEN);
//                               } else {
//                                 option = 1;
//                                 hideDialog();
//                               }
//                             } else {
//                               if (model.partyOrderDTO!.partyOrder != null) {
//                                 await model.getPartyOrder();
//                                 option = 1;
//                                 hideDialog();
//                                 Get.offNamed(RouteHandler.PARTY_ORDER_SCREEN);
//                               } else {
//                                 option = 1;
//                                 hideDialog();
//                               }
//                             }
//                           },
//                           child: Container(
//                             height: 55,
//                             width: Get.width,
//                             decoration: BoxDecoration(
//                               color: FineTheme.palettes.primary100,
//                               borderRadius: const BorderRadius.all(
//                                 Radius.circular(5),
//                               ),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 partyCode ?? "Tạo phòng Party",
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontFamily: 'Montserrat',
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 16,
//                                   fontStyle: FontStyle.normal,
//                                   color: FineTheme.palettes.shades100,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     )),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//     barrierDismissible: true,
//   );
//   return option!;
// }

void hideDialog() {
  if (Get.isDialogOpen!) {
    Get.back();
  }
}
