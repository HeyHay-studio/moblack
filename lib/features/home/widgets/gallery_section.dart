import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants.dart';
import '../../../../core/theme.dart';

class GallerySection extends StatefulWidget {
  final bool isDesktop;
  final List<String> dynamicImages;

  const GallerySection({
    super.key,
    required this.isDesktop,
    required this.dynamicImages,
  });

  @override
  State<GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<GallerySection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildGalleryGrid(),
          const SizedBox(height: 48),
          _buildViewMoreBtn(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Our Gallery',
          style: GoogleFonts.playfairDisplay(
            fontSize: widget.isDesktop ? 48 : 36,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(width: 60, height: 3, color: AppTheme.primaryGold),
        const SizedBox(height: 16),
        Text(
          'A glimpse into professional luxury artistry',
          textAlign: TextAlign.center,
          style: GoogleFonts.aboreto(
            color: Colors.white70,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryGrid() {
    final assets = widget.dynamicImages.isNotEmpty
        ? widget.dynamicImages
        : AppConstants.galleryImages;

    if (assets.isEmpty) {
      return const Center(
        child: Text(
          'No images found in your gallery.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.isDesktop ? 4 : 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: assets.length > 8 ? 8 : assets.length,
      itemBuilder: (context, index) {
        return _buildGalleryItem(assets[index], index);
      },
    );
  }

  Widget _buildGalleryItem(String url, int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double delay = (index * 0.1).clamp(0, 1);
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            delay,
            (delay + 0.3).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        );

        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: _GalleryItem(url: url),
    );
  }

  Widget _buildViewMoreBtn() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryGold,
        side: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        'VIEW ALL REELS',
        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
      ),
    );
  }
}

class _GalleryItem extends StatefulWidget {
  final String url;

  const _GalleryItem({required this.url});

  @override
  State<_GalleryItem> createState() => __GalleryItemState();
}

class __GalleryItemState extends State<_GalleryItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(
          _isHovered ? 1.05 : 1.0,
          _isHovered ? 1.05 : 1.0,
          1.0,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.white10,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Gradient Overlay on hover
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isHovered ? 1.0 : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withAlpha(150), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Align(
                    alignment: AlignmentGeometry.topStart,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        "assets/images/logo_removed.png",
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
