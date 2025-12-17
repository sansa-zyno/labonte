import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:french_app/services/stt_service.dart';

enum STTState { listening, processing, finished, error }

class SpeechToTextProvider extends ChangeNotifier {
  STTState sttState = STTState.finished;

  Future<String?> startSpeechToText() async {
    try {
      sttState = STTState.listening;
      notifyListeners();
      final audioStream = await SpeechToTextService.getAudioStream();
      if (audioStream != null) {
        sttState = STTState.processing;
        notifyListeners();
        String result = await SpeechToTextService.startRecognition(audioStream);
        sttState = STTState.finished;
        notifyListeners();
        return result;
      } else {
        sttState = STTState.finished;
        notifyListeners();
        return null;
      }
    } catch (e) {
      log(e.toString());
      sttState = STTState.error;
      notifyListeners();
      return null;
    }
  }
}
