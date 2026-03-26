import 'package:equatable/equatable.dart';

enum CameraStatus { initial, ready, capturing, captured, error }

class CameraRecipient extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isGroup;
  final bool isOnline;

  const CameraRecipient({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isGroup,
    required this.isOnline,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl, isGroup, isOnline];
}

class CameraState extends Equatable {
  final CameraStatus status;
  final bool isFrontCamera;
  final bool isFlashOn;
  final String? capturedImagePath;
  final List<CameraRecipient> recipients;
  final String selectedRecipientId;
  final String? errorMessage;

  const CameraState({
    this.status = CameraStatus.initial,
    this.isFrontCamera = true,
    this.isFlashOn = false,
    this.capturedImagePath,
    this.recipients = const [],
    this.selectedRecipientId = 'all-friends',
    this.errorMessage,
  });

  CameraState copyWith({
    CameraStatus? status,
    bool? isFrontCamera,
    bool? isFlashOn,
    String? capturedImagePath,
    List<CameraRecipient>? recipients,
    String? selectedRecipientId,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CameraState(
      status: status ?? this.status,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
      recipients: recipients ?? this.recipients,
      selectedRecipientId: selectedRecipientId ?? this.selectedRecipientId,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        isFrontCamera,
        isFlashOn,
        capturedImagePath,
        recipients,
        selectedRecipientId,
        errorMessage,
      ];
}
