import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_icons.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class CertificateScreen extends StatefulWidget {
  final String learnerName;
  const CertificateScreen({Key? key, required this.learnerName}) : super(key: key);

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final WidgetsToImageController _controller = WidgetsToImageController();
  Uint8List? _imageBytes;

  Future<void> _captureCertificate() async {
    final bytes = await _controller.capture();
    setState(() {
      _imageBytes = bytes;
    });
  }

  Future<void> _downloadCertificate(BuildContext context) async {
    await _captureCertificate();
    if (_imageBytes == null) return;
    final Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }
      if (directory == null) {
        //CustomSnackbar.showBottom(context, "Document directory not available");
        return;
      }
      final file = File('${directory.path}/certificate.png');
      await file.writeAsBytes(_imageBytes!);

      final params = SaveFileDialogParams(sourceFilePath: file.path);
      final filePath = await FlutterFileDialog.saveFile(params: params);
      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Certificate saved to: ${file.path}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred while downloading certificate')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred')),
      );
    }
  }

  Future<void> _shareCertificate() async {
    await _captureCertificate();
    if (_imageBytes == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/certificate.png');
    await file.writeAsBytes(_imageBytes!);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'My Course Certificate'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
          style: ButtonStyle(
            iconSize: WidgetStateProperty.all<double>(getSize(20, context)),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Certificate Preview (capturable widget) ---
            WidgetsToImage(
              controller: _controller,
              child: AspectRatio(
                aspectRatio: 1.2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.lightGrey, width: 2),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.buttonColor, width: 12),
                    ),
                    child: Padding(
                      padding: getPadding(context: context, all: 20),
                      child: Column(
                        children: [
                          Text(
                            'CERTIFICATE',
                            style: GoogleFonts.roboto()
                                .copyWith(fontSize: getFontSize(18, context), color: AppColors.blackColor3, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'OF APPRECIATION',
                            style: GoogleFonts.roboto().copyWith(fontSize: getFontSize(9, context), color: AppColors.blackColor3, height: 0.5),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: getVerticalSize(20, context)),
                          Text(
                            'Proudly presented to',
                            style: TextStyle(fontSize: getFontSize(fontSizeSmall, context), fontStyle: FontStyle.italic),
                          ),
                          SizedBox(height: getVerticalSize(12, context)),
                          Text(
                            widget.learnerName,
                            style: GoogleFonts.greatVibes()
                                .copyWith(fontSize: getFontSize(24, context), color: AppColors.blackColor3, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: getVerticalSize(12, context)),
                          Text(
                            'For successfully completing the 30th lesson\nin the French Learning Program.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: getFontSize(fontSizeSmall, context)),
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('____________________\nInstructor',
                                  style: TextStyle(fontSize: getFontSize(fontSizeSmall, context), color: AppColors.blackColor3),
                                  textAlign: TextAlign.center),
                              Text('____________________\nDate',
                                  style: TextStyle(fontSize: getFontSize(fontSizeSmall, context), color: AppColors.blackColor3),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: getVerticalSize(30, context)),

            // --- Download / Share ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () async => await _downloadCertificate(context),
                      child: Image.asset(
                        AppIcons.download,
                        height: getSize(24, context),
                      ),
                    ),
                    SizedBox(height: getVerticalSize(5, context)),
                    Text('Download')
                  ],
                ),
                SizedBox(width: getHorizontalSize(100, context)),
                Column(
                  children: [
                    InkWell(
                      onTap: () async => await _shareCertificate(),
                      child: Image.asset(
                        AppIcons.share2,
                        height: getSize(24, context),
                      ),
                    ),
                    SizedBox(height: getVerticalSize(5, context)),
                    Text('Share')
                  ],
                ),
              ],
            ),

            const Spacer(flex: 2),

            CustomButton(
              width: getHorizontalSize(250, context),
              text: 'Rate our app',
              textColor: AppColors.primaryColor,
              border: Border.all(color: AppColors.primaryColor, width: 1.5),
              onpressed: () {
                requestReview();
              },
            ),
            SizedBox(height: getVerticalSize(15, context)),
            CustomButton(
              text: 'Back to home ',
              color: AppColors.buttonColor,
              onpressed: () {
                changeScreenRemoveUntill(context, BottomNavbar(pageIndex: 0));
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> requestReview() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview(); // Shows the native dialog
    } else {
      // Optionally open the store listing if in-app review isn't available
      await inAppReview.openStoreListing(appStoreId: '6755325259', microsoftStoreId: 'com.labonte.www');
    }
  }
}
