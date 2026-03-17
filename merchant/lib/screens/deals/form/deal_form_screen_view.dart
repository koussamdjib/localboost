part of '../deal_form_screen.dart';

extension _DealFormScreenView on _DealFormScreenState {
  Widget _buildDealFormScreen() {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.deal == null ? 'Créer une offre' : 'Modifier l\'offre'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDealTypeSelector(),
              const SizedBox(height: 16),
              _buildTextField('Titre', _titleController, required: true),
              const SizedBox(height: 16),
              _buildTextField(
                'Description',
                _descriptionController,
                required: true,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField('Récompense', _rewardValueController,
                  required: true),
              const SizedBox(height: 16),
              _buildRewardTypeSelector(),
              const SizedBox(height: 16),
              if (_selectedDealType == DealType.loyalty) ...[
                _buildTextField(
                  'Nombre de timbres',
                  _stampsController,
                  required: true,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
              ],
              _buildDatePicker(
                'Date de début',
                _startDate,
                (date) => _setStateSafe(() => _startDate = date),
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                'Date de fin',
                _endDate,
                (date) => _setStateSafe(() => _endDate = date),
              ),
              const SizedBox(height: 16),
              _buildMaxEnrollmentsField(),
              const SizedBox(height: 16),
              _buildTextField(
                'Conditions générales',
                _termsController,
                required: true,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDealTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type d\'offre',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        RadioGroup<DealType>(
          groupValue: _selectedDealType,
          onChanged: (value) {
            if (value != null) {
              _setStateSafe(() => _selectedDealType = value);
            }
          },
          child: Column(
            children: [DealType.flashSale].map((type) {
              return RadioListTile<DealType>(
                title:
                    Text(type.displayName, style: const TextStyle(fontSize: 12)),
                value: type,
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardTypeSelector() {
    return DropdownButtonFormField<RewardType>(
      initialValue: _selectedRewardType,
      decoration: const InputDecoration(
        labelText: 'Type de récompense',
        border: OutlineInputBorder(),
      ),
      items: RewardType.values.map((type) {
        return DropdownMenuItem(value: type, child: Text(type.displayName));
      }).toList(),
      onChanged: (value) => _setStateSafe(() => _selectedRewardType = value!),
    );
  }
}
