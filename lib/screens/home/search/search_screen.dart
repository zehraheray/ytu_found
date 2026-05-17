import 'package:flutter/material.dart';
import 'package:kayip_esya_projesi/core/constans/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<String> _defaultSuggestions = ['Anahtar', 'Cüzdan', 'Kimlik', 'Telefon']; 
  
  // Veritabanından çekeceğimiz eşya isimleri ve konumların listesi
  List<String> _allSearchTerms = []; 

  @override
  void initState() {
    super.initState();
    _fetchSearchTerms(); // 2. EKRAN AÇILIRKEN VERİLERİ ÇEK
  }

  // SUPABASE'DEN ONAYLI VE GEÇERLİ İLANLARIN BAŞLIK VE KONUMLARINI ÇEKUYORUZ
  Future<void> _fetchSearchTerms() async {
    try {
      final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
      
      final response = await Supabase.instance.client
          .from('items')
          .select('title, location')
          .eq('is_approved', true)
          .eq('is_archived', false)
          .gte('created_at', ninetyDaysAgo.toIso8601String()); // Sadece son 90 gün

      final List<dynamic> data = response;
      Set<String> uniqueTerms = {}; // Aynı kelimelerin tek sefer görünmesi için Set kullanıyoruz

      for (var item in data) {
        if (item['title'] != null) uniqueTerms.add(item['title'].toString().trim());
        if (item['location'] != null) uniqueTerms.add(item['location'].toString().trim());
      }

      if (mounted) {
        setState(() {
          _allSearchTerms = uniqueTerms.toList();
        });
      }
    } catch (e) {
      debugPrint("Arama önerileri çekilemedi: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _goToSearchResults(String query) {
    if (query.trim().isEmpty) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(searchQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // KULLANICI YAZDIKÇA VERİTABANINDAN GELEN LİSTEYİ FİLTRELE
    List<String> suggestionList = [];
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      suggestionList = _allSearchTerms
          .where((term) => term.toLowerCase().contains(query))
          .toList();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.primaryDark,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: _onSearchChanged,
                      onSubmitted: _goToSearchResults,
                      decoration: InputDecoration(
                        hintText: 'Mekan veya eşya arayın...',
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged("");
                                },
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.search,
                                  color: AppColors.primaryDark,
                                ),
                                onPressed: () =>
                                    _goToSearchResults(_searchController.text),
                              ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: const BorderSide(
                            color: AppColors.primaryDark,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: const BorderSide(
                            color: AppColors.primaryDark,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildDefaultSuggestions()
                  : _buildSearchSuggestions(suggestionList),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultSuggestions() {
    if (_defaultSuggestions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Hızlı Arama',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _defaultSuggestions.map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                backgroundColor: AppColors.textFieldFill,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () => _goToSearchResults(suggestion),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions(List<String> list) {
    if (list.isEmpty) {
      return const Center(child: Text("Sonuç bulunamadı."));
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.search, color: Colors.grey), 
          title: Text(
            list[index],
            style: const TextStyle(fontSize: 16, color: AppColors.textMain),
          ),
          trailing: const Icon(Icons.north_west, size: 16, color: Colors.grey),
          onTap: () => _goToSearchResults(list[index]),
        );
      },
    );
  }
}