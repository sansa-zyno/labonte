import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_constants.dart';
import 'package:french_app/constants/app_icons.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/entitlement.dart';
import 'package:french_app/models/lesson_progress.dart';
import 'package:french_app/provider/app_provider.dart';
import 'package:french_app/provider/entitlement_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/certificate.dart';
import 'package:french_app/screens/decision.dart';
import 'package:french_app/screens/profile/settings.dart';
import 'package:french_app/screens/subscription.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _usersCollection = 'users';
  bool canViewCertificate = false;
  getProgressAndReviews() async {
    if (DatabaseService.currentUser != null) {
      final progressSnapshot = await _firestore.collection(_usersCollection).doc(DatabaseService.currentUser!.uid).collection('lessonProgress').get();
      if (progressSnapshot.docs.length >= 30) {
        final reviewsSnapshot = await _firestore.collection(_usersCollection).doc(DatabaseService.currentUser!.uid).collection('reviews').get();
        if (reviewsSnapshot.docs.isEmpty) {
          canViewCertificate = true;
          setState(() {});
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProgressAndReviews();
  }

  @override
  Widget build(BuildContext context) {
    bool canGoback = Navigator.canPop(context);
    AppProvider appProvider = Provider.of<AppProvider>(context);
    EntitlementProvider entitlementProvider = Provider.of<EntitlementProvider>(context);
    String? period = entitlementProvider.entitlementInfo?.periodType.name;
    String? expiryTime = entitlementProvider.expiryTimeCalc();
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: appBarSpace),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                InkWell(
                    onTap: () {
                      if (canGoback) {
                        Navigator.pop(context);
                      } else {
                        changeScreenRemoveUntill(context, BottomNavbar(pageIndex: 0));
                      }
                    },
                    child: Icon(Icons.arrow_back)),
                Spacer(),
                CustomText(text: 'Profile', size: getFontSize(18, context), weight: FontWeight.w500),
                Spacer(),
                InkWell(
                    onTap: () {
                      changeScreen(context, BottomNavbar(pageIndex: 3, newpage: SettingsScreen()));
                    },
                    child: Icon(Icons.settings_outlined))
              ]),
              SizedBox(height: getVerticalSize(15, context)),
              CustomText(text: 'Course Progress', weight: FontWeight.w600),
              SizedBox(height: getVerticalSize(15, context)),
              SizedBox(
                  height: getVerticalSize(130, context),
                  child: StreamBuilder<Map<String, LessonProgress>>(
                      stream: DatabaseService.getUserLessonProgress(DatabaseService.currentUser!.uid),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? snapshot.data!.isNotEmpty
                                ? ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.symmetric(horizontal: 15),
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (ctx, index) {
                                      String lessonIndex = snapshot.data!.keys.toList()[index];
                                      int subLessonIndex = snapshot.data![lessonIndex]!.currentSubLessonIndex;
                                      int? exerciseIndex = snapshot.data![lessonIndex]!.currentExerciseIndex;
                                      int partialLessonIndex = subLessonIndex + (exerciseIndex ?? 0);
                                      int totalLessonIndex = snapshot.data![lessonIndex]!.totalLessonIndex;

                                      // ──────────────────────────────────────────────────────────────
                                      // Size of one circle (you can change this value freely)
                                      final double circleSize = getSize(70.0, context);
                                      // ──────────────────────────────────────────────────────────────
                                      return Padding(
                                          padding: const EdgeInsets.only(right: 15, top: 3),
                                          child: SizedBox(
                                              width: getHorizontalSize(70, context),
                                              child: Column(children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    if (entitlementProvider.entitlement == Entitlement.pro) {
                                                      changeScreen(
                                                          context,
                                                          BottomNavbar(
                                                              pageIndex: 1,
                                                              newpage: DecisionScreen(
                                                                  isReview: false,
                                                                  previousPageIndex: 1,
                                                                  lessonData: null, //important
                                                                  lessonIndex: int.parse(lessonIndex),
                                                                  subLessonIndex: subLessonIndex,
                                                                  exerciseIndex: 0 //exerciseIndex,
                                                                  )));
                                                    } else {
                                                      changeScreen(context, Subscription());
                                                    }
                                                  },
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      // Background circle (light red)
                                                      Container(
                                                        height: circleSize,
                                                        width: circleSize,
                                                        decoration: BoxDecoration(
                                                          color: AppColors.red2.withOpacity(0.2),
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),

                                                      // The actual progress ring
                                                      SizedBox(
                                                        height: circleSize,
                                                        width: circleSize,
                                                        child: CircularProgressIndicator(
                                                          value: partialLessonIndex / totalLessonIndex,
                                                          color: AppColors.red2.withOpacity(0.6),
                                                        ),
                                                      ),

                                                      // Inner "L7", "L8" etc.
                                                      Container(
                                                        height: getVerticalSize(30, context),
                                                        width: getHorizontalSize(30, context),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.black, width: 2),
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: CustomText(
                                                          text: "L$lessonIndex",
                                                          weight: FontWeight.w600,
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: getVerticalSize(10, context)),
                                                CustomText(
                                                    text: partialLessonIndex < totalLessonIndex
                                                        ? 'Lesson ${lessonIndex} in Progress'
                                                        : 'Lesson ${lessonIndex} is Completed',
                                                    size: 12,
                                                    textAlign: TextAlign.center)
                                              ])));
                                    })
                                : Center(child: CustomText(text: 'You have not started any lesson'))
                            : Center(child: CircularProgressIndicator());
                      })),
              SizedBox(height: getVerticalSize(20, context)),
              CustomText(text: 'Practice with AI', weight: FontWeight.w600),
              SizedBox(height: getVerticalSize(8, context)),
              Card(
                  child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.blackColor1.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        CircleAvatar(backgroundColor: Color(0xFFEEF3FF), child: Image.asset(AppIcons.practicewithAI, height: getSize(20, context))),
                        SizedBox(width: getHorizontalSize(8, context)),
                        Expanded(
                            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          CustomText(text: 'Ask LaBonte AI', weight: FontWeight.bold, size: getFontSize(fontSizeMedium, context)),
                          SizedBox(height: getVerticalSize(3, context)),
                          CustomText(text: 'Get instant answers, corrections, and tips.', size: getFontSize(fontSizeSmall, context))
                        ])),
                        SizedBox(width: getHorizontalSize(15, context)),
                        CustomButton(
                            text: 'Ask AI',
                            height: getVerticalSize(28, context),
                            color: AppColors.whiteColor1,
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                            textSize: getFontSize(11, context),
                            textColor: AppColors.primaryColor,
                            border: Border.all(color: AppColors.primaryColor, width: 1.5),
                            onpressed: () {
                              changeScreenReplacement(context, BottomNavbar(pageIndex: 2));
                            })
                      ]))),
              SizedBox(height: getVerticalSize(20, context)),
              StreamBuilder<Map<String, LessonProgress>>(
                  stream: DatabaseService.getUserLessonProgress(DatabaseService.currentUser!.uid),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? snapshot.data!.isNotEmpty
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(text: 'Continue Learning', weight: FontWeight.w600),
                                  SizedBox(height: getVerticalSize(8, context)),
                                  SizedBox(
                                    height: getVerticalSize(100, context),
                                    child: ListView.builder(
                                        itemCount: snapshot.data!.length,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.all(0),
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (ctx, index) {
                                          String lessonIndex = snapshot.data!.keys.toList()[index];
                                          int subLessonIndex = snapshot.data![lessonIndex]!.currentSubLessonIndex;
                                          //int? exerciseIndex = snapshot.data![lessonIndex]!.currentExerciseIndex;
                                          return GestureDetector(
                                            onTap: () {
                                              if (entitlementProvider.entitlement == Entitlement.pro) {
                                                changeScreen(
                                                    context,
                                                    BottomNavbar(
                                                        pageIndex: 1,
                                                        newpage: DecisionScreen(
                                                            isReview: false,
                                                            previousPageIndex: 1,
                                                            lessonData: null, //important
                                                            lessonIndex: int.parse(lessonIndex),
                                                            subLessonIndex: subLessonIndex,
                                                            exerciseIndex: 0 //exerciseIndex,
                                                            )));
                                              } else {
                                                changeScreen(context, Subscription());
                                              }
                                            },
                                            child: Container(
                                                height: double.infinity,
                                                width: getHorizontalSize(150, context),
                                                padding: EdgeInsets.all(8),
                                                margin: EdgeInsets.only(right: 8),
                                                decoration: BoxDecoration(
                                                    color: (index % 2) == 0 ? AppColors.red2.withOpacity(0.2) : AppColors.yellow.withOpacity(0.8),
                                                    borderRadius: BorderRadius.circular(8)),
                                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                  CustomText(
                                                      text: 'LECON ${snapshot.data!.keys.toList()[index]}',
                                                      size: getFontSize(fontSizeSmall, context),
                                                      weight: FontWeight.w600),
                                                  const SizedBox(height: 5),
                                                  CustomText(
                                                    text: '${snapshot.data!.values.toList()[index].titleInFrench}'.split(':')[1].trim(),
                                                    size: getFontSize(fontSizeExtraSmall, context),
                                                    maxlines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Spacer(),
                                                  CustomText(
                                                      text: '${snapshot.data!.values.toList()[index].titleInEnglish}',
                                                      size: getFontSize(fontSizeExtraSmall, context))
                                                ])),
                                          );
                                        }),
                                  ),
                                ],
                              )
                            : AppConstants.emptyLessonProgress(context)
                        : Center(child: CircularProgressIndicator());
                  }),
              canViewCertificate ? const SizedBox(height: 30) : const SizedBox(height: 10),
              canViewCertificate
                  ? CustomButton(
                      text: 'View Certificate',
                      color: AppColors.buttonColor,
                      onpressed: () {
                        if (entitlementProvider.entitlement == Entitlement.pro) {
                          changeScreen(context, CertificateScreen(learnerName: '${appProvider.userModel?.name ?? 'N/A'}'));
                        } else {
                          changeScreen(context, Subscription());
                        }
                      },
                    )
                  : SizedBox.shrink(),
            ]),
          ),
          Spacer(),
          Container(
              alignment: Alignment.center,
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.yellow.withOpacity(0.8)),
              child: entitlementProvider.entitlementInfo == null
                  ? CustomText(text: 'No active subscription')
                  : expiryTime == null
                      ? CustomText(text: 'Your ${period == null || period == 'trial' ? "free trial" : 'subscription'} has ended')
                      : CustomText(text: 'Your ${period == null || period == 'trial' ? "free trial" : 'subscription'} will end in $expiryTime')),
          Spacer(),
        ],
      ),
    );
  }
}
