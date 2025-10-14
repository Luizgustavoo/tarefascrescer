import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int visualCurrentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.visualCurrentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.black54;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Color(0XFFFFD8FA),
      elevation: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(icon: Icons.home, index: 0, color: primaryColor),
            _buildNavItem(
              icon: Icons.calendar_month,
              index: 1,

              color: primaryColor,
            ),
            const SizedBox(width: 40),
            _buildNavItem(
              icon: Icons.description,
              index: 3,

              color: primaryColor,
            ),
            _buildNavItem(icon: Icons.person, index: 4, color: primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required Color color,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        color: visualCurrentIndex == index ? color : Color(0XFFD932CE),
      ),
      onPressed: () => onTap(index),
    );
  }
}
