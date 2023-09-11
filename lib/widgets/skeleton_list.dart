import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonListItem extends StatelessWidget {
  final int itemCount;

  const SkeletonListItem({Key? key, this.itemCount = 1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            // leading: CircleAvatar(
            //   backgroundColor: Colors.white,
            //   radius: 25,
            // ),
            title: Container(
              width: double.infinity,
              height: 16.0,
              color: Colors.white,
            ),
            subtitle: Container(
              width: double.infinity,
              height: 12.0,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
