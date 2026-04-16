import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/models/category_record.dart';
import '../../core/models/product_record.dart';
import '../../core/services/category_service.dart';
import '../../core/services/cloudinary_service.dart';
import '../../core/services/product_service.dart';
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
  final GlobalKey productKey = GlobalKey();
  final GlobalKey bookingKey = GlobalKey();
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey galleryKey = GlobalKey();
  final GlobalKey serviceKey = GlobalKey();

  // Dynamic Data
  List<CloudinaryResource> _allResources = [];
  Map<String, List<CloudinaryResource>> _groupedResources = {};
  Map<String, List<ProductRecord>> _groupedProducts = {};
  List<CategoryRecord> _dynamicCategories = [];
  bool _isLoading = true;
  bool _hasError = false;

  StreamSubscription<Map<String, List<ProductRecord>>>? _productSub;
  StreamSubscription<List<CategoryRecord>>? _categorySub;

  @override
  void initState() {
    super.initState();
    _fetchMasterData();

    _productSub = ProductService.streamGroupedProducts().listen((products) {
      if (mounted) {
        setState(() {
          _groupedProducts = products;
        });
      }
    }, onError: (e) {});

    _categorySub = CategoryService.streamCategories().listen((categories) {
      if (mounted) {
        setState(() {
          _dynamicCategories = categories;
        });
      }
    }, onError: (e) {});
  }

  Future<void> _fetchMasterData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final assets = await CloudinaryService.fetchMixedAssetsByTag(
        AppConstants.mainTag,
      );

      if (assets.isEmpty) {
        // If assets are empty, check if it was a failure or just no data
        // For simplicity, we treat empty as a potential connection issue if it's the first run
        // but we'll only trigger error if we actually caught an exception in the service (which we log)
      }

      if (mounted) {
        setState(() {
          _allResources = assets;
          _groupedResources = CloudinaryService.groupByFolder(assets);
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _productSub?.cancel();
    _categorySub?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  void scrollToSection(String section) {
    GlobalKey? targetKey;
    switch (section.toLowerCase()) {
      case 'home':
        targetKey = heroKey;
        break;
      case 'products':
        targetKey = productKey;
        break;
      case 'book appointment':
        targetKey = bookingKey;
        break;
      case 'gallery':
        targetKey = galleryKey;
        break;
      case 'about':
        targetKey = aboutKey;
        break;
      case 'services':
        targetKey = serviceKey;
        break;
    }

    if (targetKey?.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey!.currentContext!,
        alignment:
            targetKey == galleryKey ||
                targetKey == bookingKey ||
                targetKey == serviceKey
            ? 0
            : 0.5,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.linearToEaseOut,
      );
    }
  }

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  List<Map<String, dynamic>> _getDynamicServices() {
    // If we have dynamic categories from Firestore, use them.
    // Otherwise fallback to hardcoded list (useful for initial load or offline).
    final sourceList = _dynamicCategories.isNotEmpty
        ? _dynamicCategories
              .where((c) => c.type == 'service') // ONLY SHOW SERVICES HERE
              .map((c) => c.toLegacyMap())
              .toList()
        : AppConstants.services;

    return sourceList.map((service) {
      final imgFolder = service['folderKey'];
      final videoFolder = service['videoFolderKey'];

      final images = _groupedResources[imgFolder] ?? [];
      final videos = _groupedResources[videoFolder] ?? [];

      final dynamicMedia = [...images, ...videos];

      return {
        ...service,
        'media': dynamicMedia.isNotEmpty ? dynamicMedia : [],
        'img': dynamicMedia.isNotEmpty
            ? dynamicMedia.map((r) => r.url).toList()
            : service['img'],
      };
    }).toList();
  }

  List<CloudinaryResource> _getGalleryMedia() {
    // Collect all unique images and videos fetched
    return _allResources
        .where(
          (r) =>
              r.type == CloudinaryResourceType.image ||
              r.type == CloudinaryResourceType.video,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    final dynamicServices = _getDynamicServices();
    final galleryMedia = _getGalleryMedia();

    final productHairImages =
        _groupedProducts[AppConstants.productHairFolderKey] ?? [];
    final productHairVideos =
        _groupedProducts[AppConstants.productHairVideoFolderKey] ?? [];
    final productBagsImages =
        _groupedProducts[AppConstants.productBagsFolderKey] ?? [];
    final productBagsVideos =
        _groupedProducts[AppConstants.productBagsVideoFolderKey] ?? [];
    final productHairProductImages =
        _groupedProducts[AppConstants.productHairProductsFolderKey] ?? [];
    final productHairProductVideos =
        _groupedProducts[AppConstants.productHairProductsVideoFolderKey] ?? [];
    final productJewelleriesImages =
        _groupedProducts[AppConstants.productJewelleriesFolderKey] ?? [];
    final productJewelleriesVideos =
        _groupedProducts[AppConstants.productJewelleriesVideoFolderKey] ?? [];

    final productMedia = [
      ...productHairImages,
      ...productHairVideos,
      ...productBagsImages,
      ...productBagsVideos,
      ...productHairProductImages,
      ...productHairProductVideos,
      ...productJewelleriesImages,
      ...productJewelleriesVideos,
    ]..shuffle();

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
                  onNavTap: scrollToSection,
                ),
                ServicesSection(
                  key: serviceKey,
                  isDesktop: isDesktop,
                  dynamicServices: List.from(dynamicServices)..shuffle(),
                ),
                ProductsSection(
                  key: productKey,
                  isDesktop: isDesktop,
                  productMedia: productMedia,
                ),
                BookingSection(key: bookingKey, isDesktop: isDesktop),
                GallerySection(
                  key: galleryKey,
                  isDesktop: isDesktop,
                  dynamicMedia: galleryMedia,
                ),
                FooterSection(key: aboutKey, isDesktop: isDesktop),
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

          // --- ERROR & RETRY OVERLAY ---
          if (_hasError)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: _buildErrorBanner(),
            ),

          // --- LOADING INDICATOR (DISCRETE) ---
          if (_isLoading && _allResources.isEmpty)
            const Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryGold,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: AppTheme.primaryGold),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection Issues',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Unable to load latest media. Using fallbacks.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _fetchMasterData,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryGold,
              backgroundColor: AppTheme.primaryGold.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('RETRY'),
          ),
        ],
      ),
    );
  }
}
