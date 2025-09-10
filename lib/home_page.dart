import 'package:flutter/material.dart';
import 'package:voice_assistent/feature_box.dart';
import 'package:voice_assistent/pallete.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistent/open_ai_services.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final geminiService = GeminiService();
  String responseText = '';
  String? responseImage;

  final speechToText = SpeechToText();
  var lastWords = '';
  @override
  void initState() {
    super.initState();
    initSpeechToText();
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});

    if (lastWords.isNotEmpty) {
      final res = await geminiService.handlePrompt(lastWords);

      setState(() {
        if (res.startsWith("data:image/png;base64,")) {
          responseImage = res;
          responseText = '';
        } else {
          responseText = res;
          responseImage = null;
        }
      });
    }
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Keuu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: Icon(Icons.menu),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Pictrure
            Center(
              child: Container(
                height: 120,
                width: 120,
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Pallete.assistantCircleColor,
                ),
                child: ClipOval(
                  child: Image(
                    image: AssetImage('assets/images/assistent.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // first chat
            IntrinsicWidth(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 26).copyWith(top: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    20,
                  ).copyWith(topLeft: Radius.zero),
                  border: Border.all(color: const Color.fromARGB(255, 2, 2, 2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: responseImage != null
                      ? Image.memory(
                          base64Decode(responseImage!.split(",").last),
                          fit: BoxFit.cover,
                        )
                      : Text(
                          responseText.isEmpty
                              ? 'Good morning, What task I can do for you?'
                              : responseText,
                          style: TextStyle(
                            fontFamily: 'Cera_pro',
                            fontSize: 25,
                            color: Pallete.mainFontColor,
                          ),
                        ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ).copyWith(top: 15),
              child: Align(
                alignment: AlignmentGeometry.topLeft,
                child: Text(
                  'Hear are a few feature\'s',
                  style: TextStyle(
                    fontFamily: 'Cera_pro',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            FeatureBox(
              color: Pallete.firstSuggestionBoxColor,
              heading: 'ChatGPT',
              description:
                  'A Smarter way to stay orgnized and informed with ChatGPT.',
            ),
            FeatureBox(
              color: Pallete.secondSuggestionBoxColor,
              heading: 'Dell-E',
              description:
                  'Get inspired and stay creative eith your personal assistent powered by Dell-E.',
            ),
            FeatureBox(
              color: Pallete.thirdSuggestionBoxColor,
              heading: 'Smart Voice Assistent',
              description:
                  'Get the best of both worlds with a voice assistent powered by Dell-E and ChatGPT.',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
          } else if (speechToText.isListening) {
            await stopListening();
          } else {
            initSpeechToText();
          }
        },
        child: Icon(Icons.mic),
      ),
    );
  }
}
