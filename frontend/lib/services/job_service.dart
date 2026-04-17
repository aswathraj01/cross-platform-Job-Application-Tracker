import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/job_model.dart';

/// Service for handling Job CRUD API calls.
class JobService {
  final String _token;

  JobService(this._token);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  /// Get all jobs with optional status and company filters.
  Future<List<JobModel>> getJobs({String? status, String? company}) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (company != null && company.isNotEmpty) queryParams['company'] = company;

    final uri = Uri.parse(ApiConfig.jobsUrl).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http
        .get(uri, headers: _headers)
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => JobModel.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to fetch jobs');
    }
  }

  /// Create a new job entry.
  Future<JobModel> createJob(JobModel job) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.jobsUrl}/'),
          headers: _headers,
          body: jsonEncode(job.toJson()),
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode == 201) {
      return JobModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to create job');
    }
  }

  /// Get a single job by ID.
  Future<JobModel> getJob(String jobId) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.jobsUrl}/$jobId'),
          headers: _headers,
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode == 200) {
      return JobModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to fetch job');
    }
  }

  /// Update an existing job.
  Future<JobModel> updateJob(String jobId, Map<String, dynamic> updates) async {
    final response = await http
        .put(
          Uri.parse('${ApiConfig.jobsUrl}/$jobId'),
          headers: _headers,
          body: jsonEncode(updates),
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode == 200) {
      return JobModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to update job');
    }
  }

  /// Delete a job.
  Future<void> deleteJob(String jobId) async {
    final response = await http
        .delete(
          Uri.parse('${ApiConfig.jobsUrl}/$jobId'),
          headers: _headers,
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode != 204) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to delete job');
    }
  }
}
