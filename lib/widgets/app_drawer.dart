import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../screens/services_screen.dart';
import '../screens/customers_screen.dart';
import '../screens/appointments_screen.dart';
import '../screens/invoices_screen.dart';
import '../screens/new_invoice_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/reports_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: AppColors.babyBlue,
              child: const Row(
                children: [
                  Icon(Icons.spa, size: 36, color: Colors.black),
                  SizedBox(width: 12),
                  Text(
                    'صالون - نظام الكاشير',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
            _drawerItem(context, Icons.point_of_sale, 'فاتورة جديدة', const NewInvoiceScreen()),
            _drawerItem(context, Icons.receipt_long, 'الفواتير', const InvoicesScreen()),
            _drawerItem(context, Icons.design_services, 'الخدمات والأسعار', const ServicesScreen()),
            _drawerItem(context, Icons.people, 'العملاء', const CustomersScreen()),
            _drawerItem(context, Icons.event, 'المواعيد', const AppointmentsScreen()),
            _drawerItem(context, Icons.inventory_2, 'المخزون', const InventoryScreen()),
            _drawerItem(context, Icons.bar_chart, 'تقارير المبيعات', const ReportsScreen()),
            const Divider(),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('الوضع الليلي'),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, Widget screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}
