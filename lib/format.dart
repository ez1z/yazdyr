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

// Full i18n. Every user-facing string is keyed here; templates use {name}.
// User-entered data (transaction labels, customer names) is NOT translated.
const Map<String, Map<String, String>> _str = {
  // Nav / shell
  'navDashboard': {'en': 'Dashboard', 'tk': 'Esasy Sahypa'},
  'navCustomers': {'en': 'Customers', 'tk': 'Müşderiler'},
  'navActivity': {'en': 'Activity', 'tk': 'Işjeňlik'},
  'navSettings': {'en': 'Settings', 'tk': 'Sazlamalar'},
  'tagline': {'en': 'Offline credit ledger', 'tk': 'Oflaýn karz depderi'},
  'splashTagline': {
    'en': 'Offline-first credit ledger for small shops',
    'tk': 'Dükanlar üçin oflaýn karz depderi'
  },
  'loadingDb': {
    'en': 'LOADING LOCAL DATABASE…',
    'tk': 'MAGLUMAT BAZASY AÇYLÝAR…'
  },

  // Dashboard
  'statTotalCustomers': {'en': 'Total Customers', 'tk': 'Jemi müşderiler'},
  'statOutstandingDebt': {'en': 'Outstanding Debt', 'tk': 'Galan bergi'},
  'statTodayCredit': {'en': "Today's Credit Sales", 'tk': 'Şu günki karz satuwy'},
  'quickActions': {'en': 'Quick Actions', 'tk': 'Çalt amallar'},
  'newCredit': {'en': 'New Credit', 'tk': 'Täze karz'},
  'highestDebt': {'en': 'Highest Debt', 'tk': 'Iň ýokary bergi'},
  'noDebts': {'en': 'No debts', 'tk': 'Bergi ýok'},
  'longestWithoutPayment': {
    'en': 'Longest Without Payment',
    'tk': 'Iň uzak tölemedik'
  },
  'recentActivity': {'en': 'Recent Activity', 'tk': 'Soňky işjeňlik'},
  'seeAll': {'en': 'See all', 'tk': 'Ählisini gör'},
  'selectCustomerCredit': {
    'en': 'Select a customer to add a credit entry',
    'tk': 'Karz ýazmak üçin müşderi saýlaň'
  },
  'selectCustomerPayment': {
    'en': 'Select a customer to record a payment',
    'tk': 'Töleg bellemek üçin müşderi saýlaň'
  },
  'lastPaid': {'en': 'Last paid {date}', 'tk': 'Soňky töleg {date}'},
  'noPaymentRecorded': {'en': 'No payment recorded', 'tk': 'Töleg bellenmedik'},

  // Customers
  'addCustomer': {'en': 'Add Customer', 'tk': 'Müşderi goşmak'},
  'searchHint': {
    'en': 'Search by name or phone',
    'tk': 'At ýa-da telefon boýunça gözle'
  },
  'sortHighestDebt': {'en': 'Highest debt', 'tk': 'Iň ýokary bergi'},
  'sortRecent': {'en': 'Recent', 'tk': 'Soňky'},
  'showSampleCustomers': {
    'en': 'Show sample customers',
    'tk': 'Nusga müşderileri görkez'
  },
  'previewEmpty': {'en': 'Preview empty state', 'tk': 'Boş ýagdaýy görkez'},
  'noCustomers': {'en': 'No customers yet', 'tk': 'Entek müşderi ýok'},
  'addFirstCustomer': {
    'en': 'Add your first customer to start tracking credit.',
    'tk': 'Karzy yzarlamak üçin ilkinji müşderiňizi goşuň.'
  },

  // Customer detail
  'currentBalance': {'en': 'CURRENT BALANCE', 'tk': 'HÄZIRKI BALANS'},
  'addCredit': {'en': 'Add Credit', 'tk': 'Karz goşmak'},
  'recordPayment': {'en': 'Record Payment', 'tk': 'Töleg bellemek'},
  'editCustomer': {'en': 'Edit Customer', 'tk': 'Müşderini üýtget'},
  'transactionHistory': {'en': 'Transaction History', 'tk': 'Amallar taryhy'},

  // Customer form
  'fullName': {'en': 'Full Name *', 'tk': 'Doly ady *'},
  'phoneNumber': {'en': 'Phone Number', 'tk': 'Telefon belgisi'},
  'address': {'en': 'Address', 'tk': 'Salgysy'},
  'notes': {'en': 'Notes', 'tk': 'Bellikler'},
  'hintFullName': {'en': 'e.g. Aýgül Berdiýewa', 'tk': 'meselem: Aýgül Berdiýewa'},
  'hintAddress': {'en': 'Neighborhood, city', 'tk': 'dom kwartira nomer'},
  'hintNotes': {'en': 'Optional notes', 'tk': 'Islege bagly bellikler'},
  'saveChanges': {'en': 'Save Changes', 'tk': 'Üýtgetmeleri ýatda sakla'},
  'saveCustomer': {'en': 'Save Customer', 'tk': 'Müşderini ýatda sakla'},
  'toastCustomerUpdated': {'en': 'Customer updated', 'tk': 'Müşderi täzelendi'},
  'toastCustomerAdded': {'en': 'Customer added', 'tk': 'Müşderi goşuldy'},

  // Add credit / record payment
  'forCustomer': {'en': 'For {name}', 'tk': '{name} üçin'},
  'amountTmt': {'en': 'Amount (TMT) *', 'tk': 'Möçberi (TMT) *'},
  'description': {'en': 'Description', 'tk': 'Düşündiriş'},
  'hintCreditDesc': {'en': 'e.g. Milk, Bread', 'tk': 'meselem: Süýt, Çörek'},
  'date': {'en': 'Date', 'tk': 'Sene'},
  'saveCredit': {'en': 'Save Credit', 'tk': 'Karzy ýatda sakla'},
  'toastCreditSaved': {'en': 'Credit saved', 'tk': 'Karz ýatda saklandy'},
  'savePayment': {'en': 'Save Payment', 'tk': 'Tölegi ýatda sakla'},
  'toastPaymentRecorded': {'en': 'Payment recorded', 'tk': 'Töleg bellendi'},

  // Activity
  'periodToday': {'en': 'Today', 'tk': 'Şu gün'},
  'periodWeek': {'en': 'Week', 'tk': 'Hepde'},
  'periodMonth': {'en': 'Month', 'tk': 'Aý'},
  'periodCustom': {'en': 'Custom', 'tk': 'Saýlama'},
  'typeAll': {'en': 'All', 'tk': 'Ählisi'},
  'typeCredit': {'en': 'Credit', 'tk': 'Karz'},
  'typePayment': {'en': 'Payment', 'tk': 'Töleg'},
  'sortNewest': {'en': 'Newest', 'tk': 'Iň täze'},
  'sortAmount': {'en': 'Amount', 'tk': 'Möçber'},
  'dateFrom': {'en': 'From', 'tk': 'Başlangyç'},
  'dateTo': {'en': 'To', 'tk': 'Ahyry'},
  'dateSep': {'en': 'to', 'tk': 'çenli'},

  // Settings
  'language': {'en': 'Language', 'tk': 'Dil'},
  'theme': {'en': 'Theme', 'tk': 'Tema'},
  'themeLight': {'en': 'Light', 'tk': 'Açyk'},
  'themeDark': {'en': 'Dark', 'tk': 'Garaňky'},
  'backupRestore': {'en': 'Backup & Restore', 'tk': 'Ätiýaçlyk we dikeltme'},
  'reports': {'en': 'Reports', 'tk': 'Hasabatlar'},
  'about': {'en': 'About', 'tk': 'Barada'},

  // Backup
  'exportDatabase': {'en': 'Export Database', 'tk': 'Maglumat bazasyny çykar'},
  'importDatabase': {'en': 'Import Database', 'tk': 'Maglumat bazasyny getir'},
  'createBackup': {'en': 'Create Backup', 'tk': 'Ätiýaçlyk döret'},
  'restoreBackup': {'en': 'Restore Backup', 'tk': 'Ätiýaçlygy dikelt'},
  'backupLocalNote': {
    'en': 'Everything works locally — no internet connection required.',
    'tk': 'Ählisi internetsiz işleýär.'
  },
  'toastBackupCreated': {
    'en': 'Backup created — {name}',
    'tk': 'Ätiýaçlyk döredildi — {name}'
  },
  'toastRestored': {
    'en': 'Database restored from last backup',
    'tk': 'Maglumat bazasy soňky ätiýaçlykdan dikeldildi'
  },
  'toastNoBackup': {'en': 'No backup found yet', 'tk': 'Entek ätiýaçlyk tapylmady'},

  // Reports
  'totalCreditGiven': {'en': 'Total Credit Given', 'tk': 'Berlen jemi karz'},
  'totalPaymentsReceived': {
    'en': 'Total Payments Received',
    'tk': 'Alnan jemi töleg'
  },
  'outstandingBalance': {'en': 'Outstanding Balance', 'tk': 'Galan balans'},

  // About
  'version': {'en': 'Version 1.0.0 (MVP)', 'tk': 'Wersiýa 1.0.0 (MVP)'},
  'aboutOfflineTitle': {'en': 'Offline-first', 'tk': 'Oflaýn ileri tutulýan'},
  'aboutOfflineBody': {
    'en':
        'All data is stored on this device. Ýazdyr works fully without an internet connection — nothing is sent to a server.',
    'tk':
        'Ähli maglumat şu enjamda saklanýar. Ýazdyr internet birikmesi bolmazdan doly işleýär — hemme maglumatlar telefonuňyzda galýar.'
  },
  'storageTitle': {'en': 'Storage', 'tk': 'Ammar'},
  'privacyTitle': {'en': 'Privacy', 'tk': 'Gizlinlik'},
  'privacyBody': {
    'en':
        'Customer records stay on your phone. Nothing is collected, tracked, or shared.',
    'tk':
        'Müşderi ýazgylary telefonyňyzda galýar. Hiç zat ýygnalmaýar, yzarlanmaýar ýa-da paýlaşylmaýar.'
  },
  'storageInfo': {
    'en': '{c} customers · {t} transactions · ~{mb} MB',
    'tk': '{c} müşderi · {t} amal · ~{mb} MB'
  },
};

String tr(String key, String lang) =>
    _str[key]?[lang] ?? _str[key]?['en'] ?? '';
