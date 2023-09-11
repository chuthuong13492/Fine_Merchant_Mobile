import 'package:fine_merchant_mobile/Constant/enum.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../Accessories/dialog.dart';
import '../Accessories/loading.dart';
import '../Constant/view_status.dart';
import '../theme/FineTheme/index.dart';
import '../widgets/cache_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> _refresh() async {
    await Get.find<AccountViewModel>().fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FineTheme.palettes.shades100,
      body: SafeArea(
          child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refresh,
              child: userInfo())),
    );
  }

  Widget userInfo() {
    return ScopedModel(
      model: Get.find<AccountViewModel>(),
      child: ScopedModelDescendant<AccountViewModel>(
        builder: (context, child, model) {
          final status = model.status;
          if (status == ViewStatus.Loading) {
            return const Center(child: LoadingFine());
          } else if (status == ViewStatus.Error || model.currentUser == null) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/error.png',
                          fit: BoxFit.contain,
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Có gì đó sai sai..\n Vui lòng thử lại.",
                          // style: kTextPrimary,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FineTheme.palettes.emerald25,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    // BorderRadius.only(
                                    //     bottomRight: Radius.circular(16),
                                    //     bottomLeft: Radius.circular(16))
                                    BorderRadius.all(Radius.circular(8))),
                          ),
                          onPressed: () async {
                            await model.signOut();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Text(
                              "Đăng xuất",
                              style: FineTheme.typograhpy.subtitle2
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                account(model),
                userAccount(model),
                const SizedBox(
                  height: 4,
                ),
                // systemInfo(model)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget account(AccountViewModel model) {
    return Container(
      //color: Color(0xFFddf1ed),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                    color: FineTheme.palettes.slate600, shape: BoxShape.circle),
                child: const ClipOval(
                  child: Image(
                    width: 120,
                    height: 120,
                    image: AssetImage("assets/images/standing_mascot.png"),
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          model.currentUser?.name ?? '',
                          style: FineTheme.typograhpy.h2
                              .copyWith(color: FineTheme.palettes.emerald25),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: InkWell(
                            onTap: () async {
                              showLoadingDialog();
                              await model.fetchUser(isRefetch: true);
                              hideDialog();
                            },
                            child: Icon(
                              Icons.replay,
                              color: FineTheme.palettes.primary300,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        infoDetail("Vị trí: ", color: Colors.black, list: [
                          TextSpan(
                              text:
                                  "${AccountTypeEnum.getAccountTypeName(model.currentUser!.roleType)}",
                              style: FineTheme.typograhpy.subtitle2.copyWith(
                                  color: FineTheme.palettes.primary300))
                        ]),
                      ],
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     infoDetail("Làm việc với cửa hàng: ",
                    //         color: Colors.black,
                    //         list: [
                    //           TextSpan(
                    //               text: model.currentUser!.storeId ?? "-",
                    //               style: FineTheme.typograhpy.subtitle2
                    //                   .copyWith(
                    //                       color: FineTheme.palettes.primary300))
                    //         ]),
                    //     const SizedBox(
                    //       height: 4,
                    //     ),
                    //   ],
                    // ),

                    // Container(
                    //   width: 120,
                    //   padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    //   decoration: BoxDecoration(
                    //     border: Border.all(color: FineTheme.palettes.primary300),
                    //     color: Color(0xFFeffff4),
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: Row(
                    //     // crossAxisAlignment: CrossAxisAlignment.center,
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Image.asset(
                    //         'assets/images/icon.png',
                    //         width: 20,
                    //         height: 20,
                    //       ),
                    //       SizedBox(
                    //         width: 2,
                    //       ),
                    //       Text(
                    //         'Thành viên',
                    //         style: TextStyle(
                    //             color: Color(0xFF00ab56),
                    //             fontSize: 14,
                    //             fontWeight: FontWeight.bold),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // infoDetail("Số điện thoại: ", color: Colors.grey, list: [
                    //   TextSpan(
                    //       text: model.currentUser!.phone ?? "-",
                    //       style: FineTheme.typograhpy.subtitle2
                    //           .copyWith(color: FineTheme.palettes.primary300))
                    // ]),
                  ],
                ),
              )
            ],
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 24, right: 24, top: 8),
          //   child: Container(
          //     child: Row(
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       mainAxisAlignment: MainAxisAlignment.spaceAround,
          //       children: [
          //         // Column(
          //         //   crossAxisAlignment: CrossAxisAlignment.center,
          //         //   mainAxisAlignment: MainAxisAlignment.center,
          //         //   children: [
          //         //     Row(
          //         //       crossAxisAlignment: CrossAxisAlignment.center,
          //         //       mainAxisAlignment: MainAxisAlignment.center,
          //         //       children: [
          //         //         Image.asset(
          //         //           'assets/images/icons/bean_coin.png',
          //         //           width: 20,
          //         //           height: 20,
          //         //         ),
          //         //         SizedBox(
          //         //           width: 2,
          //         //         ),
          //         //         Text(
          //         //           'Bean của bạn',
          //         //           style: TextStyle(
          //         //               color: Colors.orange,
          //         //               fontSize: 14,
          //         //               fontWeight: FontWeight.bold),
          //         //         ),
          //         //         // RichText(
          //         //         //   text: TextSpan(
          //         //         //       text: 'BEAN: ',
          //         //         //       style: TextStyle(
          //         //         //           color: Colors.orange,
          //         //         //           fontWeight: FontWeight.bold),
          //         //         //       children: [
          //         //         //         TextSpan(
          //         //         //           text: formatPriceWithoutUnit(
          //         //         //               model.currentUser.balance),
          //         //         //         ),
          //         //         //       ]),
          //         //         // ),
          //         //       ],
          //         //     ),
          //         //     Text(
          //         //       formatPriceWithoutUnit(model.currentUser.balance),
          //         //       style: TextStyle(color: Colors.orange),
          //         //     ),
          //         //   ],
          //         // ),
          //         Container(
          //           height: 40,
          //           width: 10,
          //           child: VerticalDivider(
          //             color:
          //                 BeanOiTheme.palettes.neutral400, //color of divider
          //             width: 10, //width space of divider
          //             //Spacing at the bottom of divider.
          //             thickness: 2, //thickness of divier line
          //             indent: 8, //Spacing at the top of divider.
          //             endIndent: 8,
          //           ),
          //         ),
          //         InkWell(
          //           onTap: () {
          //             Get.toNamed(RouteHandler.VOUCHER_WALLET);
          //           },
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               Row(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 children: [
          //                   Image.asset(
          //                     'assets/images/icons/voucher_icon.png',
          //                     width: 20,
          //                     height: 20,
          //                   ),
          //                   SizedBox(
          //                     width: 2,
          //                   ),
          //                   Text(
          //                     'Quà và khuyến mãi',
          //                     style: TextStyle(
          //                         color: BeanOiTheme.palettes.neutral700,
          //                         fontSize: 14,
          //                         fontWeight: FontWeight.bold),
          //                   ),
          //                 ],
          //               ),
          //               Text(
          //                 // '$model.vouchers.length',
          //                 '$vouchers',
          //                 style: TextStyle(color: kPrimary),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget infoDetail(String title,
      {int? size, Color? color, List<InlineSpan>? list}) {
    return RichText(
        text: TextSpan(
            text: title,
            style:
                FineTheme.typograhpy.subtitle2.copyWith(color: Colors.black) ??
                    TextStyle(color: color),
            children: list ?? []));
  }

  Widget userAccount(AccountViewModel model) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            const Divider(),
            // section(
            //     icon: const Icon(Icons.person, color: Colors.black54),
            //     title: Text("Cập nhật thông tin",
            //         style: FineTheme.typograhpy.subtitle2
            //             .copyWith(color: Colors.black54)),
            //     function: () async {
            //       bool result = await Get.toNamed(RouteHandler.UPDATE,
            //           arguments: model.currentUser);
            //       if (result != null) {
            //         if (result) {
            //           await model.fetchUser();
            //         }
            //       }
            //     }),
            // const Divider(),
            // section(
            //     icon: const Icon(Icons.shopping_bag, color: Colors.black54),
            //     title: Text("Đơn hàng",
            //         style: FineTheme.typograhpy.subtitle2
            //             .copyWith(color: Colors.black54)),
            //     function: () {
            //       Get.toNamed(RouteHandler.ORDER_HISTORY);
            //     }),
            // const Divider(),
            // section(
            //     icon: const Icon(Icons.history, color: Colors.black54),
            //     title: Text("Lịch sử giao dịch",
            //         style: FineTheme.typograhpy.subtitle2
            //             .copyWith(color: Colors.black54)),
            //     function: () {
            //       Get.toNamed(RouteHandler.TRANSACTION);
            //     }),
            // const Divider(),
            // section(
            //     icon: const Icon(Icons.credit_card_outlined, color: Colors.black54),
            //     title: Text("Nhập mã giới thiệu",
            //         style: FineTheme.typograhpy.subtitle2
            //             .copyWith(color: Colors.black54)),
            //     function: () async {
            //       await model.showRefferalMessage();
            //     }),
            // const Divider(),
            // section(
            //     icon: const Icon(
            //       AntDesign.facebook_square,
            //       color: Colors.black54,
            //     ),
            //     title: Text("Theo dõi BeanOi",
            //         style: FineTheme.typograhpy.subtitle2
            //             .copyWith(color: Colors.black54)),
            //     function: () {
            //       _launchUrl(
            //           "https://www.facebook.com/Bean-%C6%A0i-103238875095890",
            //           isFB: true);
            //     }),
            // const Divider(),
            // section(
            //     icon: const Icon(Icons.feedback_outlined, color: Colors.black54),
            //     title: Text("Góp ý",
            //         style: FineTheme.typograhpy.subtitle2
            //             .copyWith(color: Colors.black54)),
            //     function: () async {
            //       await model.sendFeedback();
            //     }),
            // const Divider(),
            // section(
            //     icon: const Icon(Icons.help_outline, color: Colors.black54),
            //     title: Text("Hỗ trợ",
            //         style: FineTheme.typograhpy.subtitle2
            //             .copyWith(color: Colors.black54)),
            //     function: () async {
            //       int option = await showOptionDialog(
            //           "Vui lòng liên hệ FanPage",
            //           firstOption: "Quay lại",
            //           secondOption: "Liên hệ");
            //       if (option == 1) {
            //         _launchUrl(
            //             "https://www.facebook.com/Bean-%C6%A0i-103238875095890",
            //             isFB: true);
            //       }
            //     }),
            // const Divider(),
            section(
                icon: const Icon(Icons.logout, color: Colors.black54),
                title: Text(
                  "Đăng xuất",
                  style: FineTheme.typograhpy.subtitle2
                      .copyWith(color: Colors.red),
                ),
                function: () async {
                  await model.signOut();
                }),
            const Divider(),
            // section(
            //     icon: Icon(Icons.help_outline, color: Colors.black54),
            //     title: Text("Design System",
            //         style: Get.theme.textTheme.headline4
            //             .copyWith(color: Colors.black54)),
            //     function: () {
            //       Get.toNamed(RouteHandler.DESIGN);
            //     }),
          ],
        ),
      ),
    );
  }

  Widget section({Icon? icon, Text? title, VoidCallback? function}) {
    return InkWell(
      onTap: function ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon ?? const SizedBox.shrink(),
                const SizedBox(
                  width: 8,
                ),
                title ?? const Text("Mặc định"),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }
}
