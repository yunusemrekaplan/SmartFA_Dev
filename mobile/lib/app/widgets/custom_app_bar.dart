import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Uygulama genelinde tutarlı görünüm için özelleştirilmiş AppBar.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// AppBar başlığı
  final String title;

  /// Başlık yerine özel widget kullanılması durumunda
  final Widget? titleWidget;

  /// Sağ taraftaki eylem butonları
  final List<Widget>? actions;

  /// Geri butonu gösterilsin mi?
  final bool showBackButton;

  /// Geri butonuna basıldığında çağrılacak fonksiyon
  final VoidCallback? onBackPressed;

  /// AppBar yüksekliği
  final double height;

  /// AppBar arka plan rengi (null ise tema rengini kullanır)
  final Color? backgroundColor;

  /// Başlık metni rengi (null ise tema rengini kullanır)
  final Color? titleColor;

  /// Alt kısımda çizgi gösterilsin mi?
  final bool showBottomDivider;

  /// Gölge gösterilsin mi?
  final bool showShadow;

  /// Alt kısımda özel widget (örn. sekme çubuğu)
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title = '',
    this.titleWidget,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.height = kToolbarHeight,
    this.backgroundColor,
    this.titleColor,
    this.showBottomDivider = false,
    this.showShadow = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: titleWidget ??
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: titleColor,
            ),
          ),
      centerTitle: true,
      backgroundColor: backgroundColor,
      elevation: showShadow ? 2 : 0,
      actions: actions,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: bottom!.preferredSize,
              child: Column(
                children: [
                  bottom!,
                  if (showBottomDivider) const Divider(height: 1, thickness: 1),
                ],
              ),
            )
          : showBottomDivider
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Divider(height: 1, thickness: 1),
                )
              : null,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Get.back(),
            )
          : null,
      automaticallyImplyLeading: showBackButton,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        height +
            (bottom?.preferredSize.height ?? 0) +
            (showBottomDivider ? 1 : 0),
      );
}

/// Basit arama kutusu içeren AppBar
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Arama kutusu ipucu metni
  final String hintText;

  /// Arama değeri değiştiğinde çağrılacak fonksiyon
  final Function(String) onChanged;

  /// Arama TextEditingController'ı
  final TextEditingController controller;

  /// Temizleme butonu gösterilsin mi?
  final bool showClearButton;

  /// Geri butonu gösterilsin mi?
  final bool showBackButton;

  /// Alt kısımda çizgi gösterilsin mi?
  final bool showBottomDivider;

  const SearchAppBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    required this.controller,
    this.showClearButton = true,
    this.showBackButton = true,
    this.showBottomDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: showClearButton && controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
        ),
      ),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            )
          : null,
      automaticallyImplyLeading: showBackButton,
      bottom: showBottomDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, thickness: 1),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (showBottomDivider ? 1 : 0),
      );
}
