// ignore_for_file: avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fine_merchant_mobile/Constant/route_constraint.dart';
import 'package:fine_merchant_mobile/Constant/view_status.dart';
import 'package:fine_merchant_mobile/Model/DTO/StationDTO.dart';
import 'package:fine_merchant_mobile/ViewModel/account_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/home_viewModel.dart';
import 'package:fine_merchant_mobile/ViewModel/station_viewModel.dart';
import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:fine_merchant_mobile/widgets/fixed_app_bar.dart';
import 'package:fine_merchant_mobile/widgets/shimmer_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shimmer/shimmer.dart';

class StationScreen extends StatefulWidget {
  const StationScreen({Key? key}) : super(key: key);

  @override
  State<StationScreen> createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final double HEIGHT = 48;
  final ValueNotifier<double> notifier = ValueNotifier(0);
  final PageController controller = PageController();
  Future<void> _refresh() async {
    // await Get.find<RootViewModel>().startUp();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: FineTheme.palettes.shades100,
      body: SafeArea(
        // ignore: sized_box_for_whitespace
        child: Container(
          // color: FineTheme.palettes.primary100,
          height: Get.height,
          child: ScopedModel(
            model: Get.find<StationViewModel>(),
            child: Stack(
              children: [
                Column(
                  children: [
                    FixedAppBar(
                      // notifier: notifier,
                      height: HEIGHT,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(top: 0),
                        child: RefreshIndicator(
                          key: _refreshIndicatorKey,
                          onRefresh: _refresh,
                          child: ScopedModelDescendant<StationViewModel>(
                              builder: (context, child, model) {
                            if (model.status == ViewStatus.Error) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Center(
                                    child: Text(
                                      "Có lỗi xảy ra!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              );
                            } else {
                              return Container(
                                // color: FineTheme.palettes.neutral200,
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: (n) {
                                    if (n.metrics.pixels <= HEIGHT) {
                                      notifier.value = n.metrics.pixels;
                                    }
                                    return false;
                                  },
                                  child: SingleChildScrollView(
                                    child: Column(
                                      // addAutomaticKeepAlives: true,
                                      children: [
                                        ...renderHomeSections().toList(),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                // Positioned(
                //   left: 0,
                //   bottom: 0,
                //   child: buildNewOrder(),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> renderHomeSections() {
    var currentUser = Get.find<AccountViewModel>().currentUser;

    return [
      buildSelectStationSection(),
      const SizedBox(height: 18),
      buildBoxListSection(),
    ];
  }

  Widget buildSelectStationSection() {
    var currentUser = Get.find<AccountViewModel>().currentUser;

    return ScopedModel(
        model: Get.find<StationViewModel>(),
        child: ScopedModelDescendant<StationViewModel>(
          builder: (context, child, model) {
            ViewStatus status = model.status;
            if (status == ViewStatus.Loading) {
              return const SizedBox.shrink();
            }
            return Container(
              height: 50,
              padding: const EdgeInsets.only(top: 17, bottom: 17),
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Trạm: ",
                      style: FineTheme.typograhpy.subtitle2
                          .copyWith(color: FineTheme.palettes.neutral900),
                    ),
                    DropdownButton<String>(
                      value: model.selectedStationId,
                      onChanged: (String? value) {
                        model.onChangeStation(value!);
                      },
                      items: model.stationList
                          .map<DropdownMenuItem<String>>((StationDTO station) {
                        return DropdownMenuItem<String>(
                          value: station.id,
                          child: Text(
                            '${station.name}',
                            style: FineTheme.typograhpy.subtitle2
                                .copyWith(color: FineTheme.palettes.neutral900),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Widget buildBoxListSection() {
    return ScopedModel(
        model: Get.find<StationViewModel>(),
        child: ScopedModelDescendant<StationViewModel>(
          builder: (context, child, model) {
            ViewStatus status = model.status;
            if (status == ViewStatus.Loading) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              color: FineTheme.palettes.emerald25,
              height: 500,
              width: Get.width,
              child: Container(
                // height: 300,
                padding: const EdgeInsets.only(top: 17, bottom: 17),
                color: FineTheme.palettes.neutral200,
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Các box tại station",
                            style: FineTheme.typograhpy.h2
                                .copyWith(color: FineTheme.palettes.neutral900),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Expanded(
                        child: Container(
                          child: GridView.count(
                              // Create a grid with 2 columns. If you change the scrollDirection to
                              // horizontal, this produces 2 rows.
                              crossAxisCount: 2,
                              // Generate 100 widgets that display their index in the List.
                              children: [
                                ...model.boxList.map(
                                  (box) => Center(
                                    child: Material(
                                      child: InkWell(
                                        splashColor:
                                            FineTheme.palettes.emerald50,
                                        onTap: () {
                                          model.getBoxQrCode(box.id);
                                          print("box.id: ${box.id}");
                                          Get.toNamed(
                                            RouteHandler.QRCODE_SCREEN,
                                            arguments: box,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(25.0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: FineTheme
                                                      .palettes.emerald25)),
                                          child: Text(
                                            '${box.code}',
                                            style: FineTheme.typograhpy.body1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
