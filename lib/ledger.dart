import 'package:flutter/foundation.dart';

import 'format.dart';
import 'models.dart';
import 'store.dart';

// A transaction paired with its owner's name, for cross-customer lists.
class ActivityItem {
  final String customerId;
  final String customerName;
  final Txn txn;
  const ActivityItem(this.customerId, this.customerName, this.txn);
}

class OverdueItem {
  final String name;
  final String subLabel;
  final double balance;
  const OverdueItem(this.name, this.subLabel, this.balance);
}

// Single source of truth. Mirrors the prototype's component state + renderVals().
class Ledger extends ChangeNotifier {
  final Store store;
  Ledger(this.store);

  // ---- persisted state ----
  List<Customer> customers = const [];
  String theme = 'light';
  String language = 'tk';

  // ---- transient UI state (not persisted, matches prototype) ----
  String? selectedId;
  String searchQuery = '';
  String sortMode = 'alpha'; // alpha | debt | recent
  String activityFilter = 'today'; // today | week | month | custom
  String activityTypeFilter = 'all'; // all | credit | payment
  String activitySort = 'newest'; // newest | amount
  String customStartDate = '';
  String customEndDate = '';
  bool showEmptyDemo = false;

  bool loaded = false;

  Future<void> init() async {
    final data = await store.load();
    customers = data.customers;
    theme = data.theme;
    language = data.language;
    loaded = true;
    notifyListeners();
  }

  Future<void> _persist() =>
      store.save(LedgerData(customers: customers, theme: theme, language: language));

  // ---- settings ----
  void setTheme(String t) {
    theme = t;
    notifyListeners();
    _persist();
  }

  void setLanguage(String l) {
    language = l;
    notifyListeners();
    _persist();
  }

  String t(String key) => tr(key, language);

  // ---- filters (transient) ----
  void setSearchQuery(String q) {
    searchQuery = q;
    notifyListeners();
  }

  void setSortMode(String m) {
    sortMode = m;
    notifyListeners();
  }

  void setActivityFilter(String f) {
    activityFilter = f;
    notifyListeners();
  }

  void setActivityType(String f) {
    activityTypeFilter = f;
    notifyListeners();
  }

  void setActivitySort(String f) {
    activitySort = f;
    notifyListeners();
  }

  void setCustomStart(String d) {
    customStartDate = d;
    notifyListeners();
  }

  void setCustomEnd(String d) {
    customEndDate = d;
    notifyListeners();
  }

  void toggleEmptyDemo() {
    showEmptyDemo = !showEmptyDemo;
    notifyListeners();
  }

  // ---- selection ----
  void select(String id) {
    selectedId = id;
    notifyListeners();
  }

  Customer get selected =>
      customers.firstWhere((c) => c.id == selectedId,
          orElse: () => const Customer(id: '', name: ''));

  // ---- mutations ----
  Future<void> addCustomer(
      {required String name,
      String phone = '',
      String address = '',
      String notes = ''}) async {
    final c = Customer(
        id: 'c${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        phone: phone,
        address: address,
        notes: notes);
    customers = [c, ...customers];
    selectedId = c.id;
    showEmptyDemo = false;
    notifyListeners();
    await _persist();
  }

  Future<void> editCustomer(String id,
      {required String name,
      String phone = '',
      String address = '',
      String notes = ''}) async {
    customers = customers
        .map((c) => c.id == id
            ? c.copyWith(name: name.trim(), phone: phone, address: address, notes: notes)
            : c)
        .toList();
    notifyListeners();
    await _persist();
  }

  Future<void> deleteCustomer(String id) async {
    customers = customers.where((c) => c.id != id).toList();
    if (selectedId == id) selectedId = null;
    notifyListeners();
    await _persist();
  }

  Future<void> editTxn(String customerId, String txnId,
      {required String type,
      required double amount,
      required String label,
      required String date}) async {
    customers = customers.map((c) {
      if (c.id != customerId) return c;
      final txs = c.transactions
          .map((t) => t.id == txnId
              ? Txn(id: t.id, type: type, amount: amount, label: label, date: date)
              : t)
          .toList();
      return c.copyWith(transactions: txs).sorted();
    }).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> deleteTxn(String customerId, String txnId) async {
    customers = customers.map((c) {
      if (c.id != customerId) return c;
      return c.copyWith(
          transactions:
              c.transactions.where((t) => t.id != txnId).toList());
    }).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> _addTxn(String customerId, Txn tx) async {
    customers = customers
        .map((c) => c.id == customerId
            ? c.copyWith(transactions: [tx, ...c.transactions]).sorted()
            : c)
        .toList();
    notifyListeners();
    await _persist();
  }

  Future<void> addCredit(String customerId,
      {required double amount, String desc = '', String? date}) {
    return _addTxn(
        customerId,
        Txn(
            id: 't${DateTime.now().millisecondsSinceEpoch}',
            type: 'credit',
            amount: amount,
            label: desc.trim().isEmpty ? 'Credit entry' : desc.trim(),
            date: date ?? todayIso()));
  }

  Future<void> recordPayment(String customerId,
      {required double amount, String notes = '', String? date}) {
    return _addTxn(
        customerId,
        Txn(
            id: 't${DateTime.now().millisecondsSinceEpoch}',
            type: 'payment',
            amount: amount,
            label: notes.trim().isEmpty ? 'Payment' : notes.trim(),
            date: date ?? todayIso()));
  }

  // ---- computed (renderVals) ----
  int get totalCustomers => customers.length;

  double get totalOutstanding =>
      customers.fold(0.0, (s, c) => s + (c.balance > 0 ? c.balance : 0));

  double get todayCredit {
    final today = todayIso();
    return customers.fold(
        0.0,
        (s, c) =>
            s +
            c.transactions
                .where((t) => t.isCredit && t.date == today)
                .fold(0.0, (a, t) => a + t.amount));
  }

  // All transactions across customers, newest first.
  List<ActivityItem> get _allTx {
    final list = <ActivityItem>[];
    for (final c in customers) {
      for (final t in c.transactions) {
        list.add(ActivityItem(c.id, c.name, t));
      }
    }
    list.sort((a, b) => b.txn.date.compareTo(a.txn.date));
    return list;
  }

  List<ActivityItem> get recentActivity => _allTx.take(5).toList();

  // Top 3 customers by outstanding balance (highest first), as a list to
  // mirror the "Longest Without Payment" section on the dashboard.
  List<OverdueItem> get highestDebtList {
    final withDebt = customers.where((c) => c.balance > 0).toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));
    return withDebt.take(3).map((c) {
      final sub = c.phone.isNotEmpty ? c.phone : shortDate(c.lastDate);
      return OverdueItem(c.name, sub, c.balance);
    }).toList();
  }

  String? _lastPaymentDate(Customer c) {
    final paid = c.transactions.where((t) => t.isPayment).toList();
    if (paid.isEmpty) return null;
    return paid.map((t) => t.date).reduce((a, b) => a.compareTo(b) > 0 ? a : b);
  }

  List<OverdueItem> get overdueList {
    final items = customers.where((c) => c.balance > 0).map((c) {
      final lastPaid = _lastPaymentDate(c);
      return (c: c, lastPaid: lastPaid);
    }).toList();
    items.sort((a, b) {
      final av = a.lastPaid ?? '0000-00-00';
      final bv = b.lastPaid ?? '0000-00-00';
      return av.compareTo(bv);
    });
    return items.take(5).map((e) {
      final sub = e.lastPaid != null
          ? t('lastPaid').replaceFirst('{date}', shortDate(e.lastPaid))
          : t('noPaymentRecorded');
      return OverdueItem(e.c.name, sub, e.c.balance);
    }).toList();
  }

  // Gap #1: search + sort actually applied (prototype wired the UI but ignored it).
  List<Customer> get customersView {
    final q = searchQuery.trim().toLowerCase();
    final list = customers.where((c) {
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q);
    }).toList();
    switch (sortMode) {
      case 'debt':
        list.sort((a, b) => b.balance.compareTo(a.balance));
        break;
      case 'recent':
        list.sort((a, b) => (b.lastDate ?? '').compareTo(a.lastDate ?? ''));
        break;
      default: // alpha
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return list;
  }

  bool _inRange(String dateStr) {
    if (activityFilter == 'today') return dateStr == todayIso();
    final d = DateTime.parse('${dateStr}T00:00:00');
    final today = DateTime.parse('${todayIso()}T00:00:00');
    final diffDays = today.difference(d).inDays;
    if (activityFilter == 'week') return diffDays >= 0 && diffDays <= 7;
    if (activityFilter == 'month') return diffDays >= 0 && diffDays <= 30;
    if (activityFilter == 'custom') {
      if (customStartDate.isNotEmpty && dateStr.compareTo(customStartDate) < 0) {
        return false;
      }
      if (customEndDate.isNotEmpty && dateStr.compareTo(customEndDate) > 0) {
        return false;
      }
    }
    return true;
  }

  List<ActivityItem> get activityList {
    var list = _allTx.where((a) => _inRange(a.txn.date)).toList();
    if (activityTypeFilter == 'credit') {
      list = list.where((a) => a.txn.isCredit).toList();
    } else if (activityTypeFilter == 'payment') {
      list = list.where((a) => a.txn.isPayment).toList();
    }
    if (activitySort == 'amount') {
      list.sort((a, b) => b.txn.amount.compareTo(a.txn.amount));
    }
    return list;
  }

  double get totalCreditGiven => _allTx
      .where((a) => a.txn.isCredit)
      .fold(0.0, (s, a) => s + a.txn.amount);

  double get totalPaymentsReceived => _allTx
      .where((a) => a.txn.isPayment)
      .fold(0.0, (s, a) => s + a.txn.amount);

  String get storageInfoLabel {
    final txCount = _allTx.length;
    final mb = (0.4 + txCount * 0.02).toStringAsFixed(1);
    return t('storageInfo')
        .replaceFirst('{c}', '$totalCustomers')
        .replaceFirst('{t}', '$txCount')
        .replaceFirst('{mb}', mb);
  }
}
