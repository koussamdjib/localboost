part of '../flyer_form_screen.dart';

extension _FlyerFormScreenDatesAndActions on _FlyerFormScreenState {
  Widget _buildDateFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackVertically = constraints.maxWidth < 360;
        final startField = _DateField(
          label: 'Date de début',
          date: _startDate,
          onTap: () async {
            final date = await _selectDate(_startDate ?? DateTime.now());
            if (date != null) _setStateSafe(() => _startDate = date);
          },
        );
        final endField = _DateField(
          label: 'Date de fin',
          date: _endDate,
          onTap: () async {
            final date = await _selectDate(_endDate ?? DateTime.now());
            if (date != null) _setStateSafe(() => _endDate = date);
          },
        );

        if (stackVertically) {
          return Column(
            children: [
              startField,
              const SizedBox(height: 12),
              endField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: startField),
            const SizedBox(width: 16),
            Expanded(child: endField),
          ],
        );
      },
    );
  }

  Widget _buildActions() {
    return Consumer<FlyerProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    provider.isLoading ? null : () => _saveFlyer(draft: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                  foregroundColor: Colors.white,
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enregistrer comme brouillon'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    provider.isLoading ? null : () => _saveFlyer(draft: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Publier'),
              ),
            ),
          ],
        );
      },
    );
  }
}
