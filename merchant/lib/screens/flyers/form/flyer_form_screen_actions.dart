part of '../flyer_form_screen.dart';

extension _FlyerFormScreenActions on _FlyerFormScreenState {
  Future<DateTime?> _selectDate(DateTime initial) async {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  Future<void> _pickFile() async {
    try {
      _setStateSafe(() => _isLoadingFile = true);

      final FileType fileType;
      final List<String>? allowedExtensions;
      if (_selectedType == FlyerType.pdf) {
        fileType = FileType.custom;
        allowedExtensions = ['pdf'];
      } else {
        fileType = FileType.image;
        allowedExtensions = null;
      }

      final result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions,
        withData: true, // always get bytes — required on web
      );

      if (result == null || result.files.isEmpty || !mounted) return;

      final picked = result.files.single;
      final bytes = picked.bytes;
      if (bytes == null || bytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible de lire le fichier.')),
          );
        }
        return;
      }

      _setStateSafe(() {
        _selectedFileBytes = bytes;
        _selectedFilePath = picked.name;
        _useUrlInput = false;
        _fileUrlController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection du fichier: $e')),
        );
      }
    } finally {
      _setStateSafe(() => _isLoadingFile = false);
    }
  }

  Future<void> _saveFlyer({required bool draft}) async {
    try {
      await _doSaveFlyer(draft: draft);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur inattendue: $e')),
        );
      }
    }
  }

  Future<void> _doSaveFlyer({required bool draft}) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      // Scroll to top so the user can see validation errors
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs requis.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner les dates')),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début'),
        ),
      );
      return;
    }

    final manualFileUrl = _fileUrlController.text.trim();
    final hasExistingFileUrl = widget.flyer?.fileUrl?.trim().isNotEmpty ?? false;

    if (_useUrlInput) {
      final parsedUrl = Uri.tryParse(manualFileUrl);
      final isValidHttpUrl = parsedUrl != null &&
          (parsedUrl.scheme == 'http' || parsedUrl.scheme == 'https') &&
          parsedUrl.host.isNotEmpty;

      if (!isValidHttpUrl) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez saisir une URL valide (http/https).'),
          ),
        );
        return;
      }
    } else {
      final hasSelectedFile = _selectedFileBytes != null;
      if (!hasSelectedFile && !hasExistingFileUrl) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ajoutez un fichier ou passez en mode URL.'),
          ),
        );
        return;
      }
    }

    final shopProvider = context.read<ShopProvider>();
    final flyerProvider = context.read<FlyerProvider>();

    // Load shops if not yet available (e.g. after a web page refresh)
    if (shopProvider.selectedShop == null && !shopProvider.isLoading) {
      await shopProvider.loadMyShops();
    }

    if (!mounted) return;

    final selectedShop = shopProvider.selectedShop;

    if (selectedShop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aucune boutique trouvée. Vérifiez votre connexion ou reconnectez-vous.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final flyer = Flyer(
      id: widget.flyer?.id ?? '',
      shopId: widget.flyer?.shopId ?? selectedShop.id.toString(),
      storeName: selectedShop.name,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      validUntil:
          'Valable jusqu\'au ${DateFormat('dd MMMM', 'fr').format(_endDate!)}',
      fileType: _selectedType,
      category: _flyerCategoryFromShopCategory(selectedShop.category),
      status: draft ? FlyerStatus.draft : FlyerStatus.published,
      startDate: _startDate,
      endDate: _endDate,
      publishedDate: widget.flyer?.publishedDate ?? DateTime.now(),
      createdAt: widget.flyer?.createdAt ?? DateTime.now(),
      viewCount: widget.flyer?.viewCount ?? 0,
      shareCount: widget.flyer?.shareCount ?? 0,
      storeLogoUrl: selectedShop.logo,
      latitude: selectedShop.latitude ?? 0,
      longitude: selectedShop.longitude ?? 0,
      fileUrl: _useUrlInput ? manualFileUrl : widget.flyer?.fileUrl,
      thumbnailUrl: widget.flyer?.thumbnailUrl,
    );

    final success = isEdit
        ? await flyerProvider.updateFlyer(
            flyer.id,
            flyer,
            fileBytes: _useUrlInput ? null : _selectedFileBytes,
            fileName: _useUrlInput ? null : _selectedFilePath,
          )
        : await flyerProvider.createFlyer(
            flyer,
            fileBytes: _useUrlInput ? null : _selectedFileBytes,
            fileName: _useUrlInput ? null : _selectedFilePath,
          );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(draft ? 'Brouillon enregistré' : 'Circulaire publiée'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            flyerProvider.error ?? 'Erreur lors de la sauvegarde de la circulaire',
          ),
        ),
      );
    }
  }

  FlyerCategory _flyerCategoryFromShopCategory(String? shopCategory) {
    switch ((shopCategory ?? '').toLowerCase()) {
      case 'restaurant':
        return FlyerCategory.restaurant;
      case 'cafe':
      case 'bakery':
        return FlyerCategory.bakery;
      case 'supermarket':
        return FlyerCategory.supermarket;
      case 'electronics':
        return FlyerCategory.electronics;
      case 'pharmacy':
        return FlyerCategory.pharmacy;
      case 'sports':
        return FlyerCategory.sports;
      case 'fashion':
        return FlyerCategory.fashion;
      default:
        return FlyerCategory.other;
    }
  }
}
