import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/texttospeech/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;

class TextToSpeechService {
  static String buildFullTextFromMap(Map<String, dynamic> mapResult) {
    //alpha_numeric type lesson
    final keys = mapResult.entries.map((e) => e.key.toString()).toList();
    final buffer = StringBuffer();
    buffer.writeln('<speak>');
    buffer.writeln('<prosody rate="slow" pitch="+2st">');
    for (int i = 0; i < keys.length; i++) {
      buffer.write(keys[i]);
      if (i != keys.length - 1) {
        buffer.write('<break time="600ms"/> ');
      }
    }
    buffer.writeln('</prosody>');
    buffer.writeln('</speak>');
    return buffer.toString();
  }

  static String buildFullTextFromArray({
    required List arrayResult,
    required int lessonIndex,
    required DocumentSnapshot snapshot,
  }) {
    Map<String, dynamic> tableHeader = {};
    String type = snapshot['type'];
    final buffer = StringBuffer();
    if (type.toLowerCase().contains('table')) {
      tableHeader = snapshot['content'][0];
      //log(tableHeader.toString());
    }
    buffer.writeln('<speak>');
    buffer.writeln('<prosody rate="slow" pitch="+2st">');
    //Only speak the instructions for the first screen incase of multi-part screens
    if (type == 'tree' || arrayResult.first.toString() == (snapshot['content'] as List).first.toString()) {
      if ((snapshot.data() as Map<String, dynamic>).containsKey('instruction')) {
        String instruction = snapshot['instruction'];
        instruction = instruction.replaceAllMapped(RegExp(r'\((.*?)\)'), (match) {
          String inside = match.group(1)!;
          String replaced = inside.replaceAllMapped(RegExp(r'\bTypes\b'), (m) => 'Taïps');
          return '($replaced)';
        });
        buffer.writeln('$instruction<break time="1s"/>');
      }
      if ((snapshot.data() as Map<String, dynamic>).containsKey('note')) {
        buffer.writeln('${snapshot['note']}<break time="1s"/>');
      }
      if ((snapshot.data() as Map<String, dynamic>).containsKey('example')) {
        buffer.writeln('${snapshot['example']['title']}<break time="1s"/>${snapshot['example']['body']}<break time="1s"/>');
      }
    }
    for (int i = 0; i < arrayResult.length; i++) {
      var entry = arrayResult[i];
      String frenchWord = '';
      if (entry is String) {
        //list or tree type lesson
        frenchWord = entry;
        if (lessonIndex == 1 && snapshot.id == '2') {
          //Spelling of names
          List<String> alphabets = frenchWord.split('');
          frenchWord = '${alphabets.join('<break time="600ms"/>')} — ${alphabets.join('')}';
        }
        //fix for lesson 7 english part issues
        List<String> parts = frenchWord.split('\u2013'); //dash(U+2013) not hyphen(U+002D)
        //Pattern to match a bracket an everything inside it
        //RegExp bracketPattern = RegExp(r'\s*\([^)]*\)');
        //Pattern to match a bracket that contains atleast a number and alphabeth
        final bracketPattern = RegExp(r'\s*\((?=[^)]*\d)(?=[^)]*[A-Za-z])[^)]*\)');
        if (bracketPattern.hasMatch(frenchWord)) {
          //speak only french part
          frenchWord = parts[0].replaceAll(bracketPattern, '');
        }
        // Pattern to match a date like "14/ 4/ 2016"
        RegExp datePattern = RegExp(r'\d{1,2}/\s*\d{1,2}/\s*\d{4}');
        if (datePattern.hasMatch(frenchWord)) {
          //speak only french part
          frenchWord = parts[1];
        }
      } else if (entry is Map<String, dynamic>) {
        if (type.toLowerCase().contains('image')) {
          if (type == 'image') {
            if (entry.entries.toList()[1].key == 'image') {
              entry = Map.fromEntries(entry.entries.toList().reversed);
            }
            String key = entry.keys.last.toString();
            String value = entry.values.last.toString();
            /*if (key.length == 1) {
              key = key.replaceFirst('Y', 'wai').replaceFirst('Z', 'zed'); //fix for alphabeths screen
            }*/
            if (key != '*' && key.length == 1) {
              frenchWord = '$key<break time="600ms"/>$value';
            } else if (key != '*') {
              frenchWord = '<lang xml:lang="en-US">$key</lang><break time="600ms"/>$value';
            } else {
              frenchWord = value;
            }
          } else if (type == 'image-no-container') {
            if (entry.entries.toList()[1].key == 'image') {
              entry = Map.fromEntries(entry.entries.toList().reversed);
            }
            frenchWord = '${entry.values.last.toString()}';
          } else {
            //Pattern to match a bracket an everything inside it
            RegExp bracketPattern = RegExp(r'\s*\([^)]*\)');
            List<String> orderedKeys = List<String>.from(entry.keys);
            orderedKeys.remove('image');
            orderedKeys.remove('or');
            orderedKeys.insert(1, 'image');
            orderedKeys.insert(2, 'or');
            frenchWord =
                '${orderedKeys[0]}<break time="1s"/><lang xml:lang="en-US">${entry[orderedKeys[0]].toString().replaceAll(bracketPattern, '')}</lang>';
            if (entry.keys.contains('or')) {
              frenchWord = frenchWord +
                  '<break time="1s"/>Or<break time="1s"/>${entry['or'].entries.toList()[0].key}<break time="1s"/><lang xml:lang="en-US">${entry['or'].entries.toList()[0].value.toString().replaceAll(bracketPattern, '')}</lang>';
            }
          }
        } else if (type.toLowerCase().contains('table')) {
          List<String> orderedKeys = List<String>.from(entry.keys);
          if (type == '5C-table') {
            //5C
            if (orderedKeys.contains('m') &&
                orderedKeys.contains('f') &&
                orderedKeys.contains('mp') &&
                orderedKeys.contains('fp') &&
                orderedKeys.contains('meaning')) {
              orderedKeys = ['m', 'f', 'mp', 'fp', 'meaning']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord =
                    '${entry[orderedKeys[0]]}<break time="1s"/>${tableHeader[orderedKeys[1]]}<break time="600ms"/>${entry[orderedKeys[1]]}<break time="1s"/>${tableHeader[orderedKeys[2]]}<break time="600ms"/>${entry[orderedKeys[2]]}<break time="1s"/>${tableHeader[orderedKeys[3]]}<break time="600ms"/>${entry[orderedKeys[3]]}<break time="1s"/><lang xml:lang="en-US">${tableHeader[orderedKeys[4]]}<break time="600ms"/>${entry[orderedKeys[4]]}</lang>';
              }
            } else if (orderedKeys.contains('en') &&
                orderedKeys.contains('fr') &&
                orderedKeys.contains('mas') &&
                orderedKeys.contains('fem') &&
                orderedKeys.contains('lang')) {
              orderedKeys = ['en', 'fr', 'mas', 'fem', 'lang']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord =
                    '<lang xml:lang="en-US">${entry[orderedKeys[0]]}.</lang><break time="1s"/>${tableHeader[orderedKeys[1]]}<break time="600ms"/>${entry[orderedKeys[1]]}.<break time="1s"/>${tableHeader[orderedKeys[2]]}<break time="600ms"/>${entry[orderedKeys[2]]}.<break time="1s"/>${tableHeader[orderedKeys[3]]}<break time="600ms"/>${entry[orderedKeys[3]]}.<break time="1s"/>${tableHeader[orderedKeys[4]]}<break time="600ms"/>${entry[orderedKeys[4]]}.';
              }
            }
          } else if (type == '4C-table') {
            //4C
            if (orderedKeys.contains('en') && orderedKeys.contains('mas') && orderedKeys.contains('fem') && orderedKeys.contains('plu')) {
              orderedKeys = ['en', 'mas', 'fem', 'plu']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord =
                    '<lang xml:lang="en-US">${entry[orderedKeys[0]]}</lang><break time="1s"/>${tableHeader[orderedKeys[1]]}<break time="600ms"/>${entry[orderedKeys[1]]}<break time="1s"/>${tableHeader[orderedKeys[2]]}<break time="600ms"/>${entry[orderedKeys[2]]}<break time="1s"/>${tableHeader[orderedKeys[3]]}<break time="600ms"/>${entry[orderedKeys[3]]}';
              }
            } else if (orderedKeys.contains('m') && orderedKeys.contains('mp') && orderedKeys.contains('f') && orderedKeys.contains('fp')) {
              orderedKeys = ['m', 'mp', 'f', 'fp']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord =
                    '${entry[orderedKeys[0]]}.<break time="1s"/>${tableHeader[orderedKeys[1]]}<break time="600ms"/>${entry[orderedKeys[1]]}.<break time="1s"/>${tableHeader[orderedKeys[2]]}<break time="600ms"/>${entry[orderedKeys[2]]}.<break time="1s"/>${tableHeader[orderedKeys[3]]}<break time="600ms"/>${entry[orderedKeys[3]]}.';
              }
            }
          } else if (type == '3C-table') {
            //3C
            if (orderedKeys.contains('pho') && orderedKeys.contains('ex') && orderedKeys.contains('clc')) {
              orderedKeys = ['pho', 'ex', 'clc', 'phoSound']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord =
                    '<emphasis>${entry[orderedKeys[3]]}</emphasis><break time="1s"/>${tableHeader[orderedKeys[1]]}<break time="600ms"/>${entry[orderedKeys[1]]}';
              }
            } else if (orderedKeys.contains('mas') && orderedKeys.contains('fem') && orderedKeys.contains('plu')) {
              orderedKeys = ['mas', 'fem', 'plu']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord =
                    '${entry[orderedKeys[0]]}<break time="1s"/>${tableHeader[orderedKeys[1]]}<break time="600ms"/>${entry[orderedKeys[1]]}<break time="1s"/>${tableHeader[orderedKeys[2]]}<break time="600ms"/>${entry[orderedKeys[2]]}';
              }
            } else if (orderedKeys.contains('mas') && orderedKeys.contains('fem') && orderedKeys.contains('meaning')) {
              orderedKeys = ['mas', 'fem', 'meaning']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord =
                    '${entry[orderedKeys[0]]}<break time="1s"/>${tableHeader[orderedKeys[1]]}<break time="600ms"/>${entry[orderedKeys[1]]}<break time="1s"/>${tableHeader[orderedKeys[2]]}<break time="600ms"/><lang xml:lang="en-US">${entry[orderedKeys[2]]}</lang>';
              }
            }
          } else {
            //2C
            if (orderedKeys.contains('pho') && orderedKeys.contains('ex')) {
              orderedKeys = ['pho', 'ex', 'phoSound']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord =
                    '<emphasis>${entry[orderedKeys[2]]}</emphasis><break time="1s"/>${tableHeader[orderedKeys[1]]}<break time="600ms"/>${entry[orderedKeys[1]]}';
              }
            } else if (orderedKeys.contains('fr') && orderedKeys.contains('en')) {
              orderedKeys = ['fr', 'en']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord = '${entry[orderedKeys[0]]}.<break time="1s"/><lang xml:lang="en-US">${entry[orderedKeys[1]]}</lang>';
              }
            } else if (orderedKeys.contains('12h') && orderedKeys.contains('24h')) {
              orderedKeys = ['12h', '24h']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord =
                    '${entry[orderedKeys[0]]}<break time="1s"/><lang xml:lang="en-US">is equivalent in twenty four hours time to</lang><break time="1s"/>${entry[orderedKeys[1]]}';
              }
            } else if (orderedKeys.contains('24h') && orderedKeys.contains('meaning')) {
              orderedKeys = ['24h', 'meaning']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord =
                    '${entry[orderedKeys[0]]}<break time="1s"/><lang xml:lang="en-US">${tableHeader[orderedKeys[1]]}<break time="600ms"/>${entry[orderedKeys[1]]}</lang>';
              }
            } else if (orderedKeys.contains('suj') && orderedKeys.contains('con')) {
              orderedKeys = ['suj', 'con']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord = '${entry[orderedKeys[0]]}<break time="1s"/><lang xml:lang="en-US">${entry[orderedKeys[1]]}</lang>';
              }
            } else if (orderedKeys.contains('sin') && orderedKeys.contains('plu')) {
              orderedKeys = ['sin', 'plu']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord = '${entry[orderedKeys[0]]}<break time="1s"/>${entry[orderedKeys[1]]}';
              }
            } else if (orderedKeys.contains('fr') && orderedKeys.contains('ex')) {
              orderedKeys = ['fr', 'ex']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord = '${entry[orderedKeys[0]]}<break time="1s"/>${tableHeader[orderedKeys[1]]}<break time="600ms"/>${entry[orderedKeys[1]]}';
              }
            } else if (orderedKeys.contains('mas') && orderedKeys.contains('fem')) {
              orderedKeys = ['mas', 'fem']; //re-order
              if (tableHeader.values.toString() != entry.values.toString()) {
                frenchWord =
                    '${entry[orderedKeys[0]]}.<break time="1s"/>${tableHeader[orderedKeys[1]]}<break time="600ms"/>${entry[orderedKeys[1]]}.';
              }
            }
          }
        } else if (type.toLowerCase() == 'conversation') {
          frenchWord = '${entry['person1']}<break time="1s"/>${entry['person2']}';
        } else if (type.toLowerCase() == 'sentence-meaning') {
          //Pattern to match date patterns like 1st,2nd,3rd,4th,2025
          RegExp datePattern2 = RegExp(r'\b\d+(st|nd|rd|th)?\b');
          //Pattern to match spaces
          RegExp extraSpaces = RegExp(r'\s{2,}');
          String answer = entry['answer'].toString().replaceAll(datePattern2, '').replaceAll(extraSpaces, ' ').trim();
          frenchWord = '${entry['question']}<break time="1s"/>$answer';
        } else {
          //no type match
          frenchWord = '';
          //frenchWord = entry.values.first.toString();
        }
      } else {
        continue; // skip invalid entries
      }
      if (type == 'image' && lessonIndex == 1 && snapshot.id == '3') {
        //Dont correct 'I' for 'I-Igname' screen.
        final matchY = RegExp(r'\bY\b');
        frenchWord = frenchWord.replaceAll(matchY, 'Igrek');
      } else if (type == 'list' && lessonIndex == 1 && snapshot.id == '2') {
        //Dont correct 'I' for 'Sabrina' etc.
        frenchWord = frenchWord;
      } else {
        //Correct 'I'
        final matchI = RegExp(r'\bI\b', caseSensitive: false);
        frenchWord = frenchWord.replaceAll(matchI, 'aï');
      }

      buffer.write(frenchWord);
      if (i != arrayResult.length - 1) {
        buffer.write('.<break time="1s"/>');
      }
    }
    buffer.writeln('</prosody>');
    buffer.writeln('</speak>');
    return buffer.toString();
  }

  static Future<Uint8List> synthesizeSpeech(String text) async {
    try {
      final jsonStr = await rootBundle.loadString('assets/labonte-service-account.json');
      final serviceAccount = ServiceAccountCredentials.fromJson(jsonStr);
      final scopes = [TexttospeechApi.cloudPlatformScope];
      final client = await clientViaServiceAccount(serviceAccount, scopes);
      final ttsApi = TexttospeechApi(client);
      final input = SynthesisInput(ssml: text);
      final voice = VoiceSelectionParams(
          name: 'fr-FR-Wavenet-A', // Female, high-pitched, clear//'fr-FR-Wavenet-A'
          languageCode: 'fr-FR');
      final audioConfig = AudioConfig(
        audioEncoding: 'MP3',
        speakingRate: 0.75, // slower (default is 1.0)
        pitch: 2.0, // slightly higher pitch for friendly tone
      );
      final request = SynthesizeSpeechRequest(
        input: input,
        voice: voice,
        audioConfig: audioConfig,
      );
      final response = await ttsApi.text.synthesize(request);
      client.close();
      return base64.decode(response.audioContent!);
    } catch (e) {
      throw e.toString();
    }
  }

  /*static Future<Uint8List> generateAudioFromText(String text) async {
    final response = await http.post(
      Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM'),
      headers: {
        'accept': 'audio/mpeg',
        'xi-api-key': dotenv.env['ELEVEN_LABS_API_KEY']!,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "text": text,
        "model_id": "eleven_multilingual_v2",
        "voice_settings": {
          "stability": 0.3,
          "similarity_boost": 0.75,
        }
      }),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      print('❌ Eleven Labs error: ${response.statusCode}');
      print('❌ Response body: ${response.body}');
      throw Exception('Failed to generate audio');
    }
  }*/
}
