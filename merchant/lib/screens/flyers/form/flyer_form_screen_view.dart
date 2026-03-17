part of '../flyer_form_screen.dart';

extension _FlyerFormScreenView on _FlyerFormScreenState {
  Widget _buildFlyerFormScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier la circulaire' : 'Nouvelle circulaire'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildTypeSelector(),
              const SizedBox(height: 16),
              _buildFileUploadSection(),
              const SizedBox(height: 16),
              _buildDateFields(),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }
}
