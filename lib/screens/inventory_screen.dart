import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/inventory_item.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<InventoryItem> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DBHelper.instance.getInventory();
    setState(() => items = data);
  }

  void _showForm({InventoryItem? item}) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final qtyCtrl = TextEditingController(text: item?.quantity.toString() ?? '0');
    final minQtyCtrl = TextEditingController(text: item?.minQuantity.toString() ?? '5');
    final costCtrl = TextEditingController(text: item?.costPrice.toString() ?? '0');
    final sellCtrl = TextEditingController(text: item?.sellPrice.toString() ?? '0');
    final unitCtrl = TextEditingController(text: item?.unit ?? 'قطعة');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item == null ? 'إضافة صنف' : 'تعديل صنف', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المنتج')),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'الكمية الحالية'), keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: minQtyCtrl, decoration: const InputDecoration(labelText: 'حد التنبيه'), keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'سعر التكلفة'), keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: sellCtrl, decoration: const InputDecoration(labelText: 'سعر البيع'), keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'الوحدة')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final newItem = InventoryItem(
                      id: item?.id,
                      name: nameCtrl.text.trim(),
                      quantity: int.tryParse(qtyCtrl.text) ?? 0,
                      minQuantity: int.tryParse(minQtyCtrl.text) ?? 5,
                      costPrice: double.tryParse(costCtrl.text) ?? 0,
                      sellPrice: double.tryParse(sellCtrl.text) ?? 0,
                      unit: unitCtrl.text.trim(),
                    );
                    if (item == null) {
                      await DBHelper.instance.insertInventoryItem(newItem);
                    } else {
                      await DBHelper.instance.updateInventoryItem(newItem);
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المخزون')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: items.isEmpty
          ? const Center(child: Text('لا توجد أصناف بعد'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final it = items[i];
                return Card(
                  color: it.isLowStock ? Colors.orange.shade50 : null,
                  child: ListTile(
                    leading: Icon(
                      it.isLowStock ? Icons.warning_amber_rounded : Icons.inventory_2,
                      color: it.isLowStock ? Colors.orange : null,
                    ),
                    title: Text(it.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('الكمية: ${it.quantity} ${it.unit} • سعر البيع: ${it.sellPrice.toStringAsFixed(0)} ج.م'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showForm(item: it)),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () async {
                            await DBHelper.instance.deleteInventoryItem(it.id!);
                            _load();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
