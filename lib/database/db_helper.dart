import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/service.dart';
import '../models/customer.dart';
import '../models/appointment.dart';
import '../models/invoice.dart';
import '../models/inventory_item.dart';

class DBHelper {
  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    // دعم SQLite على الكمبيوتر (Windows/Linux/macOS) عبر FFI
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'salon_pos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT DEFAULT 'عام',
        duration_minutes INTEGER DEFAULT 30
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        service_id INTEGER NOT NULL,
        date_time TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        notes TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id),
        FOREIGN KEY (service_id) REFERENCES services (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        min_quantity INTEGER DEFAULT 5,
        cost_price REAL DEFAULT 0,
        sell_price REAL DEFAULT 0,
        unit TEXT DEFAULT 'قطعة'
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER,
        customer_name TEXT DEFAULT 'عميل عابر',
        date_time TEXT NOT NULL,
        discount REAL DEFAULT 0,
        payment_method TEXT DEFAULT 'cash',
        status TEXT DEFAULT 'paid',
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        item_type TEXT NOT NULL,
        item_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        unit_price REAL NOT NULL,
        quantity INTEGER DEFAULT 1,
        FOREIGN KEY (invoice_id) REFERENCES invoices (id)
      )
    ''');
  }

  // ---------------- الخدمات ----------------
  Future<int> insertService(ServiceModel s) async {
    final db = await database;
    return db.insert('services', s.toMap()..remove('id'));
  }

  Future<List<ServiceModel>> getServices() async {
    final db = await database;
    final rows = await db.query('services', orderBy: 'name');
    return rows.map((e) => ServiceModel.fromMap(e)).toList();
  }

  Future<int> updateService(ServiceModel s) async {
    final db = await database;
    return db.update('services', s.toMap(), where: 'id = ?', whereArgs: [s.id]);
  }

  Future<int> deleteService(int id) async {
    final db = await database;
    return db.delete('services', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- العملاء ----------------
  Future<int> insertCustomer(Customer c) async {
    final db = await database;
    return db.insert('customers', c.toMap()..remove('id'));
  }

  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final rows = await db.query('customers', orderBy: 'name');
    return rows.map((e) => Customer.fromMap(e)).toList();
  }

  Future<int> updateCustomer(Customer c) async {
    final db = await database;
    return db.update('customers', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- المواعيد ----------------
  Future<int> insertAppointment(Appointment a) async {
    final db = await database;
    return db.insert('appointments', a.toMap()..remove('id'));
  }

  Future<List<Appointment>> getAppointments() async {
    final db = await database;
    final rows = await db.query('appointments', orderBy: 'date_time');
    return rows.map((e) => Appointment.fromMap(e)).toList();
  }

  Future<int> updateAppointment(Appointment a) async {
    final db = await database;
    return db.update('appointments', a.toMap(), where: 'id = ?', whereArgs: [a.id]);
  }

  Future<int> deleteAppointment(int id) async {
    final db = await database;
    return db.delete('appointments', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- المخزون ----------------
  Future<int> insertInventoryItem(InventoryItem item) async {
    final db = await database;
    return db.insert('inventory', item.toMap()..remove('id'));
  }

  Future<List<InventoryItem>> getInventory() async {
    final db = await database;
    final rows = await db.query('inventory', orderBy: 'name');
    return rows.map((e) => InventoryItem.fromMap(e)).toList();
  }

  Future<int> updateInventoryItem(InventoryItem item) async {
    final db = await database;
    return db.update('inventory', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteInventoryItem(int id) async {
    final db = await database;
    return db.delete('inventory', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> adjustInventoryQuantity(int id, int delta) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE inventory SET quantity = quantity + ? WHERE id = ?',
      [delta, id],
    );
  }

  // ---------------- الفواتير ----------------
  Future<int> insertInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final db = await database;
    return db.transaction((txn) async {
      final invoiceId = await txn.insert('invoices', invoice.toMap()..remove('id'));
      for (final item in items) {
        await txn.insert(
          'invoice_items',
          (item.toMap()..remove('id'))..['invoice_id'] = invoiceId,
        );
        // خصم من المخزون لو كان المنتج من نوع product
        if (item.itemType == 'product') {
          await txn.rawUpdate(
            'UPDATE inventory SET quantity = quantity - ? WHERE id = ?',
            [item.quantity, item.itemId],
          );
        }
      }
      return invoiceId;
    });
  }

  Future<List<Invoice>> getInvoices() async {
    final db = await database;
    final rows = await db.query('invoices', orderBy: 'date_time DESC');
    return rows.map((e) => Invoice.fromMap(e)).toList();
  }

  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    final db = await database;
    final rows = await db.query('invoice_items', where: 'invoice_id = ?', whereArgs: [invoiceId]);
    return rows.map((e) => InvoiceItem.fromMap(e)).toList();
  }

  // ---------------- تقارير المبيعات ----------------
  Future<double> getTotalSales({DateTime? from, DateTime? to}) async {
    final db = await database;
    String where = '1=1';
    List<dynamic> args = [];
    if (from != null) {
      where += ' AND date_time >= ?';
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where += ' AND date_time <= ?';
      args.add(to.toIso8601String());
    }
    final result = await db.rawQuery('''
      SELECT SUM(ii.unit_price * ii.quantity) as total
      FROM invoice_items ii
      JOIN invoices i ON i.id = ii.invoice_id
      WHERE $where
    ''', args);
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }
}
