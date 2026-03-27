import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FavIcon extends StatelessWidget {
  const FavIcon({super.key, this.onTap, this.icon});

  final VoidCallback? onTap;
  final dynamic icon;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white12),
            color: Colors.transparent,
          ),
          child: Center(child: FaIcon(icon, color: Colors.white, size: 16)),
        ),
      ),
    );
  }
}
