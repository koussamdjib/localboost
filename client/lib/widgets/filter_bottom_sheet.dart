import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/search_filter.dart';
import 'package:localboost_shared/providers/search_provider.dart';

part 'filter_bottom_sheet/filter_bottom_sheet_view.dart';
part 'filter_bottom_sheet/filter_bottom_sheet_sections.dart';
part 'filter_bottom_sheet/filter_bottom_sheet_chip.dart';

/// Bottom sheet for advanced filtering options
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late SearchFilter _filter;

  void _setFilter(SearchFilter value) {
    setState(() {
      _filter = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _filter = context.read<SearchProvider>().currentFilter;
  }

  void _applyFilters() {
    context.read<SearchProvider>().updateFilter(_filter);
    Navigator.pop(context);
  }

  void _resetFilters() {
    _setFilter(
      SearchFilter(
        query: _filter.query,
        sortBy: _filter.sortBy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildFilterBottomSheetScaffold();
  }
}
