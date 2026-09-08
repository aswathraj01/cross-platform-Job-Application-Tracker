/// Enum representing job application statuses.
enum JobStatus {
  notApplied('Not Applied'),
  applied('Applied'),
  interview('Interview'),
  rejected('Rejected'),
  offer('Offer');

  final String value;
  const JobStatus(this.value);

  static JobStatus fromString(String status) {
    return JobStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == status.toLowerCase(),
      orElse: () => JobStatus.notApplied,
    );
  }
}

/// Enum for how the job was added.
enum JobSource {
  manual,
  aiExtract,
  extension;

  static JobSource fromString(String? s) {
    switch (s) {
      case 'extension': return JobSource.extension;
      case 'ai_extract': return JobSource.aiExtract;
      default: return JobSource.manual;
    }
  }

  String get displayLabel {
    switch (this) {
      case JobSource.extension: return 'Extension';
      case JobSource.aiExtract: return 'AI Extract';
      case JobSource.manual: return 'Manual';
    }
  }

  String get apiValue {
    switch (this) {
      case JobSource.extension: return 'extension';
      case JobSource.aiExtract: return 'ai_extract';
      case JobSource.manual: return 'manual';
    }
  }
}

/// Job model representing a job application entry.
class JobModel {
  final String? id;
  final String company;
  final String role;
  final String? location;
  final JobStatus status;
  final String? appliedDate;
  final String? applicationLink;
  final String? notes;
  final List<String> skills;
  final String? userId;
  final String? createdAt;
  final String? updatedAt;
  final JobSource source;
  final String? domain;

  JobModel({
    this.id,
    required this.company,
    required this.role,
    this.location,
    this.status = JobStatus.notApplied,
    this.appliedDate,
    this.applicationLink,
    this.notes,
    this.skills = const [],
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.source = JobSource.manual,
    this.domain,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'],
      company: json['company'] ?? '',
      role: json['role'] ?? '',
      location: json['location'],
      status: JobStatus.fromString(json['status'] ?? 'Not Applied'),
      appliedDate: json['applied_date'],
      applicationLink: json['application_link'],
      notes: json['notes'],
      skills: List<String>.from(json['skills'] ?? []),
      userId: json['user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      source: JobSource.fromString(json['source']),
      domain: json['domain'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'company': company,
      'role': role,
      'location': location,
      'status': status.value,
      'applied_date': appliedDate,
      'application_link': applicationLink,
      'notes': notes,
      'skills': skills,
      'source': source.apiValue,
      'domain': domain,
    };
  }

  JobModel copyWith({
    String? id,
    String? company,
    String? role,
    String? location,
    JobStatus? status,
    String? appliedDate,
    String? applicationLink,
    String? notes,
    List<String>? skills,
    String? userId,
    String? createdAt,
    String? updatedAt,
    JobSource? source,
    String? domain,
  }) {
    return JobModel(
      id: id ?? this.id,
      company: company ?? this.company,
      role: role ?? this.role,
      location: location ?? this.location,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      applicationLink: applicationLink ?? this.applicationLink,
      notes: notes ?? this.notes,
      skills: skills ?? this.skills,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      domain: domain ?? this.domain,
    );
  }
}
