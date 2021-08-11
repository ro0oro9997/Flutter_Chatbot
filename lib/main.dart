import 'dart:collection';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:highlight_text/highlight_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(MyApp());

bool isListening = false;
enum TtsState { playing, stopped }

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}





class _MyApp extends State<MyApp> {


  LinkedHashMap<String, HighlightedWord> highlightedWords = LinkedHashMap();

  late stt.SpeechToText speech;
  String promptText = "Press the button to start speaking";
  String speechText = '';
  double confidence = 1.0;

  //Voice
  //Voice Control
  FlutterTts? flutterTts;
  String language = 'en-US';
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;

  String? _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;


  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AvatarGlow(
              endRadius: 75,
              animate: isListening,
              glowColor: Colors.red,
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                child: Icon(
                  isListening ? Icons.mic : Icons.mic_none,
                ),
                onPressed: listenToSpeech,
              ),
            ),
            SizedBox(width: 5),
            FloatingActionButton(
              elevation: speechText.isNotEmpty ? 6 : 1,
              backgroundColor: speechText.isNotEmpty ? Colors.red : Colors.black12,
              child: Icon(Icons.copy_rounded),
              onPressed: textHighLight,
            )
          ],
        ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                    child: Text(
                      "Confidence level ${(confidence * 100).toStringAsFixed(1)}%",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SingleChildScrollView(
                    reverse: false,
                    padding: EdgeInsets.all(30),
                    child: Text(promptText,
                        style: TextStyle(
                            fontSize: 32,
                            color: Colors.black,
                            fontWeight: FontWeight.w400)),
                    // child: TextHighlight(
                    //   text: _promptText,
                    //   words: highlightedWords,
                    //   textStyle: TextStyle(
                    //       fontSize: 32,
                    //       color: Colors.black,
                    //       fontWeight: FontWeight.w400),
                    // ),
                  ),
                ),
              )
            ],
          ),
        )
      );
  }

  initTts() {
    flutterTts = FlutterTts();
    flutterTts!.setStartHandler(() {
      setState(() {
        print("playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts!.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts!.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }



  Future _speak() async {
    await flutterTts!.setVolume(volume);
    await flutterTts!.setSpeechRate(rate);
    await flutterTts!.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        var result = await flutterTts!.speak(_newVoiceText!);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts!.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts!.stop();
  }


  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }
  @override
  void initState() {
    super.initState();
    setState(() {
      speech = stt.SpeechToText();
      initTts();
    });
  }


  void textHighLight(){
    if(speechText.isNotEmpty){
      FlutterClipboard.copy(speechText);
    }
  }

  void listenToSpeech() async {

    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (val) {
          if(val.contains("notListening")){
            setState(() => isListening = false);
          }
          print('onStatus: $val');
        },
        onError: (val){
          setState(() => isListening = false);
          print('onError: $val');
        },

      );

      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (val) => setState(() {
            promptText = val.recognizedWords;
            speechText = val.recognizedWords;
            _newVoiceText = speechText;
            _speak();
            _stop();
            if (val.hasConfidenceRating && val.confidence > 0) {
              confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      print("Text: "+speechText);
      setState(() => isListening = false);
      speech.stop();
      _speak();
    }
  }
}
