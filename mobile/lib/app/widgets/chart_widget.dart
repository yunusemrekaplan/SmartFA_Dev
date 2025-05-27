import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/models/response/quick_report_response_model.dart';
import '../theme/app_colors.dart';

class ChartWidget extends StatelessWidget {
  final ChartModel chart;

  const ChartWidget({
    super.key,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getChartIcon(),
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  chart.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildChart(),
          ],
        ),
      ),
    );
  }

  IconData _getChartIcon() {
    switch (chart.chartType.toLowerCase()) {
      case 'pie':
        return Icons.pie_chart_rounded;
      case 'bar':
        return Icons.bar_chart_rounded;
      default:
        return Icons.show_chart_rounded;
    }
  }

  Widget _buildChart() {
    switch (chart.chartType) {
      case 'pie':
        return AspectRatio(
          aspectRatio: 1.5,
          child: PieChart(
            PieChartData(
              sections: _buildPieSections(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              startDegreeOffset: -90,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                enabled: true,
              ),
            ),
          ),
        );
      case 'bar':
        return AspectRatio(
          aspectRatio: 1.8,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxBarValue(),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '₺${rod.toY.toStringAsFixed(2)}',
                      GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          chart.data[value.toInt()].label,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    },
                    reservedSize: 42,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: _buildBarGroups(),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  List<PieChartSectionData> _buildPieSections() {
    final List<Color> colors = [
      AppColors.primary,
      AppColors.secondary,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return chart.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final color = colors[index % colors.length];
      final value = data.value ?? 0.0;
      final totalValue = _getTotalValue();
      final percentage = totalValue > 0 ? (value / totalValue * 100) : 0.0;

      return PieChartSectionData(
        color: color,
        value: value,
        title: '${data.label}\n%${percentage.toStringAsFixed(1)}',
        radius: 100,
        titleStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildBarGroups() {
    final List<Color> colors = [
      AppColors.primary,
      AppColors.secondary,
      Colors.orange,
      Colors.green,
    ];

    return chart.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final color = colors[index % colors.length];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.value ?? 0,
            color: color,
            width: 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxBarValue() {
    double maxValue = 0;
    for (var data in chart.data) {
      if ((data.value ?? 0) > maxValue) {
        maxValue = data.value ?? 0;
      }
    }
    return maxValue * 1.2;
  }

  double _getTotalValue() {
    double total = 0;
    for (var data in chart.data) {
      total += data.value ?? 0;
    }
    return total;
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final double size;
  final Color borderColor;

  const _Badge(
    this.label, {
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Icon(
          _getCategoryIcon(label),
          color: borderColor,
          size: size * .5,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String label) {
    final lowercaseLabel = label.toLowerCase();
    if (lowercaseLabel.contains('gelir')) {
      return Icons.arrow_upward_rounded;
    } else if (lowercaseLabel.contains('gider')) {
      return Icons.arrow_downward_rounded;
    } else if (lowercaseLabel.contains('fatura')) {
      return Icons.receipt_rounded;
    } else if (lowercaseLabel.contains('market')) {
      return Icons.shopping_cart_rounded;
    } else if (lowercaseLabel.contains('eğlence')) {
      return Icons.movie_rounded;
    } else if (lowercaseLabel.contains('spor')) {
      return Icons.fitness_center_rounded;
    } else if (lowercaseLabel.contains('sağlık')) {
      return Icons.medical_services_rounded;
    } else if (lowercaseLabel.contains('ulaşım')) {
      return Icons.directions_car_rounded;
    } else if (lowercaseLabel.contains('eğitim')) {
      return Icons.school_rounded;
    } else if (lowercaseLabel.contains('kira')) {
      return Icons.home_rounded;
    } else if (lowercaseLabel.contains('maaş')) {
      return Icons.account_balance_wallet_rounded;
    } else if (lowercaseLabel.contains('yatırım')) {
      return Icons.trending_up_rounded;
    } else if (lowercaseLabel.contains('diğer')) {
      return Icons.more_horiz_rounded;
    }
    return Icons.attach_money_rounded;
  }
}
