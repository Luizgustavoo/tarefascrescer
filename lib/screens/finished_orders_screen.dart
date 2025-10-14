import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tarefas_projetocrescer/models/finish_order.dart';
import 'package:tarefas_projetocrescer/screens/widgets/home_header.dart';

class FinishedOrdersScreen extends StatefulWidget {
  const FinishedOrdersScreen({super.key});
  @override
  State<FinishedOrdersScreen> createState() => _FinishedOrdersScreenState();
}

class _FinishedOrdersScreenState extends State<FinishedOrdersScreen> {
  final List<FinishedOrder> _allOrders = [
    FinishedOrder(
      name: 'Projeto Website XPTO',
      date: DateTime(2025, 8, 15),
      value: 5500.0,
      status: 'Entregue',
    ),
    FinishedOrder(
      name: 'Consultoria de Marketing',
      date: DateTime(2025, 7, 22),
      value: 3200.0,
      status: 'Concluído',
    ),
    FinishedOrder(
      name: 'Desenvolvimento API',
      date: DateTime(2025, 8, 1),
      value: 12500.0,
      status: 'Entregue',
    ),
  ];
  late List<FinishedOrder> _filteredOrders;

  @override
  void initState() {
    super.initState();
    _filteredOrders = _allOrders;
  }

  void _filterOrders(String query) {
    List<FinishedOrder> filteredList = _allOrders.where((order) {
      final orderName = order.name.toLowerCase();
      final orderDate = DateFormat('dd/MM/yyyy').format(order.date);
      final searchQuery = query.toLowerCase();
      return orderName.contains(searchQuery) || orderDate.contains(searchQuery);
    }).toList();
    setState(() => _filteredOrders = filteredList);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: HomeHeader(onSearchChanged: _filterOrders),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: _filteredOrders.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];
                  return _buildOrderCard(order);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(FinishedOrder order) {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Data: ${DateFormat('dd/MM/yyyy').format(order.date)}'),
                Text(
                  'Valor: ${NumberFormat.simpleCurrency(locale: 'pt_BR').format(order.value)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
