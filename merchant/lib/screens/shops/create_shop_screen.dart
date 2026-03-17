import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:localboost_merchant/models/merchant_shop.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';
import 'package:localboost_merchant/widgets/shops/shop_form_fields.dart';
import 'package:localboost_merchant/widgets/shops/shop_form_gps_card.dart';
import 'package:localboost_merchant/widgets/shops/shop_form_image_picker.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController(text: 'Djibouti');
  final _countryController = TextEditingController(text: 'Djibouti');

  double? _latitude;
  double? _longitude;
  bool _loadingGps = false;

  Uint8List? _logoBytes;
  String? _logoFileName;
  Uint8List? _coverBytes;
  String? _coverFileName;

  MerchantShopStatus _status = MerchantShopStatus.draft;

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _getGpsLocation() async {
    setState(() => _loadingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service de localisation désactivé.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Permission de localisation refusée.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Localisation refusée. Activez-la dans les paramètres.'),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur GPS: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  Future<void> _pickImage({required bool isLogo}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty || !mounted) return;

      final picked = result.files.single;
      final bytes = picked.bytes;
      if (bytes == null || bytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible de lire l\'image.')),
          );
        }
        return;
      }

      setState(() {
        if (isLogo) {
          _logoBytes = bytes;
          _logoFileName = picked.name;
        } else {
          _coverBytes = bytes;
          _coverFileName = picked.name;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ShopProvider>();
    final created = await provider.createShop(
      name: _nameController.text.trim(),
      slug: _slugController.text.trim().isEmpty
          ? null
          : _slugController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      addressLine2: _addressLine2Controller.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? 'Djibouti'
          : _cityController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? 'Djibouti'
          : _countryController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      logoBytes: _logoBytes,
      logoFileName: _logoFileName,
      coverBytes: _coverBytes,
      coverFileName: _coverFileName,
      status: _status,
    );

    if (!mounted) return;

    if (created) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.error ?? 'Creation impossible.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ShopProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Creer une boutique')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              ShopFormFields(
                nameController: _nameController,
                slugController: _slugController,
                descriptionController: _descriptionController,
                categoryController: _categoryController,
                phoneController: _phoneController,
                emailController: _emailController,
                addressController: _addressController,
                addressLine2Controller: _addressLine2Controller,
                cityController: _cityController,
                countryController: _countryController,
                slugLabel: 'Slug (optionnel)',
              ),
              const SizedBox(height: 16),
              ShopFormGpsCard(
                latitude: _latitude,
                longitude: _longitude,
                isLoading: _loadingGps,
                onGetGps: _getGpsLocation,
                onClearGps: () => setState(() {
                  _latitude = null;
                  _longitude = null;
                }),
              ),
              const SizedBox(height: 16),
              ShopFormImagePicker(
                label: 'Logo',
                bytes: _logoBytes,
                fileName: _logoFileName,
                onPick: () => _pickImage(isLogo: true),
                onClear: () => setState(() {
                  _logoBytes = null;
                  _logoFileName = null;
                }),
              ),
              const SizedBox(height: 16),
              ShopFormImagePicker(
                label: 'Image de couverture',
                bytes: _coverBytes,
                fileName: _coverFileName,
                onPick: () => _pickImage(isLogo: false),
                onClear: () => setState(() {
                  _coverBytes = null;
                  _coverFileName = null;
                }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MerchantShopStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: MerchantShopStatus.values
                    .map(
                      (status) => DropdownMenuItem<MerchantShopStatus>(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _status = value);
                },
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: const Icon(Icons.save_outlined),
                label: Text(isLoading ? 'Creation...' : 'Creer la boutique'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
