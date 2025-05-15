import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/categories/controllers/categories_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Kategori ikonu seçmek için bir ızgara görünümü sağlayan widget.
class IconPicker extends StatelessWidget {
  const IconPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoriesController>();

    // Kategori için yaygın kullanılan ikonlar
    final List<Map<String, dynamic>> icons = [
      {'code': '0xe59c', 'icon': Icons.shopping_cart}, // Alışveriş
      {'code': '0xe532', 'icon': Icons.restaurant}, // Yemek
      {'code': '0xe553', 'icon': Icons.savings}, // Tasarruf
      {'code': '0xf04dc', 'icon': Icons.currency_exchange}, // Para
      {'code': '0xe318', 'icon': Icons.home}, // Ev
      {'code': '0xe1d7', 'icon': Icons.directions_car}, // Araba
      {'code': '0xe0b2', 'icon': Icons.attach_money}, // Para
      {'code': '0xe559', 'icon': Icons.school}, // Eğitim
      {'code': '0xe3d8', 'icon': Icons.medical_services}, // Sağlık
      {'code': '0xe39b', 'icon': Icons.local_movies}, // Eğlence
      {'code': '0xe4a3', 'icon': Icons.phone_android}, // Telefon
      {'code': '0xe13e', 'icon': Icons.card_giftcard}, // Hediye
      {'code': '0xe0c4', 'icon': Icons.backpack}, // Çanta/Seyahat
      {'code': '0xe297', 'icon': Icons.flight}, // Seyahat
      {'code': '0xe257', 'icon': Icons.family_restroom}, // Aile
      {'code': '0xe4a1', 'icon': Icons.pets}, // Evcil Hayvan
      {'code': '0xe6f2', 'icon': Icons.work}, // İş
      {'code': '0xe395', 'icon': Icons.local_grocery_store}, // Market
      {'code': '0xe25b', 'icon': Icons.favorite}, // Kişisel
      {'code': '0xe28d', 'icon': Icons.fitness_center}, // Spor
      {'code': '0xe37b', 'icon': Icons.lightbulb}, // Fatura
      {'code': '0xe040', 'icon': Icons.account_balance}, // Banka
      {'code': '0xe149', 'icon': Icons.celebration}, // Kutlama
      {'code': '0xe478', 'icon': Icons.park}, // Park/Doğa
      {'code': '0xe25a', 'icon': Icons.fastfood}, // Fast Food
      {'code': '0xe50d', 'icon': Icons.receipt_long}, // Makbuz/Fatura
      {'code': '0xe041', 'icon': Icons.account_balance_wallet}, // Cüzdan
      {'code': '0xe5d8', 'icon': Icons.spa}, // Sağlık/Spa
      {'code': '0xe11a', 'icon': Icons.bus_alert}, // Ulaşım
      {'code': '0xe167', 'icon': Icons.cleaning_services}, // Temizlik
      {'code': '0xe19f', 'icon': Icons.credit_card}, // Kredi Kartı
      {'code': '0xf055d', 'icon': Icons.rocket_launch}, // İş/Kariyer
      {'code': '0xe329', 'icon': Icons.house_siding}, // Emlak
      {'code': '0xe482', 'icon': Icons.payments}, // Ödemeler
      {'code': '0xe13f', 'icon': Icons.card_membership}, // Üyelik
      {'code': '0xe4be', 'icon': Icons.piano}, // Müzik/Aktivite
      {'code': '0xf05a2', 'icon': Icons.water_drop}, // Su/Fatura
      {'code': '0xe42d', 'icon': Icons.nightlife}, // Eğlence/Gece Hayatı
      {'code': '0xe305', 'icon': Icons.health_and_safety}, // Sağlık/Güvenlik
      {'code': '0xe228', 'icon': Icons.electrical_services}, // Elektrik
      {'code': '0xe2e4', 'icon': Icons.grass}, // Bahçe/Doğa
      {'code': '0xe313', 'icon': Icons.hiking}, // Doğa Yürüyüşü
      {'code': '0xe160', 'icon': Icons.child_care}, // Çocuk Bakımı
      {'code': '0xf07a0', 'icon': Icons.energy_savings_leaf}, // Enerji Tasarrufu
      {'code': '0xf085c', 'icon': Icons.diversity_3}, // Aile/Sosyal
      {'code': '0xf085b', 'icon': Icons.diversity_2}, // Arkadaşlar
      {'code': '0xe2aa', 'icon': Icons.food_bank}, // Yiyecek Yardımı
      {'code': '0xe19b', 'icon': Icons.cottage}, // Tatil/Konaklama
      {'code': '0xf33c', 'icon': Icons.school_outlined}, // Eğitim alternatif
      {'code': '0xe59a', 'icon': Icons.shopping_bag}, // Alışveriş alternatif
      {'code': '0xe6ce', 'icon': Icons.watch}, // Saat/Aksesuar
      {'code': '0xe618', 'icon': Icons.subscriptions}, // Abonelikler
      {'code': '0xe40d', 'icon': Icons.movie}, // Film
      {'code': '0xe1c3', 'icon': Icons.desktop_windows}, // Bilgisayar/Teknoloji
      {'code': '0xe178', 'icon': Icons.coffee}, // Kahve
      {'code': '0xe22c', 'icon': Icons.emoji_events}, // Ödül/Başarı
      {'code': '0xe120', 'icon': Icons.cake}, // Doğum Günü
      {'code': '0xf04ed', 'icon': Icons.diamond}, // Değerli Eşya/Takı
      {'code': '0xe6f1', 'icon': Icons.wine_bar}, // İçki/Bar
      {'code': '0xe6e3', 'icon': Icons.whatshot}, // Sıcak Fırsat
      {'code': '0xf07a', 'icon': Icons.fitness_center_outlined}, // Spor alternatif
      {'code': '0xf085', 'icon': Icons.flight_outlined}, // Uçuş alternatif
      {'code': '0xe4f0', 'icon': Icons.public}, // Internet/Web Servisleri
      {'code': '0xe2bb', 'icon': Icons.format_paint}, // Boya/Dekorasyon
      {'code': '0xe349', 'icon': Icons.inventory}, // Stok/Envanter
      {'code': '0xe398', 'icon': Icons.local_laundry_service}, // Çamaşırhane
      {'code': '0xe4b6', 'icon': Icons.photo_camera}, // Fotoğraf
      {'code': '0xe22e', 'icon': Icons.emoji_food_beverage}, // İçecek/Kahve
      {'code': '0xe485', 'icon': Icons.pending_actions}, // Bekleyen İşlemler
      {'code': '0xe55a', 'icon': Icons.science}, // Bilim/Araştırma
      {'code': '0xe502', 'icon': Icons.radio}, // Radyo/Medya
      {'code': '0xe315', 'icon': Icons.history_edu}, // Eğitim Geçmişi
      {'code': '0xe2f2', 'icon': Icons.handyman}, // Tamir/Usta
      {'code': '0xe6fb', 'icon': Icons.yard}, // Bahçe Bakımı
      {'code': '0xe089', 'icon': Icons.apartment}, // Apartman
      {'code': '0xe3a8', 'icon': Icons.location_city}, // Şehir/Konaklama
      {'code': '0xf06c0', 'icon': Icons.roller_skating}, // Eğlence/Hobi
      {'code': '0xe2ff', 'icon': Icons.headphones}, // Müzik/Kulaklık
      {'code': '0xf050a', 'icon': Icons.forest}, // Orman/Doğa
      {'code': '0xe22b', 'icon': Icons.emoji_emotions}, // Eğlence/Duygular
      {'code': '0xf336', 'icon': Icons.savings_outlined}, // Tasarruf alternatif
      {'code': '0xe57d', 'icon': Icons.sentiment_very_satisfied}, // Memnuniyet
      {'code': '0xf33d', 'icon': Icons.science_outlined}, // Laboratuvar/Test
      {'code': '0xe377', 'icon': Icons.library_books}, // Kitaplık/Eğitim
      {'code': '0xf0548', 'icon': Icons.phishing}, // Güvenlik/Uyarı
      {'code': '0xe31c', 'icon': Icons.home_repair_service}, // Ev Tamiri
      {'code': '0xe513', 'icon': Icons.reduce_capacity}, // Kapasite/Kısıtlama
      {'code': '0xe315', 'icon': Icons.history_edu}, // Eğitim/Diploma
      // Finans ve yatırım
      {'code': '0xe67f', 'icon': Icons.trending_up}, // Yatırım/Artış
      {'code': '0xe67d', 'icon': Icons.trending_down}, // Düşüş/Kayıp
      {'code': '0xe385', 'icon': Icons.list_alt}, // Liste/Planlama
      {'code': '0xe1bf', 'icon': Icons.description}, // Belge/Rapor
      {'code': '0xe0ef', 'icon': Icons.book}, // Kitap/Öğrenme
      {'code': '0xe556', 'icon': Icons.schedule}, // Zamanlama/Planlama
      {'code': '0xe52f', 'icon': Icons.request_quote}, // Teklif/Fiyat
      {'code': '0xf0541', 'icon': Icons.newspaper}, // Gazete/Haberler
      {'code': '0xe33f', 'icon': Icons.insert_chart}, // Grafik/Analiz
      {'code': '0xf0547', 'icon': Icons.percent}, // Yüzde/İndirim
      {'code': '0xe4e8', 'icon': Icons.price_change}, // Fiyat Değişimi
      {'code': '0xe486', 'icon': Icons.people}, // İnsanlar/Topluluk
      {'code': '0xe3d7', 'icon': Icons.mediation}, // Arabuluculuk/Ortaklık
      {'code': '0xe507', 'icon': Icons.rate_review}, // Değerlendirme
      {'code': '0xe4ef', 'icon': Icons.psychology}, // Psikoloji/Danışmanlık
      {'code': '0xe596', 'icon': Icons.shield}, // Koruma/Güvenlik
      {'code': '0xe319', 'icon': Icons.home_filled}, // Ev Alternatif
      {'code': '0xe35c', 'icon': Icons.keyboard_voice}, // Ses/Sohbet
      {'code': '0xe322', 'icon': Icons.hotel}, // Otel/Konaklama
      {'code': '0xe50b', 'icon': Icons.real_estate_agent}, // Emlakçı/Gayrimenkul
      {'code': '0xe654', 'icon': Icons.theater_comedy}, // Tiyatro/Eğlence
      {'code': '0xf0575', 'icon': Icons.sunny}, // Güneş/Hava Durumu
      {'code': '0xe3d3', 'icon': Icons.masks}, // Maske/Sağlık
      {'code': '0xe6d6', 'icon': Icons.wb_incandescent}, // Ampul/Elektrik
      {'code': '0xe28e', 'icon': Icons.flag}, // Bayrak/Önemli
      {'code': '0xe50f', 'icon': Icons.recommend}, // Tavsiye/Öneri
      {'code': '0xe46b', 'icon': Icons.palette}, // Resim/Sanat
      {'code': '0xe365', 'icon': Icons.landscape}, // Manzara/Doğa
      {'code': '0xe3c1', 'icon': Icons.luggage}, // Bagaj/Seyahat
      {'code': '0xe506', 'icon': Icons.ramen_dining}, // Yemek/Noodle
      {'code': '0xe5e8', 'icon': Icons.sports_esports}, // Oyun
      {'code': '0xe250', 'icon': Icons.extension}, // Puzzle/Zeka
      {'code': '0xe514', 'icon': Icons.refresh}, // Yenile/Döngü
    ];

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6, // Bir satırda 6 ikon
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final iconData = icons[index];
          final iconCode = iconData['code'];

          return Obx(() {
            final isSelected = controller.isIconSelected(iconCode);

            return Material(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () => controller.selectIcon(iconCode),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Icon(
                    iconData['icon'],
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
