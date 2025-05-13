import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Hesaplar ekranının üst kısmında yer alan toplam bakiye ve hesap sayısı bilgisini gösteren header
class AccountsHeader extends StatelessWidget {
  final double totalBalance;
  final int accountCount;

  const AccountsHeader({
    super.key,
    required this.totalBalance,
    required this.accountCount,
  });

  @override
  Widget build(BuildContext context) {
    // Para formatlayıcı
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
    );

    // Renkler ve gradientler
    final bool isPositive = totalBalance >= 0;
    final List<Color> gradientColors = isPositive
        ? [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary,
            AppColors.primaryDark,
          ]
        : [
            AppColors.error.withOpacity(0.7),
            AppColors.error,
            AppColors.error.withOpacity(0.9),
          ];

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4, // Daha belirgin gölge
      shadowColor: isPositive
          ? AppColors.primary.withOpacity(0.4)
          : AppColors.error.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Arka plan süslemeleri - daha modern ve animasyonlu görünüm
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Küçük daire efektleri
            Positioned(
              top: 30,
              left: 80,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: 60,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Ana içerik
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 28.0, horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık ve hesap sayısı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Toplam Bakiye',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$accountCount Hesap',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24.0),

                  // Ana bakiye tutarı - daha büyük ve belirgin
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      currencyFormatter.format(totalBalance),
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8.0),

                  // Açıklama
                  Row(
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPositive
                            ? 'Tüm hesaplarınızdaki toplam bakiye'
                            : 'Hesaplarınızdaki toplam borç',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
