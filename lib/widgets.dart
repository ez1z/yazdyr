import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ledger.dart';
import 'theme.dart';

// Opens the SMS composer pre-filled via a tiny native intent (share_plus /
// url_launcher are uncached offline). Sent from the owner's own number; the
// owner reviews before sending. No-op off Android or with no SMS app.
const _smsChannel = MethodChannel('yazdyr/url');
Future<void> sendSms(String phone, String body) async {
  try {
    await _smsChannel.invokeMethod('sms', {'phone': phone, 'body': body});
  } catch (_) {}
}

// Silent send (opt-in "auto-send" setting). Returns false when it couldn't send
// — e.g. SEND_SMS not granted yet, or off Android — so the caller can fall back
// to the composer.
Future<bool> sendSmsAuto(String phone, String body) async {
  try {
    final ok = await _smsChannel.invokeMethod('smsSend',
        {'phone': phone, 'body': body});
    return ok == true;
  } catch (_) {
    return false;
  }
}

// InheritedNotifier so any screen can read the Ledger and rebuild on change.
class LedgerScope extends InheritedNotifier<Ledger> {
  const LedgerScope({super.key, required Ledger ledger, required super.child})
      : super(notifier: ledger);

  static Ledger of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LedgerScope>();
    assert(scope != null, 'No LedgerScope found in context');
    return scope!.notifier!;
  }

  // Non-subscribing read (safe in initState / callbacks).
  static Ledger read(BuildContext context) {
    final scope =
        context.getInheritedWidgetOfExactType<LedgerScope>();
    assert(scope != null, 'No LedgerScope found in context');
    return scope!.notifier!;
  }
}

TextStyle _kickerStyle(BuildContext c) => TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: accentOf(c),
    );

// Dashboard / reports stat card.
Widget statCard(BuildContext context,
    {required String kicker,
    required String value,
    bool accent = false,
    double valueSize = 26}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(kicker, style: _kickerStyle(context)),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: valueSize,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: accent ? accentOf(context) : null)),
      ],
    ),
  );
}

Widget sectionHeader(BuildContext context, String text, {Widget? trailing}) {
  final row = Text(text,
      style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)));
  if (trailing == null) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(alignment: Alignment.centerLeft, child: row),
    );
  }
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [row, trailing]),
  );
}

// A transaction row: left title/subtitle, right signed amount.
Widget txRow(BuildContext context,
    {required String title,
    required String subtitle,
    required String amount,
    required bool isCredit,
    bool boldTitle = false}) {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 2),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: boldTitle ? FontWeight.w600 : FontWeight.w400)),
              const SizedBox(height: 2),
              Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11,
                      color: onSurface.withValues(alpha: 0.55))),
            ],
          ),
        ),
        Text((isCredit ? '+' : '-') + amount,
            style: TextStyle(
                fontSize: 13,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: isCredit
                    ? accentOf(context)
                    : onSurface.withValues(alpha: 0.7))),
      ],
    ),
  );
}

// Bordered container that wraps a list of rows with dividers.
Widget boxList(BuildContext context, List<Widget> rows) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(6),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(children: rows),
  );
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 2400),
    ));
}
