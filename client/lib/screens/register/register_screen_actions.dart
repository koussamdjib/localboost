part of '../register_screen.dart';

extension _RegisterScreenActions on _RegisterScreenState {
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      phoneNumber: _optionalPhoneNumber(),
      role: UserRole.customer,
    );

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    if (!mounted) return;

    _showErrorSnackBar(authProvider.error ?? 'Erreur d\'inscription');
  }

  String? _optionalPhoneNumber() {
    final phone = _phoneController.text.trim();
    return phone.isEmpty ? null : phone;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
