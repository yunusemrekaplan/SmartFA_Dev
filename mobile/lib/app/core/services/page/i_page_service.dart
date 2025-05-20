/// Sayfa işlemlerini tanımlayan arayüz
abstract class IPageService {
  /// Yeni sayfa açar
  Future<T?> toNamed<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
  });

  /// En son sayfayı kapatır
  void closeLastPage();

  /// Tüm sayfaları kapatır (root hariç)
  void closeAllPages();

  /// Belirli bir sayfaya kadar tüm sayfaları kapatır
  void closeUntilPage(String pageName);

  /// Root sayfaya kadar tüm sayfaları kapatır
  void closeUntilRoot();

  /// Belirli bir sayfaya geri döner ve üstündeki tüm sayfaları kapatır
  void backToPage(String pageName);

  /// Belirli bir sayfaya gider ve tüm geçmişi temizler
  void offAllNamed(String page);

  /// Belirli bir sayfaya gider ve önceki sayfayı değiştirir
  void offAndToNamed(String page);
}
