import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/services/api/api_client.dart';

part 'edit_profile/edit_profile_page_save.dart';
part 'edit_profile/edit_profile_page_dialogs.dart';
part 'edit_profile/edit_profile_page_form_section.dart';
part 'edit_profile/edit_profile_page_text_field.dart';

/// Edit Profile Page - allows users to edit their profile information
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  bool _hasChanges = false;
  bool _isEmailChanged = false;
  String? _originalEmail;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _originalEmail = user.email;
    }

    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
    _countryController.addListener(_onFieldChanged);

    _loadCustomerProfile();
  }

  Future<void> _loadCustomerProfile() async {
    try {
      final response = await ApiClient.instance.get('customers/me/');
      final data = Map<String, dynamic>.from(response.data as Map);
      if (mounted) {
        _cityController.text = data['city'] as String? ?? '';
        _countryController.text = data['country'] as String? ?? '';
      }
    } catch (_) {}
  }

  void _onFieldChanged() {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      return;
    }

    setState(() {
      _hasChanges = _nameController.text != user.name ||
          _emailController.text != user.email ||
          _phoneController.text != (user.phoneNumber ?? '') ||
          _cityController.text.isNotEmpty ||
          _countryController.text.isNotEmpty;
      _isEmailChanged = _emailController.text != _originalEmail;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoalText),
          onPressed: () async {
            if (_hasChanges) {
              final nav = Navigator.of(context);
              final confirmationResult = await _showDiscardDialog();
              if (!mounted) return;
              if (confirmationResult != true) {
                return;
              }
              nav.pop();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Modifier le profil',
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveChanges,
              child: Text(
                'Enregistrer',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  _buildFormSection(),
                  const SizedBox(height: 32),
                  if (_hasChanges) _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
