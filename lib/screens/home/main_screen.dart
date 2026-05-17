import 'package:flutter/material.dart';
import 'package:kayip_esya_projesi/core/constans/app_colors.dart';
import 'package:kayip_esya_projesi/screens/home/home_screen.dart';
import 'package:kayip_esya_projesi/screens/home/add_item_screen.dart';
import 'package:kayip_esya_projesi/screens/home/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Varsayılan olarak Home (0. indeks) olacak
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Sayfaların durumunu koruyan widget
          IndexedStack(
            index: _currentIndex,
            children: [
              const HomeScreen(), // 0. İndeks
              // 1. İndeks: İlan eklendiğinde ana sayfaya dönmesini sağlar
              AddItemScreen(
                onNavigateToHome: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
              ),

              const ProfileScreen(),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. ANA SAYFA İKONU (Index 0)
                  IconButton(
                    icon: Icon(
                      // Aktifse içi dolu (home), değilse çizgili (home_outlined) ikon
                      _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                      size: 32,
                      // Aktifse koyu ana renk, değilse standart pasif metin rengi
                      color: _currentIndex == 0
                          ? AppColors.primaryDark
                          : AppColors.textMain,
                    ),
                    onPressed: () {
                      setState(() => _currentIndex = 0);
                    },
                  ),

                  // 2. EKLEME İKONU (Index 1)
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        // Aktifse içi dolu, değilse çizgili ikon
                        _currentIndex == 1
                            ? Icons.add_circle
                            : Icons.add_circle_outline_rounded,
                        size: 36,
                        // Aktifse koyu renk, değilse pasif renk
                        color: _currentIndex == 1
                            ? AppColors.primaryDark
                            : AppColors.textMain,
                      ),
                      onPressed: () {
                        setState(() => _currentIndex = 1);
                      },
                    ),
                  ),

                  // 3. PROFİL İKONU (Index 2)
                  IconButton(
                    icon: Icon(
                      // Aktifse içi dolu profil, değilse çizgili profil ikonu
                      _currentIndex == 2 ? Icons.person : Icons.person_outline,
                      size: 32,
                      // Aktifse koyu renk, değilse pasif renk
                      color: _currentIndex == 2
                          ? AppColors.primaryDark
                          : AppColors.textMain,
                    ),
                    onPressed: () {
                      setState(() => _currentIndex = 2);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
