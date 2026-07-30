import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../application/address_search_provider.dart';
import '../../data/address_search_service.dart';
import '../../domain/address_search_suggestion.dart';

class AddressMapPicker extends ConsumerStatefulWidget {
  const AddressMapPicker({
    super.key,
    required this.searchController,
    required this.selectedPoint,
    required this.loading,
    required this.onSearchEdited,
    required this.onPointSelected,
    required this.onUseCurrentLocation,
  });

  final TextEditingController searchController;
  final LatLng? selectedPoint;
  final bool loading;
  final VoidCallback onSearchEdited;
  final ValueChanged<LatLng> onPointSelected;
  final Future<void> Function() onUseCurrentLocation;

  @override
  ConsumerState<AddressMapPicker> createState() => _AddressMapPickerState();
}

class _AddressMapPickerState extends ConsumerState<AddressMapPicker> {
  static const _fallbackCenter = LatLng(10.7769, 106.7009);

  final _mapController = MapController();
  final _searchFocusNode = FocusNode();
  Timer? _debounce;
  List<AddressSearchSuggestion> _suggestions = const [];
  bool _searching = false;
  bool _mapReady = false;
  String? _searchError;
  int _searchGeneration = 0;

  @override
  void didUpdateWidget(covariant AddressMapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final point = widget.selectedPoint;
    final previous = oldWidget.selectedPoint;
    if (point == null ||
        !_mapReady ||
        (previous?.latitude == point.latitude &&
            previous?.longitude == point.longitude)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _mapReady) _mapController.move(point, 17);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPoint = widget.selectedPoint;
    final center = selectedPoint ?? _fallbackCenter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tìm hoặc chọn điểm trên bản đồ',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: AppColors.text),
        ),
        const SizedBox(height: AppSpacing.labelInputGap),
        TextField(
          controller: widget.searchController,
          focusNode: _searchFocusNode,
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            widget.onSearchEdited();
            _scheduleSearch(value);
          },
          onSubmitted: (_) => _runSearch(),
          decoration: InputDecoration(
            hintText: 'Nhập số nhà, tên đường hoặc tọa độ',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    tooltip: 'Xóa tìm kiếm',
                    onPressed: widget.searchController.text.isEmpty
                        ? null
                        : _clearSearch,
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        if (_searchError != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _searchError!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: const BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var index = 0; index < _suggestions.length; index++) ...[
                  _SuggestionTile(
                    suggestion: _suggestions[index],
                    onTap: () => _selectSuggestion(_suggestions[index]),
                  ),
                  if (index < _suggestions.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SizedBox(
            height: 300,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: selectedPoint == null ? 12 : 17,
                    minZoom: 5,
                    maxZoom: 19,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onMapReady: () => _mapReady = true,
                    onTap: (_, point) {
                      _searchFocusNode.unfocus();
                      setState(() => _suggestions = const []);
                      widget.onPointSelected(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.greentrash.green_trash_project',
                    ),
                    if (selectedPoint != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedPoint,
                            width: 52,
                            height: 52,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.location_pin,
                              color: AppColors.primary,
                              size: 46,
                              shadows: AppShadows.soft,
                            ),
                          ),
                        ],
                      ),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Column(
                    children: [
                      _MapControlButton(
                        tooltip: 'Phóng to',
                        icon: Icons.add_rounded,
                        onPressed: () => _changeZoom(1),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _MapControlButton(
                        tooltip: 'Thu nhỏ',
                        icon: Icons.remove_rounded,
                        onPressed: () => _changeZoom(-1),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _MapControlButton(
                        tooltip: 'Vị trí hiện tại',
                        icon: Icons.my_location_rounded,
                        loading: widget.loading,
                        onPressed: widget.loading
                            ? null
                            : widget.onUseCurrentLocation,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.opacity(AppColors.green950, 0.86),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          selectedPoint == null
                              ? 'Chạm bản đồ để đặt điểm thu gom'
                              : '${selectedPoint.latitude.toStringAsFixed(6)}, '
                                    '${selectedPoint.longitude.toStringAsFixed(6)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textInverse),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.loading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x33FFFFFF),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Chạm bản đồ hoặc chọn một gợi ý để đồng bộ địa chỉ và tọa độ.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  void _scheduleSearch(String _) {
    _debounce?.cancel();
    setState(() {
      _searchError = null;
      if (widget.searchController.text.trim().length < 3) {
        _suggestions = const [];
      }
    });
    _debounce = Timer(const Duration(milliseconds: 500), _runSearch);
  }

  Future<void> _runSearch() async {
    final query = widget.searchController.text.trim();
    if (query.length < 3) return;
    final generation = ++_searchGeneration;
    final bias = widget.selectedPoint ?? _mapCenter;
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final results = await ref
          .read(addressSearchServiceProvider)
          .search(query, latitude: bias.latitude, longitude: bias.longitude);
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        _suggestions = results;
        _searchError = results.isEmpty
            ? 'Không tìm thấy địa chỉ phù hợp.'
            : null;
      });
    } on AddressSearchException catch (error) {
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        _suggestions = const [];
        _searchError = error.message;
      });
    } on TimeoutException {
      if (!mounted || generation != _searchGeneration) return;
      setState(() => _searchError = 'Tìm kiếm mất quá nhiều thời gian.');
    } catch (_) {
      if (!mounted || generation != _searchGeneration) return;
      setState(() => _searchError = 'Không thể tải gợi ý địa chỉ.');
    } finally {
      if (mounted && generation == _searchGeneration) {
        setState(() => _searching = false);
      }
    }
  }

  LatLng get _mapCenter {
    if (!_mapReady) return _fallbackCenter;
    return _mapController.camera.center;
  }

  void _selectSuggestion(AddressSearchSuggestion suggestion) {
    final point = LatLng(suggestion.latitude, suggestion.longitude);
    _debounce?.cancel();
    widget.searchController.text = [
      suggestion.title,
      suggestion.subtitle,
    ].where((value) => value.isNotEmpty).join(', ');
    widget.searchController.selection = TextSelection.collapsed(
      offset: widget.searchController.text.length,
    );
    _searchFocusNode.unfocus();
    setState(() {
      _suggestions = const [];
      _searchError = null;
    });
    if (_mapReady) _mapController.move(point, 17);
    widget.onPointSelected(point);
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchGeneration++;
    widget.searchController.clear();
    setState(() {
      _suggestions = const [];
      _searchError = null;
      _searching = false;
    });
  }

  void _changeZoom(double delta) {
    if (!_mapReady) return;
    final camera = _mapController.camera;
    _mapController.move(
      camera.center,
      (camera.zoom + delta).clamp(5, 19).toDouble(),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.suggestion, required this.onTap});

  final AddressSearchSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minLeadingWidth: 24,
      leading: Icon(
        suggestion.isCoordinate
            ? Icons.gps_fixed_rounded
            : Icons.location_on_outlined,
        color: AppColors.primary,
        size: 22,
      ),
      title: Text(
        suggestion.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: suggestion.subtitle.isEmpty
          ? null
          : Text(
              suggestion.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: const Icon(Icons.north_west_rounded, size: 18),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.loading = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
      ),
    );
  }
}
