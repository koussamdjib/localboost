part of '../flyer_form_screen.dart';

extension _FlyerFormScreenPrimaryFields on _FlyerFormScreenState {
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Titre *',
        hintText: 'Ex: Promotions de Mars',
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
          value?.isEmpty ?? true ? 'Le titre est requis' : null,
      maxLength: 100,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Décrivez les offres...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      maxLength: 300,
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type de fichier *',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        RadioGroup<FlyerType>(
          groupValue: _selectedType,
          onChanged: (value) {
            if (value != null) {
              _setStateSafe(() => _selectedType = value);
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stackVertically = constraints.maxWidth < 360;
              final options = [
                const RadioListTile<FlyerType>(
                  value: FlyerType.image,
                  title: Text('Image'),
                  contentPadding: EdgeInsets.zero,
                ),
                const RadioListTile<FlyerType>(
                  value: FlyerType.pdf,
                  title: Text('PDF'),
                  contentPadding: EdgeInsets.zero,
                ),
              ];

              if (stackVertically) {
                return Column(children: options);
              }

              return Row(
                children: options
                    .map((option) => Expanded(child: option))
                    .toList(growable: false),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    final formatHint =
        'Formats acceptés: ${_selectedType == FlyerType.pdf ? "PDF" : "JPG, PNG"}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Source du fichier',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Televerser'),
                  selected: !_useUrlInput,
                  onSelected: (selected) {
                    if (!selected) {
                      return;
                    }
                    _setStateSafe(() => _useUrlInput = false);
                  },
                ),
                ChoiceChip(
                  label: const Text('URL'),
                  selected: _useUrlInput,
                  onSelected: (selected) {
                    if (!selected) {
                      return;
                    }
                    _setStateSafe(() {
                      _useUrlInput = true;
                      _selectedFileBytes = null;
                      _selectedFilePath = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_useUrlInput)
              TextFormField(
                controller: _fileUrlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL du fichier *',
                  hintText: 'https://example.com/flyers/promo.pdf',
                  border: OutlineInputBorder(),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedFileBytes != null)
                    // Compact preview card with delete/change actions
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: _selectedType == FlyerType.image
                                ? Image.memory(
                                    _selectedFileBytes!,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 72,
                                    height: 72,
                                    color: Colors.red.shade50,
                                    child: const Icon(
                                      Icons.picture_as_pdf,
                                      size: 36,
                                      color: Colors.red,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          // Filename
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFilePath ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(_selectedFileBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Actions column
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Change button
                              IconButton(
                                onPressed: _isLoadingFile ? null : _pickFile,
                                icon: const Icon(Icons.edit, size: 20),
                                tooltip: 'Changer',
                                style: IconButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  padding: const EdgeInsets.all(6),
                                  minimumSize: const Size(32, 32),
                                ),
                              ),
                              // Delete button
                              IconButton(
                                onPressed: () => _setStateSafe(() {
                                  _selectedFileBytes = null;
                                  _selectedFilePath = null;
                                }),
                                icon: const Icon(Icons.delete_outline, size: 20),
                                tooltip: 'Supprimer',
                                style: IconButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.all(6),
                                  minimumSize: const Size(32, 32),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    // No file yet — show upload button
                    Center(
                      child: _isLoadingFile
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : ElevatedButton.icon(
                              onPressed: _pickFile,
                              icon: const Icon(Icons.upload_file),
                              label: Text(
                                isEdit
                                    ? 'Changer le fichier'
                                    : 'Telecharger le fichier',
                              ),
                            ),
                    ),
                ],
              ),
            Text(
              formatHint,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
