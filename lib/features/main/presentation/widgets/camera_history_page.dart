import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../camera/presentation/pages/camera_page.dart';
import '../../../journal/presentation/pages/journal_page.dart';

/// Vertical PageView: Camera (top) ↕ History (bottom)
/// Swipe DOWN from Camera to see History
class CameraHistoryPage extends StatefulWidget {
  const CameraHistoryPage({super.key});

  @override
  State<CameraHistoryPage> createState() => _CameraHistoryPageState();
}

class _CameraHistoryPageState extends State<CameraHistoryPage> {
  late final PageController _verticalController;
  int _verticalPage = 0;

  @override
  void initState() {
    super.initState();
    _verticalController = PageController();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: _verticalController,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) {
            setState(() => _verticalPage = index);
          },
          children: const [
            // Page 0 (top): Camera
            CameraPage(),
            // Page 1 (bottom): History/Journal
            JournalPage(),
          ],
        ),

        // Swipe hint at bottom of camera page
        if (_verticalPage == 0)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _verticalPage == 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'History',
                      style: TextStyle(
                        color: AppColors.textTertiary.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textTertiary.withValues(alpha: 0.4),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Swipe hint at top of history page
        if (_verticalPage == 1)
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: AppColors.textTertiary.withValues(alpha: 0.4),
                    size: 20,
                  ),
                  Text(
                    'Camera',
                    style: TextStyle(
                      color: AppColors.textTertiary.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
