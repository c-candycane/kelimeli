import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kelimeli/AppUtilities.dart';
import 'FirebaseUtilities.dart';
import 'package:audioplayers/audioplayers.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  final TextEditingController _answerController = TextEditingController();
  AudioPlayer _audioPlayer = AudioPlayer();
  late StreamSubscription _playerStateSubscription;
  bool _noMoreQuestions = false;
  late final String? imageUrl;
  late final String? audioUrl;
  late final String displayText;
  late final currentQuestion;
  late final bool isSentence;
  late final bool isDisplayTextSentence;
  @override
  void initState() {
    super.initState();
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        _isPlaying = false;
        setState(() {});
      } else if (state == PlayerState.playing) {
        _isPlaying = true;
        setState(() {});
      } else if (state == PlayerState.paused) {
        _isPlaying = false;
        setState(() {});
      }
    });
    _loadQuestions();
  }

  Future<List<Map<String, dynamic>>> _getQuizQuestions() async {
    String? userUid = UserUtilities.getCurrentUserUid();
    if (userUid == null) return [];

    final now = DateTime.now();
    final firestore = FirebaseFirestore.instance;

    final querySnapshot = await firestore
        .collection('users')
        .doc(userUid)
        .collection('words')
        .where('stage', isLessThanOrEqualTo: 7)
        .get();

    final questions = querySnapshot.docs.where((doc) {
      final data = doc.data();
      final stage = data['stage'] as int;
      final lastKnownTime = (data['lastKnownTime'] as Timestamp?)?.toDate();

      if (lastKnownTime == null) return true;
      switch (stage) {
        case 1:
          return true;
        case 2:
          return now.isAfter(lastKnownTime.add(Duration(days: 1)));
        case 3:
          return now.isAfter(lastKnownTime.add(Duration(days: 7)));
        case 4:
          return now.isAfter(lastKnownTime.add(Duration(days: 30)));
        case 5:
          return now.isAfter(lastKnownTime.add(Duration(days: 90)));
        case 6:
          return now.isAfter(lastKnownTime.add(Duration(days: 180)));
        case 7:
          return now.isAfter(lastKnownTime.add(Duration(days: 365)));
        default:
          return false;
      }
    }).toList();

    questions.shuffle();
    return questions.take(10).map((doc) => {
      ...doc.data(),
      'id': doc.id
    }).toList();
  }

  Future<void> _loadQuestions() async {
    final questions = await _getQuizQuestions();
    setState(() {
      _questions = questions;
      if (_questions.isEmpty) {
        _noMoreQuestions = true;
      } else {
        _currentQuestionIndex = 0;
        currentQuestion = _questions[_currentQuestionIndex];

        isSentence = currentQuestion['englishSentences'] != null && currentQuestion['englishSentences'].isNotEmpty;
        List<String> options = [];

        if (isSentence) {
          for (var sentence in currentQuestion['englishSentences']) {
            if (sentence is String) {
              options.add(sentence);
            }
          }
        }

        if (currentQuestion['turkish'] != null && currentQuestion['turkish'].isNotEmpty) {
          options.add(currentQuestion['turkish'].toString());
        }

        if (options.isNotEmpty) {
          final random = Random();
          displayText = options[random.nextInt(options.length)];
        } else {
          displayText = '';
        }

        imageUrl = currentQuestion['imageUrl'];
        audioUrl = currentQuestion['audioUrl'];
        isDisplayTextSentence = (displayText != currentQuestion['turkish']);
      }
    });
  }


  Future<void> _submitAnswer() async {
    final currentQuestion = _questions[_currentQuestionIndex];
    final userAnswer = _answerController.text.trim();

    final userUid = UserUtilities.getCurrentUserUid();
    if (userUid == null) return;

    final firestore = FirebaseFirestore.instance;
    final docRef = firestore
        .collection('users')
        .doc(userUid)
        .collection('words')
        .doc(currentQuestion['id']);


    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      print('Belge bulunamadı: ${docRef.id}');
      return;
    }

    try {
      if (isDisplayTextSentence) {

        final correctAnswer = currentQuestion['turkish'];
        if (userAnswer.toLowerCase() == correctAnswer.toLowerCase()) {
          // Doğru cevap
          final newStage = (currentQuestion['stage'] as int) + 1;
          if (newStage <= 8) {
            await docRef.update({
              'stage': newStage,
              'lastKnownTime': FieldValue.serverTimestamp(),
            });
          } else {
          }
        } else {

          await docRef.update({
            'stage': 1,
            'lastKnownTime': null,
          });
        }
      } else {

        final correctAnswer = currentQuestion['english'];
        if (userAnswer.toLowerCase() == correctAnswer.toLowerCase()) {

          final newStage = (currentQuestion['stage'] as int) + 1;
          if (newStage <= 8) {
            await docRef.update({
              'stage': newStage,
              'lastKnownTime': FieldValue.serverTimestamp(),
            });
          } else {

          }
        } else {

          await docRef.update({
            'stage': 1,
            'lastKnownTime': null,
          });
        }
      }

      setState(() {
        _answerController.clear();
        _currentQuestionIndex++;
      });
    } catch (error) {
      print('Hata oluştu: $error');
    }
  }


  Duration _duration = Duration();
  Duration _position = Duration();
  bool _isPlaying = false;

  void _playAudio(_audioUrl) async {
    if (_audioUrl != null) {
      if (!_isPlaying) {
        await _audioPlayer.play(UrlSource(_audioUrl!));
        _isPlaying = true;
        _audioPlayer.onDurationChanged.listen((duration) {
          setState(() {
            _duration = duration;
          });
        });
        _audioPlayer.onPositionChanged.listen((position) {
          setState(() {
            _position = position;
          });
        });
      } else {
        await _audioPlayer.pause();
        _isPlaying = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_noMoreQuestions) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: 100,
                color: Colors.amber,
              ),
              SizedBox(height: 20),
              Text(
                'Şu anda gösterilecek kelime yok, tüm kelimeleri bildiniz!',
                style: AppUtilities.primaryTextStyleWhiteSmallItalic,
                textAlign: TextAlign.center,
              ),

            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentQuestionIndex >= _questions.length) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz'),
        ),
        body: Center(
          child: Text('Quiz tamamlandı!', style: AppUtilities.primaryTextStyleBlueXLargeBold),
        ),
      );
    }



    List<InlineSpan> _buildSentenceWithHighlightedWord(String sentence, String wordToHighlight) {
      final RegExp wordRegExp = RegExp(r"[\wğüşıöçĞÜŞİÖÇ']+|[.,!?;]");
      final List<String> words = wordRegExp.allMatches(sentence).map((match) => match.group(0)!).toList();

      return words.map((word) {
        if (word.toUpperCase() == wordToHighlight.toUpperCase()) {
          return TextSpan(
            text: '$word ',
            style: AppUtilities.primaryTextStyleBlueXLargeBold,
          );
        } else {
          return TextSpan(
            text: '$word ',
            style: AppUtilities.primaryTextStyleWhiteXLarge,
          );
        }
      }).toList();
    }


    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (imageUrl != null) Image.network(imageUrl!),
              if (audioUrl != null)
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    _playAudio(audioUrl);
                  },
                ),
              if (isSentence)
                RichText(
                  text: TextSpan(
                    children: _buildSentenceWithHighlightedWord(displayText, currentQuestion['english']),
                  ),
                )
              else
                Text(
                  displayText,
                  style: AppUtilities.primaryTextStyleBlueXLargeBold,
                ),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  labelText: isDisplayTextSentence ? 'Türkçe Cevap':'İngilizce Cevap',
                  labelStyle: AppUtilities.primaryTextStyleWhite,
                ),
                style: AppUtilities.primaryTextStyleWhiteXLarge,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitAnswer,
                child: Text('Cevapla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}