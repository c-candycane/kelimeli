import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kelimeli/AppUtilities.dart';
import 'FirebaseUtilities.dart';
import 'category_details_page.dart';

class Answer {
  final String questionId;
  final int correctCount;
  final int wrongCount;

  Answer({
    required this.questionId,
    required this.correctCount,
    required this.wrongCount,
  });

  factory Answer.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Answer(
      questionId: data['questionId'] ?? '',
      correctCount: data['correctCount'] ?? 0,
      wrongCount: data['wrongCount'] ?? 0,
    );
  }
}

class AnalysisPage extends StatefulWidget {
  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  List<Answer> _answers = [];
  late Map<String, int> _categoryCounts = {};
  late Map<String, int> _categoryCorrectCounts = {};
  final categories = [
    'Hayvanlar',
    'Renkler',
    'Yiyecekler',
    'Meslekler',
    'Giysiler',
    'Ulaşım Araçları',
    'Mutfak Eşyaları',
    'Doğa Elementleri',
    'Saatler ve Zaman',
    'Ev Eşyaları',
    'Meyve ve Sebzeler',
    'Vücut Parçaları',
    'Sporlar',
    'Mekanlar',
    'Müzik Aletleri',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  Future<void> _loadAnswers() async {
    String? userUid = UserUtilities.getCurrentUserUid();
    if (userUid == null) return;

    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore
        .collection('users')
        .doc(userUid)
        .collection('answers')
        .get();

    final answers = querySnapshot.docs.map((doc) => Answer.fromDocument(doc)).toList();

    // Kategorilere göre doğru ve toplam sayıları hesapla
    final categoryCounts = <String, int>{};
    final categoryCorrectCounts = <String, int>{};

    for (var answer in answers) {
      final category = await _getWordCategory(answer.questionId);
      final totalCount = answer.correctCount + answer.wrongCount;
      categoryCounts.update(category, (value) => value + totalCount, ifAbsent: () => totalCount);
      categoryCorrectCounts.update(category, (value) => value + answer.correctCount, ifAbsent: () => answer.correctCount);
    }

    setState(() {
      _answers = answers;
      _categoryCounts = categoryCounts;
      _categoryCorrectCounts = categoryCorrectCounts;
    });
  }

  Future<String> _getWordCategory(String questionId) async {
    String? userUid = UserUtilities.getCurrentUserUid();
    if (userUid == null) return '';

    final firestore = FirebaseFirestore.instance;
    final docSnapshot = await firestore.collection('users').doc(userUid).collection('words').doc(questionId).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        return data['category'] ?? 'Diğer';
      }
    }

    return 'Diğer';
  }

  void _openCategoryDetails(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailsPage(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analiz'),
      ),
      body: ListView(
        children: [
          for (var category in categories)
            if (_categoryCounts.containsKey(category))
              GestureDetector(
                onTap: () => _openCategoryDetails(category),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kategori: $category',
                        style: AppUtilities.primaryTextStyleBlueXLargeBold,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Toplam Cevap Sayısı: ${_categoryCounts[category]}',
                        style: AppUtilities.primaryTextStyleWhiteBold,
                      ),
                      Text(
                        'Doğru Cevap Yüzdesi: ${((_categoryCorrectCounts[category] ?? 0) / (_categoryCounts[category] ?? 1) * 100).toStringAsFixed(2)}%',
                        style: AppUtilities.primaryTextStyleWhiteBold,
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
