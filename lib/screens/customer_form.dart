import 'package:flutter/material.dart';

import '../widgets.dart';

class CustomerFormScreen extends StatefulWidget {
  final String? editId; // null → add mode
  const CustomerFormScreen({super.key, this.editId});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _notes;

  bool get _isEdit => widget.editId != null;

  @override
  void initState() {
    super.initState();
    final l = LedgerScope.read(context); // read once for prefill
    final c = _isEdit
        ? l.customers.firstWhere((c) => c.id == widget.editId)
        : null;
    _name = TextEditingController(text: c?.name ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _address = TextEditingController(text: c?.address ?? '');
    _notes = TextEditingController(text: c?.notes ?? '');
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = LedgerScope.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) return;
    if (_isEdit) {
      await l.editCustomer(widget.editId!,
          name: name,
          phone: _phone.text,
          address: _address.text,
          notes: _notes.text);
    } else {
      await l.addCustomer(
          name: name,
          phone: _phone.text,
          address: _address.text,
          notes: _notes.text);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    showToast(context, _isEdit ? 'Customer updated' : 'Customer added');
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _name.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEdit ? 'Edit Customer' : 'Add Customer',
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _field('Full Name *', _name, hint: 'e.g. Aýgül Berdiýewa'),
          _field('Phone Number', _phone, hint: '+993 6X XXXXXX'),
          _field('Address', _address, hint: 'Neighborhood, city'),
          _field('Notes', _notes, hint: 'Optional notes', lines: 3),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: canSave ? _save : null,
            child: Text(_isEdit ? 'Save Changes' : 'Save Customer'),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {String? hint, int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.75))),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            maxLines: lines,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}
