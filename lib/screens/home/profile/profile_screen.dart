import 'package:flutter/material.dart';
import 'package:kayip_esya_projesi/core/constans/app_colors.dart';
import 'package:kayip_esya_projesi/models/lost_item.dart';
import 'package:kayip_esya_projesi/screens/auth/login_screen.dart';
import 'package:kayip_esya_projesi/screens/home/item_detail_screen.dart';
import 'package:kayip_esya_projesi/screens/home/profile/edit_profile_screen.dart';
import 'package:kayip_esya_projesi/widgets/lost_item_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'İsim Soyisim';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.userMetadata?['full_name'] ?? 'İsimsiz Öğrenci';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Çıkış Yapma Butonu
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                padding: const EdgeInsets.only(right: 16, top: 8),
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                onPressed: () async {
                  // Oturumu kapatma
                  await Supabase.instance.client.auth.signOut();

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),

            // Profil Bilgileri
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 85,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(currentName: _userName),
                        ),
                      );
                      if (result != null && result is String) {
                        setState(() => _userName = result);
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Profili yönet',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMain,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.edit, size: 16, color: AppColors.textMain),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // POSTS
            const Divider(
              thickness: 1.5,
              color: AppColors.primaryDark,
              height: 1,
            ),
            const SizedBox(height: 13),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primaryDark,
                  size: 25,
                ),
                SizedBox(width: 8),
                Text(
                  'POSTS',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            const Divider(
              thickness: 1.5,
              color: AppColors.primaryDark,
              height: 1,
            ),
            const SizedBox(height: 20),

            // İlanlar Listesi
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Supabase.instance.client
                    .from('items')
                    .stream(primaryKey: ['id'])
                    .eq('user_id', userId ?? ''),
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
                        'Henüz bir ilan paylaşmadınız.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final myItems = snapshot.data!
                      .map((item) => LostItem.fromMap(item))
                      .where((item) => !item.isArchived)
                      .toList();

                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      bottom: 100.0,
                    ),
                    itemCount: myItems.length,
                    itemBuilder: (context, index) {
                      final item = myItems[index];
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
                          child: Stack(
                            children: [
                              LostItemCard(
                                title: item.title,
                                location: item.location,
                                date:
                                    "${item.date.day}.${item.date.month}.${item.date.year}",
                                isApproved: item.isApproved,
                                imageUrl: item.imageUrls.isNotEmpty
                                    ? item.imageUrls[0]
                                    : null,
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
