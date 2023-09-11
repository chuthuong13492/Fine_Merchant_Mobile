import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class FixedAppBar extends StatefulWidget {
  final double height;

  const FixedAppBar({super.key, required this.height});

  @override
  State<FixedAppBar> createState() => _FixedAppBarState();
}

class _FixedAppBarState extends State<FixedAppBar> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // deletePartyCode();
    // _orderViewModel!.getCurrentCart();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      // color: FineTheme.palettes.shades100,
      width: Get.width,
      duration: const Duration(milliseconds: 300),
      // decoration: const BoxDecoration(
      //   boxShadow: [
      //                     BoxShadow(
      //         color: Colors.grey,
      //         spreadRadius: 3,
      //         // blurRadius: 6,
      //         offset: Offset(0, 25) // changes position of shadow
      //         ),
      //   ],
      //   // color: FineTheme.palettes.primary100,
      // ),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(left: 17, right: 17, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 24,
            ),
            // search(),
          ],
        ),
      ),
    );
  }

  // Widget search() {
  //   bool hasQuantity = false;
  //   int quantity = 0;
  //   return ScopedModel(
  //     model: Get.find<OrderViewModel>(),
  //     child: ScopedModelDescendant<OrderViewModel>(
  //       builder: (context, child, model) {
  //         // PartyOrderViewModel party = Get.find<PartyOrderViewModel>();
  //         // if (party.partyOrderDTO != null) {
  //         //   quantity = party.currentCart!.itemQuantity();
  //         // } else {
  //         //   if (model.currentCart == null) {
  //         //     quantity;
  //         //   } else {
  //         //     quantity = model.currentCart!.itemQuantity();
  //         //   }
  //         // }
  //         if (model.currentCart != null) {
  //           quantity = model.currentCart!.itemQuantity();
  //         }

  //         if (model.currentCart != null) {
  //           hasQuantity = true;
  //         }
  //         if (model.notifier.value == 0) {
  //           hasQuantity = false;
  //         }
  //         // if (party.currentCart != null) {
  //         //   hasQuantity = true;
  //         // }
  //         // int quantiy = model.currentCart!.itemQuantity();
  //         return Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Expanded(
  //               child: Container(
  //                 padding: const EdgeInsets.only(left: 11, right: 11),
  //                 // color: Colors.transparent,
  //                 alignment: Alignment.center,
  //                 height: 54,
  //                 decoration: BoxDecoration(
  //                   color: FineTheme.palettes.shades100,
  //                   borderRadius: BorderRadius.circular(25),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: FineTheme.palettes.shades200.withOpacity(0.1),
  //                       offset: const Offset(
  //                         4.0,
  //                         4.0,
  //                       ),
  //                       blurRadius: 8.0,
  //                       // spreadRadius: 2.0,
  //                     ), //BoxShadow
  //                   ],
  //                 ),
  //                 child: Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Center(
  //                         child: SvgPicture.asset(
  //                       "assets/icons/Search-home.svg",
  //                       width: 24,
  //                       height: 24,
  //                       color: FineTheme.palettes.primary100,
  //                     )),
  //                     const SizedBox(
  //                       width: 10,
  //                     ),
  //                     Expanded(
  //                       child: Center(
  //                         child: TextFormField(
  //                           controller: searchController,
  //                           keyboardType: TextInputType.text,
  //                           obscureText: false,
  //                           decoration: const InputDecoration(
  //                             // hintText: text,
  //                             border: InputBorder.none,
  //                             contentPadding: EdgeInsets.all(0),
  //                             hintStyle: TextStyle(
  //                               height: 1,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(
  //               width: 25,
  //             ),
  //             ValueListenableBuilder(
  //               valueListenable: model.notifier,
  //               builder: (context, value, child) {
  //                 return InkWell(
  //                   onTap: () async {
  //                     final root = Get.find<RootViewModel>();
  //                     await root.navOrder();
  //                   },
  //                   child: Container(
  //                     width: 54,
  //                     padding: const EdgeInsets.all(7),
  //                     child: Stack(
  //                       clipBehavior: Clip.none,
  //                       children: [
  //                         Container(
  //                           width: 40,
  //                           height: 40,
  //                           decoration: BoxDecoration(
  //                               color: FineTheme.palettes.primary100,
  //                               borderRadius: BorderRadius.circular(50)),
  //                           child: Center(
  //                             child: Image.asset(
  //                               "assets/icons/shopping-bag-02.png",
  //                               height: 24,
  //                               width: 24,
  //                             ),
  //                           ),
  //                         ),
  //                         hasQuantity
  //                             ? Positioned(
  //                                 top: -2,
  //                                 left: 30,
  //                                 child: AnimatedContainer(
  //                                   duration: const Duration(microseconds: 300),
  //                                   width: 18,
  //                                   height: 18,
  //                                   decoration: BoxDecoration(
  //                                     borderRadius: BorderRadius.circular(16),
  //                                     color: Colors.red,
  //                                     //border: Border.all(color: Colors.grey),
  //                                   ),
  //                                   child: Center(
  //                                     child: Text(
  //                                       value.toString(),
  //                                       style: FineTheme.typograhpy.subtitle1
  //                                           .copyWith(color: Colors.white),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               )
  //                             : const SizedBox.shrink(),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               },
  //             )
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }
}
