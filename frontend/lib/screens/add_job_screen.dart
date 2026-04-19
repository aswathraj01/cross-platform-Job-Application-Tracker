import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/job_model.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';

/// Screen for adding a new job entry manually.
class AddJobScreen extends StatefulWidget {
  final Map<String, dynamic>? prefillData;
  final JobStatus? initialStatus;

  const AddJobScreen({
    super.key,
    this.prefillData,
    this.initialStatus,
  });

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _locationController = TextEditingController();
  final _linkController = TextEditingController();
  final _notesController = TextEditingController();
  final _skillController = TextEditingController();
  final List<String> _skills = [];
  JobStatus _status = JobStatus.notApplied;
  DateTime? _appliedDate;

  @override
  void initState() {
    super.initState();
    // Pre-fill from AI extraction
    if (widget.prefillData != null) {
      final data = widget.prefillData!;
      _companyController.text = data['company'] ?? '';
      _roleController.text = data['role'] ?? '';
      _locationController.text = data['location'] ?? '';
      _linkController.text = data['application_link'] ?? '';
      _notesController.text = data['notes'] ?? '';
      if (data['skills'] != null) {
        _skills.addAll(List<String>.from(data['skills']));
      }
    }
    if (widget.initialStatus != null) {
      _status = widget.initialStatus!;
      if (_status == JobStatus.applied) {
        _appliedDate = DateTime.now();
      }
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    _linkController.dispose();
    _notesController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _appliedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              surface: Color(0xFF16213E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _appliedDate = date);
    }
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    final token = context.read<AuthProvider>().token;
    final job = JobModel(
      company: _companyController.text.trim(),
      role: _roleController.text.trim(),
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null,
      status: _status,
      appliedDate: _appliedDate != null
          ? DateFormat('yyyy-MM-dd').format(_appliedDate!)
          : null,
      applicationLink: _linkController.text.trim().isNotEmpty
          ? _linkController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      skills: _skills,
    );

    final success = await context.read<JobProvider>().createJob(token, job);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Job added successfully!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<JobProvider>().error ?? 'Failed to save'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Job',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Company
              _buildLabel('Company *'),
              _buildTextField(
                controller: _companyController,
                hint: 'e.g. Google',
                icon: Icons.business,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Role
              _buildLabel('Role *'),
              _buildTextField(
                controller: _roleController,
                hint: 'e.g. Software Engineer',
                icon: Icons.work_outline,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Location
              _buildLabel('Location'),
              _buildTextField(
                controller: _locationController,
                hint: 'e.g. San Francisco, CA (Remote)',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),

              // Status dropdown
              _buildLabel('Status'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<JobStatus>(
                    value: _status,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF16213E),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    icon: Icon(Icons.expand_more, color: Colors.white.withValues(alpha: 0.4)),
                    items: JobStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.value),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Applied Date
              _buildLabel('Applied Date'),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white.withValues(alpha: 0.4), size: 18),
                      const SizedBox(width: 12),
                      Text(
                        _appliedDate != null
                            ? DateFormat('MMM dd, yyyy').format(_appliedDate!)
                            : 'Select date',
                        style: TextStyle(
                          color: _appliedDate != null
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Application Link
              _buildLabel('Application Link'),
              _buildTextField(
                controller: _linkController,
                hint: 'https://...',
                icon: Icons.link,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // Skills
              _buildLabel('Skills'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _skillController,
                      hint: 'Add a skill',
                      icon: Icons.code,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addSkill,
                    icon: const Icon(Icons.add_circle, color: Color(0xFF6C63FF)),
                  ),
                ],
              ),
              if (_skills.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _skills.map((skill) {
                    return Chip(
                      label: Text(
                        skill,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white54),
                      onDeleted: () => setState(() => _skills.remove(skill)),
                      side: BorderSide(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),

              // Notes
              _buildLabel('Notes'),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Any additional notes...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              Consumer<JobProvider>(
                builder: (ctx, provider, _) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _saveJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save Job',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
