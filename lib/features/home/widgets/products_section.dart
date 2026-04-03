import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme.dart';
import '../../../../core/models/product_record.dart';
import '../../products/products_page.dart';
import 'video_provider_widget.dart';

class ProductsSection extends StatefulWidget {
  final bool isDesktop;
  final List<ProductRecord> productMedia;

  const ProductsSection({
    super.key,
    required this.isDesktop,
    required this.productMedia,
  });

  @override
  State<ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<ProductsSection> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Products',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Handpicked excellence. Discover our signature collections.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  height: 400,
                  child: widget.productMedia.isEmpty
                      ? Center(
                          child: Text(
                            'New collections dropping soon! ✨',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white54,
                              fontSize: 24,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.trackpad,
                            },
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: widget.productMedia.take(8).length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 20),
                            itemBuilder: (context, index) {
                              return _ProductCard(
                                resource: widget.productMedia[index],
                              );
                            },
                          ),
                        ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: TextButton.icon(
                    onPressed: _isNavigating
                        ? null
                        : () async {
                            setState(() => _isNavigating = true);
                            await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ProductsPage(
                                  productMedia: widget.productMedia,
                                ),
                              ),
                            );
                            if (mounted) setState(() => _isNavigating = false);
                          },
                    icon: _isNavigating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CupertinoActivityIndicator(
                              color: AppTheme.primaryGold,
                              radius: 8,
                            ),
                          )
                        : const Text(
                            'VIEW ALL PRODUCTS',
                            style: TextStyle(
                              color: AppTheme.primaryGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    label: _isNavigating
                        ? const SizedBox.shrink()
                        : const Icon(
                            Icons.arrow_forward,
                            color: AppTheme.primaryGold,
                            size: 18,
                          ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildPeoplePromise(widget.isDesktop),
                ),
              ],
            ),
          ),
        ],
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

class _ProductCard extends StatefulWidget {
  final ProductRecord resource;

  const _ProductCard({required this.resource});

  @override
  State<_ProductCard> createState() => __ProductCardState();
}

class __ProductCardState extends State<_ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _isHovered ? AppTheme.primaryGold : Colors.white12,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.resource.type == MediaType.video)
                VideoProviderWidget(videoUrl: widget.resource.url)
              else
                Image.network(widget.resource.url, fit: BoxFit.cover),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black87, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PREMIUM COLLECTION',
                        style: TextStyle(
                          color: AppTheme.primaryGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.resource.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.resource.price != null
                            ? 'GH₵ ${widget.resource.price!.toStringAsFixed(0)}'
                            : 'Consult for details',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (!widget.resource.isAvailable)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'UNAVAILABLE',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
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
