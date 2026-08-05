import 'dart:io';

import 'package:exif/exif.dart';
import 'package:latlong2/latlong.dart';

/// Reads GPS coordinates out of a photo's EXIF metadata, if present.
/// Returns null if the file has no EXIF GPS tags (e.g. location services
/// were off when it was taken, or it came from a source that stripped
/// metadata) — callers should fall back to manual selection in that case.
Future<LatLng?> extractExifLocation(String filePath) async {
  try {
    final bytes = await File(filePath).readAsBytes();
    final tags = await readExifFromBytes(bytes);
    if (tags.isEmpty) return null;

    final lat = _toDecimalDegrees(tags['GPS GPSLatitude'], tags['GPS GPSLatitudeRef']);
    final lng = _toDecimalDegrees(tags['GPS GPSLongitude'], tags['GPS GPSLongitudeRef']);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  } catch (_) {
    return null;
  }
}

/// EXIF stores GPS coordinates as three rationals (degrees, minutes,
/// seconds) plus a hemisphere reference ('N'/'S'/'E'/'W').
double? _toDecimalDegrees(IfdTag? coordinate, IfdTag? ref) {
  if (coordinate == null) return null;
  final parts = coordinate.values.toList();
  if (parts.length != 3 || parts.any((p) => p is! Ratio)) return null;
  final ratios = parts.cast<Ratio>();

  double part(Ratio r) => r.denominator == 0 ? 0 : r.numerator / r.denominator;
  final degrees = part(ratios[0]) + part(ratios[1]) / 60 + part(ratios[2]) / 3600;

  final direction = ref?.printable.trim().toUpperCase();
  return (direction == 'S' || direction == 'W') ? -degrees : degrees;
}
