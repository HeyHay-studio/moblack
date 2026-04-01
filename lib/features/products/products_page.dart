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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<CloudinaryResource> _displayMedia;

  @override
  void initState() {
    super.initState();
    _displayMedia = widget.productMedia ?? [];
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _buyNow(CloudinaryResource resource) async {
    final url = AppConstants.getWhatsAppBuyUrl(resource.publicId, resource.url);
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
                  'Premium Hair Products',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: isDesktop ? 48 : 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),

                if (_displayMedia.isEmpty)
                  const Center(
                    child: Text(
                      'No products available.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : 1,
                      mainAxisSpacing: 32,
                      crossAxisSpacing: 32,
                      childAspectRatio: isDesktop ? 0.85 : 0.8,
                    ),
                    itemCount: _displayMedia.length,
                    itemBuilder: (context, index) => _buildAnimatedItem(index),
                  ),

                const SizedBox(height: 80),
                _buildPeoplePromise(isDesktop),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeoplePromise(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 60 : 32),
      decoration: BoxDecoration(
        color: AppTheme.primaryGold.withAlpha(8),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppTheme.primaryGold.withAlpha(20)),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome, color: AppTheme.primaryGold, size: 40),
          const SizedBox(height: 24),
          Text(
            'OUR PEOPLE PROMISE',
            style: GoogleFonts.aboreto(
              color: AppTheme.primaryGold,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'We don\'t just provide any product.\nWe provide confidence.',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: isDesktop ? 32 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 48),
          () {
            final promises = [
              {
                'icon': Icons.verified_user,
                'title': 'Ethical Sourcing',
                'desc': '100% authentic products from ethical sources.',
              },
              {
                'icon': Icons.inventory,
                'title': 'Quality Graded',
                'desc': 'Hand-picked bundles for hair health.',
              },
              {
                'icon': Icons.support_agent,
                'title': 'Expert Care',
                'desc': 'Direct access to pro styling advice.',
              },
              {
                'icon': Icons.local_shipping,
                'desc': 'Safe and fast shipping for your luxury pieces.',
                'title': 'Secure Delivery',
              },
            ];

            final promiseWidgets = promises
                .map(
                  (p) => _promiseItem(
                    p['icon'] as IconData,
                    p['title'] as String,
                    p['desc'] as String,
                  ),
                )
                .toList();

            if (isDesktop) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: promiseWidgets
                    .map(
                      (w) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: w,
                        ),
                      ),
                    )
                    .toList(),
              );
            } else {
              return Column(
                children:
                    promiseWidgets
                        .expand((w) => [w, const SizedBox(height: 32)])
                        .toList()
                      ..removeLast(),
              );
            }
          }(),
        ],
      ),
    );
  }

  Widget _promiseItem(IconData icon, String title, String desc) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 16),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
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
                      Container(
                        color: Colors.black26,
                        child: const Center(
                          child: Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 40,
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PREMIUM COLLECTION',
                          style: GoogleFonts.aboreto(
                            color: AppTheme.primaryGold,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Authentic Hair Extension',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
