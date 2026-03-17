import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_merchant/models/staff_member.dart';
import 'package:localboost_merchant/providers/staff_provider.dart';

/// Screen to manage staff members (scanner-only access).
class StaffManagementScreen extends StatelessWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des employés'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStaffDialog(context),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Ajouter un employé'),
      ),
      body: Consumer<StaffProvider>(
        builder: (context, provider, _) {
          if (provider.staff.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.badge_outlined, size: 72, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun employé enregistré',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les employés peuvent accéder au scanner\navec leur code PIN sans connexion.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: provider.staff.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final member = provider.staff[index];
              return _StaffCard(
                member: member,
                onDelete: () => _confirmDelete(context, provider, member),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddStaffDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Nouvel employé'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'employé',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nom requis'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: pinCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Code PIN (4 chiffres)',
                    prefixIcon: Icon(Icons.pin_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.length != 4) return 'PIN 4 chiffres requis';
                    if (int.tryParse(v) == null) return 'Chiffres uniquement';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<StaffProvider>().addStaff(
                        name: nameCtrl.text.trim(),
                        pin: pinCtrl.text.trim(),
                      );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    StaffProvider provider,
    StaffMember member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet employé ?'),
        content: Text('${member.name} sera retiré de la liste.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      provider.removeStaff(member.id);
    }
  }
}

class _StaffCard extends StatelessWidget {
  final StaffMember member;
  final VoidCallback onDelete;

  const _StaffCard({required this.member, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.12),
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(member.name),
        subtitle: const Text('Accès scanner uniquement · PIN ••••'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
          tooltip: 'Supprimer',
        ),
      ),
    );
  }
}
