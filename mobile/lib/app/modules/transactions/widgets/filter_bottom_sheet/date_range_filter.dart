import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/filter_option.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/filter_section_title.dart';

class DateRangeFilter extends StatelessWidget {
  final TransactionsController controller;

  const DateRangeFilter({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionTitle(title: 'Tarih Aralığı'),
        FilterOption(
          leadingIcon: Icons.date_range_outlined,
          title: 'Tarih Aralığı Seçin',
          subtitle: Obx(() => Text(controller.selectedStartDate.value == null
              ? 'Tüm Tarihler'
              : '${DateFormat('dd/MM/yy', 'tr_TR').format(controller.selectedStartDate.value!)} - ${DateFormat('dd/MM/yy', 'tr_TR').format(controller.selectedEndDate.value!)}')),
          onTap: () => _selectDateRange(context),
        ),
      ],
    );
  }

  void _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blueGrey,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectDateRangeFromCalendar(picked.start, picked.end);
      Get.back();
    }
  }
}
