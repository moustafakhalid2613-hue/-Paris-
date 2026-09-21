import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/appointment.dart';
import '../models/customer.dart';
import '../models/service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> appointments = [];
  List<Customer> customers = [];
  List<ServiceModel> services = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = DBHelper.instance;
    final a = await db.getAppointments();
    final c = await db.getCustomers();
    final s = await db.getServices();
    setState(() {
      appointments = a;
      customers = c;
      services = s;
    });
  }

  String _customerName(int id) => customers.firstWhere((c) => c.id == id, orElse: () => Customer(name: 'غير معروف', phone: '')).name;
  String _serviceName(int id) => services.firstWhere((s) => s.id == id, orElse: () => ServiceModel(name: 'غير معروف', price: 0)).name;

  void _showForm({Appointment? appt}) {
    if (customers.isEmpty || services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف عملاء وخدمات أولاً')),
      );
      return;
    }
    int? selectedCustomer = appt?.customerId ?? customers.first.id;
    int? selectedService = appt?.serviceId ?? services.first.id;
    DateTime selectedDate = appt?.dateTime ?? DateTime.now();
    final notesCtrl = TextEditingController(text: appt?.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(appt == null ? 'حجز موعد' : 'تعديل موعد', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedCustomer,
                decoration: const InputDecoration(labelText: 'العميل'),
                items: customers.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setSheetState(() => selectedCustomer = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selectedService,
                decoration: const InputDecoration(labelText: 'الخدمة'),
                items: services.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setSheetState(() => selectedService = v),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('التاريخ والوقت: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date == null) return;
                  final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(selectedDate));
                  if (time == null) return;
                  setSheetState(() {
                    selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'ملاحظات')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final newAppt = Appointment(
                      id: appt?.id,
                      customerId: selectedCustomer!,
                      serviceId: selectedService!,
                      dateTime: selectedDate,
                      status: appt?.status ?? 'pending',
                      notes: notesCtrl.text.trim(),
                    );
                    if (appt == null) {
                      await DBHelper.instance.insertAppointment(newAppt);
                    } else {
                      await DBHelper.instance.updateAppointment(newAppt);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
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

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.blue.shade100;
      case 'done': return Colors.green.shade100;
      case 'cancelled': return Colors.red.shade100;
      default: return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المواعيد')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: appointments.isEmpty
          ? const Center(child: Text('لا توجد مواعيد بعد'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: appointments.length,
              itemBuilder: (_, i) {
                final a = appointments[i];
                return Card(
                  color: _statusColor(a.status),
                  child: ListTile(
                    title: Text(_customerName(a.customerId), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${_serviceName(a.serviceId)}\n${DateFormat('yyyy-MM-dd HH:mm').format(a.dateTime)}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'edit') {
                          _showForm(appt: a);
                        } else if (v == 'delete') {
                          await DBHelper.instance.deleteAppointment(a.id!);
                          _load();
                        } else {
                          await DBHelper.instance.updateAppointment(Appointment(
                            id: a.id, customerId: a.customerId, serviceId: a.serviceId,
                            dateTime: a.dateTime, status: v, notes: a.notes,
                          ));
                          _load();
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'confirmed', child: Text('تأكيد')),
                        PopupMenuItem(value: 'done', child: Text('تم التنفيذ')),
                        PopupMenuItem(value: 'cancelled', child: Text('إلغاء')),
                        PopupMenuItem(value: 'edit', child: Text('تعديل')),
                        PopupMenuItem(value: 'delete', child: Text('حذف')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
