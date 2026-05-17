import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kayip_esya_projesi/core/constans/app_colors.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

class AddItemScreen extends StatefulWidget {
  final VoidCallback? onNavigateToHome;

  const AddItemScreen({super.key, this.onNavigateToHome});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDateObject;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  // Test Ödüllü Reklam ID'si
  final String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  // Ödüllü Reklam
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
        },
        onAdFailedToLoad: (err) {
          debugPrint('Ödüllü reklam yüklenemedi: $err');
          _isRewardedAdLoaded = false;
        },
      ),
    );
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // Seçilen fotoğrafı tutacağımız değişken
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Fotoğraf çekme veya seçme fonksiyonu
  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      // Kamerayı veya Galeriyi aç
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality:
            70, // Yüksek boyutlu fotoğrafları sıkıştırarak performansı artırmak için
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(
            pickedFile.path,
          ); // Seçilen resmi UI'a yansıtmak için state'e atıyoruz
        });
      }
    } catch (e) {
      print("Fotoğraf seçilirken hata oluştu veya izin verilmedi: $e");
    }
  }

  // Fotoğraf kutusuna tıklanınca alttan açılan seçim menüsü
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Fotoğraf Ekle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.textMain,
                    size: 28,
                  ),
                  title: const Text(
                    'Kameradan Çek',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.textMain,
                    size: 28,
                  ),
                  title: const Text(
                    'Galeriden Seç',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark,
              onPrimary: Colors.white,
              onSurface: AppColors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateObject = picked;

        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      });
    }
  }

  Future<void> _submitItem() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen başlık ve konum alanlarını doldurun!')),
      );
      return;
    }

    // Eğer reklam yüklendiyse gösterir, yüklenmediyse direkt ilanı yükler
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _loadRewardedAd();
          _uploadToSupabase(); // Hata olsa bile ilanı eklesin
        },
      );

      // Ödül kazanıldığında çalışacak kod
      _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        _uploadToSupabase(); 
      });
      
      _rewardedAd = null;
      _isRewardedAdLoaded = false;
    } else {
      _uploadToSupabase(); // Reklam hazır değilse bekletmez, direkt kaydeder
    }
  }

  Future<void> _uploadToSupabase() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Giriş yapmış kullanıcının ID'sini alıyoruz
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Kullanıcı girişi bulunamadı.');
      }

      List<String> imageUrls = [];

      // 3. Eğer fotoğraf seçildiyse, Supabase Storage'a yüklenir
      if (_selectedImage != null) {
        // Dosya uzantısını alıyoruz.
        final fileExt = _selectedImage!.path.split('.').last;
        // Dosyaya benzersiz bir isim veriyoruz.
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        // Kullanıcının ID'sine göre klasörlüyoruz.
        final filePath = '$userId/$fileName';

        // Fotoğrafı 'item_images' bucket'ına yüklüyoruz.
        await Supabase.instance.client.storage
            .from('item_images')
            .upload(filePath, _selectedImage!);

        // Yüklenen fotoğrafın herkese açık linkini alıyoruz.
        final publicUrl = Supabase.instance.client.storage
            .from('item_images')
            .getPublicUrl(filePath);

        imageUrls.add(publicUrl); // Linki listeye ekliyoruz.
      }

      // 4. Verileri Supabase 'items' tablosuna kaydediyoruz.
      await Supabase.instance.client.from('items').insert({
        'title': title,
        'location': location,
        'description': description,
        'image_urls': imageUrls,
        'is_approved': false,
        'user_id': userId,
        'date': _selectedDateObject?.toIso8601String(),
        'owner_email': Supabase.instance.client.auth.currentUser?.email,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İlan başarıyla eklendi!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _titleController.clear();
          _locationController.clear();
          _descriptionController.clear();
          _dateController.clear();
          _selectedImage = null;
          _selectedDateObject = null;
        });
        if (widget.onNavigateToHome != null) {
          widget.onNavigateToHome!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bir hata oluştu: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // DİNAMİK FOTOĞRAF KUTUSU
                  Center(
                    child: GestureDetector(
                      onTap:
                          _showImageSourceActionSheet,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.textFieldFill,
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(color: Colors.grey.shade300),
                          // Eğer fotoğraf seçilmişse arka plan resmi olarak ayarla
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit
                                      .cover, // Kutunun içine taşırmadan doldurur
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        // Eğer fotoğraf henüz yüklendmediyse ortadaki "+" ikonunu ve yazıyı göster
                        child: _selectedImage == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 40,
                                    color: AppColors.textMain,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Fotoğraf ekle',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                ],
                              )
                            : null, // Fotoğraf varsa içini boş bırakıyoruz ki resim görünsün
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildInputField(
                    hintText: 'Başlık: Örn. Anahtar',
                    controller: _titleController,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    hintText: 'Konum',
                    controller: _locationController,
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    hintText: 'Tarih',
                    controller: _dateController,
                    prefixIcon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    hintText: 'Açıklama',
                    controller: _descriptionController,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'İlanı Paylaş',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
    IconData? prefixIcon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textMain, fontSize: 16),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textMain)
            : null,
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 20.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(
            color: AppColors.primaryDark,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
