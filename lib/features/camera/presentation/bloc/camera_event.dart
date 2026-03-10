import 'package:equatable/equatable.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();
  @override
  List<Object?> get props => [];
}

class CameraInitRequested extends CameraEvent {
  const CameraInitRequested();
}

class CameraCaptureTapped extends CameraEvent {
  const CameraCaptureTapped();
}

class CameraFlipTapped extends CameraEvent {
  const CameraFlipTapped();
}

class CameraFlashToggled extends CameraEvent {
  const CameraFlashToggled();
}
