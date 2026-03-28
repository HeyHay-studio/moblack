import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/services/cloudinary_service.dart';
import '../../core/theme.dart';
import 'widgets/booking_section.dart';
import 'widgets/footer_section.dart';
import 'widgets/gallery_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/mobile_menu.dart';
import 'widgets/products_section.dart';
import 'widgets/services_section.dart';
import 'widgets/top_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isMenuOpen = false;
  final ScrollController scrollController = ScrollController();

  final GlobalKey heroKey = GlobalKey();
  final GlobalKey servicesKey = GlobalKey();
  final GlobalKey bookingKey = GlobalKey();
  final GlobalKey galleryKey = GlobalKey();

  // Dynamic Data
  List<CloudinaryResource> _allResources = [];
  Map<String, List<String>> _groupedResources = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMasterData();
  }

  Future<void> _fetchMasterData() async {
    final assets = await CloudinaryService.fetchMixedAssetsByTag(
      AppConstants.mainTag,
    );
    if (mounted) {
      setState(() {
        _allResources = assets;
        _groupedResources = CloudinaryService.groupByFolder(assets);
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollToSection(String section) {
    GlobalKey? targetKey;
    switch (section.toLowerCase()) {
      case 'home':
        targetKey = heroKey;
        break;
      case 'services':
        targetKey = servicesKey;
        break;
      case 'booking':
        targetKey = bookingKey;
        break;
      case 'gallery':
        targetKey = galleryKey;
        break;
    }

    if (targetKey?.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey!.currentContext!,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  List<Map<String, dynamic>> _getDynamicServices() {
    return AppConstants.services.map((service) {
      final folderKey = service['folderKey'];
      final dynamicImages = _groupedResources[folderKey] ?? [];
      return {
        ...service,
        'img': dynamicImages.isNotEmpty ? dynamicImages : service['img'],
      };
    }).toList();
  }

  List<String> _getGalleryImages() {
    // Collect all unique images fetched
    return _allResources
        .where((r) => r.type == CloudinaryResourceType.image)
        .map((r) => r.url)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundBlack,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGold),
        ),
      );
    }

    final dynamicServices = _getDynamicServices();
    final galleryImages = _getGalleryImages();
    final productImages =
        _groupedResources[AppConstants.productFolderKey] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                HeroSection(
                  key: heroKey,
                  isDesktop: isDesktop,
                  allResources: _allResources,
                ),
                ServicesSection(
                  key: servicesKey,
                  isDesktop: isDesktop,
                  dynamicServices: dynamicServices,
                ),
                if (productImages.isNotEmpty)
                  ProductsSection(
                    isDesktop: isDesktop,
                    productImages: productImages,
                  ),
                BookingSection(key: bookingKey, isDesktop: isDesktop),
                GallerySection(
                  key: galleryKey,
                  isDesktop: isDesktop,
                  dynamicImages: galleryImages,
                ),
                FooterSection(isDesktop: isDesktop),
              ],
            ),
          ),
          TopNavigation(
            isDesktop: isDesktop,
            isMenuOpen: isMenuOpen,
            onMenuToggle: toggleMenu,
            onNavTap: scrollToSection,
          ),
          if (!isDesktop)
            MobileMenu(
              isMenuOpen: isMenuOpen,
              onClose: toggleMenu,
              onNavTap: scrollToSection,
            ),
        ],
      ),
    );
  }
}
