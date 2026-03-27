import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moblack/features/widgets/fav_icon.dart';

import '../../../../core/theme.dart';

class FooterSection extends StatelessWidget {
  final bool isDesktop;

  const FooterSection({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
      child: Column(
        children: [
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _buildFooterBrand()),
                    Expanded(child: _buildFooterContact()),
                    Expanded(child: _buildFooterVisit()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFooterBrand(),
                    const SizedBox(height: 48),
                    _buildFooterContact(),
                    const SizedBox(height: 48),
                    _buildFooterVisit(),
                  ],
                ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white12),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '© 2026 MOBLACK. ALL RIGHTS RESERVED.',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              if (isDesktop)
                Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(color: Colors.white30),
                      ),
                    ),
                    const SizedBox(width: 32),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Terms of Service',
                        style: TextStyle(color: Colors.white30),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (!isDesktop) const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFooterBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MOBLACK',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Premium hair care and styling for the modern individual. '
          'Experience the difference of expert hands and luxury products.',
          style: TextStyle(color: Colors.white38, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            FavIcon(icon: FontAwesomeIcons.instagram),
            const SizedBox(width: 16),
            FavIcon(icon: FontAwesomeIcons.xTwitter),
            const SizedBox(width: 16),
            FavIcon(icon: FontAwesomeIcons.tiktok),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Us',
          style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Icon(Icons.phone, color: AppTheme.primaryPink, size: 16),
            SizedBox(width: 12),
            Text(
              '(+233)55 520-7062',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Icon(Icons.mail, color: AppTheme.primaryPink, size: 16),
            SizedBox(width: 12),
            Text(
              'moblack@gmail.com',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterVisit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visit Us',
          style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 24),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: AppTheme.primaryPink, size: 16),
            SizedBox(width: 12),
            Text(
              "Lebanon Police Junction Bus Stop.\nE1282 Tetteh Anang Rd, Tema",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
