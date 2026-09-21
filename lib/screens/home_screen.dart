import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import 'new_invoice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double todaySales = 0;
  int lowStockCount = 0;
  int todayAppointments = 0;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final db = DBHelper.instance;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final sales = await db.getTotalSales(from: startOfDay);
    final inventory = await db.getInventory();
    final appointments = await db.getAppointments();

    final lowStock = inventory.where((i) => i.isLowStock).length;
    final todayAppts = appointments.where((a) =>
        a.dateTime.year == now.year &&
        a.dateTime.month == now.month &&
        a.dateTime.day == now.day).length;

    setState(() {
      todaySales = sales;
      lowStockCount = lowStock;
      todayAppointments = todayAppts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'ar', symbol: 'ج.م', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('الرئيسية')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const NewInvoiceScreen()));
          _loadSummary();
        },
        icon: const Icon(Icons.add),
        label: const Text('فاتورة جديدة'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSummary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _summaryCard(
              icon: Icons.attach_money,
              title: 'مبيعات اليوم',
              value: currency.format(todaySales),
              color: AppColors.babyBlue,
            ),
            const SizedBox(height: 12),
            _summaryCard(
              icon: Icons.event,
              title: 'مواعيد اليوم',
              value: '$todayAppointments موعد',
              color: AppColors.babyBlueLight,
            ),
            const SizedBox(height: 12),
            _summaryCard(
              icon: Icons.warning_amber_rounded,
              title: 'منتجات منخفضة المخزون',
              value: '$lowStockCount صنف',
              color: lowStockCount > 0 ? Colors.orange.shade100 : AppColors.babyBlueLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({required IconData icon, required String title, required String value, required Color color}) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.black)),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
