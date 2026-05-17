import 'package:flutter/material.dart';
import 'package:kayip_esya_projesi/core/constans/app_colors.dart';
import 'package:kayip_esya_projesi/models/lost_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemDetailScreen extends StatefulWidget {
  final LostItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Future<void> _sendEmail() async {
    final String email = widget.item.ownerEmail.trim();

    if (email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hata: İlan sahibinin e-posta adresi bulunamadı!"),
          ),
        );
      }
      return;
    }

    final String subject = "Kayıp Eşya Hakkında: ${widget.item.title}";
    final String body =
        "Merhaba,\n\n'${widget.item.title}' başlıklı ilanınızla ilgili iletişime geçmek istiyorum.";

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': body,
      }),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'Mail başlatılamadı';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mail uygulaması açılamadı!")),
        );
      }
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Kaydırılabilir Fotoğraflar
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: item.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(item.imageUrls[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),

                // İleri/Geri Okları
                if (item.imageUrls.length > 1) ...[
                  Positioned(
                    left: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white70,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.primaryDark,
                            size: 24,
                          ),
                          onPressed: () {
                            if (_currentPage > 0) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white70,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.primaryDark,
                            size: 24,
                          ),
                          onPressed: () {
                            if (_currentPage < item.imageUrls.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],

                // Indicators
                Positioned(
                  bottom: 15,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      item.imageUrls.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.primaryDark
                              : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. İlan Bilgileri
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    Icons.text_fields_outlined,
                    "Eşya Adı",
                    item.title,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    "Konum",
                    item.location,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    "Tarih",
                    "${item.date.day}.${item.date.month}.${item.date.year}",
                  ),

                  const SizedBox(height: 24),
                  const Divider(thickness: 1, color: Colors.grey),
                  const SizedBox(height: 24),

                  const Text(
                    "Açıklama",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textMain,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. Sabit Buton Alanı
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 16.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: _buildBottomButton(context, item),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryDark, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // SİL veya MESAJ AT butonu kontrolü
  Widget _buildBottomButton(BuildContext context, LostItem item) {
    // Mevcut oturum açmış kullanıcının ID'sini alır
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    // Eğer ilanı açan kişi ilanın sahibiyse sil butonunu gösterir
    if (currentUserId != null && currentUserId == item.userId) {
      return ElevatedButton.icon(
        onPressed: () => _showDeleteConfirmDialog(context, item.id),
        icon: const Icon(Icons.delete_outline, color: Colors.white),
        label: const Text(
          "İlanı Sil",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
        ),
      );
    }

    // Eğer ilanı açan kişi başkasıysa mesaj at butonu gösterir
    return ElevatedButton.icon(
      onPressed: _sendEmail,
      icon: const Icon(Icons.message_outlined, color: Colors.white),
      label: const Text(
        "Mesaj At",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
    );
  }

  // SİLME/ARŞİVLEME ONAY KUTUSU
  Future<void> _showDeleteConfirmDialog(BuildContext context, String itemId) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'İlanı Kaldır',
            style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Bu ilanı sistemden kaldırmak üzeresiniz. İstatistiksel verilerimiz için soruyoruz:\n\nKayıp eşya bulundu mu?',
            style: TextStyle(fontSize: 15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await _archiveItem(context, itemId, isFound: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Evet, Bulundu!', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await _archiveItem(context, itemId, isFound: false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Hayır, Bulunmadı', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext), 
                  child: const Text('İptal', style: TextStyle(color: Colors.grey)),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  // SUPABASE GÜNCELLEME İŞLEMİ
  Future<void> _archiveItem(BuildContext context, String itemId, {required bool isFound}) async {
    try {
      await Supabase.instance.client
          .from('items')
          .update({
            'is_archived': true,
            'is_found': isFound,
          })
          .eq('id', itemId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFound ? 'Harika! İlan kaldırıldı.' : 'İlan sistemden kaldırıldı.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İşlem başarısız: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

} 