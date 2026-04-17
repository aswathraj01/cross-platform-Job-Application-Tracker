import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';
import '../services/ai_service.dart';

/// Provider for managing job data and state.
class JobProvider extends ChangeNotifier {
  List<JobModel> _jobs = [];
  List<JobModel> _filteredJobs = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;

  List<JobModel> get jobs => _filteredJobs.isNotEmpty || _searchQuery.isNotEmpty || _statusFilter != null
      ? _filteredJobs
      : _jobs;
  List<JobModel> get allJobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;

  // ==================== ANALYTICS ====================

  int get totalJobs => _jobs.length;

  int get notAppliedCount => _jobs.where((j) => j.status == JobStatus.notApplied).length;
  int get appliedCount => _jobs.where((j) => j.status == JobStatus.applied).length;
  int get interviewCount => _jobs.where((j) => j.status == JobStatus.interview).length;
  int get rejectedCount => _jobs.where((j) => j.status == JobStatus.rejected).length;
  int get offerCount => _jobs.where((j) => j.status == JobStatus.offer).length;

  double get successRate {
    if (totalJobs == 0) return 0;
    return (offerCount / totalJobs) * 100;
  }

  double get interviewRate {
    if (totalJobs == 0) return 0;
    return ((interviewCount + offerCount) / totalJobs) * 100;
  }

  Map<String, int> get statusCounts => {
        'Not Applied': notAppliedCount,
        'Applied': appliedCount,
        'Interview': interviewCount,
        'Rejected': rejectedCount,
        'Offer': offerCount,
      };

  // ==================== CRUD OPERATIONS ====================

  /// Fetch all jobs from the backend.
  Future<void> fetchJobs(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = JobService(token);
      _jobs = await service.getJobs();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new job.
  Future<bool> createJob(String token, JobModel job) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = JobService(token);
      final newJob = await service.createJob(job);
      _jobs.insert(0, newJob);
      _applyFilters();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing job.
  Future<bool> updateJob(String token, String jobId, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = JobService(token);
      final updatedJob = await service.updateJob(jobId, updates);
      final index = _jobs.indexWhere((j) => j.id == jobId);
      if (index != -1) {
        _jobs[index] = updatedJob;
      }
      _applyFilters();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a job.
  Future<bool> deleteJob(String token, String jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = JobService(token);
      await service.deleteJob(jobId);
      _jobs.removeWhere((j) => j.id == jobId);
      _applyFilters();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== AI EXTRACTION ====================

  /// Extract job data using AI.
  Future<Map<String, dynamic>?> extractJobData(String token, {String? text, String? url}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = AiService(token);
      final result = await service.extractJobData(text: text, url: url);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ==================== SEARCH & FILTER ====================

  /// Set search query and apply filters.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Set status filter and apply filters.
  void setStatusFilter(String? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  /// Clear all filters.
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _filteredJobs = [];
    notifyListeners();
  }

  /// Apply current search and status filters to the job list.
  void _applyFilters() {
    _filteredJobs = _jobs.where((job) {
      bool matchesSearch = true;
      bool matchesStatus = true;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        matchesSearch = job.company.toLowerCase().contains(query) ||
            job.role.toLowerCase().contains(query) ||
            (job.location?.toLowerCase().contains(query) ?? false);
      }

      if (_statusFilter != null && _statusFilter!.isNotEmpty) {
        matchesStatus = job.status.value == _statusFilter;
      }

      return matchesSearch && matchesStatus;
    }).toList();
  }

  /// Clear error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
