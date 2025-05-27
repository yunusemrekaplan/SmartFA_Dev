import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../domain/models/response/quick_report_response_model.dart';

class ChartWidget extends StatelessWidget {
  final ChartModel chart;

  const ChartWidget({
    super.key,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    switch (chart.chartType.toLowerCase()) {
      case 'pie':
        return _buildPieChart();
      case 'bar':
        return _buildBarChart();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPieChart() {
    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sections: chart.data.map((data) {
            return PieChartSectionData(
              value: data.value,
              title: '${data.label}\n${data.value?.toStringAsFixed(0)}₺',
              color: data.color != null
                  ? Color(int.parse(data.color!.replaceAll('#', '0xFF')))
                  : Colors.primaries[
                      chart.data.indexOf(data) % Colors.primaries.length],
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 0,
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: chart.data
                  .map((e) => e.value)
                  .reduce((a, b) => a! > b! ? a : b) ??
              0 * 1.2,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= chart.data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      chart.data[value.toInt()].label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}₺',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: chart.data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value ?? 0,
                  color: entry.value.color != null
                      ? Color(
                          int.parse(entry.value.color!.replaceAll('#', '0xFF')))
                      : Colors.primaries[entry.key % Colors.primaries.length],
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
