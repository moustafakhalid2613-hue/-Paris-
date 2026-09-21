import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/service.dart';
import '../models/customer.dart';
import '../models/inventory_item.dart';
import '../models/invoice.dart';

class CartLine {
  final String type; // service or product
  final int itemId;
  final String name;
  final double price;
  int quantity;

  CartLine({required this.type, required this.itemId, required this.name, required this.price, this.quantity = 1});

  double get total => price * quantity;
}

class NewInvoiceScreen extends StatefulWidget {
  const NewInvoiceScreen({super.key});

  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  List<ServiceModel> services = [];
  List<InventoryItem> products = [];
  List<Customer> customers = [];
  List<CartLine> cart = [];

  Customer? selectedCustomer;
  double discount = 0;
  String paymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = DBHelper.instance;
    final s = await db.getServices();
    final p = await db.getInventory();
    final c = await db.getCustomers();
    setState(() {
      services = s;
      products = p.where((e) => e.quantity > 0).toList();
      customers = c;
    });
  }

  void _addService(ServiceModel s) {
    setState(() {
      final existing = cart.where((c) => c.type == 'service' && c.itemId == s.id).toList();
      if (existing.isNotEmpty) {
        existing.first.quantity++;
      } else {
        cart.add(CartLine(type: 'service', itemId: s.id!, name: s.name, price: s.price));
      }
    });
  }

  void _addProduct(InventoryItem p) {
    setState(() {
      final existing = cart.where((c) => c.type == 'product' && c.itemId == p.id).toList();
      if (existing.isNotEmpty) {
        existing.first.quantity++;
      } else {
        cart.add(CartLine(type: 'product', itemId: p.id!, name: p.name, price: p.sellPrice));
      }
    });
  }

  double get subtotal => cart.fold(0, (sum, line) => sum + line.total);
  double get total => (subtotal - discount).clamp(0, double.infinity);

  Future<void> _checkout() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('السلة فارغة')));
      return;
    }
    final invoice = Invoice(
      customerId: selectedCustomer?.id,
      customerName: selectedCustomer?.name ?? 'عميل عابر',
      discount: discount,
      paymentMethod: paymentMethod,
      status: 'paid',
    );
    final items = cart.map((c) => InvoiceItem(
          invoiceId: 0,
          itemType: c.type,
          itemId: c.itemId,
          itemName: c.name,
          unitPrice: c.price,
          quantity: c.quantity,
        )).toList();

    await DBHelper.instance.insertInvoice(invoice, items);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إصدار الفاتورة بمبلغ ${total.toStringAsFixed(0)} ج.م')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فاتورة جديدة')),
      body: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(tabs: [Tab(text: 'الخدمات'), Tab(text: 'المنتجات')]),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildServiceList(),
                        _buildProductList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildCartSummary(),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
    if (services.isEmpty) return const Center(child: Text('لا توجد خدمات، أضفها من قائمة الخدمات'));
    return ListView.builder(
      itemCount: services.length,
      itemBuilder: (_, i) {
        final s = services[i];
        return ListTile(
          title: Text(s.name),
          subtitle: Text('${s.price.toStringAsFixed(0)} ج.م'),
          trailing: IconButton(icon: const Icon(Icons.add_circle), onPressed: () => _addService(s)),
          onTap: () => _addService(s),
        );
      },
    );
  }

  Widget _buildProductList() {
    if (products.isEmpty) return const Center(child: Text('لا توجد منتجات متاحة بالمخزون'));
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (_, i) {
        final p = products[i];
        return ListTile(
          title: Text(p.name),
          subtitle: Text('${p.sellPrice.toStringAsFixed(0)} ج.م • متاح: ${p.quantity}'),
          trailing: IconButton(icon: const Icon(Icons.add_circle), onPressed: () => _addProduct(p)),
          onTap: () => _addProduct(p),
        );
      },
    );
  }

  Widget _buildCartSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cart.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                itemCount: cart.length,
                itemBuilder: (_, i) {
                  final line = cart[i];
                  return ListTile(
                    dense: true,
                    title: Text(line.name),
                    subtitle: Text('${line.price.toStringAsFixed(0)} ج.م × ${line.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: () => setState(() {
                            if (line.quantity > 1) {
                              line.quantity--;
                            } else {
                              cart.removeAt(i);
                            }
                          }),
                        ),
                        Text('${line.total.toStringAsFixed(0)}'),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          onPressed: () => setState(() => cart.removeAt(i)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Customer?>(
                  value: selectedCustomer,
                  decoration: const InputDecoration(labelText: 'العميل (اختياري)'),
                  items: [
                    const DropdownMenuItem<Customer?>(value: null, child: Text('عميل عابر')),
                    ...customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))),
                  ],
                  onChanged: (v) => setState(() => selectedCustomer = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: paymentMethod,
                  decoration: const InputDecoration(labelText: 'طريقة الدفع'),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('كاش')),
                    DropdownMenuItem(value: 'card', child: Text('بطاقة')),
                  ],
                  onChanged: (v) => setState(() => paymentMethod = v ?? 'cash'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(labelText: 'الخصم (ج.م)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => setState(() => discount = double.tryParse(v) ?? 0),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الإجمالي: ${total.toStringAsFixed(0)} ج.م', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _checkout,
                icon: const Icon(Icons.check_circle),
                label: const Text('إتمام الدفع'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
