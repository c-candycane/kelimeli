import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Text(
                    'Resim / Ses / Metin',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Sesi Çal'),
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              flex: 2,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'İngilizce Cevap',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Cevapla'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

