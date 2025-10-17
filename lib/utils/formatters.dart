// FILE: lib/utils/formatters.dart

import 'package:intl/intl.dart';

// Uma classe que contém apenas métodos estáticos,
// para que você não precise criar uma instância dela para usar as funções.
class Formatters {
  // --- FORMATADOR DE DATA ---
  // Recebe uma string da API (ex: "2025-10-16") e a converte para "16/10/2025"
  static String formatApiDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A'; // Retorna 'Não Aplicável' se a data for nula ou vazia
    }
    try {
      final parsedDate = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      // Se a string da API vier em um formato inesperado, retorna a string original
      print('Erro ao formatar a data "$dateString": $e');
      return dateString;
    }
  }

  // --- FORMATADOR DE MOEDA ---
  // Recebe um valor double e o converte para "R$ 50.000,00"
  static String formatCurrency(double? value) {
    if (value == null) {
      return 'R\$ 0,00';
    }
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return currencyFormat.format(value);
  }

  // Você pode adicionar outros formatadores aqui no futuro, como:
  // static String formatPhoneNumber(String? phone) { ... }
  // static String capitalize(String? text) { ... }
}
