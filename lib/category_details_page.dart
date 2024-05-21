import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kelimeli/AppUtilities.dart';
import 'FirebaseUtilities.dart';

class Answer {
  final String questionId;
  final int correctCount;
  final int wrongCount;
  final bool isCorrect;
  final Timestamp answerDate;
  Answer({
    required this.questionId,
    required this.correctCount,
    required this.wrongCount,
    required this.isCorrect,
    required this.answerDate,
  });

  factory Answer.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Answer(
      questionId: doc.id,
      correctCount: data['correctCount'] ?? 0,
      wrongCount: data['wrongCount'] ?? 0,
      isCorrect: data['isCorrect'] ?? false,
        answerDate: data['answerDate']

    );
  }

}

class CategoryDetailsPage extends StatefulWidget {
  final String category;

  CategoryDetailsPage({required this.category});

  @override
  _CategoryDetailsPageState createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  List<Answer> _categoryAnswers = [];
  Map<String, String> _wordTranslations = {};
  Map<String, String> _wordUntranslations = {};
  Map<String, String> _wordCorrectAnswerCount = {};
  Map<String, String> _wordWrongAnswerCount = {};
  Map<String, bool> _wordLastAnswer = {};
  Map<String, Timestamp> _wordAnswerDate = {};
  @override
  void initState() {
    super.initState();
    _loadCategoryAnswers();
  }

  Future<void> _loadCategoryAnswers() async {
    String? userUid = UserUtilities.getCurrentUserUid();
    if (userUid == null) return;

    final firestore = FirebaseFirestore.instance;
    final answersSnapshot = await firestore
        .collection('users')
        .doc(userUid)
        .collection('answers')
        .get();

    final wordsSnapshot = await firestore
        .collection('users')
        .doc(userUid)
        .collection('words')
        .get();

    final answers = answersSnapshot.docs.map((doc) => Answer.fromDocument(doc)).toList();
    final words = wordsSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'questionId': doc.id,
        'category': data['category'] ?? '',
        'english': data['english'] ?? '',
        'turkish': data['turkish'] ?? ''
      };
    }).toList();

    final categoryAnswers = answers.where((answer) {
      final word = words.firstWhere(
            (word) => word['questionId'] == answer.questionId,
        orElse: () => {'category': '', 'questionId': '', 'english': '', 'turkish': ''},
      );
      return word['category'] == widget.category;
    }).toList();

    final wordTranslations = {for (var word in words) word['questionId']: word['english']};
    final wordUntranslations = {for (var word in words) word['questionId']: word['turkish']};
    final wordCorrectAnswerCount = {for (var answer in answers) answer.questionId: (answer.correctCount).toString()};
    final wordWrongAnswerCount = {for (var answer in answers) answer.questionId: (answer.wrongCount).toString()};
    final wordLastAnswer = {for (var answer in answers) answer.questionId: answer.isCorrect};
    final wordAnswerDate = {for (var answer in answers) answer.questionId: answer.answerDate};
    setState(() {
      _categoryAnswers = categoryAnswers;
      _wordTranslations = wordTranslations.cast<String, String>();
      _wordUntranslations = wordUntranslations.cast<String, String>();
      _wordCorrectAnswerCount = wordCorrectAnswerCount.cast<String, String>();
      _wordWrongAnswerCount = wordWrongAnswerCount.cast<String, String>();
      _wordLastAnswer = wordLastAnswer.cast<String, bool>();
      _wordAnswerDate = wordAnswerDate.cast<String, Timestamp>();
    });
  }

  double _calculateWordCorrectPercentage(Answer answer) {
    final total = answer.correctCount + answer.wrongCount;
    return total > 0 ? (answer.correctCount / total) * 100 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategori Detayları - ${widget.category}'),
      ),
      body: ListView.builder(
        itemCount: _categoryAnswers.length,
        itemBuilder: (context, index) {
          final answer = _categoryAnswers[index];
          final word = _wordTranslations[answer.questionId] ?? 'Unknown';
          final wordTurkish = _wordUntranslations[answer.questionId] ?? 'Unknown';
          final correctCount = _wordCorrectAnswerCount[answer.questionId] ?? 'Unknown';
          final wrongCount = _wordWrongAnswerCount[answer.questionId] ?? 'Unknown';
          final isLastAnswerTrue = _wordLastAnswer[answer.questionId] ?? false;
          final wordLastAnswerDate  = _wordAnswerDate[answer.questionId];
          print(isLastAnswerTrue);
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelime: $word',
                  style: AppUtilities.primaryTextStyleBlueXLargeBold,
                ),
                Text(
                  'Türkçe Anlamı: $wordTurkish',
                  style: AppUtilities.primaryTextStyleWhiteSmallItalic,
                ),
                Text(
                  'Doğru cevap sayısı: $correctCount',
                  style: AppUtilities.primaryTextStyleWhiteSmallItalic,
                ),
                Text(
                  'Yanlış cevap sayısı: $wrongCount',
                  style: AppUtilities.primaryTextStyleWhiteSmallItalic,
                ),
                Text(
                  'Son Cevap Durumu: ',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${isLastAnswerTrue ? 'Doğru' : 'Yanlış'}',
                  style: TextStyle(fontSize: 16, color: isLastAnswerTrue ? Colors.green : Colors.red, fontStyle: FontStyle.italic),
                ),
                Text(
                  'Son Cevap Zamanı: ${wordLastAnswerDate?.toDate()} ',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Doğru Cevap Yüzdesi: ${_calculateWordCorrectPercentage(answer).toStringAsFixed(2)}%',
                  style: AppUtilities.primaryTextStyleWhiteBold,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
