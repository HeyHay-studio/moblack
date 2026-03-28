import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../home/widgets/services_section.dart';

class ServicesPage extends StatefulWidget {
  final List<Map<String, dynamic>>? dynamicServices;

  const ServicesPage({super.key, this.dynamicServices});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Map<String, dynamic>> _displayServices;

  @override
  void initState() {
    super.initState();
    _displayServices = widget.dynamicServices ?? AppConstants.services;
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

  Widget _buildAnimatedItem(int index) {
    final service = _displayServices[index];

    // Stagger algorithm
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
      child: ServiceCard(serviceData: service),
    );
  }

  Widget _buildBenefitCard(
    String title,
    String desc,
    IconData icon,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 32),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGold.withAlpha(180),
            Colors.white.withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < (feedback['rating'] as int)
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            '"${feedback['comment']}"',
            style: const TextStyle(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            feedback['name'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final feedbacks = [
      {
        'name': 'Sarah Johnson',
        'rating': 5,
        'comment':
            'The best braiding experience I’ve ever had! Highly recommend.',
      },
      {
        'name': 'Michael Brown',
        'rating': 5,
        'comment':
            'Professional service and amazing atmosphere. My go-to place now.',
      },
      {
        'name': 'Elena Rodriguez',
        'rating': 4,
        'comment':
            'Great styling and very attention to detail. Love the result!',
      },
      {
        'name': 'David Wilson',
        'rating': 5,
        'comment': 'Amazing staff and very luxury vibes. Worth every penny.',
      },
    ];

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
          'All Services',
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
                  'Explore Luxury',
                  style: GoogleFonts.aboreto(
                    color: AppTheme.primaryGold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover Our Full Range',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: isDesktop ? 48 : 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),

                // Services Grid/List
                isDesktop
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 32,
                              crossAxisSpacing: 32,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: _displayServices.length,
                        itemBuilder: (context, index) =>
                            _buildAnimatedItem(index),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _displayServices.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 32),
                        itemBuilder: (context, index) => SizedBox(
                          height: 450,
                          child: _buildAnimatedItem(index),
                        ),
                      ),

                const SizedBox(height: 80),

                // Why Choose Us Section
                Text(
                  'Why Beauty By Moblack?',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                isDesktop
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildBenefitCard(
                              'Premium Quality',
                              'We use only the finest products for your hair.',
                              Icons.high_quality,
                              0,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildBenefitCard(
                              'Expert Stylists',
                              'Our professionals are world-class experts.',
                              Icons.star,
                              1,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildBenefitCard(
                              'Luxury Vibe',
                              'Experience hair styling in ultimate comfort.',
                              Icons.spa,
                              2,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildBenefitCard(
                            'Premium Quality',
                            'We use only the finest products for your hair.',
                            Icons.high_quality,
                            0,
                          ),
                          const SizedBox(height: 16),
                          _buildBenefitCard(
                            'Expert Stylists',
                            'Our professionals are world-class experts.',
                            Icons.star,
                            1,
                          ),
                          const SizedBox(height: 16),
                          _buildBenefitCard(
                            'Luxury Vibe',
                            'Experience hair styling in ultimate comfort.',
                            Icons.spa,
                            2,
                          ),
                        ],
                      ),

                const SizedBox(height: 80),

                // Feedbacks Section
                Text(
                  'What Our Clients Say',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 200,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: feedbacks.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 20),
                      itemBuilder: (context, index) =>
                          _buildFeedbackCard(feedbacks[index]),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
