import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';

/// Yeni kullanıcılar için özel dashboard görünümü
class WelcomeDashboard extends StatelessWidget {
  final bool hasAccounts;
  final bool hasTransactions;
  final bool hasBudgets;
  final VoidCallback onAddAccount;
  final VoidCallback onAddTransaction;
  final VoidCallback onAddBudget;

  const WelcomeDashboard({
    super.key,
    required this.hasAccounts,
    required this.hasTransactions,
    required this.hasBudgets,
    required this.onAddAccount,
    required this.onAddTransaction,
    required this.onAddBudget,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppTheme.kHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Hoş geldin kartı
            _buildWelcomeCard(context),

            const SizedBox(height: 32),

            // Başlangıç adımları
            _buildSetupSteps(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color.lerp(AppColors.primary, Colors.purple, 0.6) ??
                AppColors.primary,
          ],
          stops: const [0.2, 1.0],
        ),
        borderRadius: BorderRadius.circular(AppTheme.kCardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.waving_hand_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1.0, 1.0),
                  ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SmartFA\'ya Hoş Geldiniz!',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideX(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      'Finansal hedeflerinize ulaşmanız için size yardımcı olacağız.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideX(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildSetupSteps(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Başlangıç Adımları',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
          ),
          // 1. Adım: Hesap Ekle
          _buildSetupStep(
            context: context,
            title: 'Hesap Ekle',
            subtitle: 'Finansal hesaplarınızı takip etmeye başlayın',
            icon: Icons.account_balance_wallet_outlined,
            isCompleted: hasAccounts,
            onAction: onAddAccount,
            actionText: 'Hesap Ekle',
            delay: 0,
            stepNumber: 1,
          ),
          // 2. Adım: Bütçe Oluştur
          if (hasAccounts) ...[
            _buildSetupStep(
              context: context,
              title: 'Bütçe Oluştur',
              subtitle: 'Harcamalarınızı planlayın ve kontrol altında tutun',
              icon: Icons.pie_chart_outline_rounded,
              isCompleted: hasBudgets,
              onAction: onAddBudget,
              actionText: 'Bütçe Oluştur',
              delay: 100,
              stepNumber: 2,
            ),
            // 3. Adım: İşlem Ekle
            _buildSetupStep(
              context: context,
              title: 'İşlem Ekle',
              subtitle: 'Gelir ve giderlerinizi kaydedin',
              icon: Icons.sync_alt_rounded,
              isCompleted: hasTransactions,
              onAction: onAddTransaction,
              actionText: 'İşlem Ekle',
              delay: 200,
              stepNumber: 3,
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildSetupStep({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required VoidCallback onAction,
    required String actionText,
    required int delay,
    required int stepNumber,
  }) {
    final Color stepColor = isCompleted ? AppColors.success : AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withOpacity(0.3)
              : Colors.grey.shade100,
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCompleted ? stepColor : Colors.grey).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Adım numarası
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: stepColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: stepColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check_rounded,
                      color: stepColor,
                      size: 16,
                    )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                          duration: 2000.ms,
                          color: Colors.white.withOpacity(0.2))
                  : Text(
                      '$stepNumber',
                      style: TextStyle(
                        color: stepColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                        fontSize: 15,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
          if (!isCompleted) ...[
            const SizedBox(width: 12),
            IntrinsicWidth(
              child: StatefulBuilder(
                builder: (context, setState) {
                  bool isHovered = false;
                  return MouseRegion(
                    onEnter: (_) => setState(() => isHovered = true),
                    onExit: (_) => setState(() => isHovered = false),
                    child: ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: stepColor.withOpacity(0.1),
                        foregroundColor: stepColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: stepColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                      ).copyWith(
                        elevation: WidgetStateProperty.resolveWith<double>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.hovered)) return 4;
                            return 0;
                          },
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.hovered)) {
                              return stepColor;
                            }
                            return stepColor.withOpacity(0.1);
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.hovered)) {
                              return Colors.white;
                            }
                            return stepColor;
                          },
                        ),
                        overlayColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return stepColor.withOpacity(0.2);
                            }
                            return null;
                          },
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            actionText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: isHovered ? Colors.white : stepColor,
                          )
                              .animate(
                                target: isHovered ? 1 : 0,
                              )
                              .slideX(
                                begin: 0,
                                end: 0.2,
                                duration: 200.ms,
                                curve: Curves.easeOut,
                              ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 600.ms).slideX(
          begin: 0.2,
          end: 0,
          delay: delay.ms,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
