import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double todaySales = 0;
  double weekSales = 0;
  double monthSales = 0;
  double allTimeSales = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = DBHelper.instance;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    final today = await db.getTotalSales(from: startOfDay);
    final week = await db.getTotalSales(from: startOfWeek);
    final month = await db.getTotalSales(from: startOfMonth);
    final all = await db.getTotalSales();

    setState(() {
      todaySales = today;
      weekSales = week;
      monthSales = month;
      allTimeSales = all;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تقارير المبيعات')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _reportTile('مبيعات اليوم', todaySales),
            _reportTile('مبيعات هذا الأسبوع', weekSales),
            _reportTile('مبيعات هذا الشهر', monthSales),
            _reportTile('إجمالي المبيعات', allTimeSales),
          ],
        ),
      ),
    );
  }

  Widget _reportTile(String title, double value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text('${value.toStringAsFixed(0)} ج.م', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
