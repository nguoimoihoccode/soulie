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
  final String imagePath;

  const CameraCaptureTapped(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class CameraRecipientSelected extends CameraEvent {
  final String recipientId;

  const CameraRecipientSelected(this.recipientId);

  @override
  List<Object?> get props => [recipientId];
}

class CameraFlipTapped extends CameraEvent {
  const CameraFlipTapped();
}

class CameraFlashToggled extends CameraEvent {
  const CameraFlashToggled();
}
