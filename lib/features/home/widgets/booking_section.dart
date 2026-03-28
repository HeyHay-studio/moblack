import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingSection extends StatefulWidget {
  final bool isDesktop;

  const BookingSection({super.key, required this.isDesktop});

  @override
  State<BookingSection> createState() => _BookingSectionState();
}

class _BookingSectionState extends State<BookingSection> {
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  bool _isMovingForward = true;
  final List<String> _allTimeSlots = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
  ];

  String? _selectedTime;

  int get _daysInMonth =>
      DateUtils.getDaysInMonth(_focusedDate.year, _focusedDate.month);

  int get _firstDayOffset =>
      DateTime(_focusedDate.year, _focusedDate.month, 1).weekday - 1;

  void _moveMonth(int increment) {
    setState(() {
      _isMovingForward = increment > 0;
      _focusedDate = DateTime(
        _focusedDate.year,
        _focusedDate.month + increment,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: widget.isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildBookingCalendar()),
                const SizedBox(width: 48),
                Expanded(
                  child: Column(
                    children: [SizedBox(height: 140), _buildBookingForm()],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _buildBookingCalendar(),
                const SizedBox(height: 48),
                _buildBookingForm(),
              ],
            ),
    );
  }

  Widget _buildBookingCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder(
          duration: const Duration(seconds: 1),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, value, child) =>
              Opacity(opacity: value, child: child),
          child: Text(
            'Booking',
            style: GoogleFonts.playfairDisplay(fontSize: 40),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Ready for a transformative experience?'
          ' Book your appointment now with Beauty By Moblack.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 32),
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white12),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withAlpha(20),
                    Colors.pink.withAlpha(50),
                    Colors.transparent.withAlpha(80),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(_focusedDate),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _moveMonth(-1);
                            },
                            icon: const Icon(Icons.chevron_left),
                          ),
                          IconButton(
                            onPressed: () {
                              _moveMonth(1);
                            },
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedGrid(),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 40,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.trackpad,
                        },
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _allTimeSlots.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final time = _allTimeSlots[index];
                          final isSelected = _selectedTime == time;

                          return Padding(
                            // Spacing between the items
                            padding: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              label: Text(time),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(
                                  () => _selectedTime = selected ? time : null,
                                );
                              },
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              selectedColor: const Color(0xFFFF1493),
                              backgroundColor: Colors.white.withAlpha(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.white10,
                                ),
                              ),
                              showCheckmark: false,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 32),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Working Hours',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildWorkingHourRow('Working Days', '8AM - 9PM'),
                  const SizedBox(height: 8),
                  _buildWorkingHourRow('Saturday', '10AM - 8PM'),
                  const SizedBox(height: 8),
                  _buildWorkingHourRow('Sunday', 'Closed', isClosed: true),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkingHourRow(
    String day,
    String hours, {
    bool isClosed = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          hours,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isClosed ? const Color(0xFFFF1493) : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingForm() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We will call you',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 32),
          _buildFormField('First Name', 'John'),
          const SizedBox(height: 24),
          _buildFormField('Last Name', 'Doe'),
          const SizedBox(height: 24),
          _buildFormField('Phone Number', '+1 234 567 890', isPhone: true),
          const SizedBox(height: 24),
          _buildFormField('Email', 'john@example.com'),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2D2D2D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Book appointment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String hint, {bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
        TextField(
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 18),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white12),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedGrid() {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      switchInCurve: Curves.easeOutQuart,
      switchOutCurve: Curves.easeInQuart,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final incomingOffset = _isMovingForward
            ? const Offset(0.2, 0.0)
            : const Offset(-0.2, 0.0);

        // Slide and Fade combined
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: incomingOffset,
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      // The Key is vital! It tells the Switcher the content has changed.
      child: Container(
        key: ValueKey('${_focusedDate.year}-${_focusedDate.month}'),
        child: _buildCalendarGrid(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final totalItems = _daysInMonth + _firstDayOffset + 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        // Render Weekday Headers (MON, TUE, etc.)
        if (index < 7) {
          const weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
          return Center(
            child: Text(
              weekDays[index],
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        // Handle Empty Padding for start of month
        final int dayIndex = index - 7;
        final int dayNumber = dayIndex - _firstDayOffset + 1;

        if (dayIndex < _firstDayOffset) {
          return const SizedBox.shrink();
        }
        final DateTime cellDate = DateTime(
          _focusedDate.year,
          _focusedDate.month,
          dayNumber,
        );
        final bool isPast = cellDate.isBefore(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        );

        final bool isSelected =
            _selectedDate.day == dayNumber &&
            _selectedDate.month == _focusedDate.month;

        return GestureDetector(
          onTap: isPast ? null : () => setState(() => _selectedDate = cellDate),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF1493) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? null
                  : Border.all(color: Colors.white.withAlpha(50)),
            ),
            child: Center(
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  color: isPast
                      ? Colors.black38
                      : isSelected
                      ? Colors.white
                      : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          'Available Time',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        // Use a SizedBox to define the height of your row
      ],
    );
  }
}
