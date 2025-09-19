import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Para o avatar, usei um SVG placeholder. Você pode substituir pelo seu.
    // Adicionei um SVG genérico como exemplo.
    const String avatarSvg = '''
    <svg viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
        <path fill="#F2994A" d="M128 256C198.69 256 256 198.69 256 128C256 57.31 198.69 0 128 0C57.31 0 0 57.31 0 128C0 198.69 57.31 256 128 256Z"/>
        <path fill="#FFFFFF" d="M128 144C155.62 144 178 121.62 178 94C178 66.38 155.62 44 128 44C100.38 44 78 66.38 78 94C78 121.62 100.38 144 128 144Z"/>
        <path fill="#4F565A" d="M128 152C94.13 152 66 179.9 66 213C66 215.76 68.24 218 71 218H185C187.76 218 190 215.76 190 213C190 179.9 161.87 152 128 152Z"/>
    </svg>
    ''';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: SvgPicture.string(avatarSvg),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Olá', style: TextStyle(fontSize: 16, color: Colors.grey)),
                Text(
                  'Claudinei Fernandes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }
}
