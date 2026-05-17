import 'package:flutter/material.dart';
import 'package:kayip_esya_projesi/core/constans/app_colors.dart';
import 'package:kayip_esya_projesi/models/lost_item.dart';
import 'package:kayip_esya_projesi/screens/home/item_detail_screen.dart';
import 'package:kayip_esya_projesi/screens/home/search/search_screen.dart';
import 'package:kayip_esya_projesi/widgets/lost_item_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kayip_esya_projesi/widgets/category_filter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Reklam Değişkenleri
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  // Google reklam test ID`leri
  final String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  final String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  // Banner Reklam 
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd yüklenemedi: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  // Geçiş Reklamı 
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
        },
        onAdFailedToLoad: (err) {
          debugPrint('Geçiş Reklamı yüklenemedi: $err');
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  //  Geçiş Reklamı Gösterme Fonksiyonu 
  void _showInterstitialAd(VoidCallback onComplete) {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd(); // Kapatılınca yenisini yükler
          onComplete(); // Diğer sayfaya geçişi tetikler
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _loadInterstitialAd();
          onComplete(); // Hata olsa bile sayfaya geçişi engelleme
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialAdLoaded = false;
    } else {
      // Reklam hazır değilse bekletmeden sayfaya geçer
      onComplete();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  //  Filtreleme Değişkenleri 
  String _selectedCategory = 'Hepsi';
  String _selectedSort = 'En Yeni';

  //  Modal Menüler (Kategori Seçimi) 
  // Parametre olarak artık dışarıdan liste alıyor
  void _showFilterModal(List<String> dynamicCategories) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Kategori Filtresi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const Divider(),
                // filtre
                CategoryFilter(
                  categories: dynamicCategories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (String value) {
                    setState(() => _selectedCategory = value);
                    Navigator.pop(
                      context,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //  Modal Menüler (Sıralama Seçimi) 
  void _showSortModal() {
    final sortOptions = ['En Yeni', 'En Eski'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'İlanları Sırala',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const Divider(),
              ...sortOptions.map(
                (option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _selectedSort,
                  activeColor: AppColors.primaryDark,
                  onChanged: (value) {
                    setState(() => _selectedSort = value!);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(child: Image.asset('assets/logo.png', height: 145)),
            //  Arama Çubuğu 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Arama yap...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.search, color: AppColors.textMain),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            //  İLANLAR VE FİLTRELER 
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Supabase.instance.client
                    .from('items')
                    .stream(primaryKey: ['id'])
                    .eq('is_approved', true),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryDark,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'İlan bulunamadı.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final ninetyDaysAgo = DateTime.now().subtract(
                    const Duration(days: 90),
                  );

                  //90 gün öncesi ve arşivlenmemiş ilanları ayıklar
                  List<LostItem> allItems = snapshot.data!
                      .map((item) => LostItem.fromMap(item))
                      .where(
                        (item) =>
                            item.createdAt.isAfter(ninetyDaysAgo) &&
                            !item.isArchived,
                      )
                      .toList();

                  // Dinamik Kategorileri Ayıklar 
                  final uniqueCategories = allItems
                      .map((item) => item.title)
                      .toSet()
                      .toList();
                  uniqueCategories.sort();
                  final List<String> filterOptions = [
                    'Hepsi',
                    ...uniqueCategories,
                  ];

                  // Kategori Filtrelemesi Uygular
                  List<LostItem> displayedItems = List.from(allItems);
                  if (_selectedCategory != 'Hepsi') {
                    displayedItems = displayedItems
                        .where((item) => item.title == _selectedCategory)
                        .toList();
                  }

                  // Sıralama Uygular
                  displayedItems.sort((a, b) {
                    return _selectedSort == 'En Yeni'
                        ? b.date.compareTo(a.date)
                        : a.date.compareTo(b.date);
                  });

                  return Column(
                    children: [
                      // Filtrele ve Sırala Butonları
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showFilterModal(
                                filterOptions,
                              ),
                              icon: const Icon(
                                Icons.filter_alt_outlined,
                                color: AppColors.textMain,
                              ),
                              label: Text(
                                _selectedCategory == 'Hepsi'
                                    ? 'Filtrele'
                                    : _selectedCategory,
                                style: const TextStyle(
                                  color: AppColors.textMain,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                side: BorderSide(
                                  color: _selectedCategory == 'Hepsi'
                                      ? Colors.grey.shade400
                                      : AppColors.primaryDark,
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _showSortModal,
                              icon: const Icon(
                                Icons.swap_vert,
                                color: AppColors.textMain,
                              ),
                              label: Text(
                                _selectedSort,
                                style: const TextStyle(
                                  color: AppColors.textMain,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_isBannerAdLoaded && _bannerAd != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          color: Colors.white,
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),

                      // İlan Listesi
                      Expanded(
                        child: displayedItems.isEmpty
                            ? const Center(
                                child: Text('Bu kategoride ilan bulunamadı.'),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(
                                  left: 24.0,
                                  right: 24.0,
                                  bottom: 100.0,
                                ),
                                itemCount: displayedItems.length,
                                itemBuilder: (context, index) {
                                  final item = displayedItems[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        _showInterstitialAd(() {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ItemDetailScreen(item: item),
                                            ),
                                          );
                                        });
                                      },
                                      child: LostItemCard(
                                        title: item.title,
                                        location: item.location,
                                        date:
                                            "${item.date.day}.${item.date.month}.${item.date.year}",
                                        isApproved: item.isApproved,
                                        imageUrl: item.imageUrls.isNotEmpty
                                            ? item.imageUrls[0]
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
