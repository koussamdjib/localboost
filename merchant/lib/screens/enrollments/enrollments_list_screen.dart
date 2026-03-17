import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';
import 'package:localboost_merchant/widgets/enrollments/enrollment_card.dart';
import 'package:localboost_merchant/widgets/enrollments/enrollment_filters.dart';
import 'package:localboost_merchant/screens/enrollments/enrollment_details_screen.dart';

part 'list/enrollments_list_data.dart';
part 'list/enrollments_list_view.dart';
part 'list/enrollments_list_states.dart';

/// Screen displaying all customer enrollments for merchant's programs
class EnrollmentsListScreen extends StatefulWidget {
  const EnrollmentsListScreen({super.key});

  @override
  State<EnrollmentsListScreen> createState() => _EnrollmentsListScreenState();
}

class _EnrollmentsListScreenState extends State<EnrollmentsListScreen> {
  EnrollmentFilter _selectedFilter = EnrollmentFilter.all;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  void _setStateSafe(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return _buildEnrollmentsScreen();
  }
}
