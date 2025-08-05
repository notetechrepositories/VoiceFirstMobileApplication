class IssueType {
  final String id;
  final String issueType;
  final bool status;
  final List<IssueAnswerType> issueAnswerTypes;
  final List<MediaRequired> mediaRequired;

  IssueType({
    required this.id,
    required this.issueType,
    required this.status,
    required this.issueAnswerTypes,
    required this.mediaRequired,
  });

  factory IssueType.fromJson(Map<String, dynamic> json) {
    return IssueType(
      id: json['id'],
      issueType: json['issueType'],
      status: json['status'],
      issueAnswerTypes:
          (json['issueAnswerTypes'] as List<dynamic>?)
              ?.map((e) => IssueAnswerType.fromJson(e))
              .toList() ??
          [],
      mediaRequired:
          (json['mediaRequired'] as List<dynamic>?)
              ?.map((e) => MediaRequired.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'issueType': issueType,
    'status': status,
    'issueAnswerTypes': issueAnswerTypes.map((e) => e.toJson()).toList(),
    'mediaRequired': mediaRequired.map((e) => e.toJson()).toList(),
  };
}

class IssueAnswerType {
  final String issueAnswerTypeId;
  final String answerTypeId;
  final String answerTypeName; // optional for view

  IssueAnswerType({
    required this.issueAnswerTypeId,
    required this.answerTypeId,
    this.answerTypeName = '',
  });

  factory IssueAnswerType.fromJson(Map<String, dynamic> json) {
    return IssueAnswerType(
      issueAnswerTypeId: json['issueAnswerTypeId'] ?? '',
      answerTypeId: json['answerTypeId'] ?? '',
      answerTypeName: json['answerTypeName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'issueAnswerTypeId': issueAnswerTypeId,
    'answerTypeId': answerTypeId,
  };
}

class MediaRequired {
  final String mediaRequiredId;
  final String attachmentTypeId;
  final int maximum;
  final int maximumSize;
  final List<IssueMediaType> issueMediaType;

  MediaRequired({
    required this.mediaRequiredId,
    required this.attachmentTypeId,
    required this.maximum,
    required this.maximumSize,
    required this.issueMediaType,
  });

  factory MediaRequired.fromJson(Map<String, dynamic> json) {
    return MediaRequired(
      mediaRequiredId: json['mediaRequiredId'] ?? '',
      attachmentTypeId: json['attachmentTypeId'] ?? '',
      maximum: (json['maximum'] as num?)?.toInt() ?? 0,
      maximumSize: (json['maximumSize'] as num?)?.toInt() ?? 0,
      issueMediaType:
          (json['issueMediaType'] as List<dynamic>?)
              ?.map((e) => IssueMediaType.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'mediaRequiredId': mediaRequiredId,
    'attachmentTypeId': attachmentTypeId,
    'maximum': maximum,
    'maximumSize': maximumSize,
    'issueMediaType': issueMediaType.map((e) => e.toJson()).toList(),
  };
}

class IssueMediaType {
  final String issueMediaTypeId;
  final String mediaTypeId;
  final bool mandatory;

  IssueMediaType({
    required this.issueMediaTypeId,
    required this.mediaTypeId,
    required this.mandatory,
  });

  factory IssueMediaType.fromJson(Map<String, dynamic> json) {
    return IssueMediaType(
      issueMediaTypeId: json['issueMediaTypeId'] ?? '',
      mediaTypeId: json['mediaTypeId'] ?? '',
      mandatory: json['mandatory'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'issueMediaTypeId': issueMediaTypeId,
    'mediaTypeId': mediaTypeId,
    'mandatory': mandatory,
  };
}
