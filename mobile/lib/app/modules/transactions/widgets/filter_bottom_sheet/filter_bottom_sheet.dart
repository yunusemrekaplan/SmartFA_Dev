import 'package:flutter/material.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/account_filter.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/action_buttons.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/category_filter.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/date_range_filter.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/header.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/quick_date_filter.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/sorting_options.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/transaction_type_filter.dart';

class FilterBottomSheet extends StatelessWidget {
  final TransactionsController controller;

  const FilterBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Header(controller: controller),
            const Divider(height: 24),
            TransactionTypeFilter(controller: controller),
            const SizedBox(height: 24),
            DateRangeFilter(controller: controller),
            const SizedBox(height: 16),
            QuickDateFilter(controller: controller),
            const SizedBox(height: 16),
            CategoryFilter(controller: controller),
            const SizedBox(height: 16),
            AccountFilter(controller: controller),
            const SizedBox(height: 24),
            SortingOptions(controller: controller),
            const SizedBox(height: 24),
            ActionButtons(controller: controller),
          ],
        ),
      ),
    );
  }
}
