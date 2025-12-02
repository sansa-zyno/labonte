import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String TTS_INPUT =
      'J’espère que vous allez bien. Je m’appelle [Your Name] et je suis développeur d’applications mobiles spécialisé en [iOS/Android/Flutter/React Native]. J’ai récemment découvert [leur entreprise/projet] et j’ai été particulièrement impressionné par [mentionner un aspect spécifique de leur travail, comme une application qu’ils ont développée ou leur mission]. Je me permets donc de vous contacter afin de savoir si votre équipe recherche actuellement des développeurs mobiles pour accompagner vos projets en cours ou à venir. Grâce à mon expérience dans la création d’applications performantes et faciles à utiliser, je serais ravi d’échanger avec vous sur la manière dont je pourrais contribuer à votre équipe. Seriez-vous disponible pour une brève discussion à ce sujet ? J’attends votre retour avec impatience. Cordialement, [Your Name]';
  FlutterTts _flutterTts = FlutterTts();
  List<Map> _voices = [];
  Map? _currentVoice;
  int? _currentwordStart, _currentwordEnd;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initTTS();
  }

  void initTTS() {
    _flutterTts.setProgressHandler((text, start, end, word) {
      //log('text   ' + text);
      // log('start   ' + start.toString());
      // log('end   ' + end.toString());
      //log('word   ' + word);
      setState(() {
        _currentwordStart = start;
        _currentwordEnd = end;
      });
    });
    _flutterTts.getVoices.then((data) {
      try {
        _voices = List<Map>.from(data);

        setState(() {
          //_voices = _voices.where((_voice) => _voice['name'].toString().contains('en')).toList();
          _voices = _voices.where((_voice) => _voice['name'].toString().startsWith('fr')).toList();
          _currentVoice = _voices.first;
          setVoice(_currentVoice!);
        });
        log(_voices.toString());
      } catch (e) {
        log(e.toString());
      }
    });
  }

  void setVoice(Map voice) {
    _flutterTts.setVoice({'name': voice['name'], 'locale': voice['locale']});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _flutterTts.speak(TTS_INPUT);
        },
        child: const Icon(Icons.speaker_phone),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _speakerSelector(),
        RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 20,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(text: TTS_INPUT.substring(0, _currentwordStart)), //Shows all text initially but start at first word when TTS begins
                  if (_currentwordStart != null)
                    TextSpan(
                        text: TTS_INPUT.substring(_currentwordStart!, _currentwordEnd),
                        style: const TextStyle(color: Colors.white, backgroundColor: Colors.purpleAccent)),
                  if (_currentwordEnd != null) TextSpan(text: TTS_INPUT.substring(_currentwordEnd!)),
                ])),
      ],
    ));
  }

  Widget _speakerSelector() {
    return DropdownButton(
        value: _currentVoice,
        items: _voices
            .map((_voice) => DropdownMenuItem(
                  value: _voice,
                  child: Text(_voice['name']),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _currentVoice = value;
            setVoice(_currentVoice!);
          });
        });
  }
}
