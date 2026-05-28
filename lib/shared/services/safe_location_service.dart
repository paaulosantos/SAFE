import 'package:geolocator/geolocator.dart';

class SafeResolvedLocation {
  final double latitude;
  final double longitude;
  final String label;
  final double mapX;
  final double mapY;

  const SafeResolvedLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.mapX,
    required this.mapY,
  });
}

class SafeLocationException implements Exception {
  final String message;

  const SafeLocationException(this.message);

  @override
  String toString() => message;
}

class SafeLocationService {
  SafeLocationService._();

  // Rough Aracaju bounds used only to project GPS coordinates on the current
  // prototype map canvas. A real Google Maps screen should use the coordinates
  // directly instead of this projection.
  static const double _northLatitude = -10.84;
  static const double _southLatitude = -11.06;
  static const double _westLongitude = -37.20;
  static const double _eastLongitude = -36.96;

  static Future<SafeResolvedLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const SafeLocationException('Ative a localização do aparelho.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const SafeLocationException('Permissão de localização negada.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const SafeLocationException(
        'Permissão bloqueada. Libere a localização nas configurações.',
      );
    }

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition == null) {
        throw const SafeLocationException(
          'Não foi possível obter sua localização agora.',
        );
      }
      position = lastKnownPosition;
    }

    return fromCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  static SafeResolvedLocation fromCoordinates({
    required double latitude,
    required double longitude,
  }) {
    final x = _clampMapPosition(
      (longitude - _westLongitude) / (_eastLongitude - _westLongitude),
    );
    final y = _clampMapPosition(
      (_northLatitude - latitude) / (_northLatitude - _southLatitude),
    );

    return SafeResolvedLocation(
      latitude: latitude,
      longitude: longitude,
      label: _formatCoordinates(latitude, longitude),
      mapX: x,
      mapY: y,
    );
  }

  static String _formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
  }

  static double _clampMapPosition(double value) {
    return value.clamp(0.08, 0.92).toDouble();
  }
}
