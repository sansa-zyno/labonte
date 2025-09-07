/*import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FieldLoading extends StatefulWidget {
  const FieldLoading({Key? key}) : super(key: key);

  @override
  State<FieldLoading> createState() => _FieldLoadingState();
}

class _FieldLoadingState extends State<FieldLoading> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        enabled: true,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(width: 85.0, height: 15.0, color: kLightCardBgColor).paddingBottom(5),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: kLightCardBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
