import 'models.dart';

// The 14 sample customers from the prototype's RAW_CUSTOMERS, seeded on first
// launch only. Dates are kept fixed (2026-07) exactly as the prototype had them.
List<Customer> seedCustomers() => const [
      Customer(id: 'c1', name: 'Aýgül Berdiýewa', phone: '+993 65 112233', address: 'Parahat 3, Aşgabat', transactions: [
        Txn(id: 'c1t1', type: 'credit', amount: 45, label: 'Milk, Bread', date: '2026-07-19'),
        Txn(id: 'c1t2', type: 'payment', amount: 20, label: 'Payment', date: '2026-07-15'),
        Txn(id: 'c1t3', type: 'credit', amount: 80, label: 'Groceries', date: '2026-07-10'),
      ]),
      Customer(id: 'c2', name: 'Serdar Amanow', phone: '+993 62 223344', address: 'Berkararlyk, Aşgabat', transactions: [
        Txn(id: 'c2t1', type: 'credit', amount: 150, label: 'Flour, Oil, Rice', date: '2026-07-19'),
        Txn(id: 'c2t2', type: 'credit', amount: 60, label: 'Tea, Sweets', date: '2026-07-12'),
      ]),
      Customer(id: 'c3', name: 'Maral Nuryýewa', phone: '+993 61 334455', address: 'Bagtyýarlyk, Aşgabat', notes: 'Pays on the 1st of each month', transactions: [
        Txn(id: 'c3t1', type: 'credit', amount: 90, label: 'Vegetables', date: '2026-06-28'),
        Txn(id: 'c3t2', type: 'payment', amount: 90, label: 'Payment - full', date: '2026-07-02'),
      ]),
      Customer(id: 'c4', name: 'Rejep Gurbanow', phone: '+993 63 445566', address: 'Gurtly, Aşgabat', transactions: [
        Txn(id: 'c4t1', type: 'credit', amount: 210, label: 'Cooking gas, groceries', date: '2026-07-17'),
        Txn(id: 'c4t2', type: 'payment', amount: 50, label: 'Payment', date: '2026-07-18'),
      ]),
      Customer(id: 'c5', name: 'Bibi Hojaýewa', phone: '+993 64 556677', address: 'Choganly, Aşgabat', notes: 'Regular weekly restock', transactions: [
        Txn(id: 'c5t1', type: 'credit', amount: 300, label: 'Monthly stock', date: '2026-07-19'),
        Txn(id: 'c5t2', type: 'credit', amount: 120, label: 'Bread, Eggs', date: '2026-07-14'),
        Txn(id: 'c5t3', type: 'payment', amount: 40, label: 'Payment', date: '2026-07-08'),
      ]),
      Customer(id: 'c6', name: 'Merdan Öwezow', phone: '+993 65 667788', address: 'Parahat 7, Aşgabat', transactions: [
        Txn(id: 'c6t1', type: 'credit', amount: 55, label: 'Bread, Eggs', date: '2026-07-15'),
      ]),
      Customer(id: 'c7', name: 'Gözel Saparowa', phone: '+993 62 778899', address: 'Mir 2, Aşgabat', transactions: [
        Txn(id: 'c7t1', type: 'credit', amount: 140, label: 'Rice, Sugar', date: '2026-07-16'),
        Txn(id: 'c7t2', type: 'payment', amount: 60, label: 'Payment', date: '2026-07-11'),
      ]),
      Customer(id: 'c8', name: 'Guwanç Ýazberdiýew', phone: '+993 61 889900', address: 'Köpetdag, Aşgabat', transactions: [
        Txn(id: 'c8t1', type: 'credit', amount: 95, label: 'Cooking oil', date: '2026-07-12'),
      ]),
      Customer(id: 'c9', name: 'Ogulgerek Annamuhammedowa', phone: '+993 63 990011', address: 'Garaşsyzlyk, Aşgabat', transactions: [
        Txn(id: 'c9t1', type: 'credit', amount: 260, label: 'Groceries, gas', date: '2026-07-19'),
        Txn(id: 'c9t2', type: 'credit', amount: 90, label: 'Vegetables', date: '2026-07-13'),
        Txn(id: 'c9t3', type: 'payment', amount: 30, label: 'Payment', date: '2026-07-06'),
      ]),
      Customer(id: 'c10', name: 'Batyr Rejepow', phone: '+993 64 001122', address: 'Nusaý, Aşgabat', transactions: [
        Txn(id: 'c10t1', type: 'credit', amount: 70, label: 'Bread, Milk', date: '2026-07-14'),
        Txn(id: 'c10t2', type: 'payment', amount: 20, label: 'Payment', date: '2026-07-09'),
      ]),
      Customer(id: 'c11', name: 'Jemal Muhammedowa', phone: '+993 65 112244', address: 'Parahat 2, Aşgabat', transactions: [
        Txn(id: 'c11t1', type: 'credit', amount: 65, label: 'Tea, Sweets', date: '2026-06-30'),
        Txn(id: 'c11t2', type: 'payment', amount: 65, label: 'Payment - full', date: '2026-07-05'),
      ]),
      Customer(id: 'c12', name: 'Kakajan Durdyýew', phone: '+993 62 223355', address: 'Bagyr, Aşgabat', transactions: [
        Txn(id: 'c12t1', type: 'credit', amount: 180, label: 'Flour, Rice', date: '2026-07-18'),
        Txn(id: 'c12t2', type: 'payment', amount: 40, label: 'Payment', date: '2026-07-13'),
      ]),
      Customer(id: 'c13', name: 'Aman Weliýew', phone: '+993 61 334466', address: 'Choganly, Aşgabat', transactions: [
        Txn(id: 'c13t1', type: 'credit', amount: 90, label: 'Groceries', date: '2026-07-13'),
        Txn(id: 'c13t2', type: 'payment', amount: 20, label: 'Payment', date: '2026-07-16'),
      ]),
      Customer(id: 'c14', name: 'Ejegül Baýramowa', phone: '+993 63 445577', address: 'Mir 5, Aşgabat', notes: 'Buys in bulk for a small kiosk', transactions: [
        Txn(id: 'c14t1', type: 'credit', amount: 220, label: 'Monthly stock', date: '2026-07-19'),
        Txn(id: 'c14t2', type: 'credit', amount: 100, label: 'Vegetables, bread', date: '2026-07-11'),
      ]),
    ];
