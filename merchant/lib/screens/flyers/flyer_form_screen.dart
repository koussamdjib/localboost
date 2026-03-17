import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/flyer.dart';
import 'package:localboost_merchant/providers/flyer_provider.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';

part 'form/flyer_form_screen_view.dart';
part 'form/flyer_form_screen_fields_primary.dart';
part 'form/flyer_form_screen_fields_dates_actions.dart';
part 'form/flyer_form_screen_actions.dart';
part 'form/flyer_form_screen_date_field.dart';

/// Flyer creation/edit form screen
class FlyerFormScreen extends StatefulWidget {
  final Flyer? flyer; // null for create, existing for edit

  const FlyerFormScreen({super.key, this.flyer});

  @override
  State<FlyerFormScreen> createState() => _FlyerFormScreenState();
}

class _FlyerFormScreenState extends State<FlyerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _fileUrlController;
  late FlyerType _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // File picker state (bytes-based — works on web and mobile)
  Uint8List? _selectedFileBytes;
  String? _selectedFilePath;
  bool _isLoadingFile = false;
  bool _useUrlInput = false;

  bool get isEdit => widget.flyer != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.flyer?.title);
    _descriptionController =
        TextEditingController(text: widget.flyer?.description);
    _fileUrlController = TextEditingController(text: widget.flyer?.fileUrl ?? '');
    _selectedType = widget.flyer?.fileType ?? FlyerType.image;
    _startDate = widget.flyer?.startDate ?? DateTime.now();
    _endDate =
        widget.flyer?.endDate ?? DateTime.now().add(const Duration(days: 7));
    _useUrlInput = _fileUrlController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fileUrlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setStateSafe(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return _buildFlyerFormScaffold();
  }
}
