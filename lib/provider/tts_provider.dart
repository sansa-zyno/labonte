//import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:french_app/helpers/tts_helper.dart';
import 'package:french_app/services/tts_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

enum AudioPlayerState { stopped, playing, paused }

class TextToSpeechProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  //Uint8List? currentAudioBytes;
  //String? currentText;
  AudioPlayerState playerState = AudioPlayerState.stopped;
  bool loading = false;

  TextToSpeechProvider() {}

  Future<void> playFullAudio({required dynamic result, required DocumentSnapshot snapshot, required String filename}) async {
    try {
      String text = '';
      if (result is String) {
        //html type lesson
        text = result.replaceAll('&nbsp;', '');
      } else if (result is Map<String, dynamic>) {
        text = TextToSpeechService.buildFullTextFromMap(result);
      } else {
        text = TextToSpeechService.buildFullTextFromArray(arrayResult: result, snapshot: snapshot);
      }
      text = TextToSpeechHelper.preprocessForFrenchTTS(text);
      //final appDocDir = await getApplicationDocumentsDirectory();
      final appDocDir = await getTemporaryDirectory();
      loading = true;
      notifyListeners();
      //log(filename);
      final file = File('${appDocDir.path}/$filename.mp3');
      // ✅ If file already exists, just play it
      if (await file.exists()) {
        await _audioPlayer.stop(); //important
        loading = false;
        playerState = AudioPlayerState.playing;
        notifyListeners();
        await _audioPlayer.setFilePath(file.path);
        await _audioPlayer.play();
        playerState = AudioPlayerState.stopped;
        notifyListeners();
      } else {
        final audioBytes = await TextToSpeechService.synthesizeSpeech(text);
        await file.writeAsBytes(audioBytes);
        loading = false;
        playerState = AudioPlayerState.playing;
        notifyListeners();
        await _audioPlayer.setFilePath(file.path);
        await _audioPlayer.play();
        playerState = AudioPlayerState.stopped;
        notifyListeners();
      }
    } catch (e) {
      //log(e.toString());
      loading = false;
      notifyListeners();
    }
  }

  Future<void> playPronunciation(String text) async {
    final filename = TextToSpeechHelper.textToFileName(text);
    //log(filename);
    //final appDocDir = await getApplicationDocumentsDirectory();
    final appDocDir = await getTemporaryDirectory();
    loading = true;
    notifyListeners();
    final file = File('${appDocDir.path}/$filename.mp3');
    // ✅ If file already exists, just play it
    if (await file.exists()) {
      await _audioPlayer.stop(); //important
      loading = false;
      playerState = AudioPlayerState.playing;
      notifyListeners();
      await _audioPlayer.setFilePath(file.path);
      await _audioPlayer.play();
      playerState = AudioPlayerState.stopped;
      notifyListeners();
    } else {
      final audioBytes = await TextToSpeechService.synthesizeSpeech(text);
      await file.writeAsBytes(audioBytes);
      loading = false;
      playerState = AudioPlayerState.playing;
      notifyListeners();
      await _audioPlayer.stop();
      await _audioPlayer.setFilePath(file.path);
      await _audioPlayer.play();
      playerState = AudioPlayerState.stopped;
    }
  }

  Future<void> repeatFullAudio({required String filename}) async {
    //final appDocDir = await getApplicationDocumentsDirectory();
    final appDocDir = await getTemporaryDirectory();
    final filePath = '${appDocDir.path}/$filename.mp3';
    final file = File(filePath);
    if (await file.exists()) {
      await _audioPlayer.stop(); //important
      playerState = AudioPlayerState.playing;
      notifyListeners();
      await _audioPlayer.setFilePath(file.path);
      await _audioPlayer.play();
      playerState = AudioPlayerState.stopped;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      playerState = AudioPlayerState.paused;
      notifyListeners();
    } catch (e) {
      //log(e.toString());
    }
  }

  Future<void> resume() async {
    try {
      playerState = AudioPlayerState.playing;
      notifyListeners();
      await _audioPlayer.play();
      playerState = AudioPlayerState.stopped;
      notifyListeners();
    } catch (e) {
      //log(e.toString());
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      // currentAudioBytes = null;
      playerState = AudioPlayerState.stopped;
      notifyListeners();
    } catch (e) {
      //log(e.toString());
    }
  }

  /*Future<void> playFullAudio({required dynamic result, required DocumentSnapshot snapshot}) async {
    try {
      loading = true;
      notifyListeners();
      String text = '';
      if (result is String) {
        //html type lesson
        text = result;
      } else if (result is Map<String, dynamic>) {
        //alpha_numeric type lesson
        text = TextToSpeechService.buildFullTextFromMap(result);
      } else {
        //others
        text = TextToSpeechService.buildFullTextFromArray(arrayResult: result, snapshot: snapshot);
      }
      // Only re-generate if it's a different word
      if (text != currentText || currentAudioBytes == null) {
        currentText = text;
        currentAudioBytes = await TextToSpeechService.synthesizeSpeech(text);
      }
      final source = AudioSource.uri(Uri.dataFromBytes(currentAudioBytes!, mimeType: 'audio/mpeg'));
      loading = false;
      playerState = AudioPlayerState.playing;
      notifyListeners();
      await _audioPlayer.setAudioSource(source);
      await _audioPlayer.play();
      playerState = AudioPlayerState.stopped;
      notifyListeners();
    } catch (e) {
      log(e.toString());
      loading = false;
      notifyListeners();
    }
  }*/

  /*if(currentAudioBytes != null) {
      final source = AudioSource.uri(
        Uri.dataFromBytes(currentAudioBytes!, mimeType: 'audio/mpeg'),
      );
      await _audioPlayer.stop(); //important
      playerState = AudioPlayerState.playing;
      notifyListeners();
      await _audioPlayer.setAudioSource(source);
      await _audioPlayer.play();
      playerState = AudioPlayerState.stopped;
      notifyListeners();
    }*/

  /*static Future<void> playPronunciation(String frenchWord) async {
    // Only re-generate if it's a different word
    if (_lastFrenchWord != frenchWord || _lastAudioBytes == null) {
      _lastFrenchWord = frenchWord;
      _lastAudioBytes = await synthesizeSpeech(frenchWord);
    }

    // Play the cached audio
    final source = AudioSource.uri(
      Uri.dataFromBytes(_lastAudioBytes!, mimeType: 'audio/mpeg'),
    );

    await _audioPlayer.setAudioSource(source);
    await _audioPlayer.play();
  }*/

  @override
  void dispose() {
    debugPrint("Disposing TextToSpeechProvider");
    _audioPlayer.dispose();
    super.dispose();
  }
}
