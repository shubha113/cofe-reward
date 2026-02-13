import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _companyNameController;
  late TextEditingController _companyTypeController;
  late TextEditingController _jobTitleController;
  late TextEditingController _locationController;
  late TextEditingController _addressController;
  late TextEditingController _purchaseLocationController;
  late TextEditingController _referrerController;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _companyNameController = TextEditingController(
      text: widget.userData['company_name'],
    );
    _companyTypeController = TextEditingController(
      text: widget.userData['company_type'],
    );
    _jobTitleController = TextEditingController(
      text: widget.userData['job_title'],
    );
    _locationController = TextEditingController(
      text: widget.userData['location'],
    );
    _addressController = TextEditingController(
      text: widget.userData['address'],
    );
    _purchaseLocationController = TextEditingController(
      text: widget.userData['purchase_location'],
    );
    _referrerController = TextEditingController(
      text: widget.userData['referrer'],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    _companyTypeController.dispose();
    _jobTitleController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _purchaseLocationController.dispose();
    _referrerController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      final result = await _profileService.updateProfile(
        name: _nameController.text.trim(),
        companyName: _companyNameController.text.trim(),
        companyType: _companyTypeController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        location: _locationController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        purchaseLocation: _purchaseLocationController.text.trim().isEmpty
            ? null
            : _purchaseLocationController.text.trim(),
        referrer: _referrerController.text.trim().isEmpty
            ? null
            : _referrerController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _showSnack('Profile updated successfully!', isSuccess: true);
        // Return updated data to profile screen
        Navigator.pop(context, true);
      } else {
        _showSnack(result['message'] ?? 'Update failed');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green : AppColors.primaryRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        title: 'Personal Information',
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _jobTitleController,
                            label: 'Job Title',
                            icon: Icons.work_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Job title is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildSection(
                        title: 'Company Information',
                        children: [
                          _buildTextField(
                            controller: _companyNameController,
                            label: 'Company Name',
                            icon: Icons.business_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Company name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _companyTypeController,
                            label: 'Company Type',
                            icon: Icons.category_outlined,
                            hint: 'e.g., Distributor, Installer, Retailer',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Company type is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildSection(
                        title: 'Location Information',
                        children: [
                          _buildTextField(
                            controller: _locationController,
                            label: 'Location',
                            icon: Icons.location_on_outlined,
                            hint: 'City, State',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Location is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _addressController,
                            label: 'Address (Optional)',
                            icon: Icons.home_outlined,
                            hint: 'Full address',
                            maxLines: 3,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildSection(
                        title: 'Additional Information',
                        children: [
                          _buildTextField(
                            controller: _purchaseLocationController,
                            label: 'Purchase Location (Optional)',
                            icon: Icons.store_outlined,
                            hint: 'Where you purchased Cofe products',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _referrerController,
                            label: 'Referrer (Optional)',
                            icon: Icons.person_add_outlined,
                            hint: 'Who referred you',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildUpdateButton(),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.greyBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.darkText),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Profile',
                  style: AppTextStyles.header3.copyWith(fontSize: 20),
                ),
                Text(
                  'Update your information',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryRed),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.greyText,
            ),
            filled: true,
            fillColor: AppColors.greyBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              borderSide: BorderSide(
                color: AppColors.borderGrey.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              borderSide: const BorderSide(
                color: AppColors.primaryRed,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              borderSide: const BorderSide(
                color: AppColors.primaryRed,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUpdating ? null : _handleUpdateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          elevation: 0,
        ),
        child: _isUpdating
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Update Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}
