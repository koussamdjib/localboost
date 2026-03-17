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

class EditShopScreen extends StatefulWidget {
  final MerchantShop shop;

  const EditShopScreen({super.key, required this.shop});

  @override
  State<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _slugController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;

  double? _latitude;
  double? _longitude;
  bool _loadingGps = false;

  Uint8List? _logoBytes;
  String? _logoFileName;
  Uint8List? _coverBytes;
  String? _coverFileName;

  late String _existingLogoUrl;
  late String _existingCoverUrl;

  late MerchantShopStatus _status;

  @override
  void initState() {
    super.initState();
    final shop = widget.shop;

    _nameController = TextEditingController(text: shop.name);
    _slugController = TextEditingController(text: shop.slug);
    _descriptionController = TextEditingController(text: shop.description);
    _categoryController = TextEditingController(text: shop.category);
    _phoneController = TextEditingController(text: shop.phoneNumber);
    _emailController = TextEditingController(text: shop.email);
    _addressController = TextEditingController(text: shop.address);
    _addressLine2Controller = TextEditingController(text: shop.addressLine2);
    _cityController = TextEditingController(text: shop.city);
    _countryController = TextEditingController(text: shop.country);

    _latitude = shop.latitude;
    _longitude = shop.longitude;

    _existingLogoUrl = shop.logo;
    _existingCoverUrl = shop.coverImage;

    _status = shop.status;
  }

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
    final updated = await provider.updateShop(
      shopId: widget.shop.id,
      name: _nameController.text.trim(),
      slug: _slugController.text.trim(),
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
      logo: _existingLogoUrl,
      coverImage: _existingCoverUrl,
      logoBytes: _logoBytes,
      logoFileName: _logoFileName,
      coverBytes: _coverBytes,
      coverFileName: _coverFileName,
      status: _status,
    );

    if (!mounted) return;

    if (updated) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.error ?? 'Mise a jour impossible.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ShopProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier la boutique')),
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
                existingUrl: _existingLogoUrl,
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
                existingUrl: _existingCoverUrl,
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
                label: Text(isLoading ? 'Enregistrement...' : 'Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
