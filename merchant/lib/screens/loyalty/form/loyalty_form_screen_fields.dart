part of '../loyalty_form_screen.dart';

extension _LoyaltyFormScreenFields on _LoyaltyFormScreenState {
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: required
          ? (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null
          : null,
    );
  }
}
