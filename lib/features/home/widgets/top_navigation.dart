import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants.dart';
import '../../../core/services/pages/services_page.dart';
import '../../products/products_page.dart';

class TopNavigation extends StatelessWidget {
  final bool isDesktop;
  final bool isMenuOpen;
  final VoidCallback onMenuToggle;
  final Function(String)? onNavTap;

  const TopNavigation({
    super.key,
    required this.isDesktop,
    required this.isMenuOpen,
    required this.onMenuToggle,
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    // Note: Ensure this is used inside a Stack
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 30 : 16,
              vertical: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: isDesktop ? 40 : 30,
                      width: isDesktop ? 40 : 30,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          // contain is better for logos so they don't get cropped
                          image: AssetImage("assets/images/logo_removed.png"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Add visual space between the logo and text
                    Text(
                      'Beauty By Moblack',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: isDesktop ? 24 : 18,
                        // scaled down slightly for mobile to prevent overflow
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),

                if (isDesktop) _buildDesktopNav(context),
                if (!isDesktop) _buildActionArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopNav(BuildContext context) {
    return Row(
      children:
          AppConstants.navLinks
              .map(
                (link) => GestureDetector(
                  onTap: () {
                    if (link == 'Services') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ServicesPage(),
                        ),
                      );
                    } else if (link == 'Products') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductsPage(),
                        ),
                      );
                    } else if (onNavTap != null) {
                      onNavTap!(link);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        link.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildActionArea() {
    return IconButton(
      onPressed: onMenuToggle,
      hoverColor: Colors.white10,
      splashRadius: 28,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInBack,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return RotationTransition(
            turns: Tween<double>(begin: 0.1, end: 1.0).animate(animation),
            child: ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
          );
        },
        child: Icon(
          isMenuOpen ? Icons.close : Icons.menu,
          key: ValueKey<bool>(isMenuOpen),
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
