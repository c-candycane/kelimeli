import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:kelimeli/AppUtilities.dart';
import 'FirebaseUtilities.dart';


class AddWordScreen extends StatefulWidget {
  @override
  _AddWordScreenState createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _englishController = TextEditingController();
  final _turkishController = TextEditingController();
  List<TextEditingController> _englishSentenceControllers = [
    TextEditingController(),
    TextEditingController()
  ]; 
  File? _image;
  String? _imageUrl;
  String? _audioUrl;
  String? _selectedAudioFileName;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isUploading = false;
  late StreamSubscription _playerStateSubscription;

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
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _generateSpeech() async {


    String englishWord = _englishController.text;
    List<String> file_values = await AppUtilities.generateSpeech(englishWord);
    setState(() {
      _audioUrl = file_values[0];
      _selectedAudioFileName = file_values[1];
    });
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _getAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      setState(() {
        _audioUrl = file.path;
        _selectedAudioFileName = file.path
            .split('/')
            .last;
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    String englishWord = _englishController.text.toLowerCase();
    List<String> englishSentences = _englishSentenceControllers.map((controller) => controller.text).toList();


    for (int i = 0; i < englishSentences.length; i++) {
      String sanitizedSentence = englishSentences[i].replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase();
      if (!sanitizedSentence.contains(englishWord)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Hata', style: AppUtilities.primaryTextStyleBlueLarge,),
            content: Text('İngilizce kelime "${englishWord}" ${i + 1}. cümlede geçmiyor: "${englishSentences[i]}"', style: AppUtilities.primaryTextStyleWhite,),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Tamam'),
              ),
            ],
          ),
        );
        return;
      }
    }

    setState(() {
      _isUploading = true;
    });

    await _uploadImage();
    await _uploadAudio();

    String? userUid = UserUtilities.getCurrentUserUid();
    if (userUid != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('words')
          .add({
        'english': _englishController.text,
        'turkish': _turkishController.text,
        'imageUrl': _imageUrl,
        'audioUrl': _audioUrl,
        'englishSentences': englishSentences,
        'stage': 1,
        'lastKnownTime': null,
        'category': _selectedCategory
      });

      setState(() {
        _isUploading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Yükleme tamamlandı', style: AppUtilities.primaryTextStyleBlueLarge,),
          content: Text('Kelime başarıyla eklendi', style: AppUtilities.primaryTextStyleWhite,),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _englishController.clear();
                _turkishController.clear();
                _image = null;
                _imageUrl = null;
                _audioUrl = null;
                _selectedAudioFileName = null;
                _englishSentenceControllers.clear();
                _englishSentenceControllers.add(TextEditingController());
                _englishSentenceControllers.add(TextEditingController());
                setState(() {});
              },
              child: Text('Tamam'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _isUploading = false;
      });

      AppUtilities.showAlertDialog("Hata", "Kullanıcı oturumu açık değil", context);
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    _imageUrl = await StorageUtilities.uploadFile(
        _image!.path, 'images', _englishController.text, 'jpg');
  }

  Future<void> _uploadAudio() async {
    if (_audioUrl == null) return;
    _audioUrl = await StorageUtilities.uploadFile(
        _audioUrl!, 'sounds', _englishController.text, 'mp3');
  }

  Duration _duration = Duration();
  Duration _position = Duration();
  bool _isPlaying = false;

  void _playAudio() async {
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

  void _addEnglishSentenceField() {
    setState(() {
      _englishSentenceControllers.add(TextEditingController());
    });
  }


  void _removeEnglishSentenceField(int index) {
    if (_englishSentenceControllers.length > 2) {
      setState(() {
        _englishSentenceControllers.removeAt(index);
      });
    }
  }
  String _selectedCategory = 'Hayvanlar';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelime Ekle'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _englishController,
                decoration: InputDecoration(
                  labelText: 'İngilizce Kelime',
                  labelStyle: TextStyle(color: Colors.blue),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir İngilizce kelime girin';
                  }
                  return null;
                },
                style: AppUtilities.primaryTextStyleWhite,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _turkishController,
                decoration: InputDecoration(
                  labelText: 'Türkçe Karşılığı',
                  labelStyle: TextStyle(color: Colors.blue),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir Türkçe karşılık girin';
                  }
                  return null;
                },
                style: AppUtilities.primaryTextStyleWhite,
              ),
              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: AppUtilities.categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  labelStyle: TextStyle(color: Colors.blue),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                style: AppUtilities.primaryTextStyleWhite,
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _englishSentenceControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _englishSentenceControllers[index],
                          decoration: InputDecoration(
                            labelText: 'İngilizce Cümle ${index + 1}',
                            labelStyle: TextStyle(color: Colors.blue),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen bir cümle girin';
                            }
                            return null;
                          },
                          style: AppUtilities.primaryTextStyleWhite,
                        ),
                      ),
                      if (_englishSentenceControllers.length > 2)
                        IconButton(
                          icon: Icon(Icons.remove_circle),
                          onPressed: () => _removeEnglishSentenceField(index),
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addEnglishSentenceField,
                child: Text('İngilizce Cümle Ekle'),
              ),
              _image == null
                  ? ElevatedButton.icon(
                onPressed: _getImage,
                icon: Icon(Icons.image),
                label: Text('Resim Seç'),
              )
                  : Column(
                children: [
                  Image.file(
                    _image!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _getImage,
                    icon: Icon(Icons.edit),
                    label: Text('Resmi Değiştir'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getAudio,
                child: Text(_selectedAudioFileName ?? 'Ses Seç'),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _generateSpeech,
                icon: Icon(Icons.record_voice_over),
                label: Text('Ses Oluştur'),
              ),

              SizedBox(height: 20),
              _audioUrl != null
                  ? Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '${_position.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_position.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                        style: AppUtilities.primaryTextStyleWhite,
                      ),
                      ElevatedButton(
                        onPressed: _playAudio,
                        child: _isPlaying
                            ? Icon(Icons.pause)
                            : Icon(Icons.play_arrow),
                      ),
                    ],
                  ),
                ],
              )
                  : Container(),
              SizedBox(height: 20),
              _isUploading
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : ElevatedButton(
                onPressed: _submitForm,
                child: Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
