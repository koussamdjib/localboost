part of '../login_screen.dart';

extension _LoginScreenActions on _LoginScreenState {
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      return;
    }
    if (!mounted) return;

    _showErrorSnackBar(authProvider.error ?? 'Erreur de connexion');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _openRegisterScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ClientRegisterScreen(),
      ),
    );
  }
}
