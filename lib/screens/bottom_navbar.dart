import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_icons.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/provider/app_provider.dart';
import 'package:french_app/provider/tts_provider.dart';
import 'package:french_app/screens/decision.dart';
import 'package:french_app/screens/home.dart';
import 'package:french_app/screens/practiceI_with_AI.dart';
import 'package:french_app/screens/profile/profile.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

// ignore: must_be_immutable
class BottomNavbar extends StatefulWidget {
  final int pageIndex;
  Widget? newpage;
  BottomNavbar({Key? key, required this.pageIndex, this.newpage}) : super(key: key);

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late AppProvider appProvider;
  late TextToSpeechProvider textToSpeechProvider;

  late int pageIndex;
  late Widget _showPage;

  late Home _home;
  late DecisionScreen _decisionScreen;
  late PracticeiWithAI _practiceiWithAI;
  late Profile _profile;

  //navbar
  Widget _pageChooser(int page) {
    switch (page) {
      case 0:
        return _home;
      case 1:
        return _decisionScreen;
      case 2:
        return _practiceiWithAI;
      case 3:
        return _profile;
      default:
        return new Container(
            child: new Center(
          child: new Text(
            //'No Page found by page thrower',
            "This screen is still under development",
            style: new TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
          ),
        ));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    appProvider = Provider.of<AppProvider>(context, listen: false);
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);

    _home = Home();
    _decisionScreen = DecisionScreen(previousPageIndex: 1, lessonData: null, lessonIndex: 1, subLessonIndex: 0);
    _practiceiWithAI = PracticeiWithAI();
    _profile = Profile();

    pageIndex = widget.pageIndex;
    _showPage = _pageChooser(pageIndex);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        //backgroundColor: Color(0xff0e6dfd),
        //drawer: Menu(),
        body: UpgradeAlert(
          upgrader: Upgrader(),
          child: widget.newpage == null ? _showPage : widget.newpage,
        ),
        bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            elevation: 10,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Image.asset(
                  AppIcons.home,
                  height: getSize(20, context),
                ),
                activeIcon: Image.asset(
                  AppIcons.homeActive,
                  height: getSize(20, context),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  AppIcons.lessons,
                  height: getSize(20, context),
                ),
                activeIcon: Image.asset(
                  AppIcons.lessonsActive,
                  height: getSize(20, context),
                ),
                label: 'Lessons',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  AppIcons.practicewithAI,
                  height: getSize(20, context),
                ),
                activeIcon: Image.asset(
                  AppIcons.practicewithAIActive,
                  height: getSize(20, context),
                ),
                label: 'Practice with AI',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  AppIcons.profile,
                  height: getSize(20, context),
                ),
                activeIcon: Image.asset(
                  AppIcons.profileActive,
                  height: getSize(20, context),
                ),
                label: 'Profile',
              ),
            ],
            showSelectedLabels: true,
            showUnselectedLabels: true,
            currentIndex: pageIndex,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: AppColors.blackColor2.withOpacity(0.6),
            unselectedFontSize: getFontSize(fontSizeExtraSmall, context),
            selectedFontSize: getFontSize(fontSizeExtraSmall, context),
            onTap: (int tappedIndex) async {
              await textToSpeechProvider.stop(); //To stop audio player when bottom navigating away from lesson screen
              if (appProvider.continueLessonData != null && tappedIndex == 1) {
                _decisionScreen = DecisionScreen(
                    previousPageIndex: 1,
                    lessonData: appProvider.continueLessonData,
                    lessonIndex: appProvider.continueLessonData!.lessonIndex,
                    subLessonIndex: appProvider.continueSubLessonIndex,
                    exerciseIndex: 0 //appProvider.continueExerciseIndex,
                    );
              }
              setState(() {
                pageIndex = tappedIndex;
                _showPage = _pageChooser(pageIndex);
                widget.newpage = null;
              });
            }));
  }
}
