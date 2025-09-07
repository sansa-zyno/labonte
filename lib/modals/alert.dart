import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowDialogWidget extends StatelessWidget {
  final String? image;
  final String titleText;
  final String subText;
  final bool? isActionOptions;
  final double? titleSize;
  final double? subTitleSize;
  //final Color borderColor;

  ShowDialogWidget({
    required this.titleText,
    required this.subText,
    this.image,
    this.isActionOptions,
    this.titleSize,
    this.subTitleSize,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: SizedBox(
          height: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              image == null
                  ? Center(
                      child: Image.asset(AppImages.logo, height: 50),
                    )
                  : Center(
                      child: Image.asset(image!, height: 100),
                    ),
              SizedBox(height: 15),
              Center(
                child: CustomText(
                  text: titleText,
                  fontFamily: GoogleFonts.roboto().fontFamily,
                  weight: FontWeight.bold,
                  textAlign: TextAlign.center,
                  size: titleSize ?? 20,
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: CustomText(
                  text: subText,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  size: subTitleSize ?? 16,
                ),
              )
            ],
          ),
        ),
        actions: isActionOptions == null || isActionOptions == false
            ? <Widget>[
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.primaryColor)),
                    child: Text("Ok", style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              ]
            : <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.blackColor1)),
                      child: Text("No", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                    ),
                    SizedBox(width: 15),
                    ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.primaryColor)),
                      child: Text("Yes", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    )
                  ],
                ),
              ]);
  }
}
