import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../database_helper.dart';
import '../../models/appointment_model.dart';
import '../../models/hospital_model.dart';
import '../../services/location_service.dart';

class AppointmentVerificationScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const AppointmentVerificationScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  _AppointmentVerificationScreenState createState() => _AppointmentVerificationScreenState();
}

class _AppointmentVerificationScreenState extends State<AppointmentVerificationScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  HospitalModel? _hospital;
  LocationVerificationResult? _locationResult;
  bool _isVerifying = false;
  bool _isLoading = true;
  bool _verificationCompleted = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _loadHospitalData();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  Future<void> _loadHospitalData() async {
    try {
      final hospital = await _databaseHelper.getHospitalById(widget.appointment.hospitalId);
      setState(() {
        _hospital = hospital;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to load hospital information: $e');
    }
  }

  Future<void> _verifyLocation() async {
    if (_hospital == null) {
      _showErrorDialog('HospitalModel information not available');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final result = await LocationService.verifyHospitalLocation(
        _hospital!.latitude,
        _hospital!.longitude,
        maxDistanceKm: 0.5, // 500 meters
      );

      setState(() {
        _locationResult = result;
        _isVerifying = false;
        _verificationCompleted = true;
      });

      if (result.isVerified) {
        // Update appointment with location verification
        await _databaseHelper.verifyPatientLocation(
          widget.appointment.id!,
          result.userLatitude!,
          result.userLongitude!,
        );
        
        _showSuccessDialog();
      } else {
        _showLocationFailureDialog(result);
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      _showErrorDialog('Location verification failed: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Verification Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your location has been successfully verified.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next Steps:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Proceed to the hospital reception'),
                  const Text('• Show your appointment token'),
                  Text('• Token: ${widget.appointment.token}'),
                  const Text('• Carry a valid photo ID'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Return success to previous screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLocationFailureDialog(LocationVerificationResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Verification Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.errorMessage ?? 'Location verification failed'),
            const SizedBox(height: 16),
            if (result.distance != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distance Information:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Your distance: ${LocationService.formatDistance(result.distance!)}'),
                    const Text('Required: Within 500m'),
                    Text('Travel time: ${LocationService.getEstimatedTravelTime(result.distance!)}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (result.errorType == LocationErrorType.tooFarFromHospital) ...[
              const Text(
                '⚠️ Your appointment will be automatically cancelled if you cannot reach the hospital in time.',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
        actions: [
          if (result.errorType == LocationErrorType.permissionDenied ||
              result.errorType == LocationErrorType.permissionDeniedForever) ...[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await LocationService.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
          TextButton(
            onPressed: () => _verifyLocation(),
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Location Verification'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header Section
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'AppointmentModel Location Verification',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please verify your location to confirm your appointment',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // AppointmentModel Details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AppointmentModel Details',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          _buildDetailRow('Token', widget.appointment.token ?? 'N/A'),
                          _buildDetailRow('Date', _formatDate(widget.appointment.appointmentDate)),
                          _buildDetailRow('Time', widget.appointment.timeSlot),
                          _buildDetailRow('HospitalModel', _hospital?.name ?? 'Loading...'),
                          if (_hospital != null)
                            _buildDetailRow('Address', _hospital!.address),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Location Status
                  if (_locationResult != null) ...[
                    Card(
                      color: _locationResult!.isVerified ? Colors.green[50] : Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _locationResult!.isVerified 
                                      ? Icons.check_circle 
                                      : Icons.error,
                                  color: _locationResult!.isVerified 
                                      ? Colors.green 
                                      : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _locationResult!.isVerified 
                                      ? 'Location Verified' 
                                      : 'Verification Failed',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _locationResult!.isVerified 
                                        ? Colors.green 
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_locationResult!.distance != null) ...[
                              Text('Distance from hospital: ${LocationService.formatDistance(_locationResult!.distance!)}'),
                              Text('Travel time: ${LocationService.getEstimatedTravelTime(_locationResult!.distance!)}'),
                            ],
                            if (_locationResult!.accuracy != null)
                              Text('Location accuracy: ${_locationResult!.accuracy!.toStringAsFixed(0)}m'),
                            if (_locationResult!.errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _locationResult!.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Verification Button or Status
                  if (!_verificationCompleted) ...[
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isVerifying ? _pulseAnimation.value : 1.0,
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton.icon(
                              onPressed: _isVerifying ? null : _verifyLocation,
                              icon: _isVerifying
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.my_location),
                              label: Text(
                                _isVerifying ? 'Verifying Location...' : 'Verify My Location',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Important Information
                  Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                'Important Information',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('• You must be within 500 meters of the hospital'),
                          const Text('• Location services must be enabled'),
                          const Text('• Verification is required on appointment day'),
                          const Text('• Appointments may be cancelled if verification fails'),
                          const SizedBox(height: 8),
                          Text(
                            'Current time: ${DateTime.now().toString().substring(0, 16)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
