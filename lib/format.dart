// Formatting + partial i18n, ported from the prototype (fmt, fmtDate, STR/tr).

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

// fmt(n) → rounded, thousands-separated + ' TMT'  (e.g. 1234.5 → '1,235 TMT')
String money(num n) {
  final v = n.round().abs();
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  final sign = n.round() < 0 ? '-' : '';
  return '$sign${buf.toString()} TMT';
}

// fmtDate(iso) → 'MMM d'  (e.g. '2026-07-19' → 'Jul 19'); '—' when null.
String shortDate(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  final d = DateTime.tryParse('${iso}T00:00:00');
  if (d == null) return '—';
  return '${_months[d.month - 1]} ${d.day}';
}

// Today as ISO 'yyyy-MM-dd' (prototype used a fixed TODAY; real app uses now).
String todayIso() {
  final d = DateTime.now();
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

// Partial i18n matching the prototype's STR map (only these keys are localized;
// everything else stays English — ponytail: mirrors the prototype scope).
const Map<String, Map<String, String>> _str = {
  'navDashboard': {'en': 'Dashboard', 'tk': 'Umumy görnüş'},
  'navCustomers': {'en': 'Customers', 'tk': 'Müşderiler'},
  'navActivity': {'en': 'Activity', 'tk': 'Işjeňlik'},
  'navSettings': {'en': 'Settings', 'tk': 'Sazlamalar'},
  'addCustomer': {'en': 'Add Customer', 'tk': 'Müşderi goşmak'},
  'tagline': {'en': 'Offline credit ledger', 'tk': 'Oflaýn karz depderi'},
};

String tr(String key, String lang) =>
    _str[key]?[lang] ?? _str[key]?['en'] ?? '';
