import 'package:flutter_bloc/flutter_bloc.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc() : super(const CameraState()) {
    on<CameraInitRequested>(_onInit);
    on<CameraCaptureTapped>(_onCapture);
    on<CameraFlipTapped>(_onFlip);
    on<CameraFlashToggled>(_onFlashToggle);
  }

  Future<void> _onInit(
    CameraInitRequested event,
    Emitter<CameraState> emit,
  ) async {
    emit(state.copyWith(status: CameraStatus.ready));
  }

  Future<void> _onCapture(
    CameraCaptureTapped event,
    Emitter<CameraState> emit,
  ) async {
    emit(state.copyWith(status: CameraStatus.capturing));
    await Future.delayed(const Duration(milliseconds: 300));
    emit(state.copyWith(status: CameraStatus.captured));
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(status: CameraStatus.ready));
  }

  void _onFlip(CameraFlipTapped event, Emitter<CameraState> emit) {
    emit(state.copyWith(isFrontCamera: !state.isFrontCamera));
  }

  void _onFlashToggle(CameraFlashToggled event, Emitter<CameraState> emit) {
    emit(state.copyWith(isFlashOn: !state.isFlashOn));
  }
}
