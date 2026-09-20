import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';
import '../services/ai_service.dart';
import 'auth_provider.dart';

/// Provider for managing job data and state.
class JobProvider extends ChangeNotifier {
  AuthProvider? _authProvider;

  /// Inject the AuthProvider so we can silently refresh tokens on 401.
  void setAuthProvider(AuthProvider auth) {
    _authProvider = auth;
  }

  List<JobModel> _jobs = [];
  List<JobModel> _filteredJobs = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;
  String? _sourceFilter;

  bool get _hasActiveFilter => _searchQuery.isNotEmpty || _statusFilter != null || _sourceFilter != null;

  List<JobModel> get jobs => _hasActiveFilter ? _filteredJobs : _jobs;
  List<JobModel> get allJobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  String? get sourceFilter => _sourceFilter;

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

  int get extensionCount => _jobs.where((j) => j.source == JobSource.extension).length;
  int get aiExtractCount => _jobs.where((j) => j.source == JobSource.aiExtract).length;
  int get manualCount => _jobs.where((j) => j.source == JobSource.manual).length;

  Map<String, int> get statusCounts => {
        'Not Applied': notAppliedCount,
        'Applied': appliedCount,
        'Interview': interviewCount,
        'Rejected': rejectedCount,
        'Offer': offerCount,
      };

  // ==================== TOKEN REFRESH HELPER ====================

  /// Runs [action] with the current token. If a 401 / credential error is
  /// detected it silently refreshes the token via [_authProvider] and retries
  /// once. Returns null and sets [_error] if the retry also fails.
  Future<T?> _withRefresh<T>(String token, Future<T> Function(String t) action) async {
    try {
      return await action(token);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if ((msg.contains('401') || msg.contains('credential') || msg.contains('token')) &&
          _authProvider != null) {
        // Try to silently refresh the ID token and retry once
        final newToken = await _authProvider!.refreshIfNeeded();
        if (newToken.isNotEmpty) {
          return await action(newToken);
        }
      }
      rethrow;
    }
  }

  // ==================== CRUD OPERATIONS ====================

  /// Fetch all jobs from the backend.
  Future<void> fetchJobs(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final jobs = await _withRefresh(
        token,
        (t) => JobService(t).getJobs(),
      );
      _jobs = jobs ?? [];
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
      final newJob = await _withRefresh(
        token,
        (t) => JobService(t).createJob(job),
      );
      if (newJob != null) {
        _jobs.insert(0, newJob);
        _applyFilters();
      }
      _isLoading = false;
      notifyListeners();
      return newJob != null;
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
      final updatedJob = await _withRefresh(
        token,
        (t) => JobService(t).updateJob(jobId, updates),
      );
      if (updatedJob != null) {
        final index = _jobs.indexWhere((j) => j.id == jobId);
        if (index != -1) _jobs[index] = updatedJob;
        _applyFilters();
      }
      _isLoading = false;
      notifyListeners();
      return updatedJob != null;
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
      await _withRefresh(
        token,
        (t) async { await JobService(t).deleteJob(jobId); return true; },
      );
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
      final result = await _withRefresh(
        token,
        (t) => AiService(t).extractJobData(text: text, url: url),
      );
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

  /// Set source filter (extension/ai_extract/manual) and apply filters.
  void setSourceFilter(String? source) {
    _sourceFilter = source;
    _applyFilters();
    notifyListeners();
  }

  /// Clear all filters.
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _sourceFilter = null;
    _filteredJobs = [];
    notifyListeners();
  }

  /// Apply current search, status, and source filters to the job list.
  void _applyFilters() {
    _filteredJobs = _jobs.where((job) {
      bool matchesSearch = true;
      bool matchesStatus = true;
      bool matchesSource = true;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        matchesSearch = job.company.toLowerCase().contains(query) ||
            job.role.toLowerCase().contains(query) ||
            (job.location?.toLowerCase().contains(query) ?? false);
      }

      if (_statusFilter != null && _statusFilter!.isNotEmpty) {
        matchesStatus = job.status.value == _statusFilter;
      }

      if (_sourceFilter != null && _sourceFilter!.isNotEmpty) {
        matchesSource = job.source.apiValue == _sourceFilter;
      }

      return matchesSearch && matchesStatus && matchesSource;
    }).toList();
  }

  /// Clear error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
