import 'dart:io';

class FeedbackEntry {
  final String issueType;
  final String message;
  final String transcription;
  final List<File?> images;
  final List<File?> videos;

  FeedbackEntry({
    required this.issueType,
    required this.message,
    required this.transcription,
    required this.images,
    required this.videos,
  });
}

// ✅ Global feedback list
List<FeedbackEntry> feedbackList = [];
