import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
//import 'package:french_app/models/dummy_data.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
//import 'package:purchases_flutter/object_wrappers.dart';

class PaywallWidget extends StatefulWidget {
  final String title;
  final String description;
  final List<Package> packages;
  final ValueChanged<Package> onClickedPackage;

  const PaywallWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.packages,
    required this.onClickedPackage,
  }) : super(key: key);

  @override
  _PaywallWidgetState createState() => _PaywallWidgetState();
}

class _PaywallWidgetState extends State<PaywallWidget> {
  int selectedIdx = -1;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
            color: AppColors.blackColor1.withOpacity(0.2),
            width: 1.0,
          )),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          )),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        size: 20,
                      ),
                    ),
                  ),
                  CustomText(
                    text: widget.title,
                    size: getFontSize(fontSizeBig, context),
                    weight: FontWeight.w600,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: buildPackages(selectedIdx, (index) {
                      selectedIdx = index;
                      setState(() {});
                    }),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 90,
            padding: EdgeInsets.fromLTRB(15, 20, 15, 25),
            decoration: BoxDecoration(color: AppColors.whiteColor1, boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(-2, 2),
              )
            ]),
            child: Opacity(
              opacity: selectedIdx == -1 ? 0.1 : 1,
              child: CustomButton(
                text: 'Continue',
                color: AppColors.buttonColor,
                onpressed: () {
                  if (selectedIdx != -1) {
                    widget.onClickedPackage(widget.packages[selectedIdx]);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPackages(int selectedIdx, Function(int x) setIndex) => ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: widget.packages.length,
      itemBuilder: (context, index) {
        final package = widget.packages[index];
        return buildPackage(context, package, selectedIdx, index, setIndex);
      });

  Widget buildPackage(BuildContext context, Package package, int selectedIdx, int index, Function(int x) setIndex) {
    final product = package.storeProduct;
    return GestureDetector(
      onTap: () {
        setIndex(index);
      },
      child: Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
              border: Border.all(
                color: selectedIdx == index ? Color(0xFFEEC45C) : Color(0xFF100C0C),
                width: selectedIdx == index ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: product.title,
                weight: FontWeight.w500,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  product.introductoryPrice != null
                      ? CustomText(
                          text: product.introductoryPrice!.priceString,
                          size: getFontSize(fontSizeSmall, context),
                          color: AppColors.blackColor2.withOpacity(0.6),
                          textDecoration: TextDecoration.lineThrough,
                        )
                      : SizedBox.shrink(),
                  product.introductoryPrice != null ? SizedBox(width: 5) : SizedBox.shrink(),
                  CustomText(
                    text: product.priceString,
                    size: getFontSize(fontSizeSmall, context),
                    weight: FontWeight.w700,
                  ),
                ],
              ),
              SizedBox(height: 8),
              CustomText(
                text: product.description,
                size: getFontSize(fontSizeSmall, context),
                //weight: FontWeight.w600,
              ),
            ],
          )),
    );
  }
}
