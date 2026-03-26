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
