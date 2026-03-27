import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moblack/core/constants.dart';

import '../../widgets/fav_icon.dart';

class MobileMenu extends StatefulWidget {
  final bool isMenuOpen;
  final VoidCallback onClose;

  const MobileMenu({
    super.key,
    required this.isMenuOpen,
    required this.onClose,
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
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didUpdateWidget(MobileMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMenuOpen != oldWidget.isMenuOpen) {
      if (widget.isMenuOpen) {
        _controller.forward();
      } else {
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
    final navLinks = AppConstants.navLinks;

    return AnimatedPositioned(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOutExpo,
      top: 0,
      bottom: 0,
      left: widget.isMenuOpen ? 0 : screenWidth,
      width: screenWidth,
      child: Padding(
        padding: const EdgeInsets.only(top: 88),
        child: Stack(
          children: [
            // 1. Background Blur
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),

            // 2. Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const Spacer(flex: 1),

                    // Staggered Links
                    ...List.generate(navLinks.length, (index) {
                      return _buildStaggeredLink(
                        navLinks[index],
                        index,
                        navLinks.length,
                        () {},
                      );
                    }),

                    const Spacer(flex: 4),
                    _buildFooterButton('book appointment', false),
                    SizedBox(height: 20),
                    _buildFooterButton('contact us', true),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        FavIcon(icon: FontAwesomeIcons.instagram),
                        FavIcon(icon: FontAwesomeIcons.xTwitter),
                        FavIcon(icon: FontAwesomeIcons.tiktok),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredLink(
    String label,
    int index,
    int total,
    VoidCallback action,
  ) {
    final double start = (0.2 + (index * 0.1)).clamp(0.0, 1.0);
    final double end = (start + 0.4).clamp(0.0, 1.0);

    final Animation<double> fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    final Animation<Offset> slideAnimation =
        Tween<Offset>(begin: const Offset(0.6, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeInOutBack),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: GestureDetector(
            onTap: () {
              widget.onClose;
              action;
            },
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'MENU',
      style: GoogleFonts.playfairDisplay(
        color: Colors.white60,
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
          curve: const Interval(0, 0.3),
        ),
        child: SizedBox(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: inverse ? Colors.white : Color(0xFFFF1493),
              foregroundColor: inverse ? Color(0xFFFF1493) : Colors.white,
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
