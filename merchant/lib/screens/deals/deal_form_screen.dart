import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_merchant/models/deal.dart';
import 'package:localboost_merchant/providers/deal_provider.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';

part 'form/deal_form_screen_view.dart';
part 'form/deal_form_screen_fields.dart';
part 'form/deal_form_screen_actions.dart';

/// Form screen for creating/editing deals
class DealFormScreen extends StatefulWidget {
  final Deal? deal;

  const DealFormScreen({super.key, this.deal});

  @override
  State<DealFormScreen> createState() => _DealFormScreenState();
}

class _DealFormScreenState extends State<DealFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardValueController = TextEditingController();
  final _termsController = TextEditingController();
  final _stampsController = TextEditingController(text: '10');
  final _maxEnrollmentsController = TextEditingController();

  DealType _selectedDealType = DealType.flashSale;
  RewardType _selectedRewardType = RewardType.freeItem;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _hasMaxEnrollments = false;

  @override
  void initState() {
    super.initState();
    if (widget.deal != null) {
      _titleController.text = widget.deal!.title;
      _descriptionController.text = widget.deal!.description;
      _rewardValueController.text = widget.deal!.rewardValue;
      _termsController.text = widget.deal!.termsAndConditions;
      _stampsController.text = widget.deal!.stampsRequired.toString();
      _selectedDealType = widget.deal!.dealType;
      _selectedRewardType = widget.deal!.rewardType;
      _startDate = widget.deal!.startDate;
      _endDate = widget.deal!.endDate;
      if (widget.deal!.maxEnrollments != null) {
        _hasMaxEnrollments = true;
        _maxEnrollmentsController.text = widget.deal!.maxEnrollments.toString();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rewardValueController.dispose();
    _termsController.dispose();
    _stampsController.dispose();
    _maxEnrollmentsController.dispose();
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
    return _buildDealFormScreen();
  }
}
