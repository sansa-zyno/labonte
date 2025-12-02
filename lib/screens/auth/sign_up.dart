import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/modals/alert.dart';
import 'package:french_app/models/user.dart';
import 'package:french_app/screens/auth/log_in.dart';
import 'package:french_app/screens/onboarding/onboarding_start.dart';
import 'package:french_app/services/auth.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:french_app/widgets/custom_textfield.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isloading = false;
  bool obscureText = false;

  UserModel userModel = UserModel(id: '');

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
                    height: getSize(50, context),
                  ),
                  SizedBox(height: getVerticalSize(15, context)),
                  CustomText(
                    text: 'Sign Up',
                    size: getFontSize(fontSizeBig, context),
                    weight: FontWeight.bold,
                  ),
                  SizedBox(height: getVerticalSize(8, context)),
                  RichText(
                      text: TextSpan(
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: getFontSize(fontSizeSmall, context),
                          ),
                          children: [
                        TextSpan(text: 'Existing user? '),
                        TextSpan(
                          recognizer: TapGestureRecognizer()..onTap = () => changeScreenReplacement(context, const Login()),
                          text: 'Log in',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ])),
                  SizedBox(height: getVerticalSize(30, context)),
                  CustomTextField(
                      prefixIcon: Icon(
                        Icons.person_3_outlined,
                        size: getSize(18, context),
                        color: AppColors.blackColor1.withOpacity(0.5),
                      ),
                      controller: nameController,
                      hintText: 'Name',
                      onChanged: (name) {
                        userModel = userModel.copyWith(name: name);
                      },
                      validator: (value) {
                        if (value == "") {
                          return "Name cannot be empty";
                        }
                        return null;
                      }),
                  SizedBox(height: getVerticalSize(15, context)),
                  CustomTextField(
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        size: getSize(18, context),
                        color: AppColors.blackColor1.withOpacity(0.5),
                      ),
                      controller: emailController,
                      hintText: 'Email',
                      onChanged: (email) {
                        userModel = userModel.copyWith(email: email);
                      },
                      validator: (value) {
                        return validateEmail(emailController.text) ? null : "Enter a valid email address";
                      }),
                  SizedBox(height: getVerticalSize(15, context)),
                  CustomTextField(
                      prefixIcon: Icon(
                        Icons.flag_outlined,
                        size: getSize(18, context),
                        color: AppColors.blackColor1.withOpacity(0.5),
                      ),
                      controller: countryController,
                      hintText: 'Country',
                      suffixIcon: Icon(
                        Icons.keyboard_arrow_down_outlined,
                        size: getSize(18, context),
                        color: AppColors.blackColor1.withOpacity(0.5),
                      ),
                      onChanged: (country) {
                        userModel = userModel.copyWith(country: country);
                      },
                      validator: (value) {
                        if (value == "") {
                          return "Country cannot be empty";
                        }
                        return null;
                      }),
                  SizedBox(height: getVerticalSize(15, context)),
                  CustomTextField(
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        size: getSize(18, context),
                        color: AppColors.blackColor1.withOpacity(0.5),
                      ),
                      controller: passwordController,
                      obscureText: obscureText,
                      hintText: 'Password',
                      suffixIcon: GestureDetector(
                        onTap: () {
                          obscureText = !obscureText;
                          setState(() {});
                        },
                        child: !obscureText
                            ? Icon(
                                Icons.visibility_off,
                                size: getSize(18, context),
                                color: AppColors.blackColor1.withOpacity(0.5),
                              )
                            : Icon(
                                Icons.visibility,
                                size: getSize(18, context),
                                color: AppColors.blackColor1.withOpacity(0.5),
                              ),
                      ),
                      validator: (value) {
                        if (value == "") {
                          return "Password cannot be empty";
                        } else if (value!.length < 6) {
                          return "The password has to be at least 6 characters long";
                        }
                        return null;
                      }),
                  SizedBox(height: getVerticalSize(30, context)),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: getFontSize(fontSizeSmall, context),
                      ),
                      children: [
                        const TextSpan(text: "By signing up, you agree to our "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: TextStyle(
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              // Navigate to your privacy policy screen or open URL
                              await launchUrl(Uri.parse('https://labontelanguages.ca/privacy-policy/'));
                            },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: getVerticalSize(15, context)),
                  isloading
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          text: 'Sign Up',
                          color: AppColors.buttonColor,
                          onpressed: () {
                            if (_formKey.currentState!.validate()) {
                              signUp();
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

  signUp() async {
    try {
      isloading = true;
      setState(() {});
      String? userId = await AuthService.signUpWithEmailAndPassword(emailController.text, passwordController.text);
      if (userId == null) {
        throw 'An unexpected error occurred, please try again';
      } else {
        userModel = userModel.copyWith(id: userId);
        await DatabaseService.createUser(userModel.id, userModel);
        changeScreenRemoveUntill(context, OnboardingStart(userModel: userModel));
        isloading = false;
        setState(() {});
      }
    } catch (e) {
      isloading = false;
      setState(() {});
      showDialog(
        context: context,
        builder: (ctx) => ShowDialogWidget(titleText: toSentenceCase(e.toString().replaceAll('-', " ")), subText: ""),
      );
    }
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
