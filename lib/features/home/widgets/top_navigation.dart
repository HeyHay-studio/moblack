import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';

class TopNavigation extends StatelessWidget {
  final bool isDesktop;
  final bool isMenuOpen;
  final VoidCallback onMenuToggle;

  const TopNavigation({
    super.key,
    required this.isDesktop,
    required this.isMenuOpen,
    required this.onMenuToggle,
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
              horizontal: isDesktop ? 48 : 24,
              vertical: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // LOGO
                Text(
                  'MOBLACK',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                // DESKTOP NAV LINKS
                if (isDesktop) _buildDesktopNav(),

                // ACTIONS (Button or Mobile Menu)
                _buildActionArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopNav() {
    return Row(
      children: AppConstants.navLinks
          .map(
            (link) => Padding(
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
          )
          .toList(),
    );
  }

  Widget _buildActionArea() {
    if (isDesktop) {
      return ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryPink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'CONTACT US',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      );
    }

    // MOBILE MENU ICON
    return IconButton(
      onPressed: onMenuToggle,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
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
