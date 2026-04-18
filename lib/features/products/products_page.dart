import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/product_record.dart';
import '../../core/theme.dart';
import '../home/widgets/video_provider_widget.dart';

class ProductsPage extends StatefulWidget {
  final List<ProductRecord>? productMedia;

  const ProductsPage({super.key, this.productMedia});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _controller;
  late AnimationController _pulseController;
  late List<ProductRecord> _displayMedia;
  String _searchQuery = "";
  bool _isInitialLoading = true;
  String _selectedCategory = 'All';

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

  void _handleDeleteItem(int index) {
    final removedItem = cartManager.removeFromCart(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildCartItem(removedItem, animation, isRemoving: true),
      duration: const Duration(milliseconds: 300),
    );
  }

  List<String> get _categories {
    final sets =
        widget.productMedia
            ?.map((p) => p.assetFolder.split('/')[1])
            .toSet()
            .toList() ??
        [];
    return ['All', ...sets];
  }

  void _filterProducts(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _displayMedia =
          widget.productMedia?.where((product) {
            final categoryMatch =
                _selectedCategory == 'All' ||
                product.categoryName == _selectedCategory;

            final searchMatch = product.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

            return categoryMatch && searchMatch;
          }).toList() ??
          [];
    });

    // Re-trigger the entrance animation
    _controller.reset();
    _controller.forward();
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ListenableBuilder(
          listenable: cartManager,
          builder: (context, child) {
            if (cartManager.items.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'Your cart is empty.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              );
            }
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'YOUR CART',
                      style: GoogleFonts.aboreto(
                        color: AppTheme.primaryGold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: AnimatedList(
                        key: _listKey,
                        initialItemCount: cartManager.items.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index, animation) {
                          return _buildCartItem(
                            cartManager.items[index],
                            animation,
                            index: index,
                          );
                        },
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          'GH₵ ${cartManager.totalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: AppTheme.primaryGold,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _buyNow(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'PROCEED TO CHECKOUT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
      },
    );
  }

  Future<void> _buyNow() async {
    if (cartManager.items.isEmpty) return;

    final cartItems = cartManager.items;
    final String itemSummary = cartItems
        .map((item) => "• ${item.product.title} (x${item.quantity})")
        .join("\n");

    final String itemId = cartItems
        .map((item) => "• ${item.product.publicId} (x${item.quantity})")
        .join("\n");

    final double total = cartManager.totalPrice;

    FirebaseFirestore.instance
        .collection(AppConstants.firestoreNotification)
        .add({
          'title': '🛍️ Product Inquiry',
          'body':
              'A customer is interested in:\n$itemSummary\n'
              '\nTotal: GH₵ ${total.toStringAsFixed(2)}',
          'itemCount': cartManager.totalItems,
          'totalPrice': total,
          'productId': itemId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

    final url = AppConstants.getWhatsAppBuyUrl(cartItems, total);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      Navigator.pop(context);
      cartManager.clearCart();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open WhatsApp")));
    }
  }

  Widget _buildCartItem(
    CartItem item,
    Animation<double> animation, {
    bool isRemoving = false,
    int? index,
  }) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'GH₵ ${(item.product.price ?? 0).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.primaryGold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity Controls
              if (!isRemoving)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _qtyButton(
                        icon: CupertinoIcons.minus,
                        onTap: () {
                          if (item.quantity > 1) {
                            cartManager.updateQuantity(
                              item.product.publicId,
                              -1,
                            );
                          } else {
                            _handleDeleteItem(index!);
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _qtyButton(
                        icon: CupertinoIcons.plus,
                        onTap: () => cartManager.updateQuantity(
                          item.product.publicId,
                          1,
                        ),
                      ),
                    ],
                  ),
                ),

              if (!isRemoving) const SizedBox(width: 8),

              // Final Delete Button
              if (!isRemoving)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () => _handleDeleteItem(index!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
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
        onBuy: () {
          cartManager.addToCart(resource);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              showCloseIcon: true,
              content: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Text(
                  '${resource.title} added to cart!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    letterSpacing: 2,
                    color: AppTheme.textWhite,
                    fontSize: 18,
                  ),
                ),
              ),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
              elevation: 0,
              backgroundColor: Colors.transparent,
              duration: const Duration(seconds: 2),
            ),
          );
        },
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Premium Products',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: isDesktop ? 48 : 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ListenableBuilder(
                      listenable: cartManager,
                      builder: (context, child) {
                        return Badge(
                          isLabelVisible: cartManager.totalItems > 0,
                          label: Text(cartManager.totalItems.toString()),
                          backgroundColor: AppTheme.primaryGold,
                          textColor: Colors.black,
                          child: IconButton.filled(
                            onPressed: () => _showCartBottomSheet(context),
                            icon: const Icon(
                              CupertinoIcons.shopping_cart,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _applyFilters();
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(
                        CupertinoIcons.search,
                        color: AppTheme.primaryGold,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white54,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = "");
                                _applyFilters();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withAlpha(10),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryGold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          showCheckmark: false,
                          label: Text(category),
                          labelStyle: GoogleFonts.aboreto(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryGold,
                          backgroundColor: Colors.white.withAlpha(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryGold
                                  : Colors.white12,
                            ),
                          ),
                          onSelected: (_) => _filterProducts(category),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                if (_displayMedia.isEmpty && !_isInitialLoading)
                  Center(
                    key: const ValueKey('no_results'),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Icon(
                          CupertinoIcons.search_circle,
                          size: 64,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found for "$_searchQuery"',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 6),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = "";
                              _selectedCategory = "All";
                            });
                            _applyFilters();
                          },
                          child: const Text(
                            'Clear all filters',
                            style: TextStyle(color: AppTheme.primaryGold),
                          ),
                        ),
                      ],
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
  final ProductRecord resource;
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
                    if (widget.resource.type == MediaType.video)
                      VideoProviderWidget(
                        videoUrl: widget.resource.url,
                        thumbnailUrl: widget.resource.thumbnailUrl,
                      )
                    else
                      Image.network(widget.resource.url, fit: BoxFit.cover),

                    if (_isHovered)
                      IgnorePointer(
                        child: Align(
                          alignment: AlignmentDirectional.topStart,
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
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        if (!widget.resource.isAvailable)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'UNAVAILABLE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                        'ADD TO CART',
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
