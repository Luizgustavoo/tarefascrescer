import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Formatters {
  static String formatApiDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }
    try {
      final parsedDate = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      Exception('Erro ao formatar a data "$dateString": $e');
      return dateString;
    }
  }

  static String formatDateForApi(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  static double? parseCurrency(String text) {
    if (text.isEmpty) return null;
    try {
      final sanitized = text
          .replaceAll('R\$', '')
          .trim()
          .replaceAll('.', '')
          .replaceAll(',', '.');
      return double.parse(sanitized);
    } catch (e) {
      return null;
    }
  }

  static String formatDateForDisplayFromString(String apiDateString) {
    if (apiDateString.isEmpty) return '';
    try {
      final parsedDate = DateTime.parse(apiDateString);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return apiDateString;
    }
  }

  static String formatDateForApiFromString(String displayDateString) {
    if (displayDateString.isEmpty) return '';
    try {
      final parsedDate = DateFormat(
        'dd/MM/yyyy',
      ).parseStrict(displayDateString);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      print("Erro ao formatar data para API: $displayDateString");
      return '';
    }
  }

  static String formatCurrency(double? value) {
    if (value == null) {
      return 'R\$ 0,00';
    }
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return currencyFormat.format(value);
  }

  static Color colorFromHex(
    String? hexColor, {
    Color defaultColor = Colors.grey,
  }) {
    if (hexColor == null || hexColor.isEmpty) {
      return defaultColor;
    }

    final String hexCode = hexColor.replaceAll('#', '');
    String fullHexCode = hexCode;

    if (hexCode.length == 3) {
      final r = hexCode[0];
      final g = hexCode[1];
      final b = hexCode[2];
      fullHexCode = '$r$r$g$g$b$b';
    }

    if (fullHexCode.length != 6) {
      return defaultColor;
    }

    try {
      final int colorValue = int.parse('FF$fullHexCode', radix: 16);
      return Color(colorValue);
    } catch (e) {
      Exception('Erro ao converter cor Hex "$hexColor": $e');
      return defaultColor;
    }
  }
}
