import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kelimeli/info_screen.dart';
import 'AppUtilities.dart';
import 'FirebaseUtilities.dart';

import 'profile_edit_page.dart';


class ErrorReportingPopup extends StatefulWidget {
  final String senderUsername;
  final String senderMail;
  ErrorReportingPopup({required this.senderUsername, required this.senderMail});

  @override
  _ErrorReportingPopupState createState() => _ErrorReportingPopupState();
}

class _ErrorReportingPopupState extends State<ErrorReportingPopup> {
  TextEditingController _errorMessageController = TextEditingController();

  void _sendErrorMessage() {
    String errorMessage = _errorMessageController.text.trim();
    if (errorMessage.isNotEmpty) {
      // Firebase'e hata mesajını ve diğer bilgileri kaydetme
      FirebaseFirestore.instance.collection('errorMessages').add({
        'message': errorMessage,
        'senderName': widget.senderUsername,
        'senderMail': widget.senderMail,
        'timestamp': Timestamp.now(),
      });

      // Popup'ı kapat
      Navigator.of(context).pop();
    } else {
      // Hata mesajı boşsa kullanıcıyı uyar
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata!'),
            content: Text('Lütfen bir hata mesajı girin.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppUtilities.backgroundColor,
      title: Text('Hata Bildir', style: AppUtilities.primaryTextStyleBlue,),
      content: TextField(
        controller: _errorMessageController,
        decoration: InputDecoration(
            hintText: 'Hata mesajınızı buraya girin...',
            hintStyle: AppUtilities.primaryTextStyleWhiteSmall
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('İptal', style: AppUtilities.primaryTextStyleBlueSmall,),
        ),
        ElevatedButton(
          onPressed: _sendErrorMessage,
          child: Text('Gönder'),
        ),
      ],
    );
  }
}



class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late String userName;
  late String userEmail;
  late String uid;
  late int questionCount;

  bool isLoading = true; // Yükleme işareti için durum değişkeni

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    UserUtilities.getUserName().then((name) {
      setState(() {
        userName = name;
      });
    });

    UserUtilities.getUserMail().then((email) {
      setState(() {
        userEmail = email;
      });
    });

    setState(() {
      uid = UserUtilities.getCurrentUserUid()!;
    });


    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> userInfo) {
      setState(() {
        questionCount = userInfo.get('questionCount');
        isLoading = false;
      });
    });
  }

  void _updateQuestionCount(int newCount) {
    FirebaseFirestore.instance.collection('users').doc(uid).update({
      'questionCount': newCount,
    }).then((value) {
      setState(() {
        questionCount = newCount;
      });
    }).catchError((error) {
      print("Hata: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: AppUtilities.backgroundColor,
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Yükleme işareti
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(AppUtilities.appLogoPath, height: 220, width: 220),
            SizedBox(height: 20),
            Text(
              'Merhaba $userName',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '$userEmail',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 30),
            Text("Soru Sayısı",style: AppUtilities.primaryTextStyleWhite,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (questionCount > 0) {
                      _updateQuestionCount(questionCount - 1);
                    }
                  },
                ),
                Text(
                  '$questionCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _updateQuestionCount(questionCount + 1);
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ErrorReportingPopup(senderUsername: userName, senderMail: userEmail);
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Text('Hata Bildir'),
            ),
            SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen(username: userName)),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Text('Şifreyi Değiştir'),
            ),
            SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                UserUtilities.signOut(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Text('Çıkış Yap'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InfoScreen(),
            ),
          );
        },
        child: Icon(
          Icons.info,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
