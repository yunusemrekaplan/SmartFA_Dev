import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mobile/app/services/page_refresh_service.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/widgets/empty_state_view.dart';
import 'package:mobile/app/widgets/error_view.dart';
import 'package:mobile/app/widgets/loading_state_view.dart';

/// Standart içerik görüntüleme ve yenileme davranışı sağlayan widget.
/// İçeriğin durumuna göre (yükleniyor, hata, boş veya dolu) uygun UI gösterir.
/// Pull-to-refresh desteği ile kullanıcının içeriği yenilemesine olanak tanır.
class RefreshableContentView<T> extends StatelessWidget {
  /// İçeriğin kendisi (liste, grid veya başka bir widget olabilir)
  final Widget contentView;

  /// Yükleme durumu
  final RxBool isLoading;

  /// Hata mesajı (boş string yoksa hata olmadığını gösterir)
  final RxString errorMessage;

  /// Veri listesi (boş liste kontrolü için)
  final RxList<T>? items;

  /// Boş durum mesajı ve görünümü (items boşsa gösterilir)
  final EmptyStateView? emptyStateView;

  /// İçeriği yenileme işlevi
  final Future<void> Function() onRefresh;

  /// Hata durumunda yeniden deneme işlevi (genellikle onRefresh ile aynı)
  final VoidCallback? onRetry;

  /// Yükleniyor mesajı
  final String loadingMessage;

  /// Eğer içerik dolu olsa bile yükleme göstergesi gösterilsin mi?
  final bool showLoadingOverlay;

  /// İçerik için padding
  final EdgeInsetsGeometry contentPadding;

  /// Yükleme göstergesi için renk
  final Color? progressColor;

  /// İçeriğin etrafına scrollbar eklensin mi?
  final bool addScrollbar;

  /// Başlık widget'ı (opsiyonel, içeriğin üstünde gösterilir)
  final Widget? headerWidget;

  /// Alt kısım widget'ı (opsiyonel, içeriğin altında gösterilir)
  final Widget? footerWidget;

  /// ScrollController (opsiyonel, dışarıdan kontrol için)
  final ScrollController? scrollController;

  const RefreshableContentView({
    super.key,
    required this.contentView,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    this.items,
    this.emptyStateView,
    this.onRetry,
    this.loadingMessage = 'Veriler yükleniyor...',
    this.showLoadingOverlay = false,
    this.contentPadding = EdgeInsets.zero,
    this.progressColor,
    this.addScrollbar = false,
    this.headerWidget,
    this.footerWidget,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // RefreshIndicator'un çalışması için ListView veya Builder içermesi gerekiyor
    return RefreshIndicator(
      color: progressColor ?? AppColors.primary,
      onRefresh: () => PageRefreshService.handlePullToRefresh(
        refreshAction: onRefresh,
        isLoading: isLoading,
      ),
      child: Obx(() => _buildMainContent(context)),
    );
  }

  /// İçeriğin ana durumunu belirler ve uygun widget'ı döndürür
  Widget _buildMainContent(BuildContext context) {
    // Tamamen boş ve yükleniyor durumu
    if (isLoading.value && _isContentEmpty()) {
      return LoadingStateView(message: loadingMessage);
    }

    // Tamamen hata durumu
    if (errorMessage.isNotEmpty && _isContentEmpty()) {
      return ErrorView(
        message: errorMessage.value,
        onRetry: onRetry ?? onRefresh,
        isLarge: true,
      );
    }

    // Boş içerik durumu (yükleme veya hata yok)
    if (_isContentEmpty() && !isLoading.value && errorMessage.isEmpty) {
      // İçerik boş ama yükleme durumunda değilse, yeniden yüklemeyi dene
      // Bu özellikle ilk yüklemede içerik alınamadığında yardımcı olur
      Future.microtask(() => onRefresh());

      if (emptyStateView != null) {
        return emptyStateView!;
      }
      // Varsayılan boş durum görünümü
      return const EmptyStateView(
        title: 'İçerik Bulunamadı',
        message: 'Henüz gösterilecek içerik bulunmamaktadır.',
        icon: Icons.inbox_outlined,
      );
    }

    // Normal içerik görünümü
    return _buildContentWithStates(context);
  }

  /// Yüklenme ve hata durumlarını içeren normal içerik görünümü
  Widget _buildContentWithStates(BuildContext context) {
    Widget content = addScrollbar
        ? Scrollbar(
            controller: scrollController,
            thickness: 6.0,
            radius: const Radius.circular(10),
            thumbVisibility: true,
            child: _buildScrollableContent(),
          )
        : _buildScrollableContent();

    return Stack(
      children: [
        // Ana içerik
        content,

        // Yüklenme göstergesi (eğer aktifse ve showLoadingOverlay true ise)
        if (isLoading.value && showLoadingOverlay)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              backgroundColor:
                  (progressColor ?? AppColors.primary).withOpacity(0.1),
              color: progressColor ?? AppColors.primary,
            ).animate().fadeIn(),
          ),

        // Hata durum göstergesi (kısmi hata için)
        if (errorMessage.isNotEmpty && !_isContentEmpty())
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 4,
              color: Colors.red.shade100,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage.value,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh,
                          color: Colors.red, size: 18),
                      onPressed: onRetry ?? onRefresh,
                      tooltip: 'Yeniden Dene',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().slideY(begin: -1, end: 0),
          ),
      ],
    );
  }

  /// Kaydırılabilir içerik oluşturur, header ve footer ekler
  Widget _buildScrollableContent() {
    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Header widget
        if (headerWidget != null) SliverToBoxAdapter(child: headerWidget!),

        // Ana içerik
        SliverPadding(
          padding: contentPadding,
          sliver: SliverToBoxAdapter(child: contentView),
        ),

        // Footer widget
        if (footerWidget != null) SliverToBoxAdapter(child: footerWidget!),

        // Ekstra boşluk - pull-to-refresh için
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }

  /// İçeriğin tamamen boş olup olmadığını kontrol eder
  bool _isContentEmpty() {
    if (items != null) {
      return items!.isEmpty;
    }
    // items null ise, içeriğin dolu olduğunu varsayıyoruz
    return false;
  }
}
