import 'package:flutter/material.dart';
import 'package:kayip_esya_projesi/core/constans/app_colors.dart';
import 'package:kayip_esya_projesi/models/lost_item.dart';
import 'package:kayip_esya_projesi/screens/home/item_detail_screen.dart';
import 'package:kayip_esya_projesi/screens/home/search/search_screen.dart';
import 'package:kayip_esya_projesi/widgets/category_filter.dart';
import 'package:kayip_esya_projesi/widgets/lost_item_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;

  const SearchResultsScreen({super.key, required this.searchQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  List<LostItem> _allItems = [];
  List<LostItem> _displayedItems = [];
  bool _isLoading = true;

  String _selectedCategory = 'Hepsi';
  String _selectedSort = 'En Yeni';

  @override
  void initState() {
    super.initState();
    _fetchSearchResults();
  }

  Future<void> _fetchSearchResults() async {
    try {
      final response = await Supabase.instance.client
          .from('items')
          .select()
          .eq('is_approved', true)
          .or(
            'title.ilike.%${widget.searchQuery}%,location.ilike.%${widget.searchQuery}%',
          )
          .order('created_at', ascending: false);

      final List<dynamic> data = response;

      if (mounted) {
        setState(() {
          final ninetyDaysAgo = DateTime.now().subtract(
            const Duration(days: 90),
          );

          _allItems = data
              .map((item) => LostItem.fromMap(item))
              .where(
                (item) => item.createdAt.isAfter(ninetyDaysAgo) && !item.isArchived,
              )
              .toList();

          _processItems();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Hata: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _processItems() {
    setState(() {
      var tempItems = _allItems;

      if (_selectedCategory != 'Hepsi') {
        tempItems = tempItems
            .where((item) => item.title == _selectedCategory)
            .toList();
      }

      tempItems.sort((a, b) {
        return _selectedSort == 'En Yeni'
            ? b.date.compareTo(a.date)
            : a.date.compareTo(b.date);
      });

      _displayedItems = tempItems;
    });
  }

  void _showFilterModal() {
    // Dinamik Kategorileri Ayıklama
    final uniqueCategories = _allItems
        .map((item) => item.title)
        .toSet()
        .toList();
    uniqueCategories.sort();
    final List<String> dynamicCategories = ['Hepsi', ...uniqueCategories];

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
                  categories:
                      dynamicCategories, // dinamik liste gönderiliyor
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (String value) {
                    setState(() {
                      _selectedCategory = value;
                      _processItems();
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
              ...sortOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _selectedSort,
                  activeColor: AppColors.primaryDark,
                  onChanged: (value) {
                    setState(() {
                      _selectedSort = value!;
                      _processItems();
                    });
                    Navigator.pop(context);
                  },
                );
              }),
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
            const SizedBox(height: 20),
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 40,
                    color: AppColors.textMain,
                  ),
                  Text(
                    'LOST N FOUND',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.primaryDark,
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textFieldFill,
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(
                            color: AppColors.primaryDark,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${widget.searchQuery} (${_displayedItems.length} ilan)',
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.search,
                              color: AppColors.primaryDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: _showFilterModal,
                    icon: const Icon(
                      Icons.filter_alt_outlined,
                      color: AppColors.textMain,
                    ),
                    label: Text(
                      _selectedCategory == 'Hepsi'
                          ? 'Filtrele'
                          : _selectedCategory,
                      style: const TextStyle(color: AppColors.textMain),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                        color: _selectedCategory == 'Hepsi'
                            ? Colors.grey.shade400
                            : AppColors.primaryDark,
                        width: _selectedCategory == 'Hepsi' ? 1 : 2,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _showSortModal,
                    label: Text(
                      _selectedSort,
                      style: const TextStyle(color: AppColors.textMain),
                    ),
                    icon: const Icon(
                      Icons.swap_vert,
                      color: AppColors.textMain,
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

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryDark,
                      ),
                    )
                  : _displayedItems.isEmpty
                  ? const Center(
                      child: Text(
                        'Bu kriterlere uygun ilan bulunamadı.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        bottom: 20.0,
                      ),
                      itemCount: _displayedItems.length,
                      itemBuilder: (context, index) {
                        final item = _displayedItems[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ItemDetailScreen(item: item),
                                ),
                              );
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
        ),
      ),
    );
  }
}
