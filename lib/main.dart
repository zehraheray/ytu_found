import 'package:flutter/material.dart';
import 'package:kayip_esya_projesi/core/constans/app_colors.dart';
import 'package:kayip_esya_projesi/screens/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_URL',
    anonKey:
        'YOUR_KEY',
  );
  MobileAds.instance.initialize();
  runApp(const LostAndFoundApp());
}

class LostAndFoundApp extends StatelessWidget {
  const LostAndFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YTU Found',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryDark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primaryDark,
          secondary: AppColors.primaryDark,
        ),
      ),
      home: LoginScreen(),
    );
  }
}
