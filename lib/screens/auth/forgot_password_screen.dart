import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kayip_esya_projesi/core/constans/app_colors.dart';
import 'package:kayip_esya_projesi/core/constans/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  int step = 0; // 0: E-posta, 1: OTP Girişi, 2: Yeni Şifre
  bool _isLoading = false;
  String errorMessage = "";

  final supabase = Supabase.instance.client;

  // 1. Sıfırlama Kodunu Gönder
  Future<void> _sendOTP() async {
    if (emailController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await supabase.auth.resetPasswordForEmail(emailController.text.trim());
      setState(() {
        step = 1;
        errorMessage = "";
      });
    } catch (e) {
      setState(() => errorMessage = "Kod gönderilemedi: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. Kodu Doğrulama
  Future<void> _verifyOTP() async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.verifyOTP(
        email: emailController.text.trim(),
        token: otpController.text.trim(),
        type: OtpType.recovery,
      );
      setState(() {
        step = 2;
        errorMessage = "";
      });
    } catch (e) {
      setState(() => errorMessage = "Kod hatalı veya süresi dolmuş.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 3. Şifreyi Güncelleme
  Future<void> _updatePassword() async {
    if (newPasswordController.text.length < 6) {
      setState(() => errorMessage = "Şifre en az 6 karakter olmalı.");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPasswordController.text.trim()),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Şifreniz başarıyla güncellendi! Giriş yapabilirsiniz.",
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => errorMessage = "Hata oluştu: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMain),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              step == 0
                  ? "Şifre Sıfırlama"
                  : (step == 1 ? "Kodu Girin" : "Yeni Şifre"),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 30),

            if (step == 0) ...[
              const Text(
                "Kayıtlı e-posta adresinizi girin, size bir doğrulama kodu gönderelim.",
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "E-posta",
                controller: emailController,
                suffixIcon: Icons.email,
              ),
            ] else if (step == 1) ...[
              Text(
                "${emailController.text} adresine gelen doğrulama kodunu girin.",
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "Doğrulama Kodu",
                controller: otpController,
                suffixIcon: Icons.numbers,
              ),
            ] else ...[
              const Text("Lütfen yeni şifrenizi belirleyin."),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "Yeni Şifre",
                controller: newPasswordController,
                isPassword: true,
                suffixIcon: Icons.lock,
              ),
            ],

            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : (step == 0
                        ? _sendOTP
                        : (step == 1 ? _verifyOTP : _updatePassword)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
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
                  : Text(
                      step == 0
                          ? "Kod Gönder"
                          : (step == 1 ? "Kodu Doğrula" : "Şifreyi Güncelle"),
                      style: const TextStyle(
                        color: Colors
                            .white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
