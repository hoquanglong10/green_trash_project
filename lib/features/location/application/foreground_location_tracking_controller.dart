import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../orders/application/order_workflow_providers.dart';
import '../../orders/domain/order_workflow_models.dart';
import '../../orders/domain/order_workflow_repository.dart';
import '../data/foreground_location_service.dart';

enum LocationTrackingPhase {
  idle,
  requestingPermission,
  active,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  failed,
}

class LocationTrackingState {
  const LocationTrackingState({
    this.phase = LocationTrackingPhase.idle,
    this.lastUpdated,
    this.message,
  });

  final LocationTrackingPhase phase;
  final DateTime? lastUpdated;
  final String? message;

  bool get isActive => phase == LocationTrackingPhase.active;
}

class ForegroundLocationTrackingController
    extends StateNotifier<LocationTrackingState> {
  ForegroundLocationTrackingController({
    required ForegroundLocationService locationService,
    required OrderWorkflowRepository workflowRepository,
  }) : _locationService = locationService,
       _workflowRepository = workflowRepository,
       super(const LocationTrackingState());

  static const _minimumDistanceMeters = 10.0;
  static const _maximumAcceptedAccuracyMeters = 50.0;

  final ForegroundLocationService _locationService;
  final OrderWorkflowRepository _workflowRepository;
  StreamSubscription<Position>? _positionSubscription;
  String? _staffId;
  String? _orderId;
  double? _destinationLatitude;
  double? _destinationLongitude;
  double? _lastLatitude;
  double? _lastLongitude;
  bool _isStarting = false;

  Future<void> start({
    required String staffId,
    String? maDon,
    double? diaChiLat,
    double? diaChiLng,
  }) async {
    if (_staffId == staffId &&
        _orderId == maDon &&
        (_isStarting || _positionSubscription != null)) {
      return;
    }

    await stop();
    _staffId = staffId;
    _orderId = maDon;
    _destinationLatitude = diaChiLat;
    _destinationLongitude = diaChiLng;
    _isStarting = true;
    state = const LocationTrackingState(
      phase: LocationTrackingPhase.requestingPermission,
    );

    late final LocationAccess access;
    try {
      access = await _locationService.requestAccess().timeout(
        const Duration(seconds: 15),
      );
    } on TimeoutException {
      if (_staffId == staffId) {
        _isStarting = false;
        state = const LocationTrackingState(
          phase: LocationTrackingPhase.failed,
          message:
              'Khong nhan duoc phan hoi GPS. Kiem tra quyen vi tri trong Chrome hoac cai dat thiet bi.',
        );
      }
      return;
    }
    if (_staffId != staffId) return;
    _isStarting = false;

    switch (access) {
      case LocationAccess.granted:
        _positionSubscription = _locationService.watchPositions().listen(
          (position) => _publishPosition(staffId, position),
          onError: (_) {
            if (_staffId == staffId) {
              state = const LocationTrackingState(
                phase: LocationTrackingPhase.failed,
                message: 'Không thể nhận dữ liệu GPS. Hãy kiểm tra định vị.',
              );
            }
          },
        );
        state = const LocationTrackingState(
          phase: LocationTrackingPhase.active,
          message: 'Da duoc cap quyen. Dang cho diem GPS dau tien.',
        );
        _publishInitialPosition(staffId);
      case LocationAccess.serviceDisabled:
        state = const LocationTrackingState(
          phase: LocationTrackingPhase.serviceDisabled,
          message: 'Hãy bật dịch vụ định vị trên thiết bị.',
        );
      case LocationAccess.denied:
        state = const LocationTrackingState(
          phase: LocationTrackingPhase.permissionDenied,
          message: 'Cần cho phép vị trí để khách hàng theo dõi đơn.',
        );
      case LocationAccess.deniedForever:
        state = const LocationTrackingState(
          phase: LocationTrackingPhase.permissionDeniedForever,
          message: 'Hãy cấp quyền vị trí trong phần cài đặt ứng dụng.',
        );
    }
  }

  Future<void> _publishInitialPosition(String staffId) async {
    try {
      final position = await _locationService.getCurrentPosition().timeout(
        const Duration(seconds: 20),
      );
      await _publishPosition(staffId, position);
    } on TimeoutException {
      if (_staffId == staffId) {
        state = const LocationTrackingState(
          phase: LocationTrackingPhase.active,
          message:
              'Da duoc cap quyen. GPS dang bat tin hieu, hay dua thiet bi ra noi thoang hon.',
        );
      }
    } catch (_) {
      // The position stream can still provide a later location.
    }
  }

  Future<void> stop() async {
    final subscription = _positionSubscription;
    _positionSubscription = null;
    _staffId = null;
    _orderId = null;
    _destinationLatitude = null;
    _destinationLongitude = null;
    _lastLatitude = null;
    _lastLongitude = null;
    _isStarting = false;
    await subscription?.cancel();
    state = const LocationTrackingState();
  }

  Future<void> _publishPosition(String staffId, Position position) async {
    if (_staffId != staffId || !_shouldSend(position)) return;
    _lastLatitude = position.latitude;
    _lastLongitude = position.longitude;

    try {
      await _workflowRepository.updateStaffLocation(
        StaffLocationCommand(
          nhanVienId: staffId,
          latitude: position.latitude,
          longitude: position.longitude,
          maDon: _orderId,
          diaChiLat: _destinationLatitude,
          diaChiLng: _destinationLongitude,
        ),
      );
      if (_staffId == staffId) {
        state = LocationTrackingState(
          phase: LocationTrackingPhase.active,
          lastUpdated: DateTime.now(),
        );
      }
    } on OrderWorkflowException catch (error) {
      if (_staffId == staffId) {
        state = LocationTrackingState(
          phase: LocationTrackingPhase.failed,
          message: error.message,
        );
      }
    } catch (_) {
      if (_staffId == staffId) {
        state = const LocationTrackingState(
          phase: LocationTrackingPhase.failed,
          message: 'Không thể gửi vị trí lên hệ thống. Hãy thử lại.',
        );
      }
    }
  }

  bool _shouldSend(Position position) {
    if (position.accuracy > _maximumAcceptedAccuracyMeters) return false;
    final previousLatitude = _lastLatitude;
    final previousLongitude = _lastLongitude;
    if (previousLatitude == null || previousLongitude == null) return true;
    return Geolocator.distanceBetween(
          previousLatitude,
          previousLongitude,
          position.latitude,
          position.longitude,
        ) >=
        _minimumDistanceMeters;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}

final foregroundLocationTrackerProvider =
    StateNotifierProvider<
      ForegroundLocationTrackingController,
      LocationTrackingState
    >((ref) {
      return ForegroundLocationTrackingController(
        locationService: const ForegroundLocationService(),
        workflowRepository: ref.watch(orderWorkflowRepositoryProvider),
      );
    });
