import 'package:flutter/material.dart';
import 'package:kayip_esya_projesi/core/constans/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;

  const EditProfileScreen({super.key, required this.currentName});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  // Şifreler için controller'lar
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);

    final user = Supabase.instance.client.auth.currentUser;
    _emailController = TextEditingController(
      text: user?.email ?? "Mail bulunamadı",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Şifre Değiştirme
  void _showPasswordChangeModal() {
    // eski yazılanları temizler
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    // Hata mesajını tutacağımız değişken
    String errorMessage = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Şifre Değiştir',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildPasswordField('Mevcut Şifre', _oldPasswordController),
                  const SizedBox(height: 16),
                  _buildPasswordField('Yeni Şifre', _newPasswordController),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    'Yeni Şifre (Tekrar)',
                    _confirmPasswordController,
                  ),

                  if (errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      if (_newPasswordController.text !=
                          _confirmPasswordController.text) {
                        setModalState(() {
                          errorMessage = 'Yeni şifreler uyuşmuyor!';
                        });
                        return;
                      }

                      try {
                        await Supabase.instance.client.auth.updateUser(
                          UserAttributes(
                            password: _newPasswordController.text.trim(),
                          ),
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Şifreniz güncellendi!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        setModalState(() {
                          errorMessage =
                              'Hata: Şifre en az 6 karakter olmalı veya oturum süresi dolmuş.';
                        });
                      }

                      final messenger = ScaffoldMessenger.of(context);

                      Navigator.pop(context);

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Şifreniz başarıyla güncellendi!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                    child: const Text(
                      'Şifreyi Güncelle',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPasswordField(
    String hintText,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hintText,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.primaryDark,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'Profili Düzenle',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 30),

              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 60, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 40),

              const Text(
                'İsim Soyisim',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(
                      color: AppColors.primaryDark,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // MAİL ADRESİ (readOnly)
              const Text(
                'Öğrenci Mail Adresi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors
                      .grey
                      .shade200,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 20.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // ŞİFRE DEĞİŞTİR BUTONU
              OutlinedButton.icon(
                onPressed: _showPasswordChangeModal,
                icon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.primaryDark,
                ),
                label: const Text(
                  'Şifre Değiştir',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(
                    color: AppColors.primaryDark,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // KAYDET BUTONU
              ElevatedButton(
                onPressed: () async {
                  try {
                    await Supabase.instance.client.auth.updateUser(
                      UserAttributes(
                        data: {'full_name': _nameController.text.trim()},
                      ),
                    );
                    if (context.mounted) {
                      Navigator.pop(context, _nameController.text);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Profil güncellenemedi: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
                child: const Text(
                  'Değişiklikleri Kaydet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
