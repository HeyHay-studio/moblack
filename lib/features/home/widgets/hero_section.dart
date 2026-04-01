import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants.dart';
import '../../../../core/theme.dart';
import '../../../core/services/cloudinary_service.dart';
import 'hero_video_background.dart';

class HeroSection extends StatefulWidget {
  final bool isDesktop;
  final List<CloudinaryResource>? allResources;
  final Function(String)? onNavTap;

  const HeroSection({
    super.key,
    required this.isDesktop,
    this.allResources,
    this.onNavTap,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  List<CloudinaryResource> _heroResources = [];

  @override
  void initState() {
    super.initState();
    if (widget.allResources != null && widget.allResources!.isNotEmpty) {
      _processResources(widget.allResources!);
    } else {
      _heroResources = _getFallbackResources();
      _fetchAssets();
    }
  }

  @override
  void didUpdateWidget(HeroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allResources != oldWidget.allResources &&
        widget.allResources != null) {
      _processResources(widget.allResources!);
    }
  }

  void _processResources(List<CloudinaryResource> assets) {
    final videos =
        assets.where((r) => r.type == CloudinaryResourceType.video).toList()
          ..shuffle();
    final selectedVideos = videos.take(6).toList();

    final images =
        assets.where((r) => r.type == CloudinaryResourceType.image).toList()
          ..shuffle();
    final selectedImages = images.take(6).toList();

    // Priority: Videos first, then random images
    final combined = [...selectedVideos, ...selectedImages]..shuffle();

    if (mounted) {
      setState(() {
        _heroResources = combined.isNotEmpty
            ? combined
            : _getFallbackResources();
      });
      _startTimer();
    }
  }

  Future<void> _fetchAssets() async {
    final assets = await CloudinaryService.fetchMixedAssetsByTag(
      AppConstants.mainTag,
    );
    _processResources(assets);
    log('Hero assets fetched manually: ${assets.isNotEmpty}');
  }

  List<CloudinaryResource> _getFallbackResources() {
    return AppConstants.heroImages
        .map(
          (url) => CloudinaryResource(
            url: url,
            type: CloudinaryResourceType.image,
            publicId: 'fallback',
          ),
        )
        .toList();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_heroResources.isEmpty) return;

    _timer = Timer.periodic(const Duration(seconds: 8), (Timer time) {
      if (_pageController.hasClients) {
        if (_currentPage < _heroResources.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOutCubic,
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

    // Progressive loading: fallback is shown immediately by initState

    return SizedBox(
      height: widget.isDesktop ? height : (height <= width ? width : height),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _heroResources.length,
            onPageChanged: (idx) {
              setState(() {
                _currentPage = idx;
              });
            },
            itemBuilder: (context, index) {
              final resource = _heroResources[index];
              if (resource.type == CloudinaryResourceType.video) {
                return HeroVideoBackground(url: resource.url);
              }
              return Image.network(
                resource.url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(color: Colors.black26);
                },
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
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.white.withAlpha(50),
                  AppTheme.primaryGold.withAlpha(50),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomRight,
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: widget.isDesktop
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!widget.isDesktop) const SizedBox(height: 60),
          Text(
            'Everything Beauty...',
            textAlign: widget.isDesktop ? TextAlign.left : TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: widget.isDesktop ? 64 : 42,
              fontWeight: FontWeight.normal,
              height: 1.1,
            ),
          ),
          SizedBox(height: widget.isDesktop ? 32 : 16),
          Text(
            "Step into a world of refined elegance and bespoke artistry at Beauty By Moblack."
            "\nWe don’t just style hair; we curate your signature look.",
            textAlign: widget.isDesktop ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: widget.isDesktop ? 18 : 16,
              height: 1.5,
            ),
          ),
          SizedBox(height: widget.isDesktop ? 48 : 24),
          ElevatedButton(
            onPressed: () {
              widget.onNavTap!("book appointment");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isDesktop ? 48 : 32,
                vertical: widget.isDesktop ? 24 : 18,
              ),
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
          SizedBox(height: widget.isDesktop ? 48 : 24),
          _buildStatCard('New Arrivals', 'Products'),
          if (!widget.isDesktop) const SizedBox(height: 40),
        ],
      ),
    );
  }

  //Todo: have to clear the box shadow around the card
  Widget _buildStatCard(String subtitle, String title) {
    return ClipRRect(
      child: BackdropFilter.grouped(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: GestureDetector(
          onTap: () {
            widget.onNavTap!("products");
          },
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
      ),
    );
  }
}
