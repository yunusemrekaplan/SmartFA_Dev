import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/models/response/account_response_model.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/dropdown.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/filter_section_title.dart';

class AccountFilter extends StatelessWidget {
  final TransactionsController controller;

  const AccountFilter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionTitle(title: 'Hesap'),
        Obx(
          () => DropDown<AccountModel?>(
            value: controller.selectedAccount.value,
            items: [
              const DropdownMenuItem<AccountModel?>(
                value: null,
                child: Text('Tüm Hesaplar'),
              ),
              ...controller.filterAccounts.map(
                (account) => DropdownMenuItem<AccountModel>(
                  value: account,
                  child: Text(account.name, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: (value) => controller.selectedAccount.value = value,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }
}
