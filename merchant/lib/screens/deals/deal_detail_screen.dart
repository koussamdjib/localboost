import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_merchant/models/deal.dart';
import 'package:localboost_merchant/providers/deal_provider.dart';
import 'package:localboost_merchant/screens/deals/deal_form_screen.dart';
import 'package:localboost_merchant/widgets/deals/deal_detail_analytics_card.dart';
import 'package:localboost_merchant/widgets/deals/deal_detail_info_cards.dart';
import 'package:localboost_merchant/widgets/deals/deal_status_chip.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class DealDetailScreen extends StatefulWidget {
  final Deal deal;

  const DealDetailScreen({super.key, required this.deal});

  @override
  State<DealDetailScreen> createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends State<DealDetailScreen> {
  late Deal _deal;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _deal = widget.deal;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDeal(trackView: true);
    });
  }

  Future<void> _refreshDeal({bool trackView = false}) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    final provider = context.read<DealProvider>();
    Deal? loadedDeal;

    if (trackView) {
      loadedDeal = await provider.recordDealView(_deal.id);
    }

    loadedDeal ??= await provider.loadDealById(_deal.id);
    if (!mounted) {
      return;
    }

    final refreshedDeal = loadedDeal;
    if (refreshedDeal != null) {
      setState(() {
        _deal = refreshedDeal;
      });
    }

    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> _shareDeal(BuildContext shareContext) async {
    final RenderBox? renderBox = shareContext.findRenderObject() as RenderBox?;
    final shareOrigin = renderBox == null
        ? null
        : renderBox.localToGlobal(Offset.zero) & renderBox.size;

    try {
      final result = await Share.share(
        _buildShareMessage(),
        subject: _deal.title,
        sharePositionOrigin: shareOrigin,
      );

      if (!mounted || result.status != ShareResultStatus.success) {
        return;
      }

      final trackedDeal = await context.read<DealProvider>().recordDealShare(_deal.id);
      if (!mounted) {
        return;
      }

      if (trackedDeal != null) {
        setState(() {
          _deal = trackedDeal;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deal shared.')),
        );
        return;
      }

      final error = context.read<DealProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Deal shared, but analytics could not be updated.'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to share this deal right now.')),
      );
    }
  }

  Future<void> _openEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DealFormScreen(deal: _deal)),
    );

    if (!mounted) {
      return;
    }
    await _refreshDeal();
  }

  Future<void> _activateDraftDeal() async {
    final success = await context.read<DealProvider>().activateDeal(_deal.id);
    if (!mounted) {
      return;
    }

    if (!success) {
      final error = context.read<DealProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Unable to activate this deal.')),
      );
      return;
    }

    await _refreshDeal();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deal activated.')),
    );
  }

  Future<void> _archiveDeal() async {
    final shouldArchive = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive deal'),
        content: Text('Do you want to archive "${_deal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (shouldArchive != true || !mounted) {
      return;
    }

    final provider = context.read<DealProvider>();
    final success = await provider.deleteDeal(_deal.id);
    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Unable to archive this deal.')),
      );
      return;
    }

    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deal archived.')),
    );
  }

  String _buildShareMessage() {
    final description = _deal.description.trim();
    final day = _deal.endDate.day.toString().padLeft(2, '0');
    final month = _deal.endDate.month.toString().padLeft(2, '0');
    final sections = <String>[
      _deal.title,
      if (description.isNotEmpty) description,
      'Offer type: ${_deal.dealType.displayName}',
      'Valid until $day/$month/${_deal.endDate.year}',
    ];
    return sections.join('\n');
  }

  Color _dealTypeColor(DealType type) {
    switch (type) {
      case DealType.flashSale:
        return Colors.orange;
      case DealType.loyalty:
        return Colors.green;
      case DealType.standard:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DealProvider>();
    final isBusy = _isRefreshing || provider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deal details'),
        actions: [
          Builder(
            builder: (shareContext) => IconButton(
              tooltip: 'Share',
              onPressed: isBusy ? null : () => _shareDeal(shareContext),
              icon: const Icon(Icons.share_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: isBusy ? null : _refreshDeal,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: isBusy ? null : _openEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshDeal,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _deal.title,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DealStatusChip(status: _deal.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _dealTypeColor(_deal.dealType).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          _deal.dealType.displayName,
                          style: TextStyle(
                            color: _dealTypeColor(_deal.dealType),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_deal.maxEnrollments != null)
                        Chip(label: Text('Max: ${_deal.maxEnrollments}')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DealDetailAnalyticsCard(deal: _deal),
                  const SizedBox(height: 12),
                  DealDetailInfoCards(deal: _deal),
                ],
              ),
            ),
            if (isBusy)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : _openEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 8),
            if (_deal.status == DealStatus.draft)
              Expanded(
                child: FilledButton.icon(
                  onPressed: isBusy ? null : _activateDraftDeal,
                  icon: const Icon(Icons.publish_outlined),
                  label: const Text('Publish'),
                ),
              ),
            if (_deal.status == DealStatus.draft) const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: isBusy ? null : _archiveDeal,
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Archive'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
