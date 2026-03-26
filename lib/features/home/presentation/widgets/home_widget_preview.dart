import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeWidgetPreview extends StatelessWidget {
  const HomeWidgetPreview({
    super.key,
    required this.title,
    required this.subtitle,
    required this.highlight,
    required this.friendNames,
  });

  final String title;
  final String subtitle;
  final String highlight;
  final List<String> friendNames;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1726), Color(0xFF120F17)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.85)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Color(0xFF120F17),
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFD7C8E5),
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2233),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Live vibe',
                    style: TextStyle(
                      color: Color(0xFF9E8FB0),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    highlight,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              friendNames.isEmpty
                  ? 'Open Soulie to reconnect.'
                  : friendNames.join('  •  '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFB8A8C9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
