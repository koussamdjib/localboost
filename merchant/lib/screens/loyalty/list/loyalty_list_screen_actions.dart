part of '../loyalty_list_screen.dart';

extension _LoyaltyListScreenActions on _LoyaltyListScreenState {
  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoyaltyFormScreen()),
    ).then((_) => _loadPrograms());
  }

  void _navigateToEdit(program) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoyaltyFormScreen(program: program)),
    ).then((_) => _loadPrograms());
  }

  Future<void> _activateProgram(String programId) async {
    final provider = context.read<LoyaltyProvider>();
    final success = await provider.activateProgram(programId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Programme activé' : 'Erreur')),
      );
    }
  }

  Future<void> _pauseProgram(String programId) async {
    final provider = context.read<LoyaltyProvider>();
    final success = await provider.pauseProgram(programId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Programme mis en pause' : 'Erreur')),
      );
    }
  }
  void _confirmDelete(program) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le programme'),
        content: Text('Voulez-vous vraiment supprimer "${program.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProgram(program.id);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProgram(String programId) async {
    final provider = context.read<LoyaltyProvider>();
    final success = await provider.deleteProgram(programId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Programme supprimé' : 'Erreur')),
      );
    }
  }

  void _navigateToDetail(BuildContext context, dynamic program) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoyaltyDetailScreen(program: program),
      ),
    ).then((_) => _loadPrograms());
  }
}
