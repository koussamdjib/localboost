import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/providers/auth_provider.dart';

part 'change_password/change_password_page_actions.dart';
part 'change_password/change_password_page_view.dart';
part 'change_password/change_password_page_form_section.dart';
part 'change_password/change_password_page_field.dart';

/// Change Password Page
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  void _setCurrentPasswordObscured(bool value) {
    setState(() {
      _obscureCurrentPassword = value;
    });
  }

  void _setNewPasswordObscured(bool value) {
    setState(() {
      _obscureNewPassword = value;
    });
  }

  void _setConfirmPasswordObscured(bool value) {
    setState(() {
      _obscureConfirmPassword = value;
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildChangePasswordScaffold();
  }
}
