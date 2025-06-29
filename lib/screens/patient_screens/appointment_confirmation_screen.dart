import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../database_helper.dart';
import '../../models/appointment_model.dart';
import '../../patient_dashboard.dart';

class AppointmentConfirmationScreen extends StatefulWidget {
  final String appointmentToken;
  final int patientId;

  const AppointmentConfirmationScreen({
    Key? key,
    required this.appointmentToken,
    required this.patientId,
  }) : super(key: key);

  @override
  _AppointmentConfirmationScreenState createState() => _AppointmentConfirmationScreenState();
}

class _AppointmentConfirmationScreenState extends State<AppointmentConfirmationScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  AppointmentModel? _appointment;
  String? _doctorName;
  String? _hospitalName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _loadAppointmentDetails();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  Future<void> _loadAppointmentDetails() async {
    try {
      final appointment = await _databaseHelper.getAppointmentByToken(widget.appointmentToken);
      if (appointment != null) {
        final doctor = await _databaseHelper.getDoctorById(appointment.doctorId);
        final hospital = await _databaseHelper.getHospitalById(appointment.hospitalId);
        
        setState(() {
          _appointment = appointment;
          _doctorName = doctor?.fullName ?? 'Unknown DoctorModel';
          _hospitalName = hospital?.name ?? 'Unknown HospitalModel';
          _isLoading = false;
        });
      } else {
        throw Exception('AppointmentModel not found');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to load appointment details: $e');
    }
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

  void _copyToken() {
    Clipboard.setData(ClipboardData(text: widget.appointmentToken));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AppointmentModel token copied to clipboard'),
        backgroundColor: Colors.green,
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
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('AppointmentModel Confirmed'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointment == null
              ? _buildErrorState()
              : _buildConfirmationContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load appointment details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PatientDashboard(user: {'id': widget.patientId}),
              ),
            ),
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Success Animation
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    spreadRadius: 10,
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          const Text(
            'AppointmentModel Booked Successfully!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Your appointment request has been sent to the doctor',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // AppointmentModel Details Card
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AppointmentModel Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 30),
                  
                  _buildDetailRow('👨‍⚕️ DoctorModel', _doctorName!),
                  _buildDetailRow('🏥 HospitalModel', _hospitalName!),
                  _buildDetailRow('📅 Date', _formatDate(_appointment!.appointmentDate)),
                  _buildDetailRow('⏰ Time', _appointment!.timeSlot),
                  _buildDetailRow('🩺 Reason', _appointment!.reason),
                  if (_appointment!.notes?.isNotEmpty == true)
                    _buildDetailRow('📝 Notes', _appointment!.notes!),
                  _buildDetailRow('📊 Status', _getStatusWidget(_appointment!.status)),
                  
                  const SizedBox(height: 20),
                  
                  // Token Section
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AppointmentModel Token',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.appointmentToken,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Courier',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _copyToken,
                              icon: const Icon(Icons.copy, color: Colors.blue),
                              tooltip: 'Copy Token',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Save this token. You\'ll need it for your appointment.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Important Information Card
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
                  const Text('• Your appointment is pending doctor approval'),
                  const Text('• You will receive a notification once approved'),
                  const Text('• Please arrive 15 minutes before your scheduled time'),
                  const Text('• Carry your appointment token and valid ID'),
                  const Text('• Contact hospital if you need to reschedule'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientDashboard(user: {'id': widget.patientId}),
                    ),
                  ),
                  icon: const Icon(Icons.dashboard),
                  label: const Text('Back to Dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to appointments list
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientDashboard(user: {'id': widget.patientId}),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('My Appointments'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: value is Widget ? value : Text(value.toString()),
          ),
        ],
      ),
    );
  }

  Widget _getStatusWidget(String status) {
    Color color;
    String displayText;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        displayText = 'Pending Approval';
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        color = Colors.green;
        displayText = 'Approved';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        displayText = 'Rejected';
        icon = Icons.cancel;
        break;
      case 'completed':
        color = Colors.blue;
        displayText = 'Completed';
        icon = Icons.done_all;
        break;
      default:
        color = Colors.grey;
        displayText = status;
        icon = Icons.help;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
