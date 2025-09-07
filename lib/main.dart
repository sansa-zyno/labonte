import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/firebase_options.dart';
import 'package:french_app/provider/app_provider.dart';
import 'package:french_app/provider/stt_provider.dart';
import 'package:french_app/provider/tts_provider.dart';
import 'package:french_app/provider/entitlement_provider.dart';
import 'package:french_app/screens/splash.dart';
import 'package:french_app/services/local_storage.dart';
import 'package:french_app/services/purchase_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load environment variables
  //await PurchaseApi.init();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    log(e.toString());
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => EntitlementProvider()),
        ChangeNotifierProvider(create: (_) => TextToSpeechProvider()),
        ChangeNotifierProvider(create: (_) => SpeechToTextProvider()),
      ],
      child: MaterialApp(
        title: 'La Bonte',
        theme: ThemeData(
            useMaterial3: true,
            textTheme: GoogleFonts.notoSansTextTheme(),
            appBarTheme: const AppBarTheme(backgroundColor: AppColors.whiteColor1),
            scaffoldBackgroundColor: AppColors.whiteColor1,
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: AppColors.whiteColor1,
            ),
            dialogTheme: const DialogTheme(
              backgroundColor: AppColors.whiteColor1,
            )),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
