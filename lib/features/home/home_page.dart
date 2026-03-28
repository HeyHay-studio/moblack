import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'widgets/booking_section.dart';
import 'widgets/footer_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/mobile_menu.dart';
import 'widgets/services_section.dart';
import 'widgets/top_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isMenuOpen = false;
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                HeroSection(isDesktop: isDesktop),
                ServicesSection(isDesktop: isDesktop),
                BookingSection(isDesktop: isDesktop),
                FooterSection(isDesktop: isDesktop),
              ],
            ),
          ),
          TopNavigation(
            isDesktop: isDesktop,
            isMenuOpen: isMenuOpen,
            onMenuToggle: toggleMenu,
          ),
          if (!isDesktop)
            MobileMenu(isMenuOpen: isMenuOpen, onClose: toggleMenu),
        ],
      ),
    );
  }
}
