import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:nexus/feature_box.dart';
import 'package:nexus/openai_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'core/constants/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String greeting = "";
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = "";
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl = "";
  bool isDownloading = false;
  bool isSharing = false;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
    getGreeting();
    setState(() {});
  }

  @override
  void dispose() {
    speechToText.stop();
    flutterTts.stop();
    super.dispose();
  }

  void getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      greeting = "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      greeting = "Good Afternoon";
    } else {
      greeting = "Good Evening";
    }
  }

  Future<void> initSpeechToText() async {
    final isAvailable = await speechToText.initialize();
    setState(() {});
    print("isAvailable: $isAvailable");
  }

  /// Each time to start a speech recognition session
  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
      print('lastWords: $lastWords');
    });
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  Future<bool> downloadImage(String imageUrl) async {
    isDownloading = true;
    setState(() {});
    // Check and request the necessary permissions
    var status = await Permission.storage.request();
    if (!status.isGranted && !status.isLimited) {
      print('Permission denied');
      // return false;
    }

    try {
      // Send an HTTP GET request to the image URL
      var response = await http.get(Uri.parse(imageUrl));

      // Get the temporary directory path
      var directory = await getApplicationDocumentsDirectory();
      print("directory: $directory");
      var now = DateTime.now();
      var filePath =
          '${directory.path}/image_${now.millisecondsSinceEpoch}.png';
      print("filePath: $filePath");

      // Write the image data to the file
      await File(filePath).writeAsBytes(response.bodyBytes);

      print('Image downloaded successfully: $filePath');
      isDownloading = false;
      setState(() {});
      return true;
    } catch (e) {
      print('Failed to download image: $e');
      isDownloading = false;
      setState(() {});
      return false;
    }
  }

  Future<void> shareImage(String imageUrl) async {
    isSharing = true;
    setState(() {});

    try {
      var response = await http.get(Uri.parse(imageUrl));
      final directory = await getTemporaryDirectory();
      final now = DateTime.now();
      final filePath =
          '${directory.path}/image_${now.millisecondsSinceEpoch}.png';
      await File(filePath).writeAsBytes(response.bodyBytes);
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Image generated from $kAppName',
        subject: "Image generated from $kAppName",
      );
      isSharing = false;
      setState(() {});
    } catch (e) {
      print('Failed to share image: $e');
      isSharing = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: BounceInDown(
          child: const Text(kAppName),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            print("Menu Clicked");
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Virtual Assistant Picture
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(Images.virtualAssistant),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Chat Bubble
            FadeInRight(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40)
                    .copyWith(top: 30),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Pallete.borderColor,
                  ),
                  borderRadius: BorderRadius.circular(20).copyWith(
                    topLeft: const Radius.circular(0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    generatedContent == null
                        ? "$greeting, what can I help you with?"
                        : generatedContent!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null && generatedImageUrl!.isNotEmpty)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        generatedImageUrl!,
                        filterQuality: FilterQuality.low,
                        loadingBuilder: (context, child, loadingProgress) {
                          print("loadingProgress: $loadingProgress");
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print("error: $error");
                          return const Center(
                            child: Text("Error loading image"),
                          );
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // download button
                      isDownloading
                          ? const CircularProgressIndicator()
                          : InkWell(
                              onTap: () async {
                                var downloaded =
                                    await downloadImage(generatedImageUrl!);
                                if (downloaded && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("Image downloaded successfully"),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Failed to download image"),
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Ink(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Pallete.blackColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.download,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Download",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      // Share button
                      isSharing
                          ? const CircularProgressIndicator()
                          : InkWell(
                              onTap: () async {
                                await shareImage(generatedImageUrl!);
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Ink(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Pallete.blackColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.share,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Share",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            SlideInLeft(
              child: Container(
                margin: const EdgeInsets.only(top: 10, left: 22),
                padding: const EdgeInsets.all(10),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Here are a few features",
                  style: Theme.of(context).textTheme.bodyMedium!,
                ),
              ),
            ),
            //Suggestions
            Column(
              children: [
                SlideInLeft(
                  delay: Duration(milliseconds: start),
                  child: const FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: "ChatGPT",
                    bodyText:
                        "A smarter way to stay organized and informed with ChatGPT",
                  ),
                ),
                SlideInRight(
                  delay: Duration(milliseconds: start + delay),
                  child: const FeatureBox(
                    color: Pallete.secondSuggestionBoxColor,
                    headerText: "Dall-E",
                    bodyText:
                        "Get inspired and stay creative with your personal assistant powered by Dall-E",
                  ),
                ),
                SlideInLeft(
                  delay: Duration(milliseconds: start + (delay * 2)),
                  child: const FeatureBox(
                    color: Pallete.thirdSuggestionBoxColor,
                    headerText: "Smart Voice Assistant",
                    bodyText:
                        "Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT",
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + (delay * 3)),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              await stopListening();
              await Future.delayed(const Duration(seconds: 1), () async {
                final speech = await openAIService.isArtPromptAPI(lastWords);
                print("speech: $speech");
                if (speech.contains("https")) {
                  generatedImageUrl = speech;
                  generatedContent = null;
                  setState(() {});
                } else {
                  generatedImageUrl = null;
                  generatedContent = speech;
                  setState(() {});
                  if (generatedContent != null &&
                      !generatedContent!.contains("Exception")) {
                    await systemSpeak(speech);
                  }
                }
              });
            } else {
              await initSpeechToText();
            }
          },
          child: Icon(
            speechToText.isListening ? Icons.stop : Icons.mic,
          ),
        ),
      ),
    );
  }
}
