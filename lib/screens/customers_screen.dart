import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/customer.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Customer> customers = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DBHelper.instance.getCustomers();
    setState(() => customers = data);
  }

  void _showForm({Customer? customer}) {
    final nameCtrl = TextEditingController(text: customer?.name ?? '');
    final phoneCtrl = TextEditingController(text: customer?.phone ?? '');
    final notesCtrl = TextEditingController(text: customer?.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(customer == null ? 'إضافة عميل' : 'تعديل عميل', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم')),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'ملاحظات')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final newCustomer = Customer(
                    id: customer?.id,
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    notes: notesCtrl.text.trim(),
                    createdAt: customer?.createdAt,
                  );
                  if (customer == null) {
                    await DBHelper.instance.insertCustomer(newCustomer);
                  } else {
                    await DBHelper.instance.updateCustomer(newCustomer);
                  }
                  if (context.mounted) Navigator.pop(context);
                  _load();
                },
                child: const Text('حفظ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = customers.where((c) =>
        c.name.contains(query) || c.phone.contains(query)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('العملاء')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(labelText: 'بحث بالاسم أو رقم الهاتف', prefixIcon: Icon(Icons.search)),
              onChanged: (v) => setState(() => query = v),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('لا يوجد عملاء'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(c.name),
                          subtitle: Text(c.phone),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showForm(customer: c)),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () async {
                                  await DBHelper.instance.deleteCustomer(c.id!);
                                  _load();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
