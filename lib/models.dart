// Data model ported from the Ýazdyr prototype (renderVals / computeCustomer).

class Txn {
  final String id;
  final String type; // 'credit' | 'payment'
  final double amount;
  final String label;
  final String date; // ISO 'yyyy-MM-dd'

  const Txn({
    required this.id,
    required this.type,
    required this.amount,
    required this.label,
    required this.date,
  });

  bool get isCredit => type == 'credit';
  bool get isPayment => type == 'payment';

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'label': label,
        'date': date,
      };

  factory Txn.fromJson(Map<String, dynamic> j) => Txn(
        id: j['id'] as String,
        type: j['type'] as String,
        amount: (j['amount'] as num).toDouble(),
        label: (j['label'] as String?) ?? '',
        date: j['date'] as String,
      );
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String notes;
  final List<Txn> transactions; // sorted newest-first (see computeSorted)

  const Customer({
    required this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.notes = '',
    this.transactions = const [],
  });

  // balance = Σ credits − Σ payments  (prototype computeCustomer)
  double get balance => transactions.fold(
      0.0, (sum, t) => sum + (t.isCredit ? t.amount : -t.amount));

  // most-recent transaction date, or null
  String? get lastDate => transactions.isNotEmpty ? transactions.first.date : null;

  // Returns a copy with transactions sorted newest-first, mirroring the
  // prototype's computeCustomer so `transactions.first` is always the latest.
  Customer sorted() {
    final txs = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    return copyWith(transactions: txs);
  }

  Customer copyWith({
    String? name,
    String? phone,
    String? address,
    String? notes,
    List<Txn>? transactions,
  }) =>
      Customer(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        notes: notes ?? this.notes,
        transactions: transactions ?? this.transactions,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'notes': notes,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: j['id'] as String,
        name: j['name'] as String,
        phone: (j['phone'] as String?) ?? '',
        address: (j['address'] as String?) ?? '',
        notes: (j['notes'] as String?) ?? '',
        transactions: ((j['transactions'] as List?) ?? const [])
            .map((e) => Txn.fromJson(e as Map<String, dynamic>))
            .toList(),
      ).sorted();
}
