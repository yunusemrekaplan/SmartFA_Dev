import 'package:flutter/material.dart';
import 'package:mobile/app/widgets/empty_state_view.dart';
import 'package:mobile/app/modules/dashboard/widgets/welcome_dashboard.dart';

/// Dashboard için özel boş durum görünümü
class WelcomeEmptyStateView extends EmptyStateView {
  final bool hasAccounts;
  final bool hasTransactions;
  final bool hasBudgets;
  final VoidCallback onAddAccount;
  final VoidCallback onAddTransaction;
  final VoidCallback onAddBudget;

  const WelcomeEmptyStateView({
    super.key,
    required this.hasAccounts,
    required this.hasTransactions,
    required this.hasBudgets,
    required this.onAddAccount,
    required this.onAddTransaction,
    required this.onAddBudget,
  }) : super(
          title: '',
          message: '',
          icon: Icons.waving_hand_rounded,
        );

  @override
  Widget build(BuildContext context) {
    return WelcomeDashboard(
      hasAccounts: hasAccounts,
      hasTransactions: hasTransactions,
      hasBudgets: hasBudgets,
      onAddAccount: onAddAccount,
      onAddTransaction: onAddTransaction,
      onAddBudget: onAddBudget,
    );
  }
}
