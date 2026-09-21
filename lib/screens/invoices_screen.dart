import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/invoice.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  List<Invoice> invoices = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DBHelper.instance.getInvoices();
    setState(() => invoices = data);
  }

  void _showDetails(Invoice inv) async {
    final items = await DBHelper.instance.getInvoiceItems(inv.id!);
    final total = items.fold<double>(0, (sum, i) => sum + i.total) - inv.discount;
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('فاتورة #${inv.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(inv.customerName),
            Text(DateFormat('yyyy-MM-dd HH:mm').format(inv.dateTime)),
            const Divider(),
            ...items.map((i) => ListTile(
                  dense: true,
                  title: Text(i.itemName),
                  subtitle: Text('${i.unitPrice.toStringAsFixed(0)} × ${i.quantity}'),
                  trailing: Text('${i.total.toStringAsFixed(0)} ج.م'),
                )),
            const Divider(),
            if (inv.discount > 0) Text('الخصم: ${inv.discount.toStringAsFixed(0)} ج.م'),
            Text('الإجمالي: ${total.toStringAsFixed(0)} ج.م', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('طريقة الدفع: ${inv.paymentMethod == 'cash' ? 'كاش' : 'بطاقة'}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الفواتير')),
      body: invoices.isEmpty
          ? const Center(child: Text('لا توجد فواتير بعد'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: invoices.length,
              itemBuilder: (_, i) {
                final inv = invoices[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text(inv.customerName),
                    subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(inv.dateTime)),
                    trailing: Text('#${inv.id}'),
                    onTap: () => _showDetails(inv),
                  ),
                );
              },
            ),
    );
  }
}
