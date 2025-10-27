import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_constants.dart';
import 'package:french_app/constants/app_icons.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/lesson_progress.dart';
import 'package:french_app/models/review.dart';
import 'package:french_app/provider/app_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/decision.dart';
import 'package:french_app/screens/profile/profile.dart';
import 'package:french_app/services/database.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime now = DateTime.now();
  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(statusBarColor: AppColors.whiteColor1, systemNavigationBarColor: AppColors.whiteColor1),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: appBarSpace),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                        text:
                            '${now.hour < 12 ? 'Bonjour' : now.hour <= 16 ? 'Bon après-midi' : 'Bonsoir'}, ${appProvider.userModel?.name?.split(' ')[0] ?? 'USER'}! Let\'s learn',
                        size: getFontSize(16, context),
                        weight: FontWeight.w600),
                    InkWell(
                      onTap: () {
                        changeScreen(context, BottomNavbar(pageIndex: 3, newpage: const Profile()));
                      },
                      child: Image.asset(
                        AppIcons.user,
                        height: getSize(24, context),
                      ),
                    )
                  ],
                ),
                SizedBox(height: getVerticalSize(5, context)),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: getVerticalSize(219, context),
                        width: double.infinity,
                      ),
                      Positioned(bottom: 0, right: 12, child: Image.asset(AppImages.girl2)),
                      Positioned(
                          top: 30,
                          left: 10,
                          child: CustomText(
                              text: 'LECON ${appProvider.continueLessonData?.lessonIndex ?? 1} 0f 30',
                              size: getFontSize(fontSizeSmall, context),
                              weight: FontWeight.w500,
                              color: AppColors.whiteColor1)),
                      Positioned(
                          top: 50,
                          left: 10,
                          right: 150,
                          child: CustomText(
                              text: '${appProvider.continueLessonData?.subLessons[0]['title'].split(':')[1].trim() ?? 'LES ALPHABETS FRANÇAIS'}',
                              size: getFontSize(fontSizeSmall, context),
                              weight: FontWeight.w500,
                              color: AppColors.whiteColor1)),
                      Positioned(
                          bottom: 50,
                          left: 10,
                          child: CustomButton(
                            height: getVerticalSize(36, context),
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            color: AppColors.whiteColor1,
                            textColor: AppColors.primaryColor,
                            text: appProvider.continueLessonData == null ? 'Start Now' : 'Continue',
                            icon: Image.asset(AppImages.play, color: AppColors.primaryColor, height: getSize(15, context)),
                            onpressed: () {
                              changeScreen(
                                  context,
                                  BottomNavbar(
                                      pageIndex: 1,
                                      newpage: DecisionScreen(
                                          previousPageIndex: 1,
                                          lessonData: appProvider.continueLessonData,
                                          lessonIndex: appProvider.continueLessonData?.lessonIndex ?? 1,
                                          subLessonIndex: appProvider.continueSubLessonIndex,
                                          exerciseIndex: 0 //appProvider.continueExerciseIndex,
                                          )));
                            },
                          ))
                    ],
                  ),
                ),
                SizedBox(height: getVerticalSize(15, context)),
                StreamBuilder<Map<String, LessonProgress>>(
                    stream: DatabaseService.getUserLessonProgress(DatabaseService.currentUser!.uid),
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? snapshot.data!.isNotEmpty
                              ? Column(
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
                                                changeScreen(
                                                    context,
                                                    BottomNavbar(
                                                        pageIndex: 1,
                                                        newpage: DecisionScreen(
                                                            previousPageIndex: 1,
                                                            lessonData: null, //important
                                                            lessonIndex: int.parse(lessonIndex),
                                                            subLessonIndex: subLessonIndex,
                                                            exerciseIndex: 0 //exerciseIndex,
                                                            )));
                                              },
                                              child: Container(
                                                  width: 150,
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
                                                        size: getFontSize(fontSizeExtraSmall, context)),
                                                  ])),
                                            );
                                          }),
                                    ),
                                  ],
                                )
                              : AppConstants.emptyLessonProgress(context)
                          : Center(child: CircularProgressIndicator());
                    }),
                SizedBox(height: getVerticalSize(15, context)),
                CustomText(text: 'Practice with AI', weight: FontWeight.w600),
                SizedBox(height: getVerticalSize(8, context)),
                Card(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.blackColor1.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFFEEF3FF),
                          child: Image.asset(AppIcons.practicewithAI, height: getSize(20, context)),
                        ),
                        SizedBox(width: getHorizontalSize(8, context)),
                        Expanded(
                          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            CustomText(
                              text: 'Ask LaBonte AI',
                              weight: FontWeight.bold,
                              size: getFontSize(fontSizeMedium, context),
                            ),
                            SizedBox(height: getVerticalSize(3, context)),
                            CustomText(text: 'Get instant answers, corrections, and tips.', size: getFontSize(fontSizeSmall, context))
                          ]),
                        ),
                        SizedBox(width: getHorizontalSize(15, context)),
                        CustomButton(
                          text: 'Ask AI',
                          height: 28,
                          color: AppColors.whiteColor1,
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                          textSize: getFontSize(11, context),
                          textColor: AppColors.primaryColor,
                          border: Border.all(color: AppColors.primaryColor, width: 1.5),
                          onpressed: () {
                            changeScreenReplacement(context, BottomNavbar(pageIndex: 2));
                          },
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: getVerticalSize(15, context)),
                CustomText(text: 'Book a Session', weight: FontWeight.w600),
                SizedBox(height: getVerticalSize(8, context)),
                Container(
                  height: getVerticalSize(146, context),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.red2.withOpacity(0.2), width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.lightGrey2,
                            child: Image.asset(AppIcons.user2, height: getSize(24, context)),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: 'Schedule a session with a tutor',
                                  size: getFontSize(fontSizeSmall, context),
                                  weight: FontWeight.w600,
                                ),
                                SizedBox(height: getVerticalSize(4, context)),
                                Row(
                                  children: [
                                    Image.asset(AppIcons.timer, height: getSize(12, context)),
                                    SizedBox(width: 3),
                                    CustomText(
                                      text: '30min - 2 hrs',
                                      size: getFontSize(fontSizeSmall, context),
                                      color: AppColors.blackColor2.withOpacity(0.8),
                                    ),
                                  ],
                                ),
                                SizedBox(height: getVerticalSize(6, context)),
                                Container(
                                  height: getVerticalSize(22, context),
                                  width: getHorizontalSize(64, context),
                                  padding: EdgeInsets.only(left: 6, right: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.blackColor1.withOpacity(0.4)),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_3, size: 12),
                                      SizedBox(width: getHorizontalSize(3, context)),
                                      CustomText(
                                        text: 'Private',
                                        size: getFontSize(fontSizeExtraSmall, context),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: getVerticalSize(10, context)),
                      CustomButton(
                        height: getVerticalSize(38, context),
                        width: double.infinity,
                        text: 'Schedule Now',
                        textSize: getFontSize(12, context),
                        color: AppColors.buttonColor,
                        onpressed: () {
                          launchCalendryUrl('labontelanguages-info/new-meeting');
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(height: getVerticalSize(15, context)),
                CustomText(
                  text: 'Quick Review',
                  weight: FontWeight.w600,
                ),
                SizedBox(height: getVerticalSize(8, context)),
                SizedBox(
                  height: getVerticalSize(100, context),
                  child: StreamBuilder<List<Review>>(
                      stream: DatabaseService.getUserReviews(DatabaseService.currentUser!.uid),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? snapshot.data!.isNotEmpty
                                ? ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.all(0),
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (ctx, index) => GestureDetector(
                                          onTap: () {
                                            changeScreen(
                                                context,
                                                BottomNavbar(
                                                    pageIndex: 1,
                                                    newpage: DecisionScreen(
                                                        previousPageIndex: 1,
                                                        lessonData: null, //important
                                                        lessonIndex: int.parse(snapshot.data![index].lessonId),
                                                        subLessonIndex: 0,
                                                        exerciseIndex: null)));
                                          },
                                          child: Container(
                                            width: 150,
                                            height: double.infinity,
                                            padding: EdgeInsets.all(8),
                                            margin: EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(
                                                color: (index % 2) == 0 ? AppColors.red2.withOpacity(0.2) : AppColors.yellow.withOpacity(0.8),
                                                borderRadius: BorderRadius.circular(8)),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                    text: 'LECON ${snapshot.data![index].lessonId}',
                                                    size: getFontSize(fontSizeSmall, context),
                                                    weight: FontWeight.w600),
                                                const SizedBox(height: 5),
                                                CustomText(
                                                  text: '${snapshot.data![index].titleInFrench}'.split(':')[1].trim(),
                                                  size: getFontSize(fontSizeExtraSmall, context),
                                                  maxlines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Spacer(),
                                                CustomText(
                                                    text: '${snapshot.data![index].titleInEnglish}', size: getFontSize(fontSizeExtraSmall, context)),
                                              ],
                                            ),
                                          ),
                                        ))
                                : Center(child: CustomText(text: 'You have not completed any lesson'))
                            : Center(child: CircularProgressIndicator());
                      }),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> launchCalendryUrl(String address) async {
    final url = 'https://www.calendly.com/$address';
    await launchUrl(Uri.parse(url));
  }
}
/*                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      SizedBox(
                        height: getVerticalSize(50, context),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              backgroundColor: Colors.transparent,
                              color: AppColors.primaryColor,
                              value: 0.8,
                            ),
                            Center(child: CustomText(text: '10'))
                          ],
                        ),
                      ),
                      SizedBox(width: getHorizontalSize(8, context)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Daily Goal Remider',
                            size: getFontSize(fontSizeSmall, context),
                            weight: FontWeight.w600,
                          ),
                          CustomText(
                            text: 'You set 15 minutes/day',
                            size: getFontSize(fontSizeExtraSmall, context),
                            color: AppColors.blackColor1.withOpacity(0.8),
                          )
                        ],
                      ),
                      Spacer(),
                      CustomButton(
                        height: 28,
                        color: AppColors.whiteColor1,
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        text: 'Edit goal',
                        textSize: getFontSize(11, context),
                        textColor: AppColors.primaryColor,
                        border: Border.all(color: AppColors.primaryColor, width: 1.5),
                      )
                    ],
                  ),
                ),
                SizedBox(height: getVerticalSize(20, context))*/
