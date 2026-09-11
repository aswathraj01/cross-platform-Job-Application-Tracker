import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/job_model.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../config/liquid_glass_theme.dart';
import '../widgets/animated_orb_background.dart';
import '../widgets/glass_container.dart';

/// Screen for adding a new job entry manually — Apple Liquid Glass design.
class AddJobScreen extends StatefulWidget {
  final Map<String, dynamic>? prefillData;
  final JobStatus? initialStatus;
  final JobSource source;

  const AddJobScreen({
    super.key,
    this.prefillData,
    this.initialStatus,
    this.source = JobSource.manual,
  });

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey           = GlobalKey<FormState>();
  final _companyController  = TextEditingController();
  final _roleController     = TextEditingController();
  final _locationController = TextEditingController();
  final _linkController     = TextEditingController();
  final _notesController    = TextEditingController();
  final _skillController    = TextEditingController();
  final List<String> _skills = [];
  JobStatus _status = JobStatus.notApplied;
  DateTime? _appliedDate;

  @override
  void initState() {
    super.initState();
    if (widget.prefillData != null) {
      final data = widget.prefillData!;
      _companyController.text  = data['company'] ?? '';
      _roleController.text     = data['role'] ?? '';
      _locationController.text = data['location'] ?? '';
      _linkController.text     = data['application_link'] ?? '';
      _notesController.text    = data['notes'] ?? '';
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
              primary: LiquidGlass.accentPrimary,
              surface: LiquidGlass.bgSurface,
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
      source: widget.source,
    );

    final success = await context.read<JobProvider>().createJob(token, job);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅  Job added successfully!'),
          backgroundColor: LiquidGlass.bgSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: LiquidGlass.accentGreen.withValues(alpha: 0.4)),
          ),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<JobProvider>().error ?? 'Failed to save'),
          backgroundColor: LiquidGlass.bgSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: LiquidGlass.accentRed.withValues(alpha: 0.4)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiquidGlass.bgDeep,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
          ),
        ),
        title: Text(
          'Add Job',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedOrbBackground()),

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 32),
            child: Form(
              key: _formKey,
              child: GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Company
                    _buildLabel('Company *'),
                    _buildTextField(
                      controller: _companyController,
                      hint: 'e.g. Google',
                      icon: Icons.business_outlined,
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

                    // Status
                    _buildLabel('Status'),
                    _buildGlassDropdown(),
                    const SizedBox(height: 16),

                    // Applied Date
                    _buildLabel('Applied Date'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: Colors.white.withValues(alpha: 0.4), size: 18),
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
                            hint: 'Add a skill (e.g. Flutter)',
                            icon: Icons.code,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _addSkill,
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              gradient: LiquidGlass.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: LiquidGlass.glowShadow(LiquidGlass.accentPrimary, blur: 12),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    if (_skills.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _skills.map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: LiquidGlass.accentPrimary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: LiquidGlass.accentPrimary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  skill,
                                  style: const TextStyle(
                                    color: LiquidGlass.accentPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => setState(() => _skills.remove(skill)),
                                  child: Icon(Icons.close, size: 14, color: Colors.white.withValues(alpha: 0.5)),
                                ),
                              ],
                            ),
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
                      decoration: LiquidGlass.glassInputDecoration(hint: 'Any additional notes...'),
                    ),
                    const SizedBox(height: 28),

                    // Save Button
                    Consumer<JobProvider>(
                      builder: (ctx, provider, _) {
                        return GestureDetector(
                          onTap: provider.isLoading ? null : _saveJob,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 52,
                            decoration: provider.isLoading
                                ? BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(14),
                                  )
                                : LiquidGlass.glowButtonDecoration(),
                            child: Center(
                              child: provider.isLoading
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      'Save Job',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.65),
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
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
      decoration: LiquidGlass.glassInputDecoration(
        hint: hint,
        prefix: Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 20),
      ),
    );
  }

  Widget _buildGlassDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<JobStatus>(
          value: _status,
          isExpanded: true,
          dropdownColor: LiquidGlass.bgSurface,
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
    );
  }
}
