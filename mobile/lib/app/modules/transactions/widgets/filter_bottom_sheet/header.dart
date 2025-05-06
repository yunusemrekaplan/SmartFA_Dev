import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';

class Header extends StatelessWidget {
  final TransactionsController controller;

  const Header({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'İşlem Filtreleri',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ],
    );
  }
}