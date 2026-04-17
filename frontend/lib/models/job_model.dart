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
    );
  }
}
