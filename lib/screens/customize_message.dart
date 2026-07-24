import 'package:flutter/material.dart';

import '../widgets.dart';

// Lets the owner edit the SMS receipt templates. Each field is pre-filled with
// the template currently in use (custom text, or the translated default). On
// save, text equal to the current default is stored as '' so it keeps tracking
// the language default instead of being frozen to one language.
class CustomizeMessageScreen extends StatefulWidget {
  const CustomizeMessageScreen({super.key});

  @override
  State<CustomizeMessageScreen> createState() => _CustomizeMessageScreenState();
}

class _CustomizeMessageScreenState extends State<CustomizeMessageScreen> {
  late final TextEditingController _credit;
  late final TextEditingController _payment;

  @override
  void initState() {
    super.initState();
    final l = LedgerScope.read(context);
    _credit = TextEditingController(text: l.smsTemplate(true));
    _payment = TextEditingController(text: l.smsTemplate(false));
  }

  @override
  void dispose() {
    _credit.dispose();
    _payment.dispose();
    super.dispose();
  }

  void _save() {
    final l = LedgerScope.read(context);
    // '' when unchanged from the default → keep following the language default.
    final credit = _credit.text.trim() == l.t('smsCreditMsg') ? '' : _credit.text;
    final payment =
        _payment.text.trim() == l.t('smsPaymentMsg') ? '' : _payment.text;
    l.setSmsTemplate(isCredit: true, value: credit);
    l.setSmsTemplate(isCredit: false, value: payment);
    showToast(context, l.t('saved'));
  }

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Scaffold(
      appBar: AppBar(
          title: Text(l.t('customizeMessage'),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(l.t('customizeMessageHint'),
              style: TextStyle(fontSize: 13, height: 1.4, color: muted)),
          const SizedBox(height: 6),
          Text(l.t('placeholdersLabel'),
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 20),
          _field(l.t('creditMessageLabel'), _credit, () {
            _credit.text = l.t('smsCreditMsg');
          }),
          const SizedBox(height: 20),
          _field(l.t('paymentMessageLabel'), _payment, () {
            _payment.text = l.t('smsPaymentMsg');
          }),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: Text(l.t('save')),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, VoidCallback onReset) {
    final l = LedgerScope.read(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            TextButton(
              onPressed: () => setState(onReset),
              child: Text(l.t('resetToDefault'),
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: c,
          maxLines: 4,
          minLines: 2,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }
}
