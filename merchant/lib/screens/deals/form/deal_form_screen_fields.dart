part of '../deal_form_screen.dart';

extension _DealFormScreenFields on _DealFormScreenState {
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: required
          ? (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null
          : null,
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime date,
    Function(DateTime) onSelected,
  ) {
    return ListTile(
      title: Text(label),
      subtitle: Text(DateFormat('dd/MM/yyyy').format(date)),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onSelected(picked);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildMaxEnrollmentsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('Limiter le nombre d\'inscriptions'),
          value: _hasMaxEnrollments,
          onChanged: (value) => _setStateSafe(() => _hasMaxEnrollments = value!),
          contentPadding: EdgeInsets.zero,
        ),
        if (_hasMaxEnrollments)
          _buildTextField(
            'Nombre max d\'inscriptions',
            _maxEnrollmentsController,
            isNumber: true,
          ),
      ],
    );
  }
}
