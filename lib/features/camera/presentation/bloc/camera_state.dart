import 'package:equatable/equatable.dart';

enum CameraStatus { initial, ready, capturing, captured, error }

class CameraState extends Equatable {
  final CameraStatus status;
  final bool isFrontCamera;
  final bool isFlashOn;
  final String? capturedImagePath;

  const CameraState({
    this.status = CameraStatus.initial,
    this.isFrontCamera = true,
    this.isFlashOn = false,
    this.capturedImagePath,
  });

  CameraState copyWith({
    CameraStatus? status,
    bool? isFrontCamera,
    bool? isFlashOn,
    String? capturedImagePath,
  }) {
    return CameraState(
      status: status ?? this.status,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
    );
  }

  @override
  List<Object?> get props => [status, isFrontCamera, isFlashOn, capturedImagePath];
}
