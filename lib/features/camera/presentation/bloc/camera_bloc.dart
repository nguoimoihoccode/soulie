import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../soulie/data/soulie_repository.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc({required SoulieRepository soulieRepository})
    : _soulieRepository = soulieRepository,
      super(const CameraState()) {
    on<CameraInitRequested>(_onInit);
    on<CameraCaptureTapped>(_onCapture);
    on<CameraFlipTapped>(_onFlip);
    on<CameraFlashToggled>(_onFlashToggle);
    on<CameraRecipientSelected>(_onRecipientSelected);
  }

  final SoulieRepository _soulieRepository;

  Future<void> _onInit(
    CameraInitRequested event,
    Emitter<CameraState> emit,
  ) async {
    try {
      final recipients = await _soulieRepository.fetchCameraRecipients();
      emit(
        state.copyWith(
          status: CameraStatus.ready,
          recipients: recipients
              .map(
                (recipient) => CameraRecipient(
                  id: recipient.id,
                  name: recipient.name,
                  avatarUrl: recipient.avatarUrl,
                  isGroup: recipient.isGroup,
                  isOnline: recipient.isOnline,
                ),
              )
              .toList(growable: false),
          selectedRecipientId: recipients.isEmpty
              ? 'all-friends'
              : recipients.first.id,
          clearErrorMessage: true,
        ),
      );
    } on SoulieRepositoryException catch (error) {
      emit(
        state.copyWith(status: CameraStatus.error, errorMessage: error.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'Không thể tải danh sách người nhận',
        ),
      );
    }
  }

  Future<void> _onCapture(
    CameraCaptureTapped event,
    Emitter<CameraState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CameraStatus.capturing,
        capturedImagePath: event.imagePath,
        clearErrorMessage: true,
      ),
    );
    try {
      await _soulieRepository.createMoment(
        recipientIds: [state.selectedRecipientId],
      );
      emit(
        state.copyWith(
          status: CameraStatus.captured,
          capturedImagePath: event.imagePath,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 700));
      emit(
        state.copyWith(
          status: CameraStatus.ready,
          clearCapturedImagePath: true,
        ),
      );
    } on SoulieRepositoryException catch (error) {
      emit(
        state.copyWith(
          status: CameraStatus.error,
          capturedImagePath: event.imagePath,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CameraStatus.error,
          capturedImagePath: event.imagePath,
          errorMessage: 'Không thể gửi moment',
        ),
      );
    }
  }

  void _onFlip(CameraFlipTapped event, Emitter<CameraState> emit) {
    emit(state.copyWith(isFrontCamera: !state.isFrontCamera));
  }

  void _onFlashToggle(CameraFlashToggled event, Emitter<CameraState> emit) {
    emit(state.copyWith(isFlashOn: !state.isFlashOn));
  }

  void _onRecipientSelected(
    CameraRecipientSelected event,
    Emitter<CameraState> emit,
  ) {
    emit(state.copyWith(selectedRecipientId: event.recipientId));
  }
}
