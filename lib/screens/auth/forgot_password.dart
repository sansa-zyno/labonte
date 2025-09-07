import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/modals/alert.dart';
import 'package:french_app/screens/auth/sign_up.dart';
import 'package:french_app/services/auth.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:french_app/widgets/custom_textfield.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(statusBarColor: AppColors.whiteColor2),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor2,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: appBarSpace),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.arrow_back),
                    ),
                  ),
                  Image.asset(
                    AppImages.logo,
                    width: getHorizontalSize(75, context),
                    height: getVerticalSize(59, context),
                  ),
                  SizedBox(height: getVerticalSize(15, context)),
                  CustomText(text: 'Forgot Password', size: getFontSize(fontSizeBig, context), weight: FontWeight.bold),
                  SizedBox(height: getVerticalSize(8, context)),
                  RichText(
                      text: TextSpan(
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: getFontSize(fontSizeSmall, context),
                          ),
                          children: [
                        TextSpan(text: 'Dont have an account? '),
                        TextSpan(
                            recognizer: TapGestureRecognizer()..onTap = () => changeScreenReplacement(context, const SignUp()),
                            text: 'Sign Up',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ))
                      ])),
                  SizedBox(height: getVerticalSize(30, context)),
                  CustomTextField(
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        size: getSize(18, context),
                        color: AppColors.blackColor1.withOpacity(0.5),
                      ),
                      controller: emailController,
                      hintText: 'Email',
                      validator: (value) {
                        return validateEmail(emailController.text) ? null : "Enter a valid email address";
                      }),
                  SizedBox(height: getVerticalSize(50, context)),
                  isloading
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          text: 'Submit',
                          color: AppColors.buttonColor,
                          onpressed: () {
                            if (_formKey.currentState!.validate()) {
                              resetPass();
                            }
                          },
                        ),
                  SizedBox(height: getVerticalSize(30, context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  resetPass() async {
    try {
      isloading = true;
      setState(() {});
      await AuthService.resetPassword(emailController.text);
      showDialog(
        context: context,
        builder: (ctx) => ShowDialogWidget(
          image: AppImages.handUp,
          titleText: 'A password reset link has been sent to ${emailController.text}',
          subText: "",
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => ShowDialogWidget(
          titleText: toSentenceCase(e.toString().replaceAll('-', " ")),
          subText: "",
        ),
      );
    }
    isloading = false;
    setState(() {});
  }
}

String toSentenceCase(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

bool validateEmail(String value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  return (!regex.hasMatch(value)) ? false : true;
}
