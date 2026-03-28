import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moblack/core/constants.dart';
import 'package:moblack/core/theme.dart';

import '../../../core/services/communication_service.dart';
import '../../../core/services/pages/services_page.dart';
import '../../widgets/fav_icon.dart';

class MobileMenu extends StatefulWidget {
  final bool isMenuOpen;
  final VoidCallback onClose;
  final Function(String)? onNavTap;

  const MobileMenu({
    super.key,
    required this.isMenuOpen,
    required this.onClose,
    this.onNavTap,
  });

  @override
  State<MobileMenu> createState() => _MobileMenuState();
}

class _MobileMenuState extends State<MobileMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void didUpdateWidget(MobileMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMenuOpen != oldWidget.isMenuOpen) {
      if (widget.isMenuOpen) {
        _controller.forward();
      } else {
        _controller.stop();
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final navLinks = AppConstants.navLinks;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.value == 0.0 && !widget.isMenuOpen) {
          return const SizedBox.shrink();
        }

        final dropTop = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: -80,
              end: screenHeight / 2 - 40,
            ).chain(CurveTween(curve: Curves.bounceOut)),
            weight: 40,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: screenHeight / 2 - 40,
              end: 0,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 30,
          ),
          TweenSequenceItem(tween: ConstantTween<double>(0), weight: 30),
        ]).evaluate(_controller);

        final dropLeft = TweenSequence<double>([
          TweenSequenceItem(
            tween: ConstantTween<double>(screenWidth / 2 - 40),
            weight: 20,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: screenWidth / 2 - 40,
              end: 0,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 10,
          ),
          TweenSequenceItem(tween: ConstantTween<double>(0), weight: 30),
        ]).evaluate(_controller);

        final sizeWidth = TweenSequence<double>([
          TweenSequenceItem(tween: ConstantTween<double>(80), weight: 40),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 80,
              end: screenWidth,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: ConstantTween<double>(screenWidth),
            weight: 30,
          ),
        ]).evaluate(_controller);

        final sizeHeight = TweenSequence<double>([
          TweenSequenceItem(tween: ConstantTween<double>(80), weight: 40),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 80,
              end: screenHeight,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: ConstantTween<double>(screenHeight),
            weight: 20,
          ),
        ]).evaluate(_controller);

        final borderRadius = TweenSequence<double>([
          TweenSequenceItem(tween: ConstantTween<double>(40), weight: 40),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 40,
              end: 0,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 30,
          ),
          TweenSequenceItem(tween: ConstantTween<double>(0), weight: 30),
        ]).evaluate(_controller);

        final contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.7, 0.8, curve: Curves.easeIn),
          ),
        );

        return Positioned(
          top: dropTop,
          left: dropLeft,
          width: sizeWidth,
          height: sizeHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              children: [
                Positioned(
                  top: 88,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.white.withAlpha(12)),
                    ),
                  ),
                ),
                if (_controller.value > 0.6)
                  Positioned.fill(
                    child: OverflowBox(
                      maxWidth: screenWidth,
                      maxHeight: screenHeight,
                      alignment: Alignment.topCenter,
                      child: Opacity(
                        opacity: contentOpacity.value,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 88),
                          child: SafeArea(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 26,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(child: _buildHeader()),
                                    const SizedBox(height: 10),

                                    ...List.generate(navLinks.length, (index) {
                                      final label = navLinks[index];
                                      return _buildStaggeredLink(
                                        label,
                                        index,
                                        navLinks.length,
                                        () {
                                          widget.onClose();
                                          if (label == 'Services') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ServicesPage(),
                                              ),
                                            );
                                          } else if (widget.onNavTap != null) {
                                            widget.onNavTap!(label);
                                          }
                                        },
                                      );
                                    }),

                                    const SizedBox(height: 40),
                                    _buildFooterButton(
                                      'book appointment',
                                      false,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildFooterButton('contact us', true),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Follow us:',
                                          style: GoogleFonts.aboreto(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        FavIcon(
                                          icon: FontAwesomeIcons.instagram,
                                          onTap: () =>
                                              CommunicationService.launchInstagram(
                                                'moblack',
                                              ),
                                        ),
                                        FavIcon(
                                          icon: FontAwesomeIcons.xTwitter,
                                          onTap: () =>
                                              CommunicationService.launchX(
                                                'moblack',
                                              ),
                                        ),
                                        FavIcon(
                                          icon: FontAwesomeIcons.tiktok,
                                          onTap: () =>
                                              CommunicationService.launchTikTok(
                                                'moblack',
                                              ),
                                        ),
                                        FavIcon(
                                          icon: FontAwesomeIcons.whatsapp,
                                          onTap: () =>
                                              CommunicationService.launchWhatsApp(
                                                phoneNumber:
                                                    AppConstants.phoneNum,
                                                message: 'Hello!',
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaggeredLink(
    String label,
    int index,
    int total,
    VoidCallback action,
  ) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double waveFactor = _controller.value;
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: GestureDetector(
                  onTap: () {
                    widget.onClose();
                    action();
                  },
                  child: Container(
                    width:
                        MediaQuery.of(context).size.width *
                        (0.4 + (waveFactor * 0.5)).clamp(0.4, 0.9),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(80),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withAlpha(20),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGold.withAlpha(30),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      label.toUpperCase(),
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Text(
      'MENU',
      style: GoogleFonts.playfairDisplay(
        color: AppTheme.backgroundBlack.withAlpha(120),
        letterSpacing: 3,
        fontSize: 18,
      ),
    );
  }

  Widget _buildFooterButton(String text, bool inverse) {
    return Center(
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.85, 1.0),
        ),
        child: SizedBox(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: inverse ? Colors.white : AppTheme.primaryGold,
              foregroundColor: inverse ? AppTheme.primaryGold : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(18),
              ), // Sharp edges for luxury look
            ),
            child: Text(
              text.toUpperCase(),
              style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
