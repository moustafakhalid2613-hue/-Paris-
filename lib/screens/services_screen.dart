import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<ServiceModel> services = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DBHelper.instance.getServices();
    setState(() => services = data);
  }

  void _showForm({ServiceModel? service}) {
    final nameCtrl = TextEditingController(text: service?.name ?? '');
    final priceCtrl = TextEditingController(text: service?.price.toString() ?? '');
    final categoryCtrl = TextEditingController(text: service?.category ?? 'عام');
    final durationCtrl = TextEditingController(text: service?.durationMinutes.toString() ?? '30');

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
            Text(service == null ? 'إضافة خدمة' : 'تعديل خدمة', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الخدمة')),
            const SizedBox(height: 12),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'التصنيف')),
            const SizedBox(height: 12),
            TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'المدة (دقيقة)'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final newService = ServiceModel(
                    id: service?.id,
                    name: nameCtrl.text.trim(),
                    price: double.tryParse(priceCtrl.text) ?? 0,
                    category: categoryCtrl.text.trim(),
                    durationMinutes: int.tryParse(durationCtrl.text) ?? 30,
                  );
                  if (service == null) {
                    await DBHelper.instance.insertService(newService);
                  } else {
                    await DBHelper.instance.updateService(newService);
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
    return Scaffold(
      appBar: AppBar(title: const Text('الخدمات والأسعار')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: services.isEmpty
          ? const Center(child: Text('لا توجد خدمات بعد، اضغط + للإضافة'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: services.length,
              itemBuilder: (_, i) {
                final s = services[i];
                return Card(
                  child: ListTile(
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${s.category} • ${s.durationMinutes} دقيقة'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${s.price.toStringAsFixed(0)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showForm(service: s)),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () async {
                            await DBHelper.instance.deleteService(s.id!);
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
