import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kayip_esya_projesi/core/constans/app_colors.dart';
import 'package:kayip_esya_projesi/core/constans/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();

  String errorMessage = "";
  bool _isLoading = false;

  bool _isConsentAccepted = false;

  Future<void> _registerFunc() async {
    // 1. AÇIK RIZA KONTROLÜ
    if (!_isConsentAccepted) {
      setState(() {
        errorMessage = 'Kayıt olmak için Aydınlatma Metni\'ni onaylamalısınız!';
      });
      return;
    }
    // 2. BOŞ ALAN KONTROLÜ
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordConfirmController.text.isEmpty) {
      setState(() {
        errorMessage = 'Lütfen tüm alanları doldurun!';
      });
      return;
    }

    // 3. ŞİFRE EŞLEŞME KONTROLÜ
    if (passwordController.text != passwordConfirmController.text) {
      setState(() {
        errorMessage = 'Şifreler birbiriyle uyuşmuyor!';
      });
      return;
    }

    if (!emailController.text.trim().endsWith('yildiz.edu.tr')) {
      setState(() {
        errorMessage = 'Lütfen sadece yildiz.edu.tr uzantılı mail kullanın!';
      });
      return;
    }

    setState(() {
      errorMessage = "";
      _isLoading = true;
    });

    FocusScope.of(context).unfocus();

    try {
      // 1. signUp işlemini bir değişkene atıyoruz
      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {'full_name': nameController.text.trim()},
      );

      // 2. Eğer identities boşsa bu mail zaten kayıtlıdır!
      if (response.user != null &&
          response.user!.identities != null &&
          response.user!.identities!.isEmpty) {
        if (mounted) {
          setState(() {
            errorMessage = 'Bu e-posta adresi ile zaten bir hesap bulunuyor!';
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Hesabınız başarıyla oluşturuldu! Giriş yapabilirsiniz.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Kayıt yapılamadı. Beklenmeyen bir hata oluştu.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showConsentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Aydınlatma ve Açık Rıza Metni',
            style: TextStyle(color: AppColors.primaryDark),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'YTU Found uygulamasına hoş geldiniz. 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) kapsamında kişisel verilerinizin işlenmesine ilişkin sizi bilgilendirmek isteriz.\n\n'
              '1. İşlenen Kişisel Verileriniz\n'
              'Uygulamaya kayıt olurken ve ilan verirken paylaştığınız adınız, soyadınız, "yildiz.edu.tr" uzantılı e-posta adresiniz ile platforma yüklediğiniz kayıp eşya görselleri ve konum bilgileri işlenmektedir.\n\n'
              '2. İşlenme Amaçları\n'
              'Kişisel verileriniz; yalnızca kampüs içindeki kayıp eşyaların sahiplerine ulaştırılmasını sağlamak, sahte hesapları engellemek (sadece üniversite öğrencilerine hizmet verebilmek) ve ilan sahibi ile eşyayı bulan kişi arasındaki e-posta iletişimini kurmak amacıyla işlenmektedir.\n\n'
              '3. Verilerin Aktarımı\n'
              'İlan verdiğinizde, eşyanızla ilgili sizinle iletişime geçilebilmesi için "yildiz.edu.tr" uzantılı e-posta adresiniz uygulamanın diğer kullanıcıları tarafından görülebilecektir. Ayrıca verileriniz, uygulamanın altyapısını sağlayan bulut sunucu (Supabase) hizmetleri üzerinde güvenle saklanmaktadır.\n\n'
              '4. Açık Rıza Beyanı\n'
              'Bu kutucuğu işaretleyerek; kişisel verilerimin YTU Found uygulaması tarafından yukarıda belirtilen şartlar, amaçlar ve kapsam dahilinde işlenmesini, saklanmasını ve uygulamanın işleyişi gereği diğer kullanıcılarla/sunucu hizmet sağlayıcılarıyla paylaşılmasını özgür irademle kabul ediyorum.',
              style: TextStyle(height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Kapat',
                style: TextStyle(color: AppColors.primaryDark),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Yeni Öğrenci Kaydı\nHesap Aç',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 40),

              CustomTextField(
                hintText: 'İsim Soyisim',
                controller: nameController,
              ),
              CustomTextField(
                hintText: 'Öğrenci Mail Adresi\n(ör. ogrenci@uni.edu.tr)',
                controller: emailController,
              ),
              CustomTextField(
                hintText: 'Şifre',
                isPassword: true,
                controller: passwordController,
              ),
              CustomTextField(
                hintText: 'Şifre Tekrar',
                isPassword: true,
                controller: passwordConfirmController,
              ),

              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isConsentAccepted,
                    activeColor: AppColors.primaryDark,
                    onChanged: (value) {
                      setState(() {
                        _isConsentAccepted = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showConsentDialog,
                      child: RichText(
                        text: const TextSpan(
                          text: 'KVKK kapsamında ',
                          style: TextStyle(
                            color: AppColors.textMain,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: 'Aydınlatma ve Açık Rıza Metni',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: "'ni okudum ve kabul ediyorum."),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (errorMessage.isNotEmpty) ...[
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              ElevatedButton(
                onPressed: _isLoading ? null : _registerFunc,
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
                        'Hesap Aç',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Zaten hesabınız var mı?',
                    style: TextStyle(color: AppColors.textMain),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Giriş Yap',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
