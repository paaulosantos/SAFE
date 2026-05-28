import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe/core/constants/app_colors.dart';
import 'package:safe/core/models/traffic_point.dart';
import 'package:safe/shared/services/safe_app_store.dart';
import 'package:safe/shared/services/safe_location_service.dart';

class MapScreen extends StatefulWidget {
  final ValueListenable<String?>? pointToOpen;

  const MapScreen({super.key, this.pointToOpen});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final SafeAppStore _store = SafeAppStore.instance;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final List<TrafficPointCategory?> _filters = [
    null,
    ...TrafficPointCategory.values,
  ];

  int _selectedFilter = 0;
  String? _selectedPointId;
  SafeResolvedLocation? _currentLocation;
  bool _isLocating = false;
  String _searchQuery = '';
  static const LatLng _fallbackCenter = LatLng(-10.9472, -37.0731);
  static const double _localRiskRadiusInMeters = 30000;

  @override
  void initState() {
    super.initState();
    widget.pointToOpen?.addListener(_openRequestedPoint);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openRequestedPoint();
      if (widget.pointToOpen?.value == null) {
        _centerOnCurrentLocation();
      }
    });
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pointToOpen == widget.pointToOpen) return;

    oldWidget.pointToOpen?.removeListener(_openRequestedPoint);
    widget.pointToOpen?.addListener(_openRequestedPoint);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openRequestedPoint());
  }

  @override
  void dispose() {
    widget.pointToOpen?.removeListener(_openRequestedPoint);
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  TrafficPoint? get _selectedPoint {
    final selectedId = _selectedPointId;
    if (selectedId == null) return null;
    return _store.trafficPointById(selectedId);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final selectedPoint = _selectedPoint;

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: Stack(
            children: [
              _buildMapBackground(),
              _buildTopOverlay(),
              _buildLocateButton(),
              _buildAddButton(),
              if (selectedPoint != null) _buildBottomSheet(selectedPoint),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapBackground() {
    final visiblePoints = _visibleTrafficPoints();

    final currentLocation = _currentLocation;
    final initialCenter =
        currentLocation != null && _isLocationNearRiskMap(currentLocation)
        ? LatLng(currentLocation.latitude, currentLocation.longitude)
        : _fallbackCenter;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 12.5,
        minZoom: 10,
        maxZoom: 18,
        onTap: (_, _) => setState(() => _selectedPointId = null),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.safe.safe',
        ),
        MarkerLayer(markers: _buildMapMarkers(visiblePoints)),
      ],
    );
  }

  List<TrafficPoint> _visibleTrafficPoints() {
    final points = _store.trafficPointsByCategory(_filters[_selectedFilter]);
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return points;

    return points.where((point) {
      return point.title.toLowerCase().contains(query) ||
          point.address.toLowerCase().contains(query) ||
          point.description.toLowerCase().contains(query) ||
          point.category.label.toLowerCase().contains(query) ||
          point.category.shortLabel.toLowerCase().contains(query);
    }).toList();
  }

  List<Marker> _buildMapMarkers(List<TrafficPoint> visiblePoints) {
    final markers = visiblePoints
        .map(
          (point) => Marker(
            point: _pointLatLng(point),
            width: 48,
            height: 48,
            child: _buildMarker(point),
          ),
        )
        .toList();

    final currentLocation = _currentLocation;
    if (currentLocation != null) {
      markers.add(
        Marker(
          point: LatLng(currentLocation.latitude, currentLocation.longitude),
          width: 54,
          height: 54,
          child: _buildCurrentLocationMarker(),
        ),
      );
    }

    return markers;
  }

  LatLng _pointLatLng(TrafficPoint point) {
    final latitude = point.latitude;
    final longitude = point.longitude;

    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }

    return LatLng(
      _fallbackCenter.latitude + (point.y - 0.5) * 0.08,
      _fallbackCenter.longitude + (point.x - 0.5) * 0.08,
    );
  }

  Widget _buildCurrentLocationMarker() {
    return Center(
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFF2F80ED).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Center(
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF2F80ED),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarker(TrafficPoint point) {
    final color = _categoryColor(point.category);
    final isSelected = point.id == _selectedPointId;

    return GestureDetector(
      onTap: () => setState(() => _selectedPointId = point.id),
      child: AnimatedScale(
        scale: isSelected ? 1.12 : 1,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(
            _categoryIcon(point.category),
            color: AppColors.bgPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            final points = _visibleTrafficPoints();
                            _selectedPointId = points.isEmpty
                                ? null
                                : points.first.id;
                          });
                        },
                        onSubmitted: (_) => _focusFirstVisiblePoint(),
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Buscar risco ou endereço',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                      onPressed: _searchQuery.isEmpty
                          ? _focusFirstVisiblePoint
                          : () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _selectedPointId = null;
                              });
                            },
                      icon: Icon(
                        _searchQuery.isEmpty
                            ? Icons.tune_rounded
                            : Icons.close_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_filters.length, (index) {
                      final isSelected = _selectedFilter == index;
                      final category = _filters[index];
                      final label = category == null
                          ? 'Todos'
                          : category.shortLabel;

                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < _filters.length - 1 ? 8 : 0,
                        ),
                        child: ChoiceChip(
                          selected: isSelected,
                          label: Text(label),
                          selectedColor: AppColors.accent,
                          backgroundColor: AppColors.bgCard,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.bgPrimary
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = index;
                              final points = _visibleTrafficPoints();
                              _selectedPointId = points.isEmpty
                                  ? null
                                  : points.first.id;
                            });
                            _focusFirstVisiblePoint();
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Positioned(
      right: 18,
      bottom: _selectedPoint == null ? 96 : 300,
      child: FloatingActionButton(
        heroTag: 'add-traffic-point',
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.bgPrimary,
        onPressed: _showAddPointSheet,
        child: const Icon(Icons.add_location_alt_rounded),
      ),
    );
  }

  Widget _buildLocateButton() {
    return Positioned(
      right: 18,
      bottom: _selectedPoint == null ? 164 : 368,
      child: FloatingActionButton.small(
        heroTag: 'center-current-location',
        backgroundColor: AppColors.bgCard,
        foregroundColor: AppColors.accent,
        onPressed: _isLocating ? null : () => _centerOnCurrentLocation(),
        child: _isLocating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              )
            : const Icon(Icons.my_location_rounded),
      ),
    );
  }

  Widget _buildBottomSheet(TrafficPoint point) {
    final color = _categoryColor(point.category);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_categoryIcon(point.category), color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    point.category.label,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _selectedPointId = null),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                point.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.accent,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      point.latitude == null || point.longitude == null
                          ? point.address
                          : '${point.address} • ${point.latitude!.toStringAsFixed(5)}, ${point.longitude!.toStringAsFixed(5)}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  point.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildCountPill(
                    Icons.check_circle_rounded,
                    '${point.confirmations} confirmações',
                  ),
                  const SizedBox(width: 8),
                  _buildCountPill(
                    Icons.cancel_rounded,
                    '${point.dismissals} descartes',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () => _validatePoint(point),
                        icon: const Icon(Icons.thumb_up_alt_rounded, size: 18),
                        label: const Text('Validar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.bgPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _discardPoint(point);
                        },
                        icon: const Icon(Icons.report_off_rounded, size: 18),
                        label: const Text('Descartar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.red,
                          side: const BorderSide(color: AppColors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountPill(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textMuted, size: 15),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddPointSheet() async {
    final titleController = TextEditingController();
    final addressController = TextEditingController(
      text: _currentLocation?.label ?? 'Use sua localização atual',
    );
    final descriptionController = TextEditingController();
    var selectedCategory = TrafficPointCategory.pothole;
    SafeResolvedLocation? currentLocation = _currentLocation;
    var isLocating = false;
    String? locationError;
    var requestedLocationOnOpen = currentLocation != null;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> resolveLocation() async {
              setSheetState(() {
                isLocating = true;
                locationError = null;
              });

              try {
                final location = await SafeLocationService.getCurrentLocation();
                if (!context.mounted) return;

                setSheetState(() {
                  currentLocation = location;
                  isLocating = false;
                  addressController.text = location.label;
                });
                if (mounted) {
                  setState(() => _currentLocation = location);
                }
              } on SafeLocationException catch (error) {
                if (!context.mounted) return;

                setSheetState(() {
                  isLocating = false;
                  locationError = error.message;
                });
              } catch (_) {
                if (!context.mounted) return;

                setSheetState(() {
                  isLocating = false;
                  locationError =
                      'Não foi possível obter sua localização agora.';
                });
              }
            }

            if (!requestedLocationOnOpen) {
              requestedLocationOnOpen = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted && currentLocation == null) {
                  resolveLocation();
                }
              });
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Novo ponto perigoso',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgCardLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: currentLocation == null
                                ? AppColors.border
                                : AppColors.green.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: currentLocation == null
                                    ? AppColors.accentLight
                                    : AppColors.greenBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: isLocating
                                  ? const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.accent,
                                      ),
                                    )
                                  : Icon(
                                      currentLocation == null
                                          ? Icons.my_location_rounded
                                          : Icons.check_circle_rounded,
                                      color: currentLocation == null
                                          ? AppColors.accent
                                          : AppColors.green,
                                      size: 22,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentLocation == null
                                        ? 'Localização do ponto'
                                        : 'Localização capturada',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    locationError ??
                                        currentLocation?.label ??
                                        'Use o GPS para posicionar no mapa.',
                                    style: TextStyle(
                                      color: locationError == null
                                          ? AppColors.textSecondary
                                          : AppColors.red,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: isLocating ? null : resolveLocation,
                              child: Text(
                                currentLocation == null ? 'Usar' : 'Atualizar',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: TrafficPointCategory.values
                            .where((category) => !category.isReport)
                            .map((category) {
                              final selected = selectedCategory == category;
                              return ChoiceChip(
                                selected: selected,
                                label: Text(category.shortLabel),
                                selectedColor: AppColors.accent,
                                backgroundColor: AppColors.bgCardLight,
                                side: BorderSide(
                                  color: selected
                                      ? AppColors.accent
                                      : AppColors.border,
                                ),
                                labelStyle: TextStyle(
                                  color: selected
                                      ? AppColors.bgPrimary
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (_) => setSheetState(
                                  () => selectedCategory = category,
                                ),
                              );
                            })
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      _buildSheetField(
                        controller: titleController,
                        label: 'Título',
                        hint: 'Ex.: Buraco na curva',
                      ),
                      const SizedBox(height: 12),
                      _buildSheetField(
                        controller: addressController,
                        label: 'Localização',
                        hint: 'Endereço ou referência',
                      ),
                      const SizedBox(height: 12),
                      _buildSheetField(
                        controller: descriptionController,
                        label: 'Detalhes',
                        hint: 'Descreva o risco para outros usuários',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: currentLocation == null
                              ? null
                              : () {
                                  final location = currentLocation!;
                                  final point = _store.addTrafficPoint(
                                    category: selectedCategory,
                                    title: titleController.text,
                                    address: addressController.text,
                                    description: descriptionController.text,
                                    x: location.mapX,
                                    y: location.mapY,
                                    latitude: location.latitude,
                                    longitude: location.longitude,
                                  );
                                  setState(() {
                                    _currentLocation = location;
                                    _selectedFilter = 0;
                                    _selectedPointId = point.id;
                                  });
                                  Navigator.of(sheetContext).pop();
                                  _mapController.move(
                                    LatLng(
                                      location.latitude,
                                      location.longitude,
                                    ),
                                    16,
                                    offset: const Offset(0, 110),
                                  );
                                },
                          icon: const Icon(Icons.add_location_alt_rounded),
                          label: Text(
                            currentLocation == null
                                ? 'Use a localização para adicionar'
                                : 'Adicionar ao mapa',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            disabledBackgroundColor: AppColors.bgCardLight,
                            foregroundColor: AppColors.bgPrimary,
                            disabledForegroundColor: AppColors.textMuted,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    addressController.dispose();
    descriptionController.dispose();
  }

  Widget _buildSheetField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
    );
  }

  Future<void> _centerOnCurrentLocation({bool showErrors = true}) async {
    if (_isLocating) return;

    setState(() => _isLocating = true);

    try {
      final location = await SafeLocationService.getCurrentLocation();
      if (!mounted) return;

      setState(() {
        _currentLocation = location;
        _isLocating = false;
        _selectedPointId = null;
      });

      if (_isLocationNearRiskMap(location)) {
        _mapController.move(LatLng(location.latitude, location.longitude), 16);
      } else {
        _mapController.move(_fallbackCenter, 12.5);
        if (showErrors) {
          _showMapSnackBar(
            'Localização real capturada. Mantendo os riscos cadastrados no mapa.',
          );
        }
      }
    } on SafeLocationException catch (error) {
      if (!mounted) return;
      setState(() => _isLocating = false);
      if (showErrors) _showMapSnackBar(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLocating = false);
      if (showErrors) {
        _showMapSnackBar('Não foi possível obter sua localização agora.');
      }
    }
  }

  bool _isLocationNearRiskMap(SafeResolvedLocation location) {
    const distance = Distance();
    final meters = distance.as(
      LengthUnit.Meter,
      _fallbackCenter,
      LatLng(location.latitude, location.longitude),
    );

    return meters <= _localRiskRadiusInMeters;
  }

  void _focusFirstVisiblePoint() {
    final points = _visibleTrafficPoints();

    if (points.isEmpty) {
      _showMapSnackBar('Nenhum risco encontrado para esta busca.');
      return;
    }

    final point = points.first;
    setState(() => _selectedPointId = point.id);
    _mapController.move(_pointLatLng(point), 15, offset: const Offset(0, 110));
  }

  void _openRequestedPoint() {
    final pointId = widget.pointToOpen?.value;
    if (pointId == null) return;

    final point = _store.trafficPointById(pointId);
    if (point == null) return;

    setState(() {
      _selectedFilter = 0;
      _selectedPointId = point.id;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(
        _pointLatLng(point),
        15,
        offset: const Offset(0, 110),
      );
    });
  }

  void _validatePoint(TrafficPoint point) {
    _store.confirmTrafficPoint(point.id);
    final updatedPoint = _store.trafficPointById(point.id);
    if (updatedPoint == null) return;

    setState(() => _selectedPointId = updatedPoint.id);
    _showMapSnackBar('${updatedPoint.confirmations} confirmações neste ponto.');
  }

  void _discardPoint(TrafficPoint point) {
    _store.discardTrafficPoint(point.id);
    final updatedPoint = _store.trafficPointById(point.id);

    if (updatedPoint == null) {
      setState(() => _selectedPointId = null);
      _showMapSnackBar('Ponto removido após 3 descartes.');
      return;
    }

    setState(() => _selectedPointId = updatedPoint.id);
    _showMapSnackBar('${updatedPoint.dismissals} descartes neste ponto.');
  }

  void _showMapSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.bgCard),
    );
  }

  Color _categoryColor(TrafficPointCategory category) {
    return switch (category) {
      TrafficPointCategory.accident => AppColors.red,
      TrafficPointCategory.pothole => AppColors.orange,
      TrafficPointCategory.signal => AppColors.purple,
      TrafficPointCategory.construction => AppColors.accent,
      TrafficPointCategory.phone => AppColors.purpleLight,
      TrafficPointCategory.redLight => AppColors.red,
      TrafficPointCategory.speeding => AppColors.green,
    };
  }

  IconData _categoryIcon(TrafficPointCategory category) {
    return switch (category) {
      TrafficPointCategory.accident => Icons.car_crash_rounded,
      TrafficPointCategory.pothole => Icons.warning_amber_rounded,
      TrafficPointCategory.signal => Icons.traffic_rounded,
      TrafficPointCategory.construction => Icons.construction_rounded,
      TrafficPointCategory.phone => Icons.phone_android_rounded,
      TrafficPointCategory.redLight => Icons.traffic_rounded,
      TrafficPointCategory.speeding => Icons.speed_rounded,
    };
  }
}
