import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kelimeli/add_word.dart';
import 'package:kelimeli/analysis_page.dart';
import 'package:kelimeli/quiz_page.dart';
import 'package:kelimeli/user_page.dart';

import 'AppUtilities.dart';
import 'FirebaseUtilities.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class mainScreen extends StatefulWidget {
  const mainScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<mainScreen> createState() => _mainScreenState();
}

class _mainScreenState extends State<mainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String username = "";

  void initState() {
    super.initState();
    fetchUsername();

  }

  void fetchUsername() async {
    username = await UserUtilities.getUserName();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUtilities.backgroundColor,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserPage()),
            );
          },
          child: Row(
            children: [
              Image.asset(
                AppUtilities.appLogoPath,
                height: 50,
                width: 50,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppUtilities.appName),
                  Text(
                    "$username",
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddWordScreen()),
                );
              }
               ,
              icon: Icon(Icons.add),
              label: Text('Kelime Ekle'),
              style: ButtonStyle(

              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizPage()),
                );
              },
              icon: Icon(Icons.quiz),
              label: Text('Sınav Yap'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnalysisPage()),
                );
              },
              icon: Icon(Icons.analytics),
              label: Text('Analiz'),
            ),
          ],
        ),
      ),
    );
  }
}
