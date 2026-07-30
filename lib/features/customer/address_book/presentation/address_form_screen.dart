import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/app_models.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../application/address_book_actions.dart';
import '../application/reverse_geocoding_provider.dart';
import '../data/reverse_geocoding_service.dart';
import 'widgets/address_map_picker.dart';

class AddressFormScreen extends ConsumerStatefulWidget {
  const AddressFormScreen({super.key, this.address});

  final CustomerAddress? address;

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  late final TextEditingController _detailController;
  late final TextEditingController _wardController;
  late final TextEditingController _districtController;
  late final TextEditingController _cityController;
  late bool _isDefault;
  late double _latitude;
  late double _longitude;
  bool _locating = false;
  bool _saving = false;
  bool _addressResolvedFromMap = false;
  int _resolveGeneration = 0;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _detailController = TextEditingController(
      text: address?.diaChiChiTiet ?? '',
    );
    _wardController = TextEditingController(text: address?.phuongXa ?? '');
    _districtController = TextEditingController(text: address?.quanHuyen ?? '');
    _cityController = TextEditingController(
      text: address?.tinhThanh ?? 'TP. Hồ Chí Minh',
    );
    _isDefault = address?.macDinh ?? false;
    _latitude = address?.toaDoLat ?? 0;
    _longitude = address?.toaDoLng ?? 0;
    _addressResolvedFromMap = _hasValidCoordinates;
  }

  @override
  void dispose() {
    _detailController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPoint = _hasValidCoordinates
        ? LatLng(_latitude, _longitude)
        : null;
    return AppPage(
      maxWidth: 760,
      title: widget.address == null ? 'Thêm địa chỉ' : 'Chỉnh sửa địa chỉ',
      subtitle: 'Thông tin điểm thu gom',
      appBarBackgroundColor: AppColors.surface,
      appBarTitleColor: AppColors.text,
      appBarSubtitleColor: AppColors.textMuted,
      scaffoldBackgroundColor: AppColors.screenBackground,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.xl,
          AppSpacing.screenHorizontal,
          AppSpacing.xxxl,
        ),
        children: [
          const SectionHeader(
            title: 'Địa chỉ nhận rác',
            subtitle: 'Ghim đúng điểm để nhân viên đến chính xác',
          ),
          const SizedBox(height: AppSpacing.xl),
          AddressMapPicker(
            searchController: _detailController,
            selectedPoint: selectedPoint,
            loading: _locating,
            onSearchEdited: () {
              if (_addressResolvedFromMap) {
                setState(() => _addressResolvedFromMap = false);
              }
            },
            onPointSelected: (point) => _resolveMapPoint(point),
            onUseCurrentLocation: _useCurrentLocation,
          ),
          if (_addressResolvedFromMap) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Địa chỉ và điểm bản đồ đã được đồng bộ. Hãy kiểm tra lại thông tin bên dưới.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          const SectionHeader(
            title: 'Thông tin địa chỉ',
            subtitle:
                'Có thể chỉnh lại tên hành chính nếu dữ liệu bản đồ thiếu',
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextInput(
            label: 'Phường/Xã',
            hint: 'Ví dụ: Phường 4',
            controller: _wardController,
            icon: Icons.location_city_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextInput(
            label: 'Quận/Huyện (nếu có)',
            hint: 'Ví dụ: Quận Gò Vấp',
            controller: _districtController,
            icon: Icons.map_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextInput(
            label: 'Tỉnh/Thành phố',
            hint: 'Ví dụ: TP. Hồ Chí Minh',
            controller: _cityController,
            icon: Icons.apartment_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: const BorderSide(color: AppColors.border),
            ),
            child: SwitchListTile(
              value: _isDefault,
              onChanged: widget.address?.macDinh == true
                  ? null
                  : (value) => setState(() => _isDefault = value),
              secondary: const Icon(Icons.home_rounded),
              title: const Text('Đặt làm địa chỉ mặc định'),
              subtitle: Text(
                widget.address?.macDinh == true
                    ? 'Hãy chọn một địa chỉ khác làm mặc định trước khi thay đổi.'
                    : 'Địa chỉ này sẽ được chọn trước khi đặt lịch.',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryActionButton(
            label: widget.address == null ? 'Lưu địa chỉ' : 'Lưu thay đổi',
            icon: Icons.save_outlined,
            loading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Hãy bật dịch vụ vị trí trên thiết bị.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Ứng dụng chưa được cấp quyền vị trí.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      await _resolveMapPoint(LatLng(position.latitude, position.longitude));
    } catch (error) {
      if (mounted) _showMessage(_messageFor(error));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _resolveMapPoint(LatLng point) async {
    final generation = ++_resolveGeneration;
    setState(() {
      _latitude = point.latitude;
      _longitude = point.longitude;
      _addressResolvedFromMap = false;
      _locating = true;
    });
    try {
      final address = await ref
          .read(reverseGeocodingServiceProvider)
          .reverse(latitude: point.latitude, longitude: point.longitude);
      if (!mounted || generation != _resolveGeneration) return;
      _applyResolvedAddress(address);
    } on ReverseGeocodingException catch (error) {
      if (!mounted || generation != _resolveGeneration) return;
      _showMessage(
        'Đã ghim tọa độ nhưng ${error.message.toLowerCase()} '
        'Hãy chọn gợi ý khác hoặc thử lại.',
      );
    } finally {
      if (mounted && generation == _resolveGeneration) {
        setState(() => _locating = false);
      }
    }
  }

  void _applyResolvedAddress(ReverseGeocodedAddress address) {
    if (address.detail.isNotEmpty) {
      _detailController.text = address.detail;
    }
    if (address.ward.isNotEmpty) {
      _wardController.text = address.ward;
    }
    _districtController.text = address.district;
    if (address.city.isNotEmpty) {
      _cityController.text = address.city;
    }
    setState(() => _addressResolvedFromMap = true);
  }

  Future<void> _save() async {
    final detail = _detailController.text.trim();
    final ward = _wardController.text.trim();
    final district = _districtController.text.trim();
    final city = _cityController.text.trim();
    if (!_hasValidCoordinates) {
      _showMessage('Vui lòng chọn chính xác điểm thu gom trên bản đồ.');
      return;
    }
    if (!_addressResolvedFromMap) {
      _showMessage('Hãy chọn một gợi ý hoặc chạm bản đồ để xác nhận địa chỉ.');
      return;
    }
    if ([detail, ward, city].any((value) => value.isEmpty)) {
      _showMessage('Vui lòng nhập đầy đủ địa chỉ, phường/xã và thành phố.');
      return;
    }

    setState(() => _saving = true);
    try {
      final addressId = await ref
          .read(addressBookActionsProvider)
          .save(
            existing: widget.address,
            detail: detail,
            ward: ward,
            district: district,
            city: city,
            latitude: _latitude,
            longitude: _longitude,
            isDefault: _isDefault,
          );
      if (mounted) Navigator.of(context).pop(addressId);
    } catch (error) {
      if (mounted) _showMessage(_messageFor(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool get _hasValidCoordinates {
    return _latitude >= -90 &&
        _latitude <= 90 &&
        _longitude >= -180 &&
        _longitude <= 180 &&
        (_latitude != 0 || _longitude != 0);
  }

  String _messageFor(Object error) {
    if (error is ReverseGeocodingException) {
      return error.message;
    }
    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' =>
          'Firestore chưa cho phép lưu địa chỉ của tài khoản này.',
        'unavailable' => 'Không kết nối được Firestore. Vui lòng thử lại.',
        _ => error.message ?? 'Không thể lưu địa chỉ (${error.code}).',
      };
    }
    return error.toString().replaceFirst('Bad state: ', '');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
