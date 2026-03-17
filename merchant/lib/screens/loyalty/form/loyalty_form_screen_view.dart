part of '../loyalty_form_screen.dart';

extension _LoyaltyFormScreenView on _LoyaltyFormScreenState {
  Widget _buildLoyaltyFormScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.program == null
              ? 'Créer un programme'
              : 'Modifier le programme',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTextField('Titre du programme', _titleController,
                  required: true),
              const SizedBox(height: 16),
              _buildTextField(
                'Description',
                _descriptionController,
                required: true,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Nombre de timbres requis',
                _stampsController,
                required: true,
                isNumber: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Description de la récompense',
                _rewardController,
                required: true,
              ),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
