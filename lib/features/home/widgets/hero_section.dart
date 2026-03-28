import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants.dart';
import '../../../../core/theme.dart';

class HeroSection extends StatefulWidget {
  final bool isDesktop;

  const HeroSection({super.key, required this.isDesktop});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer time) {
      if (_pageController.hasClients) {
        if (_currentPage < AppConstants.heroImages.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCirc,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.heightOf(context);
    final width = MediaQuery.widthOf(context);
    return SizedBox(
      height: widget.isDesktop ? height : (height <= width ? width : height),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: AppConstants.heroImages.length,
            onPageChanged: (idx) {
              _currentPage = idx;
            },
            itemBuilder: (context, index) {
              return Image.network(
                AppConstants.heroImages[index],
                fit: BoxFit.cover,
              );
            },
          ),

          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withAlpha(50),
                      Colors.black.withAlpha(50),
                      AppTheme.primaryPink.withAlpha(40),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),
            ),
          ),

          // Dark/Pink Gradient Overlay for legibility and branding
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  AppTheme.primaryPink.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Align(
              alignment: widget.isDesktop
                  ? Alignment.centerLeft
                  : Alignment.center,
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 1200),
                tween: Tween<double>(begin: 0, end: 1),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: FractionallySizedBox(
                  widthFactor: widget.isDesktop ? 0.6 : 1.0,
                  child: _buildHeroContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroContent() {
    return Column(
      crossAxisAlignment: widget.isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: widget.isDesktop ? 0 : 50),
        Text(
          'Everything Beauty...',
          textAlign: widget.isDesktop ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: widget.isDesktop ? 64 : 48,
            fontWeight: FontWeight.normal,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          "Step into a world of refined elegance and bespoke artistry at Beauty By Moblack."
          "\nWe don’t just style hair; we curate your signature look.",
          textAlign: widget.isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 18,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 10,
          ),
          child: const Text(
            'Book appointment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 48),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: widget.isDesktop
              ? WrapAlignment.start
              : WrapAlignment.center,
          children: [
            _buildStatCard('New Arrivals', 'Products'),
            _buildStatCard('Only Today', '50% OFF'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String subtitle, String title) {
    return ClipRRect(
      child: BackdropFilter.grouped(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                subtitle.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: .min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_right_alt,
                      color: Colors.white,
                      size: 16,
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
