import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:localboost_merchant/models/business_hours.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';

class EditBusinessHoursScreen extends StatefulWidget {
  final BusinessHours initialHours;

  const EditBusinessHoursScreen({
    super.key,
    required this.initialHours,
  });

  @override
  State<EditBusinessHoursScreen> createState() => _EditBusinessHoursScreenState();
}

class _EditBusinessHoursScreenState extends State<EditBusinessHoursScreen> {
  late Map<DayOfWeek, DaySchedule?> _draftSchedule;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _draftSchedule = Map<DayOfWeek, DaySchedule?>.from(widget.initialHours.schedule);
  }

  Future<void> _pickTime(DayOfWeek day, {required bool isOpening}) async {
    final current = _draftSchedule[day];
    if (current == null) {
      return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: isOpening ? current.openTime : current.closeTime,
      helpText: isOpening ? 'Heure d\'ouverture' : 'Heure de fermeture',
    );

    if (picked == null || !mounted) {
      return;
    }

    final updated = DaySchedule(
      openTime: isOpening ? picked : current.openTime,
      closeTime: isOpening ? current.closeTime : picked,
    );

    if (_toMinutes(updated.closeTime) <= _toMinutes(updated.openTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fermeture doit etre apres l\'ouverture.'),
        ),
      );
      return;
    }

    setState(() {
      _draftSchedule[day] = updated;
    });
  }

  void _toggleDay(DayOfWeek day, bool isOpen) {
    setState(() {
      if (isOpen) {
        _draftSchedule[day] ??= const DaySchedule(
          openTime: TimeOfDay(hour: 9, minute: 0),
          closeTime: TimeOfDay(hour: 18, minute: 0),
        );
      } else {
        _draftSchedule[day] = null;
      }
    });
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<ShopProvider>();
    final businessHours = BusinessHours(
      schedule: Map<DayOfWeek, DaySchedule?>.from(_draftSchedule),
    );

    final success = await provider.updateBusinessHours(businessHours);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.error ?? 'Mise a jour des horaires impossible.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier les horaires'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enregistrer'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const Text(
            'Definissez les heures d\'ouverture pour chaque jour.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...DayOfWeek.values.map(_buildDayCard),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: const Text('Sauvegarder'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(DayOfWeek day) {
    final schedule = _draftSchedule[day];
    final isOpen = schedule != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    day.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: isOpen,
                  onChanged: (value) => _toggleDay(day, value),
                ),
              ],
            ),
            if (schedule != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(day, isOpening: true),
                      icon: const Icon(Icons.login, size: 18),
                      label: Text('Ouvre: ${_formatTime(schedule.openTime)}'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(day, isOpening: false),
                      icon: const Icon(Icons.logout, size: 18),
                      label: Text('Ferme: ${_formatTime(schedule.closeTime)}'),
                    ),
                  ),
                ],
              ),
            ] else
              Text(
                'Ferme',
                style: TextStyle(color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
