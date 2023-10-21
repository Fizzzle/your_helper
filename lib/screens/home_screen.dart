import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:virtual_helper/services/api_service.dart';

import '../constants/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController userInputTextEditingController =
      TextEditingController();
  final SpeechToText speechToTextInstance = SpeechToText();
  String recordedAudioString = "";
  bool isLoading = false;
  String sendText = 'Тут будет ответ';
  var testText = "Testing";

  void initalizeSpeechToText() async {
    await speechToTextInstance.initialize();

    setState(() {});
  }

  void testFunction() {
    sendText = userInputTextEditingController.text;

    userInputTextEditingController.clear();
    setState(() {});
  }

  void startListeningNow() async {
    FocusScope.of(context).unfocus();
    userInputTextEditingController.clear();

    // await speechToTextInstance.listen(onResult: onSpeechToTextResult);

    setState(() {
      speechToTextInstance.listen(onResult: (result) {
        setState(() {
          testText = result.recognizedWords;
          userInputTextEditingController.text = testText;
        });
      });
      /*
      print("Speech:");
      print(recordedAudioString);
      */
    });
  }

  void stopListeningNow() async {
    await speechToTextInstance.stop();

    setState(() {});
  }

  void onSpeechToTextResult(SpeechRecognitionResult recognitionResult) {
    recordedAudioString = recognitionResult.recognizedWords;

    setState(() {
      print("Speech Result:");
      print(recordedAudioString);
    });
  }

  @override
  void initState() {
    super.initState();

    initalizeSpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {},
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("assets/images/sound.png"),
        ),
      ),
      */
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.orangeAccent.shade100,
              Colors.deepOrange,
            ]),
          ),
        ),
        title: Image.asset(
          'assets/images/logo.png',
          width: 140,
        ),
        titleSpacing: 10,
        elevation: 14,
        actions: [
          // chat
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {},
              child: Icon(
                Icons.chat,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),

          //image
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              onTap: () {},
              child: Icon(
                Icons.image,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              // image
              Center(
                child: InkWell(
                  onTap: () {
                    speechToTextInstance.isListening
                        ? stopListeningNow()
                        : startListeningNow();
                  },
                  child: speechToTextInstance.isListening
                      ? Center(
                          child: LoadingAnimationWidget.beat(
                            size: 300,
                            color: speechToTextInstance.isListening
                                ? Colors.deepOrangeAccent
                                : isLoading
                                    ? Colors.deepOrange[400]!
                                    : Colors.deepOrangeAccent[200]!,
                          ),
                        )
                      : Image.asset('assets/images/assistant-icon.png'),
                ),
              ),
              SizedBox(
                height: 50,
              ),

              //Test
              Center(
                child: Text(
                  testText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              //textfild
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 4,
                      ),
                      child: TextField(
                        controller: userInputTextEditingController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Напиши чем я могу помочь",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),

                  // button
                  InkWell(
                    onTap: () async {
                      if (speechToTextInstance.isListening != true)
                        testFunction();
                      if (speechToTextInstance.isListening == true)
                        stopListeningNow();

                      try {
                        await ApiService.sendMessage(
                            message: userInputTextEditingController.text);
                      } catch (error) {
                        print("error $error");
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 1000,
                      ),
                      curve: Curves.bounceInOut,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.deepOrangeAccent,
                      ),
                      child: speechToTextInstance.isListening
                          ? Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            )
                          : Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 30,
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    child: Text(
                      sendText,
                      style: gptStyle,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
