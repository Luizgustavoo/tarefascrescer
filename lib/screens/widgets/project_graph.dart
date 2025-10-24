import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_projetocrescer/providers/graph_provider.dart';
import 'package:tarefas_projetocrescer/utils/formatters.dart';

class ProjectValuesPieChart extends StatefulWidget {
  const ProjectValuesPieChart({super.key});

  @override
  State<ProjectValuesPieChart> createState() => _ProjectValuesPieChartState();
}

class _ProjectValuesPieChartState extends State<ProjectValuesPieChart> {
  int touchedIndex = -1;

  BarChartGroupData generateBarGroup(
    int x,
    Color color,
    double value,
    double maxValue,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 14,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(4),
          ),
        ),
      ],

      showingTooltipIndicators: touchedIndex == x ? [0] : [],
    );
  }

  String _compactCurrencyFormatter(double value) {
    if (value == 0) return 'R\$ 0';
    return NumberFormat.compactCurrency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final graphProvider = context.watch<GraphProvider>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildChartContent(context, graphProvider),
    );
  }

  Widget _buildChartContent(BuildContext context, GraphProvider provider) {
    if (provider.isLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    } else if (provider.errorMessage != null) {
      return Center(
        key: const ValueKey('error'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Erro ao carregar dados: ${provider.errorMessage}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (provider.graphData.isEmpty) {
      return const Center(
        key: ValueKey('empty'),
        child: Text(
          'Nenhum projeto com valor aprovado encontrado.',
          textAlign: TextAlign.center,
        ),
      );
    } else {
      final maxValue = provider.graphData.fold<double>(
        0.0,
        (max, item) => item.approvedValue > max ? item.approvedValue : max,
      );
      final safeMaxValue = maxValue == 0 ? 1.0 : maxValue;

      return Padding(
        key: const ValueKey('chart'),

        padding: const EdgeInsets.only(
          top: 24,
          bottom: 12,
          left: 15,
          right: 25,
        ),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: safeMaxValue * 1.1,
            minY: 0,

            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: safeMaxValue / 4,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey.shade300, strokeWidth: 0.8),
            ),
            borderData: FlBorderData(show: false),

            titlesData: FlTitlesData(
              show: true,

              bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),

              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 65,
                  interval: safeMaxValue / 4,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return Container();
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4,
                      child: Text(
                        _compactCurrencyFormatter(value),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    );
                  },
                ),
              ),

              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),

            barGroups: List.generate(provider.graphData.length, (index) {
              final dataPoint = provider.graphData[index];
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: dataPoint.approvedValue,
                    color: dataPoint.color,
                    width: 16,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],

                showingTooltipIndicators: touchedIndex == index ? [0] : [],
              );
            }),

            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  if (groupIndex < 0 || groupIndex >= provider.graphData.length)
                    return null;
                  final dataPoint = provider.graphData[groupIndex];
                  return BarTooltipItem(
                    '${dataPoint.projectName}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: Formatters.formatCurrency(rod.toY),
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
              touchCallback: (FlTouchEvent event, barTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      barTouchResponse?.spot == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex = barTouchResponse!.spot!.touchedBarGroupIndex;
                });
              },
            ),
          ),
        ),
      );
    }
  }
}
