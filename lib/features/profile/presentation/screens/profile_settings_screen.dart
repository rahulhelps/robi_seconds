import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/storage/user_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/profile_bloc.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _professionalHeadlineController = TextEditingController();
  final _careerObjectiveController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _dobController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _institutionController = TextEditingController();
  final _skillInputController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _currentCompanyController = TextEditingController();
  final _currentDesignationController = TextEditingController();
  final _yearsInCurrentRoleController = TextEditingController();
  final _noticePeriodController = TextEditingController();
  final _expectedSalaryController = TextEditingController();

  String? _gender;
  String? _experienceYears;
  String? _educationLevel;
  String? _maritalStatus;
  String? _avatarUrl;
  List<String> _skills = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isChangingPassword = false;

  final List<String> _suggestedSkills = [
    'Flutter',
    'Dart',
    'Laravel',
    'PHP',
    'Python',
    'React',
    'JavaScript',
    'SQL',
    'Git',
    'Project Management',
    'UI/UX Design',
    'Data Analysis',
    'SEO',
    'Communication',
  ];

  @override
  void initState() {
    super.initState();
    _populateFromState();
  }

  void _populateFromState() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      final p = state.profile;
      _nameController.text = p.name;
      _emailController.text = p.email;
      _phoneController.text = p.phone;
      _jobTitleController.text = p.jobTitle;
      _professionalHeadlineController.text = p.professionalHeadline;
      _careerObjectiveController.text = p.careerObjective;
      _bioController.text = p.bio;
      _addressController.text = p.address;
      _permanentAddressController.text = p.permanentAddress;
      _dobController.text = p.dateOfBirth;
      _gender = p.gender.isNotEmpty ? p.gender : null;
      _nationalityController.text = p.nationality.isNotEmpty ? p.nationality : 'Bangladeshi';
      _experienceYears = p.experienceYears.isNotEmpty ? p.experienceYears : null;
      _educationLevel = p.educationLevel.isNotEmpty ? p.educationLevel : null;
      _institutionController.text = p.institution;
      _linkedinController.text = p.linkedinUrl;
      _githubController.text = p.githubUrl;
      _portfolioController.text = p.portfolioUrl;
      _avatarUrl = p.avatarUrl;
      _skills = List.from(p.skills);
      _fatherNameController.text = p.fatherName;
      _motherNameController.text = p.motherName;
      _currentCompanyController.text = p.currentCompany;
      _currentDesignationController.text = p.currentDesignation;
      _yearsInCurrentRoleController.text = p.yearsInCurrentRole;
      _noticePeriodController.text = p.noticePeriod;
      _expectedSalaryController.text = p.expectedSalary;
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _professionalHeadlineController.dispose();
    _careerObjectiveController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _permanentAddressController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _institutionController.dispose();
    _skillInputController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _currentCompanyController.dispose();
    _currentDesignationController.dispose();
    _yearsInCurrentRoleController.dispose();
    _noticePeriodController.dispose();
    _expectedSalaryController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null && mounted) {
      context.read<ProfileBloc>().add(
            UploadAvatarEvent(picked.path, picked.name, 'image/jpeg'),
          );
      setState(() {
        _avatarUrl = picked.path;
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    DateTime initial = DateTime(2000, 1, 1);
    if (_dobController.text.isNotEmpty) {
      try {
        initial = DateTime.parse(_dobController.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Color(0xFF191C1D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _addSkill(String skill) {
    final clean = skill.trim();
    if (clean.isNotEmpty && !_skills.contains(clean)) {
      setState(() {
        _skills.add(clean);
        _skillInputController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (!_isInitialized && state is ProfileLoaded) {
          _populateFromState();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Complete Your Profile',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: Text(
                'Save',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Avatar Card ──────────────────────────────────────────
                _buildAvatarSection(),
                const SizedBox(height: 20),

                // ── 2. Personal Information Section ────────────────────────
                _buildSectionHeader('Personal Information', Icons.person_rounded),
                const SizedBox(height: 12),
                _buildCard([
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'e.g. Tanvir Ahmed',
                    icon: Icons.badge_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'tanvir@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: '+880 1712 345678',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectDateOfBirth,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller: _dobController,
                              label: 'Date of Birth',
                              hint: 'YYYY-MM-DD',
                              icon: Icons.calendar_month_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Gender',
                          value: _gender,
                          icon: Icons.people_alt_outlined,
                          items: const ['Male', 'Female', 'Other'],
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nationalityController,
                    label: 'Nationality',
                    hint: 'Bangladeshi',
                    icon: Icons.flag_outlined,
                  ),
                  const SizedBox(height: 16),
                   _buildTextField(
                     controller: _addressController,
                     label: 'Present Address',
                     hint: 'e.g. Dhanmondi, Dhaka, Bangladesh',
                     icon: Icons.location_on_outlined,
                   ),
                   const SizedBox(height: 16),
                   _buildTextField(
                     controller: _permanentAddressController,
                     label: 'Permanent Address',
                     hint: 'e.g. House #12, Road #5, Dhanmondi, Dhaka-1209',
                     icon: Icons.home_outlined,
                   ),
                 ]),
                 const SizedBox(height: 24),

                 // ── 2b. Family Information ───────────────────────────────────
                 _buildSectionHeader('Family Information', Icons.family_restroom_rounded),
                 const SizedBox(height: 12),
                 _buildCard([
                   Row(
                     children: [
                       Expanded(
                         child: _buildTextField(
                           controller: _fatherNameController,
                           label: "Father's Name",
                           hint: 'e.g. Late Rafiqul Islam',
                           icon: Icons.man_2_outlined,
                         ),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: _buildTextField(
                           controller: _motherNameController,
                           label: "Mother's Name",
                           hint: 'e.g. Rahima Begum',
                           icon: Icons.woman_2_outlined,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   _buildDropdown(
                     label: 'Marital Status',
                     value: _maritalStatus,
                     icon: Icons.favorite_border_rounded,
                     items: const ['Single', 'Married', 'Divorced', 'Widowed'],
                     onChanged: (v) => setState(() => _maritalStatus = v),
                   ),
                 ]),
                 const SizedBox(height: 24),

                // ── 3. Professional Background ──────────────────────────────
                _buildSectionHeader('Professional Background', Icons.work_rounded),
                const SizedBox(height: 12),
                 _buildCard([
                   _buildTextField(
                     controller: _professionalHeadlineController,
                     label: 'Professional Headline',
                     hint: 'e.g. Senior Full Stack Developer | 6+ Years Experience',
                     icon: Icons.vertical_align_center_outlined,
                   ),
                   const SizedBox(height: 16),
                   _buildTextField(
                     controller: _jobTitleController,
                     label: 'Current Job Title',
                     hint: 'e.g. Senior Full Stack Software Engineer',
                     icon: Icons.business_center_outlined,
                   ),
                   const SizedBox(height: 16),
                   Row(
                     children: [
                       Expanded(
                         child: _buildTextField(
                           controller: _currentCompanyController,
                           label: 'Current Company',
                           hint: 'e.g. ABC Technologies',
                           icon: Icons.apartment_outlined,
                         ),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: _buildTextField(
                           controller: _currentDesignationController,
                           label: 'Current Designation',
                           hint: 'e.g. Senior Engineer',
                           icon: Icons.badge_outlined,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   Row(
                     children: [
                       Expanded(
                         child: _buildTextField(
                           controller: _yearsInCurrentRoleController,
                           label: 'Years in Current Role',
                           hint: 'e.g. 3 years',
                           icon: Icons.timelapse_outlined,
                         ),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: _buildTextField(
                           controller: _noticePeriodController,
                           label: 'Notice Period',
                           hint: 'e.g. 30 days',
                           icon: Icons.notifications_active_outlined,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   _buildTextField(
                     controller: _expectedSalaryController,
                     label: 'Expected Salary',
                     hint: 'e.g. BDT 120,000 - 150,000',
                     icon: Icons.attach_money_rounded,
                   ),
                   const SizedBox(height: 16),
                   _buildDropdown(
                     label: 'Experience Level',
                     value: _experienceYears,
                     icon: Icons.trending_up_rounded,
                     items: const [
                       'Entry-level (< 1 year)',
                       'Junior (1 - 2 years)',
                       'Mid-level (3 - 5 years)',
                       'Senior (5 - 8 years)',
                       'Lead / Executive (8+ years)',
                     ],
                     onChanged: (v) => setState(() => _experienceYears = v),
                   ),
                   const SizedBox(height: 16),
                   _buildDropdown(
                     label: 'Highest Education Level',
                     value: _educationLevel,
                     icon: Icons.school_outlined,
                     items: const [
                       'SSC / O-Level',
                       'HSC / A-Level',
                       "Bachelor's / Honours",
                       "Master's Degree",
                       'Diploma / Technical',
                       'Doctorate / PhD',
                     ],
                     onChanged: (v) => setState(() => _educationLevel = v),
                   ),
                   const SizedBox(height: 16),
                   _buildTextField(
                     controller: _institutionController,
                     label: 'College / University',
                     hint: 'e.g. University of Dhaka',
                     icon: Icons.account_balance_outlined,
                   ),
                   const SizedBox(height: 16),
                   _buildTextField(
                     controller: _bioController,
                     label: 'Professional Summary / Bio',
                     hint: 'Brief summary of your skills, achievements, and career aspirations...',
                     icon: Icons.notes_rounded,
                     maxLines: 4,
                   ),
                   const SizedBox(height: 16),
                   _buildTextField(
                     controller: _careerObjectiveController,
                     label: 'Career Objective',
                     hint: 'What are your career goals and aspirations?',
                     icon: Icons.flag_rounded,
                     maxLines: 3,
                   ),
                 ]),
                const SizedBox(height: 24),

                // ── 4. Skills & Expertise ───────────────────────────────────
                _buildSectionHeader('Skills & Competencies', Icons.stars_rounded),
                const SizedBox(height: 12),
                _buildCard([
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _skillInputController,
                          label: 'Add a Skill',
                          hint: 'e.g. React, Flutter, Python...',
                          icon: Icons.code_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onPressed: () => _addSkill(_skillInputController.text),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Display current skills
                  if (_skills.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills.map((skill) {
                        return Chip(
                          label: Text(
                            skill,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          deleteIcon: const Icon(Icons.close_rounded, size: 16, color: AppColors.primary),
                          onDeleted: () => _removeSkill(skill),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                  ],
                  // Suggested skills
                  Text(
                    'Suggestions (tap to add):',
                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _suggestedSkills.where((s) => !_skills.contains(s)).take(8).map((s) {
                      return ActionChip(
                        label: Text('+ $s', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569))),
                        backgroundColor: const Color(0xFFF1F5F9),
                        onPressed: () => _addSkill(s),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ]),
                const SizedBox(height: 24),

                // ── 5. Social & Portfolio Links ─────────────────────────────
                _buildSectionHeader('Online Presence & Social Links', Icons.link_rounded),
                const SizedBox(height: 12),
                _buildCard([
                  _buildTextField(
                    controller: _linkedinController,
                    label: 'LinkedIn Profile',
                    hint: 'https://linkedin.com/in/username',
                    icon: Icons.link_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _githubController,
                    label: 'GitHub Profile',
                    hint: 'https://github.com/username',
                    icon: Icons.code_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _portfolioController,
                    label: 'Personal Website / Portfolio',
                    hint: 'https://yourwebsite.com',
                    icon: Icons.public_rounded,
                  ),
                 ]),
                 const SizedBox(height: 24),

                 // ── 5. Social & Portfolio Links ─────────────────────────────
                 _buildSectionHeader('Online Presence & Social Links', Icons.link_rounded),
                 const SizedBox(height: 12),
                 _buildCard([
                   _buildTextField(
                     controller: _linkedinController,
                     label: 'LinkedIn Profile',
                     hint: 'https://linkedin.com/in/username',
                     icon: Icons.link_rounded,
                   ),
                   const SizedBox(height: 16),
                   _buildTextField(
                     controller: _githubController,
                     label: 'GitHub Profile',
                     hint: 'https://github.com/username',
                     icon: Icons.code_rounded,
                   ),
                   const SizedBox(height: 16),
                   _buildTextField(
                     controller: _portfolioController,
                     label: 'Personal Website / Portfolio',
                     hint: 'https://yourwebsite.com',
                     icon: Icons.public_rounded,
                   ),
                 ]),
                 const SizedBox(height: 24),

                 // ── 6. Change Password ───────────────────────────────────────
                 _buildSectionHeader('Change Password', Icons.lock_outline_rounded),
                 const SizedBox(height: 12),
                 _buildCard([
                   _buildTextField(
                     controller: _currentPasswordController,
                     label: 'Current Password',
                     hint: 'Enter your current password',
                     icon: Icons.lock_rounded,
                     obscureText: true,
                   ),
                   const SizedBox(height: 16),
                   _buildTextField(
                     controller: _newPasswordController,
                     label: 'New Password',
                     hint: 'Min 6 characters',
                     icon: Icons.lock_open_rounded,
                     obscureText: true,
                   ),
                   const SizedBox(height: 16),
                   _buildTextField(
                     controller: _confirmPasswordController,
                     label: 'Confirm New Password',
                     hint: 'Re-enter new password',
                     icon: Icons.check_circle_outline_rounded,
                     obscureText: true,
                   ),
                 ]),
                 const SizedBox(height: 12),
                 SizedBox(
                   height: 48,
                   child: ElevatedButton.icon(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppColors.primary,
                       foregroundColor: Colors.white,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                       elevation: 2,
                     ),
                     onPressed: _isChangingPassword ? null : _changePassword,
                     icon: _isChangingPassword
                         ? const SizedBox(
                             width: 18,
                             height: 18,
                             child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                           )
                         : const Icon(Icons.lock_reset_rounded, size: 18),
                     label: Text(
                       _isChangingPassword ? 'Updating...' : 'Change Password',
                       style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                     ),
                   ),
                 ),
                 const SizedBox(height: 32),

                 // ── 7. Save Action Button ───────────────────────────────────
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    onPressed: _isLoading ? null : _saveProfile,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline_rounded, size: 20),
                    label: Text(
                      _isLoading ? 'Saving Profile...' : 'Save & Update Profile',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                    ? NetworkImage(_avatarUrl!)
                    : null,
                child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                    ? const Icon(Icons.person_rounded, size: 40, color: AppColors.primary)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isNotEmpty ? _nameController.text : 'Your Name',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _jobTitleController.text.isNotEmpty ? _jobTitleController.text : 'Add job title & details',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Text(
                    'Change Profile Photo',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      obscureText: obscureText,
      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'job_title': _jobTitleController.text.trim(),
      'professional_headline': _professionalHeadlineController.text.trim(),
      'career_objective': _careerObjectiveController.text.trim(),
      'bio': _bioController.text.trim(),
      'address': _addressController.text.trim(),
      'permanent_address': _permanentAddressController.text.trim(),
      'date_of_birth': _dobController.text.trim(),
      'gender': _gender ?? '',
      'nationality': _nationalityController.text.trim(),
      'experience_years': _experienceYears ?? '',
      'education_level': _educationLevel ?? '',
      'institution': _institutionController.text.trim(),
      'skills': _skills,
      'linkedin_url': _linkedinController.text.trim(),
      'github_url': _githubController.text.trim(),
      'portfolio_url': _portfolioController.text.trim(),
      'marital_status': _maritalStatus ?? '',
      'father_name': _fatherNameController.text.trim(),
      'mother_name': _motherNameController.text.trim(),
      'current_company': _currentCompanyController.text.trim(),
      'current_designation': _currentDesignationController.text.trim(),
      'years_in_current_role': _yearsInCurrentRoleController.text.trim(),
      'notice_period': _noticePeriodController.text.trim(),
      'expected_salary': _expectedSalaryController.text.trim(),
    };

    try {
      final response = await AuthService.authenticatedPatch('/profile', payload);

      if (response['__status'] == 401) {
        throw 'Session expired. Please log in again.';
      }

      final success = response['success'] == true;
      if (!success) {
        throw response['message'] ?? 'Failed to update profile';
      }

      final data = response['data'] as Map<String, dynamic>? ?? response;
      await UserStorage.saveUser(data);

      if (!mounted) return;

      // Update ProfileBloc so dashboard immediately reflects changes
      context.read<ProfileBloc>().add(const FetchProfile(forceNetwork: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Profile saved and updated successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your current password.'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 6 characters.'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      final response = await AuthService.changePassword(
        currentPassword: current,
        password: newPass,
        passwordConfirmation: confirm,
      );

      if (response['__status'] == 401) {
        throw 'Session expired. Please log in again.';
      }

      final success = response['success'] == true;
      if (!success) {
        throw response['message'] ?? 'Failed to change password';
      }

      if (!mounted) return;

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Password changed successfully!'),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isChangingPassword = false);
    }
  }
}
