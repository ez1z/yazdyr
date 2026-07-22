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

// Full month names per language (Russian in genitive, as used with a day number).
const _monthsLong = {
  'en': [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ],
  'tk': [
    'Ýanwar', 'Fewral', 'Mart', 'Aprel', 'Maý', 'Iýun',
    'Iýul', 'Awgust', 'Sentýabr', 'Oktýabr', 'Noýabr', 'Dekabr',
  ],
  'ru': [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
  ],
};

// Localized date + 24h time: '2026-07-22T14:30:…' → '22 Iýul, 14:30' (tk).
String localDateTime(String iso, String lang) {
  final d = DateTime.tryParse(iso);
  if (d == null) return '';
  final months = _monthsLong[lang] ?? _monthsLong['en']!;
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${months[d.month - 1]}, $hh:$mm';
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
  'navDashboard': {'en': 'Dashboard', 'tk': 'Esasy', 'ru': 'Главная'},
  'navCustomers': {'en': 'Customers', 'tk': 'Müşderiler', 'ru': 'Клиенты'},
  'navActivity': {'en': 'Activity', 'tk': 'Işjeňlik', 'ru': 'Активность'},
  'navSettings': {'en': 'Settings', 'tk': 'Sazlamalar', 'ru': 'Настройки'},
  'tagline': {'en': 'Offline credit ledger', 'tk': 'Oflaýn karz depderi', 'ru': 'Офлайн-книга долгов'},
  'splashTagline': {
    'en': 'Offline-first credit ledger for small shops',
    'tk': 'Dükanlar üçin oflaýn karz depderi',
    'ru': 'Офлайн-книга долгов для небольших магазинов'
  },
  'loadingDb': {
    'en': 'LOADING LOCAL DATABASE…',
    'tk': 'MAGLUMAT BAZASY AÇYLÝAR…',
    'ru': 'ЗАГРУЗКА ЛОКАЛЬНОЙ БАЗЫ…'
  },

  // Dashboard
  'statTotalCustomers': {'en': 'Total Customers', 'tk': 'Jemi müşderiler', 'ru': 'Всего клиентов'},
  'statOutstandingDebt': {'en': 'Outstanding Debt', 'tk': 'Galan bergi', 'ru': 'Остаток долга'},
  'statTodayCredit': {'en': "Today's Credit Sales", 'tk': 'Şu günki karz satuwy', 'ru': 'Долги за сегодня'},
  'quickActions': {'en': 'Quick Actions', 'tk': 'Çalt amallar', 'ru': 'Быстрые действия'},
  'newCredit': {'en': 'New Credit', 'tk': 'Täze karz', 'ru': 'Новый долг'},
  'highestDebt': {'en': 'Highest Debt', 'tk': 'Iň ýokary bergi', 'ru': 'Наибольший долг'},
  'noDebts': {'en': 'No debts', 'tk': 'Bergi ýok', 'ru': 'Нет долгов'},
  'longestWithoutPayment': {
    'en': 'Longest Without Payment',
    'tk': 'Iň uzak tölemedik',
    'ru': 'Дольше всех без оплаты'
  },
  'recentActivity': {'en': 'Recent Activity', 'tk': 'Soňky işjeňlik', 'ru': 'Недавняя активность'},
  'seeAll': {'en': 'See all', 'tk': 'Ählisini gör', 'ru': 'Показать всё'},
  'selectCustomerCredit': {
    'en': 'Select a customer to add a credit entry',
    'tk': 'Karz ýazmak üçin müşderi saýlaň',
    'ru': 'Выберите клиента, чтобы добавить долг'
  },
  'selectCustomerPayment': {
    'en': 'Select a customer to record a payment',
    'tk': 'Töleg bellemek üçin müşderi saýlaň',
    'ru': 'Выберите клиента, чтобы записать оплату'
  },
  'lastPaid': {'en': 'Last paid {date}', 'tk': 'Soňky töleg {date}', 'ru': 'Последняя оплата {date}'},
  'noPaymentRecorded': {'en': 'No payment recorded', 'tk': 'Töleg bellenmedik', 'ru': 'Оплат не записано'},

  // Customers
  'addCustomer': {'en': 'Add Customer', 'tk': 'Müşderi goşmak', 'ru': 'Добавить клиента'},
  'searchHint': {
    'en': 'Search by name or phone',
    'tk': 'At ýa-da telefon boýunça gözle',
    'ru': 'Поиск по имени или телефону'
  },
  'sortHighestDebt': {'en': 'Highest debt', 'tk': 'Iň ýokary bergi', 'ru': 'Наибольший долг'},
  'sortRecent': {'en': 'Recent', 'tk': 'Soňky', 'ru': 'Недавние'},
  'showSampleCustomers': {
    'en': 'Show sample customers',
    'tk': 'Nusga müşderileri görkez',
    'ru': 'Показать примеры клиентов'
  },
  'previewEmpty': {'en': 'Preview empty state', 'tk': 'Boş ýagdaýy görkez', 'ru': 'Показать пустой вид'},
  'noCustomers': {'en': 'No customers yet', 'tk': 'Entek müşderi ýok', 'ru': 'Пока нет клиентов'},
  'addFirstCustomer': {
    'en': 'Add your first customer to start tracking credit.',
    'tk': 'Karzy yzarlamak üçin ilkinji müşderiňizi goşuň.',
    'ru': 'Добавьте первого клиента, чтобы вести учёт долгов.'
  },

  // Customer detail
  'currentBalance': {'en': 'CURRENT BALANCE', 'tk': 'HÄZIRKI BALANS', 'ru': 'ТЕКУЩИЙ БАЛАНС'},
  'addCredit': {'en': 'Add Credit', 'tk': 'Karz goşmak', 'ru': 'Добавить долг'},
  'recordPayment': {'en': 'Record Payment', 'tk': 'Töleg bellemek', 'ru': 'Записать оплату'},
  'editCustomer': {'en': 'Edit Customer', 'tk': 'Müşderini üýtget', 'ru': 'Изменить клиента'},
  'deleteCustomer': {'en': 'Delete Customer', 'tk': 'Müşderini poz', 'ru': 'Удалить клиента'},
  'deleteCustomerConfirm': {
    'en': 'Delete {name} and all their transactions? This cannot be undone.',
    'tk': '{name} we onuň ähli amallaryny pozmakçymy? Bu yzyna gaýtaryp bolmaýar.',
    'ru': 'Удалить {name} и все операции? Это действие необратимо.'
  },
  'cancel': {'en': 'Cancel', 'tk': 'Ýatyr', 'ru': 'Отмена'},
  'delete': {'en': 'Delete', 'tk': 'Poz', 'ru': 'Удалить'},
  // SMS receipt sent to the customer after recording a credit/payment.
  'smsCreditMsg': {
    'en': 'Hello {name}. Credit added: {amount} ({date}). Balance due: {balance}.',
    'tk': 'Salam {name}. Karz ýazyldy: {amount} ({date}). Galan bergi: {balance}.',
    'ru': 'Здравствуйте, {name}. Долг: {amount} ({date}). Остаток: {balance}.'
  },
  'smsPaymentMsg': {
    'en': 'Hello {name}. Payment received: {amount} ({date}). Balance due: {balance}.',
    'tk': 'Salam {name}. Töleg kabul edildi: {amount} ({date}). Galan bergi: {balance}.',
    'ru': 'Здравствуйте, {name}. Оплата: {amount} ({date}). Остаток: {balance}.'
  },
  'toastCustomerDeleted': {'en': 'Customer deleted', 'tk': 'Müşderi pozuldy', 'ru': 'Клиент удалён'},
  'transactionHistory': {'en': 'Transaction History', 'tk': 'Amallar taryhy', 'ru': 'История операций'},
  'editTransaction': {'en': 'Edit Transaction', 'tk': 'Amaly üýtget', 'ru': 'Изменить операцию'},
  'type': {'en': 'Type', 'tk': 'Görnüşi', 'ru': 'Тип'},
  'toastTransactionUpdated': {
    'en': 'Transaction updated',
    'tk': 'Amal täzelendi',
    'ru': 'Операция обновлена'
  },
  'deleteTransaction': {'en': 'Delete Transaction', 'tk': 'Amaly poz', 'ru': 'Удалить операцию'},
  'deleteTransactionConfirm': {
    'en': 'Delete this transaction? This cannot be undone.',
    'tk': 'Bu amal pozulsynmy? Bu yzyna gaýtaryp bolmaýar.',
    'ru': 'Удалить эту операцию? Это действие необратимо.'
  },
  'toastTransactionDeleted': {
    'en': 'Transaction deleted',
    'tk': 'Amal pozuldy',
    'ru': 'Операция удалена'
  },

  // Customer form
  'fullName': {'en': 'Full Name *', 'tk': 'Doly ady *', 'ru': 'Полное имя *'},
  'phoneNumber': {'en': 'Phone Number', 'tk': 'Telefon belgisi', 'ru': 'Номер телефона'},
  'address': {'en': 'Address', 'tk': 'Salgysy', 'ru': 'Адрес'},
  'notes': {'en': 'Notes', 'tk': 'Bellikler', 'ru': 'Заметки'},
  'hintFullName': {'en': 'e.g. Aýgül Berdiýewa', 'tk': 'meselem: Aýgül Berdiýewa', 'ru': 'напр. Айгуль Бердыева'},
  'hintAddress': {'en': 'Neighborhood, city', 'tk': 'dom kwartira nomer', 'ru': 'район, город'},
  'hintNotes': {'en': 'Optional notes', 'tk': 'Islege bagly bellikler', 'ru': 'Необязательные заметки'},
  'saveChanges': {'en': 'Save Changes', 'tk': 'Üýtgetmeleri ýatda sakla', 'ru': 'Сохранить изменения'},
  'saveCustomer': {'en': 'Save Customer', 'tk': 'Müşderini ýatda sakla', 'ru': 'Сохранить клиента'},
  'toastCustomerUpdated': {'en': 'Customer updated', 'tk': 'Müşderi täzelendi', 'ru': 'Клиент обновлён'},
  'toastCustomerAdded': {'en': 'Customer added', 'tk': 'Müşderi goşuldy', 'ru': 'Клиент добавлен'},

  // Add credit / record payment
  'forCustomer': {'en': 'For {name}', 'tk': '{name} üçin', 'ru': 'Для {name}'},
  'amountTmt': {'en': 'Amount (TMT) *', 'tk': 'Möçberi (TMT) *', 'ru': 'Сумма (TMT) *'},
  'description': {'en': 'Description', 'tk': 'Düşündiriş', 'ru': 'Описание'},
  'hintCreditDesc': {'en': 'e.g. Milk, Bread', 'tk': 'meselem: Süýt, Çörek', 'ru': 'напр. Молоко, Хлеб'},
  'date': {'en': 'Date', 'tk': 'Sene', 'ru': 'Дата'},
  'saveCredit': {'en': 'Save Credit', 'tk': 'Karzy ýatda sakla', 'ru': 'Сохранить долг'},
  'toastCreditSaved': {'en': 'Credit saved', 'tk': 'Karz ýatda saklandy', 'ru': 'Долг сохранён'},
  'savePayment': {'en': 'Save Payment', 'tk': 'Tölegi ýatda sakla', 'ru': 'Сохранить оплату'},
  'toastPaymentRecorded': {'en': 'Payment recorded', 'tk': 'Töleg bellendi', 'ru': 'Оплата записана'},

  // Activity
  'periodToday': {'en': 'Today', 'tk': 'Şu gün', 'ru': 'Сегодня'},
  'periodWeek': {'en': 'Week', 'tk': 'Hepde', 'ru': 'Неделя'},
  'periodMonth': {'en': 'Month', 'tk': 'Aý', 'ru': 'Месяц'},
  'periodCustom': {'en': 'Custom', 'tk': 'Saýlama', 'ru': 'Свой период'},
  'typeAll': {'en': 'All', 'tk': 'Ählisi', 'ru': 'Все'},
  'typeCredit': {'en': 'Credit', 'tk': 'Karz', 'ru': 'Долг'},
  'typePayment': {'en': 'Payment', 'tk': 'Töleg', 'ru': 'Оплата'},
  'sortNewest': {'en': 'Newest', 'tk': 'Iň täze', 'ru': 'Новые'},
  'sortAmount': {'en': 'Amount', 'tk': 'Möçber', 'ru': 'Сумма'},
  'dateFrom': {'en': 'From', 'tk': 'Başlangyç', 'ru': 'С'},
  'dateTo': {'en': 'To', 'tk': 'Ahyry', 'ru': 'По'},
  'dateSep': {'en': 'to', 'tk': 'çenli', 'ru': 'по'},

  // Settings
  'language': {'en': 'Language', 'tk': 'Dil', 'ru': 'Язык'},
  'theme': {'en': 'Theme', 'tk': 'Tema', 'ru': 'Тема'},
  'themeLight': {'en': 'Light', 'tk': 'Açyk', 'ru': 'Светлая'},
  'themeDark': {'en': 'Dark', 'tk': 'Garaňky', 'ru': 'Тёмная'},
  'reports': {'en': 'Reports', 'tk': 'Hasabatlar', 'ru': 'Отчёты'},
  'about': {'en': 'About', 'tk': 'Barada', 'ru': 'О приложении'},

  // Reports
  'totalCreditGiven': {'en': 'Total Credit Given', 'tk': 'Berlen jemi karz', 'ru': 'Всего выдано в долг'},
  'totalPaymentsReceived': {
    'en': 'Total Payments Received',
    'tk': 'Alnan jemi töleg',
    'ru': 'Всего получено оплат'
  },
  'outstandingBalance': {'en': 'Outstanding Balance', 'tk': 'Galan balans', 'ru': 'Остаток баланса'},

  // About
  'version': {'en': 'Version 1.0.0 (MVP)', 'tk': 'Wersiýa 1.0.0 (MVP)', 'ru': 'Версия 1.0.0 (MVP)'},
  'aboutOfflineTitle': {'en': 'Offline-first', 'tk': 'Oflaýn ileri tutulýan', 'ru': 'Работает офлайн'},
  'aboutOfflineBody': {
    'en':
        'All data is stored on this device. Ýazdyr works fully without an internet connection — nothing is sent to a server.',
    'tk':
        'Ähli maglumat şu enjamda saklanýar. Ýazdyr internet birikmesi bolmazdan doly işleýär — hemme maglumatlar telefonuňyzda galýar.',
    'ru':
        'Все данные хранятся на этом устройстве. Ýazdyr полностью работает без интернета — ничего не отправляется на сервер.'
  },
  'storageTitle': {'en': 'Storage', 'tk': 'Ammar', 'ru': 'Хранилище'},
  'privacyTitle': {'en': 'Privacy', 'tk': 'Gizlinlik', 'ru': 'Конфиденциальность'},
  'privacyBody': {
    'en':
        'Customer records stay on your phone. Nothing is collected, tracked, or shared.',
    'tk':
        'Müşderi ýazgylary telefonyňyzda galýar. Hiç zat ýygnalmaýar, yzarlanmaýar ýa-da paýlaşylmaýar.',
    'ru':
        'Записи о клиентах остаются на вашем телефоне. Ничего не собирается, не отслеживается и не передаётся.'
  },
  'storageInfo': {
    'en': '{c} customers · {t} transactions · ~{mb} MB',
    'tk': '{c} müşderi · {t} amal · ~{mb} MB',
    'ru': '{c} клиентов · {t} операций · ~{mb} МБ'
  },
};

String tr(String key, String lang) =>
    _str[key]?[lang] ?? _str[key]?['en'] ?? '';
