import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/entitlement.dart';
import 'package:french_app/provider/entitlement_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/subscription.dart';
import 'package:french_app/services/gemini_service.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:french_app/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PracticeiWithAI extends StatefulWidget {
  const PracticeiWithAI({super.key});

  @override
  State<PracticeiWithAI> createState() => _PracticeiWithAIState();
}

class _PracticeiWithAIState extends State<PracticeiWithAI> {
  TextEditingController textEditingController = TextEditingController();
  bool isLoading = false;
  String correctedText = 'Bonjou, Je suis content. Correction: sui - suis';

  Future<void> extractTextFromPdf() async {
    //pick file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        //extract file
        // Load the PDF file
        final File file = File(filePath);
        final Uint8List bytes = await file.readAsBytes();
        final PdfDocument document = PdfDocument(inputBytes: bytes);
        // Extract text from all pages
        String text = PdfTextExtractor(document).extractText();
        //log(text); // Output extracted text
        // Dispose the document
        document.dispose();

        //show extracted text
        textEditingController.text = text;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    bool canGoback = Navigator.canPop(context);
    EntitlementProvider entitlementProvider = Provider.of<EntitlementProvider>(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: appBarSpace),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 30, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    if (canGoback) {
                      Navigator.pop(context);
                    } else {
                      changeScreenRemoveUntill(context, BottomNavbar(pageIndex: 0));
                    }
                  },
                  child: Icon(Icons.arrow_back),
                ),
                Spacer(),
                CustomText(
                  text: 'Practice with AI',
                  size: getFontSize(18, context),
                  weight: FontWeight.w500,
                ),
                Spacer(),
              ],
            ),
          ),
          SizedBox(height: getVerticalSize(15, context)),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: SizedBox(
                      height: height / 3.2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Type in French',
                            size: getFontSize(14, context),
                            weight: FontWeight.w500,
                          ),
                          SizedBox(height: getVerticalSize(8, context)),
                          CustomTextField(
                            borderRadius: 8,
                            contentPadding: EdgeInsets.all(8),
                            controller: textEditingController,
                            hintText: '',
                            minLines: 3,
                            maxLines: 5,
                          ),
                          SizedBox(
                            height: getVerticalSize(8, context),
                          ),
                          GestureDetector(
                            onTap: () {
                              extractTextFromPdf();
                            },
                            child: Row(children: [
                              Icon(
                                Icons.file_upload_outlined,
                              ),
                              SizedBox(width: getHorizontalSize(8, context)),
                              CustomText(text: 'Upload')
                            ]),
                          ),
                          SizedBox(height: getVerticalSize(20, context)),
                          CustomButton(
                            text: 'Submit',
                            color: AppColors.buttonColor,
                            onpressed: () {
                              if (entitlementProvider.entitlement == Entitlement.pro) {
                                correctGrammar(textEditingController.text);
                              } else {
                                changeScreen(context, Subscription());
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'AI Feedback',
                          color: AppColors.yellow2,
                          size: getFontSize(18, context),
                          weight: FontWeight.bold,
                        ),
                        SizedBox(height: getVerticalSize(10, context)),
                        isLoading
                            ? SizedBox(height: height / 3, child: const Center(child: CircularProgressIndicator()))
                            : Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.blackColor1.withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomText(text: correctedText),
                              )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> correctGrammar(String text) async {
    setState(() {
      isLoading = true;
      correctedText = '';
    });
    correctedText = await GeminiService.correctText(text);
    setState(() {
      isLoading = false;
    });
  }
}
