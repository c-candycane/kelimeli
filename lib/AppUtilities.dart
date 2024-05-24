import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'login_page.dart';

class AppUtilities {
  static const String appName = "Kelimeli";
  static const Color backgroundColor = Color.fromRGBO(31, 44, 55, 1);
  static const Color primaryButtonColor = Colors.blue;
  static const String appLogoPath = "images/kelimeli_logo.jpg";

  static const TextStyle primaryTextStyleWhite = TextStyle(
    color: Colors.white,
    fontSize: 20
  );
  static const TextStyle primaryTextStyleWhiteBold = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20
  );
  static const TextStyle primaryTextStyleWhiteSmall = TextStyle(
      color: Colors.white,
      fontSize: 14
  );
  static const TextStyle primaryTextStyleWhiteSmallItalic = TextStyle(
      color: Colors.white,
      fontStyle: FontStyle.italic,
      fontSize: 14
  );
  static const TextStyle primaryTextStyleWhiteXLarge = TextStyle(
      color: Colors.white,
      fontSize: 26
  );
  static const TextStyle primaryTextStyleBlue = TextStyle(
      color: Colors.blue,
      fontSize: 18
  );
  static const TextStyle primaryTextStyleBlueSmall = TextStyle(
      color: Colors.blue,
      fontSize: 14
  );
  static const TextStyle primaryTextStyleBlueLarge = TextStyle(
      color: Colors.blue,
      fontSize: 22
  );
  static const TextStyle primaryTextStyleBlueXLargeBold = TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
      fontSize: 26
  );
  static const TextStyle primaryTextStyleBlueItalic = TextStyle(
      color: Colors.blue,
      fontStyle: FontStyle.italic,
      fontSize: 18
  );

  static String removeSpaces(String input) {
    return input.replaceAll(' ', '');
  }


  static void showAlertDialog(String title, String message, context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(31, 44, 55, 1),
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Tamam',
                style: TextStyle(
                  color: AppUtilities.primaryButtonColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  static void showAlertDialogAndNavigate(String title, String message, String page, String pageMessage,context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(31, 44, 55, 1),
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Tamam',
                style: TextStyle(
                  color: primaryButtonColor
                ),
              ),
              onPressed: () {
                if (page == "LoginPage"){
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage(title: pageMessage)),
                        (route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  static Future<List<String>> generateSpeech(String text) async {
    FlutterTts flutterTts = FlutterTts();





    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setVolume(1.0);

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String audioFilePath = '$tempPath/${text}_audio.mp3';


    var result = await flutterTts.synthesizeToFile(text, audioFilePath,);

    if (result == 1) {

       String _audioUrl = audioFilePath;
       String _audioFileName = '${text}_audio.mp3';

       return [_audioUrl, _audioFileName];

    } else {
      print("Ses dosyası oluşturulamadı.");
      return ["null"];
    }
  }
  
}
