//import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';

class FileRecorder {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  static Future<FileRecorder> create() async {
    final recorder = FileRecorder();
    await recorder._recorder.openRecorder();
    return recorder;
  }

  Future<String> record(Duration duration) async {
    // 1. Confirm WAV support
    //final supported = await _recorder.isEncoderSupported(Codec.pcm16WAV);
    //log("🎧 WAV supported: $supported");
    // 2. Start recording to a known filename in temp directory
    final dir = await getTemporaryDirectory();
    final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.wav';
    final fullPath = '${dir.path}/$fileName';
    //log("📍 Recording path: $fullPath");
    await _recorder.startRecorder(
      toFile: fullPath,
      codec: Codec.pcm16WAV,
      numChannels: 1,
      sampleRate: 16000,
    );
    // 3. Wait for user-specified duration
    await Future.delayed(duration);
    // 4. Stop recording and get final path
    final stoppedPath = await _recorder.stopRecorder();
    //log("🛑 Stopped recording at: $stoppedPath");
    // 5. Confirm file size
    final file = File(stoppedPath!);
    final size = await file.length();
    //log("📦 Final file size: $size bytes");
    if (size < 1000) {
      // log("⚠️ File likely silent or too short.");
    }
    return stoppedPath;
  }

  Future<void> dispose() async {
    await _recorder.closeRecorder();
  }
}
