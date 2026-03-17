import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_merchant/models/loyalty_program.dart';
import 'package:localboost_merchant/providers/loyalty_provider.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';

part 'form/loyalty_form_screen_view.dart';
part 'form/loyalty_form_screen_fields.dart';
part 'form/loyalty_form_screen_actions.dart';

/// Form screen for creating/editing loyalty programs
class LoyaltyFormScreen extends StatefulWidget {
  final LoyaltyProgram? program;

  const LoyaltyFormScreen({super.key, this.program});

  @override
  State<LoyaltyFormScreen> createState() => _LoyaltyFormScreenState();
}

class _LoyaltyFormScreenState extends State<LoyaltyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stampsController = TextEditingController(text: '10');
  final _rewardController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.program != null) {
      _titleController.text = widget.program!.title;
      _descriptionController.text = widget.program!.description;
      _stampsController.text = widget.program!.stampsRequired.toString();
      _rewardController.text = widget.program!.rewardDescription;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stampsController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLoyaltyFormScreen();
  }
}
