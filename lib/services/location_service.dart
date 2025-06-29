import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Calculate distance between two points using Haversine formula
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c; // Distance in kilometers
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Get current location with permission handling
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException();
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationPermissionDeniedException();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationPermissionDeniedForeverException();
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Check if user is within acceptable range of hospital
  static Future<LocationVerificationResult> verifyHospitalLocation(
    double hospitalLatitude,
    double hospitalLongitude,
    {double maxDistanceKm = 0.5} // 500 meters default
  ) async {
    try {
      Position? currentPosition = await getCurrentLocation();
      
      if (currentPosition == null) {
        return LocationVerificationResult(
          isVerified: false,
          errorMessage: 'Unable to get your current location',
          errorType: LocationErrorType.locationUnavailable,
        );
      }

      double distance = calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        hospitalLatitude,
        hospitalLongitude,
      );

      bool isWithinRange = distance <= maxDistanceKm;

      return LocationVerificationResult(
        isVerified: isWithinRange,
        distance: distance,
        userLatitude: currentPosition.latitude,
        userLongitude: currentPosition.longitude,
        hospitalLatitude: hospitalLatitude,
        hospitalLongitude: hospitalLongitude,
        accuracy: currentPosition.accuracy,
        timestamp: DateTime.now(),
        errorMessage: isWithinRange 
            ? null 
            : 'You are ${distance.toStringAsFixed(2)}km away from the hospital. Please be within ${maxDistanceKm}km to verify your appointment.',
        errorType: isWithinRange ? null : LocationErrorType.tooFarFromHospital,
      );
    } catch (e) {
      String errorMessage;
      LocationErrorType errorType;
      
      if (e is LocationServiceDisabledException) {
        errorMessage = 'Location services are disabled. Please enable them in your device settings.';
        errorType = LocationErrorType.serviceDisabled;
      } else if (e is LocationPermissionDeniedException) {
        errorMessage = 'Location permission denied. Please grant location access to verify your appointment.';
        errorType = LocationErrorType.permissionDenied;
      } else if (e is LocationPermissionDeniedForeverException) {
        errorMessage = 'Location permission permanently denied. Please enable location access in app settings.';
        errorType = LocationErrorType.permissionDeniedForever;
      } else {
        errorMessage = 'Failed to verify location: ${e.toString()}';
        errorType = LocationErrorType.unknown;
      }

      return LocationVerificationResult(
        isVerified: false,
        errorMessage: errorMessage,
        errorType: errorType,
      );
    }
  }

  // Request location permissions
  static Future<bool> requestLocationPermission() async {
    try {
      PermissionStatus status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  // Check if location permissions are granted
  static Future<bool> hasLocationPermission() async {
    try {
      PermissionStatus status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  // Open app settings for location permission
  static Future<void> openLocationSettings() async {
    await openAppSettings();
  }

  // Get location stream for real-time tracking
  static Stream<Position> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
    Duration intervalDuration = const Duration(seconds: 5),
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        timeLimit: intervalDuration,
      ),
    );
  }

  // Format distance for display
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    } else {
      return '${distanceKm.toStringAsFixed(1)}km';
    }
  }

  // Get estimated travel time (very basic estimation)
  static String getEstimatedTravelTime(double distanceKm) {
    if (distanceKm < 0.5) {
      return '1-2 minutes walk';
    } else if (distanceKm < 2) {
      return '${(distanceKm * 12).round()} minutes walk';
    } else if (distanceKm < 10) {
      return '${(distanceKm * 3).round()} minutes drive';
    } else {
      return '${(distanceKm * 2).round()} minutes drive';
    }
  }
}

class LocationVerificationResult {
  final bool isVerified;
  final double? distance;
  final double? userLatitude;
  final double? userLongitude;
  final double? hospitalLatitude;
  final double? hospitalLongitude;
  final double? accuracy;
  final DateTime? timestamp;
  final String? errorMessage;
  final LocationErrorType? errorType;

  LocationVerificationResult({
    required this.isVerified,
    this.distance,
    this.userLatitude,
    this.userLongitude,
    this.hospitalLatitude,
    this.hospitalLongitude,
    this.accuracy,
    this.timestamp,
    this.errorMessage,
    this.errorType,
  });

  Map<String, dynamic> toMap() {
    return {
      'isVerified': isVerified,
      'distance': distance,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
      'hospitalLatitude': hospitalLatitude,
      'hospitalLongitude': hospitalLongitude,
      'accuracy': accuracy,
      'timestamp': timestamp?.toIso8601String(),
      'errorMessage': errorMessage,
      'errorType': errorType?.toString(),
    };
  }
}

enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  locationUnavailable,
  tooFarFromHospital,
  timeout,
  unknown,
}

// Custom exceptions for better error handling
class LocationServiceDisabledException implements Exception {
  final String message = 'Location services are disabled';
}

class LocationPermissionDeniedException implements Exception {
  final String message = 'Location permission denied';
}

class LocationPermissionDeniedForeverException implements Exception {
  final String message = 'Location permission denied forever';
}
