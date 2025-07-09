import 'dart:io';
// import 'package:file_picker/file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voicefirst/Views/Dashboard/saved_screen.dart';

import '../Models/feedback_entry.dart';

List<FeedbackEntry> feedbackList = [];

class FeedbackFormScreen extends StatefulWidget {
  @override
  _FeedbackFormScreenState createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _messageController = TextEditingController();
  String? _selectedIssue;
  File? _image1, _image2, _video1, _video2;

  // Speech-to-text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;
  String _transcribedText = '';

  final List<String> issueTypes = [
    'Damaged Item',
    'Late Delivery',
    'Wrong Order',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    setState(() {});
  }

  Future<void> _startListening() async {
    if (_speechAvailable && !_isListening) {
      setState(() {
        _isListening = true;
        _transcribedText = 'Listening...';
      });

      _speech.listen(
        onResult: (val) {
          setState(() {
            _transcribedText = val.recognizedWords;
            if (val.finalResult) _isListening = false;
          });
        },
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    await _initSpeech(); // Re-warm
    setState(() => _isListening = false);
  }

  Future<void> _pickFile({required bool isImage, required int slot}) async {
    final result = await FilePicker.platform.pickFiles(
      type: isImage ? FileType.image : FileType.video,
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      setState(() {
        if (isImage) {
          if (slot == 1) _image1 = file;
          if (slot == 2) _image2 = file;
        } else {
          if (slot == 1) _video1 = file;
          if (slot == 2) _video2 = file;
        }
      });
    }
  }

  Widget _filePickerBox(File? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: file == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, color: Colors.grey),
                    Text(
                      "No file selected",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              : Text(
                  file.path.split('/').last,
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_selectedIssue == null || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final entry = FeedbackEntry(
      issueType: _selectedIssue!,
      message: _messageController.text.trim(),
      transcription: _transcribedText,
      images: [_image1, _image2],
      videos: _selectedIssue == 'Late Delivery' ? [] : [_video1, _video2],
    );

    feedbackList.add(entry);

    // Reset state
    setState(() {
      _selectedIssue = null;
      _messageController.clear();
      _transcribedText = '';
      _image1 = null;
      _image2 = null;
      _video1 = null;
      _video2 = null;
    });

    // Navigate to Saved screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SavedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLateDelivery = _selectedIssue == 'Late Delivery';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Feedback Form'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Issue Type', style: TextStyle(color: Colors.white)),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.grey[900],
              value: _selectedIssue,
              items: issueTypes.map((issue) {
                return DropdownMenuItem<String>(
                  value: issue,
                  child: Text(issue, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedIssue = val),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Message', style: TextStyle(color: Colors.white)),
            TextField(
              controller: _messageController,
              maxLines: 5,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                hintText: 'Enter your feedback...',
                hintStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Voice Transcription', style: TextStyle(color: Colors.white)),
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic_off : Icons.mic,
                      color: Color(0xFFFCC737),
                    ),
                    onPressed: _isListening ? _stopListening : _startListening,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _transcribedText.isEmpty
                          ? 'Tap the mic and speak...'
                          : _transcribedText,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedIssue != null) ...[
              Text('Image Uploads', style: TextStyle(color: Colors.white)),
              _filePickerBox(_image1, () => _pickFile(isImage: true, slot: 1)),
              _filePickerBox(_image2, () => _pickFile(isImage: true, slot: 2)),
            ],
            if (!isLateDelivery && _selectedIssue != null) ...[
              SizedBox(height: 20),
              Text('Video Uploads', style: TextStyle(color: Colors.white)),
              _filePickerBox(_video1, () => _pickFile(isImage: false, slot: 1)),
              _filePickerBox(_video2, () => _pickFile(isImage: false, slot: 2)),
            ],
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFCC737),
                foregroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
