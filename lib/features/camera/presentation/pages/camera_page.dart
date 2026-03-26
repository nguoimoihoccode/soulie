import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../soulie/data/soulie_repository.dart';
import '../bloc/camera_bloc.dart';
import '../bloc/camera_event.dart';
import '../bloc/camera_state.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CameraBloc(
        soulieRepository: context.read<SoulieRepository>(),
      )..add(const CameraInitRequested()),
      child: const _CameraView(),
    );
  }
}

class _CameraView extends StatelessWidget {
  const _CameraView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CameraBloc, CameraState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<CameraBloc, CameraState>(
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                // Top bar: flash | title | settings
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context
                              .read<CameraBloc>()
                              .add(const CameraFlashToggled()),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              state.isFlashOn
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              color: state.isFlashOn
                                  ? AppColors.warning
                                  : AppColors.textTertiary,
                              size: 20,
                            ),
                          ),
                        ),
                        const Text(
                          'Soulie',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/main/profile'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.settings_outlined,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                // Camera viewfinder - SQUARE with rounded corners (Locket style)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AspectRatio(
                          aspectRatio: 1.0, // Square
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: AppColors.surfaceLight,
                              border: Border.all(
                                color: state.status == CameraStatus.capturing
                                    ? AppColors.primary
                                    : AppColors.cardBorder,
                                width: state.status == CameraStatus.capturing
                                    ? 2
                                    : 0.5,
                              ),
                              boxShadow: state.status == CameraStatus.capturing
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 24,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(31),
                              child: Stack(
                                children: [
                                // Camera preview placeholder
                                Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        state.isFrontCamera
                                            ? Icons.person_outline_rounded
                                            : Icons.landscape_outlined,
                                        size: 56,
                                        color: AppColors.textTertiary
                                            .withValues(alpha: 0.2),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        state.isFrontCamera
                                            ? 'Front Camera'
                                            : 'Back Camera',
                                        style: TextStyle(
                                          color: AppColors.textTertiary
                                              .withValues(alpha: 0.4),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Friends strip at top of viewfinder
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    right: 12,
                                    child: SizedBox(
                                      height: 34,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: state.recipients.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (context, index) {
                                          final recipient =
                                              state.recipients[index];
                                          final isSelected =
                                              recipient.id ==
                                              state.selectedRecipientId;
                                          return GestureDetector(
                                            onTap: () => context
                                                .read<CameraBloc>()
                                                .add(
                                                  CameraRecipientSelected(
                                                    recipient.id,
                                                  ),
                                                ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.primary
                                                        .withValues(
                                                          alpha: 0.25,
                                                        )
                                                    : Colors.black.withValues(
                                                        alpha: 0.35,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(17),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.primary
                                                          .withValues(
                                                            alpha: 0.5,
                                                          )
                                                      : Colors.white.withValues(
                                                          alpha: 0.08,
                                                        ),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  recipient.name,
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? AppColors.primary
                                                        : AppColors
                                                            .textSecondary,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                // Bottom controls: gallery | capture | flip
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      // Gallery
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: AppColors.surfaceLight,
                            border:
                                Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Icon(
                            Icons.photo_library_outlined,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                        ),
                      ),
                      // Capture button
                      GestureDetector(
                        onTap: () => context
                            .read<CameraBloc>()
                            .add(const CameraCaptureTapped()),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width:
                              state.status == CameraStatus.capturing ? 72 : 80,
                          height:
                              state.status == CameraStatus.capturing ? 72 : 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: state.status == CameraStatus.capturing
                                  ? AppColors.primary
                                  : AppColors.primary
                                      .withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                      ),
                      // Flip camera
                      GestureDetector(
                        onTap: () => context
                            .read<CameraBloc>()
                            .add(const CameraFlipTapped()),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: AppColors.surfaceLight,
                            border:
                                Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Icon(
                            Icons.flip_camera_ios_outlined,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
