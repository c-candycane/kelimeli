import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kelimeli/add_word.dart';
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
  bool isAdmin = false;

  void initState() {
    super.initState();
    fetchUsername();
    checkAdmin();
  }

  void fetchUsername() async {
    username = await UserUtilities.getUserName();
    setState(() {});
  }

  void checkAdmin() async {
    isAdmin = await UserUtilities.isCurrentUserAdmin();
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
              onPressed: isAdmin
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddWordScreen()),
                );
              }
                  : () {
                AppUtilities.showAlertDialog("İzin Hatası", "Kelime ekleme yetkiniz yok.", context);
              },
              icon: Icon(Icons.add),
              label: Text('Kelime Ekle'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (isAdmin) {
                      return Colors.blue; // Admin ise buton rengi mavi
                    }
                    return Colors.grey; // Admin değilse buton rengi gri
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Sınav ekranına yönlendirme
              },
              icon: Icon(Icons.quiz),
              label: Text('Sınav Yap'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Analiz ekranına yönlendirme
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
