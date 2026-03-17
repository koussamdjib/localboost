import 'package:flutter/material.dart';

/// The 10 text form fields shared by create and edit shop screens.
///
/// Does NOT include the Status dropdown (which appears below the image
/// pickers) or any image-related widgets. Use [slugLabel] to customise
/// the slug field hint between screens.
class ShopFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController slugController;
  final TextEditingController descriptionController;
  final TextEditingController categoryController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController addressLine2Controller;
  final TextEditingController cityController;
  final TextEditingController countryController;

  /// Label for the slug field. Defaults to `'Slug'`.
  final String slugLabel;

  const ShopFormFields({
    super.key,
    required this.nameController,
    required this.slugController,
    required this.descriptionController,
    required this.categoryController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.addressLine2Controller,
    required this.cityController,
    required this.countryController,
    this.slugLabel = 'Slug',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nom *'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le nom est requis.';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: slugController,
          decoration: InputDecoration(labelText: slugLabel),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: categoryController,
          decoration: const InputDecoration(labelText: 'Categorie'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: phoneController,
          decoration: const InputDecoration(labelText: 'Telephone'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          validator: (value) {
            final normalized = value?.trim() ?? '';
            if (normalized.isEmpty) return null;
            if (!normalized.contains('@')) return 'Email invalide.';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: addressController,
          decoration: const InputDecoration(labelText: 'Adresse *'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'L\'adresse est requise.';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: addressLine2Controller,
          decoration: const InputDecoration(labelText: 'Adresse (ligne 2)'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: cityController,
          decoration: const InputDecoration(labelText: 'Ville'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: countryController,
          decoration: const InputDecoration(labelText: 'Pays'),
        ),
      ],
    );
  }
}
