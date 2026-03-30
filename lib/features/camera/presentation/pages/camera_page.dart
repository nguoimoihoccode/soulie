import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
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
      create: (_) =>
          CameraBloc(soulieRepository: context.read<SoulieRepository>())
            ..add(const CameraInitRequested()),
      child: const _CameraView(),
    );
  }
}

class _CameraView extends StatefulWidget {
  const _CameraView();

  @override
  State<_CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<_CameraView> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _availableCameras = const [];
  bool _isInitializing = true;
  String? _cameraError;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_setupCamera());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_disposeController());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      unawaited(_disposeController());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(
        _setupCamera(
          preferredLens: context.read<CameraBloc>().state.isFrontCamera,
        ),
      );
    }
  }

  Future<void> _setupCamera({bool? preferredLens}) async {
    setState(() {
      _isInitializing = true;
      _cameraError = null;
    });

    try {
      final cameras = await availableCameras();
      if (!mounted) return;

      if (cameras.isEmpty) {
        setState(() {
          _availableCameras = const [];
          _cameraError = 'Thiết bị không có camera khả dụng';
          _isInitializing = false;
        });
        return;
      }

      _availableCameras = cameras;
      final useFront =
          preferredLens ?? context.read<CameraBloc>().state.isFrontCamera;
      final selected = _pickCamera(cameras, useFront: useFront);
      await _initializeController(selected);
    } on CameraException catch (error) {
      if (!mounted) return;
      setState(() {
        _cameraError = _cameraExceptionMessage(error);
        _isInitializing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cameraError = 'Không thể khởi tạo camera';
        _isInitializing = false;
      });
    }
  }

  CameraDescription _pickCamera(
    List<CameraDescription> cameras, {
    required bool useFront,
  }) {
    final desiredDirection = useFront
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    return cameras.firstWhere(
      (camera) => camera.lensDirection == desiredDirection,
      orElse: () => cameras.first,
    );
  }

  Future<void> _initializeController(CameraDescription description) async {
    await _disposeController();

    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = controller;
    await controller.initialize();

    if (!mounted) {
      await controller.dispose();
      return;
    }

    final state = context.read<CameraBloc>().state;
    if (controller.value.flashMode !=
        (state.isFlashOn ? FlashMode.torch : FlashMode.off)) {
      await controller.setFlashMode(
        state.isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    }

    setState(() {
      _cameraError = null;
      _isInitializing = false;
    });
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      await controller.dispose();
    }
  }

  Future<void> _toggleLens(bool isFrontCamera) async {
    if (_availableCameras.isEmpty) {
      await _setupCamera(preferredLens: isFrontCamera);
      return;
    }

    final selected = _pickCamera(_availableCameras, useFront: isFrontCamera);
    await _initializeController(selected);
  }

  Future<void> _applyFlash(bool enabled) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      await controller.setFlashMode(enabled ? FlashMode.torch : FlashMode.off);
    } on CameraException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thiết bị không hỗ trợ flash hiện tại')),
      );
    }
  }

  Future<void> _captureMoment() async {
    final controller = _controller;
    final bloc = context.read<CameraBloc>();
    if (_isTakingPicture ||
        controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    setState(() => _isTakingPicture = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      bloc.add(CameraCaptureTapped(file.path));
    } on CameraException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_cameraExceptionMessage(error))));
    } finally {
      if (mounted) {
        setState(() => _isTakingPicture = false);
      }
    }
  }

  String _cameraExceptionMessage(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
        return 'Camera permission đã bị từ chối';
      case 'CameraAccessDeniedWithoutPrompt':
        return 'Hãy bật camera permission trong Settings';
      case 'CameraAccessRestricted':
        return 'Camera đang bị giới hạn trên thiết bị';
      default:
        return error.description ?? 'Không thể sử dụng camera';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CameraBloc, CameraState>(
      listenWhen: (previous, current) =>
          previous.isFrontCamera != current.isFrontCamera ||
          previous.isFlashOn != current.isFlashOn ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        unawaited(_toggleLens(state.isFrontCamera));
        unawaited(_applyFlash(state.isFlashOn));
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<CameraBloc, CameraState>(
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.read<CameraBloc>().add(
                            const CameraFlashToggled(),
                          ),
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
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AspectRatio(
                          aspectRatio: 1,
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
                                        color: AppColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 24,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(31),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _buildCameraSurface(state),
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    right: 12,
                                    child: SizedBox(
                                      height: 34,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: state.recipients.length,
                                        separatorBuilder: (_, _) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (context, index) {
                                          final recipient =
                                              state.recipients[index];
                                          final isSelected =
                                              recipient.id ==
                                              state.selectedRecipientId;
                                          return GestureDetector(
                                            onTap: () =>
                                                context.read<CameraBloc>().add(
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
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  if (state.status == CameraStatus.captured &&
                                      state.capturedImagePath != null)
                                    Positioned(
                                      bottom: 16,
                                      left: 16,
                                      right: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.45,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.08,
                                            ),
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: AppColors.success,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Moment sent',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: AppColors.surfaceLight,
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: const Icon(
                              Icons.photo_library_outlined,
                              color: AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _isTakingPicture ? null : _captureMoment,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: state.status == CameraStatus.capturing
                                ? 72
                                : 80,
                            height: state.status == CameraStatus.capturing
                                ? 72
                                : 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.35,
                                  ),
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
                                    : AppColors.primary.withValues(alpha: 0.15),
                              ),
                              child: _isTakingPicture
                                  ? const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.read<CameraBloc>().add(
                            const CameraFlipTapped(),
                          ),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: AppColors.surfaceLight,
                              border: Border.all(color: AppColors.cardBorder),
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

  Widget _buildCameraSurface(CameraState state) {
    final capturedPath = state.capturedImagePath;

    if (capturedPath != null &&
        (state.status == CameraStatus.captured ||
            state.status == CameraStatus.error)) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(capturedPath), fit: BoxFit.cover),
          if (state.status == CameraStatus.error)
            Container(color: Colors.black.withValues(alpha: 0.25)),
        ],
      );
    }

    if (_cameraError != null) {
      return _buildCameraMessage(
        icon: Icons.no_photography_outlined,
        title: 'Camera unavailable',
        subtitle: _cameraError!,
      );
    }

    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return _buildCameraMessage(
        icon: Icons.photo_camera_back_outlined,
        title: 'Preparing camera',
        subtitle: 'Try again in a second',
      );
    }

    return CameraPreview(controller);
  }

  Widget _buildCameraMessage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56,
              color: AppColors.textTertiary.withValues(alpha: 0.22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textTertiary.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
