import 'dart:io';
import 'package:flutter/services.dart';
import 'package:french_app/helpers/file_recorder.dart';
import 'package:google_speech/google_speech.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextService {
  static Future<String> startRecognition(List<int> audioStream) async {
    final serviceAccount = ServiceAccount.fromString(await rootBundle.loadString('assets/labonte-service-account.json'));
    SpeechToText speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final config = RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: 'fr-FR',
    );
    final response = await speechToText.recognize(config, audioStream);
    final text = response.results.map((r) => r.alternatives.first.transcript).join('\n');
    //log(text);
    return text;
  }

  static Future<List<int>?> getAudioStream() async {
    // Record 60 seconds of audio
    if (!await Permission.microphone.request().isGranted) {
      // Show message: "Microphone permission is required"
      return null;
    }
    final recorder = await FileRecorder.create(); //initialize
    final filePath = await recorder.record(Duration(seconds: 59)); //start recording and send filePath
    final file = File(filePath);
    return file.readAsBytes(); //For Stream: return file.openRead();
  }
}
