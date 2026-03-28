import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants.dart';
import '../../../../core/theme.dart';
import '../../services/pages/services_page.dart';

class ServicesSection extends StatelessWidget {
  final bool isDesktop;

  const ServicesSection({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Services',
                      style: GoogleFonts.playfairDisplay(fontSize: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Beyond hairstyle, discover a comprehensive range of '
                      'services, from coloring to extensions and more...',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
              if (isDesktop)
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ServicesPage(),
                      ),
                    );
                  },
                  icon: const Text(
                    'See all services',
                    style: TextStyle(
                      color: AppTheme.primaryPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  label: const Icon(
                    Icons.arrow_forward,
                    color: AppTheme.primaryPink,
                  ),
                ),
            ],
          ),
          if (!isDesktop) const SizedBox(height: 24),
          if (!isDesktop)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ServicesPage(),
                    ),
                  );
                },
                icon: const Text(
                  'See all services',
                  style: TextStyle(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                label: const Icon(
                  Icons.arrow_forward,
                  color: AppTheme.primaryPink,
                ),
              ),
            ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              if (isDesktop) {
                return Row(
                  children: AppConstants.services
                      .take(4)
                      .map(
                        (s) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: ServiceCard(serviceData: s),
                          ),
                        ),
                      )
                      .toList(),
                );
              } else {
                return Column(
                  children: AppConstants.services
                      .take(4)
                      .map(
                        (s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: ServiceCard(serviceData: s),
                        ),
                      )
                      .toList(),
                );
              }
            },
          ),
          SizedBox(height: isDesktop ? 40 : 20),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ServicesPage()),
              );
            },
            label: const Text(
              'See more',
              style: TextStyle(
                color: AppTheme.primaryPink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final Map<String, dynamic> serviceData;

  const ServiceCard({super.key, required this.serviceData});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _isHovered = false;
  final PageController _pageController = PageController();
  Timer? _timer;
  late List<String> images;

  @override
  void initState() {
    images = List<String>.from(widget.serviceData['img'] ?? []);
    _startSlideshow(images.length);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _stopSlideshow();
    super.dispose();
  }

  void _startSlideshow(int totalImages) {
    _timer = Timer.periodic(Duration(seconds: Random().nextInt(4) + 1), (
      timer,
    ) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        if (nextPage >= totalImages) nextPage = 0;

        _pageController.animateToPage(
          nextPage,
          duration: Duration(seconds: Random().nextInt(3) + 1),
          curve: Curves.easeInOutCirc,
        );
      }
    });
  }

  void _stopSlideshow() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 450,
        transform: Matrix4.diagonal3Values(
          _isHovered ? 1.02 : 1.0,
          _isHovered ? 1.02 : 1.0,
          1.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPink.withValues(
                alpha: _isHovered ? 0.3 : 0.0,
              ),
              blurRadius: _isHovered ? 30 : 20,
              offset: Offset(0, _isHovered ? 15 : 10),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: AnimatedScale(
                scale: _isHovered ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                child: PageView.builder(
                  physics: BouncingScrollPhysics(),
                  controller: _pageController,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Image.network(images[index], fit: BoxFit.cover);
                  },
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: _isHovered ? 0.8 : 0.6),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              top: 24,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Text(
                  widget.serviceData['title']!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            if (images.length > 1)
              Positioned(
                top: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.layers,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              bottom: _isHovered ? 32 : 24,
              right: 32,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isHovered ? 1.0 : 0.0,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
