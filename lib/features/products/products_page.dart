import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/services/cloudinary_service.dart';
import '../../core/theme.dart';
import '../home/widgets/video_provider_widget.dart';

class ProductsPage extends StatefulWidget {
  final List<CloudinaryResource>? productMedia;

  const ProductsPage({super.key, this.productMedia});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late List<CloudinaryResource> _displayMedia;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _displayMedia = widget.productMedia ?? [];
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _controller.forward();

    // Brief delay to allow the page transition to finish and media to prep
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _buyNow(CloudinaryResource resource) async {
    final url = AppConstants.getWhatsAppBuyUrl(
      resource.publicId,
      resource.type == CloudinaryResourceType.video,
    );
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildAnimatedItem(int index) {
    final resource = _displayMedia[index];

    final double startDelay = (index * 0.1).clamp(0.0, 0.7);
    final Animation<double> slideAnim = Tween<double>(begin: 80, end: 0)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              startDelay,
              startDelay + 0.3,
              curve: Curves.easeOutCirc,
            ),
          ),
        );
    final Animation<double> fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(startDelay, startDelay + 0.3, curve: Curves.easeIn),
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, slideAnim.value),
          child: Opacity(opacity: fadeAnim.value, child: child),
        );
      },
      child: _ProductGridCard(
        resource: resource,
        onBuy: () => _buyNow(resource),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Signature Collection',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exclusive Styles',
                  style: GoogleFonts.aboreto(
                    color: AppTheme.primaryGold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Premium Products',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: isDesktop ? 48 : 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),

                if (_displayMedia.isEmpty && !_isInitialLoading)
                  const Center(
                    child: Text(
                      'No products available.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                else
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: _isInitialLoading
                        ? _buildSkeletonGrid(isDesktop)
                        : GridView.builder(
                            key: const ValueKey('actual_grid'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isDesktop ? 3 : 1,
                                  mainAxisSpacing: 32,
                                  crossAxisSpacing: 32,
                                  childAspectRatio: isDesktop ? 0.85 : 0.8,
                                ),
                            itemCount: _displayMedia.length,
                            itemBuilder: (context, index) =>
                                _buildAnimatedItem(index),
                          ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonGrid(bool isDesktop) {
    return GridView.builder(
      key: const ValueKey('skeleton_grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        mainAxisSpacing: 32,
        crossAxisSpacing: 32,
        childAspectRatio: isDesktop ? 0.85 : 0.8,
      ),
      itemCount: _displayMedia.isNotEmpty ? _displayMedia.length : 6,
      itemBuilder: (context, index) =>
          _SkeletonCard(animation: _pulseController),
    );
  }
}

class _ProductGridCard extends StatefulWidget {
  final CloudinaryResource resource;
  final VoidCallback onBuy;

  const _ProductGridCard({required this.resource, required this.onBuy});

  @override
  State<_ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<_ProductGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(5),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: _isHovered ? AppTheme.primaryGold : Colors.white12,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.resource.type == CloudinaryResourceType.video)
                      VideoProviderWidget(videoUrl: widget.resource.url)
                    else
                      Image.network(widget.resource.url, fit: BoxFit.cover),

                    if (_isHovered)
                      Align(
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'PREMIUM COLLECTION',
                      style: GoogleFonts.aboreto(
                        color: AppTheme.primaryGold,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onBuy,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'PURCHASE INQUIRY',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final Animation<double> animation;

  const _SkeletonCard({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (animation.value * 0.35),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withAlpha(20)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        height: 10,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(10),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 18,
                        width: 160,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(10),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(10),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
