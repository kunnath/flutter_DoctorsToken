import 'package:flutter/material.dart';
import 'dart:async';
import 'database_helper.dart';
import 'login_screen.dart';
import 'screens/patient_screens/book_appointment_screen.dart';
import 'screens/patient_screens/my_appointments_screen.dart';
import 'screens/patient_screens/appointment_verification_screen.dart';
import 'models/appointment_model.dart' as apt;
import 'models/doctor_model.dart';
import 'services/location_service.dart';

class PatientDashboard extends StatefulWidget {
  final Map<String, dynamic> user;

  const PatientDashboard({super.key, required this.user});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> with WidgetsBindingObserver {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _appointments = [];
  List<DoctorModel> _doctors = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDashboardData();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _loadDashboardData();
    }
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      final appointments = await _databaseHelper.getAppointmentsByPatient(widget.user['id']);
      final doctors = await _databaseHelper.getAllDoctors();
      
      // Check for new notifications
      await _checkForNewNotifications();
      
      setState(() {
        _appointments = appointments;
        _doctors = doctors.map((d) => DoctorModel.fromMap(d)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
      );
    }
  }

  Future<void> _checkForNewNotifications() async {
    try {
      final notifications = await _databaseHelper.getNotifications(widget.user['id']);
      final unreadNotifications = notifications.where((n) => n['is_read'] == 0).toList();
      
      if (unreadNotifications.isNotEmpty && mounted) {
        for (var notification in unreadNotifications.take(1)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(notification['message']),
              backgroundColor: notification['type'] == 'appointment_status' 
                  ? Colors.green 
                  : Colors.blue,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Mark Read',
                onPressed: () {
                  _databaseHelper.markNotificationAsRead(notification['id']);
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Silently handle notification errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.user['full_name']}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadDashboardData();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatsCard(
                          'Total Appointments',
                          _appointments.length.toString(),
                          Icons.calendar_today,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatsCard(
                          'Pending',
                          _appointments.where((a) => a['status'] == 'pending').length.toString(),
                          Icons.pending,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              'Book AppointmentModel',
                              'Find doctors and book appointments',
                              Icons.add_circle,
                              Colors.green,
                              () => _navigateToBookAppointment(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionCard(
                              'My Appointments',
                              'View and manage appointments',
                              Icons.calendar_today,
                              Colors.blue,
                              () => _navigateToMyAppointments(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              'Find Doctors',
                              'Search by specialization',
                              Icons.search,
                              Colors.purple,
                              () => _navigateToFindDoctors(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionCard(
                              'Verify Location',
                              'Location verification for today',
                              Icons.location_on,
                              Colors.orange,
                              () => _navigateToLocationVerification(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Recent Appointments
                  Text(
                    'Recent Appointments',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _appointments.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No appointments yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Book your first appointment to get started',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _navigateToBookAppointment(),
                                  child: const Text('Book AppointmentModel'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _appointments.take(5).length,
                          itemBuilder: (context, index) {
                            final appointment = _appointments[index];
                            return _buildAppointmentCard(appointment);
                          },
                        ),
                  
                  if (_appointments.length > 5) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => _navigateToAllAppointments(),
                        child: const Text('View All Appointments'),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  // Top Doctors
                  Text(
                    'Top Rated Doctors',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _doctors.take(5).length,
                      itemBuilder: (context, index) {
                        final doctor = _doctors[index];
                        return _buildDoctorCard(doctor);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    Color statusColor = _getStatusColor(appointment['status']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
            _getStatusIcon(appointment['status']),
            color: Colors.white,
          ),
        ),
        title: Text(
          appointment['doctor_name'] ?? 'Unknown DoctorModel',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${appointment['specialization']} • ${appointment['hospital_name']}'),
            Text('${appointment['appointment_date']} at ${appointment['appointment_time']}'),
            Text('Status: ${appointment['status'].toUpperCase()}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleAppointmentAction(appointment, value),
          itemBuilder: (context) => [
            if (appointment['status'] == 'pending' || appointment['status'] == 'approved')
              const PopupMenuItem(
                value: 'cancel',
                child: Text('Cancel'),
              ),
            const PopupMenuItem(
              value: 'details',
              child: Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  (doctor.fullName ?? 'D')[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                doctor.fullName ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                doctor.specialization,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  Text(
                    doctor.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'no_show':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'approved':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      case 'no_show':
        return Icons.person_off;
      default:
        return Icons.help;
    }
  }

  void _handleAppointmentAction(Map<String, dynamic> appointment, String action) {
    switch (action) {
      case 'cancel':
        _showCancelDialog(appointment);
        break;
      case 'details':
        _showAppointmentDetails(appointment);
        break;
    }
  }

  void _showCancelDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel AppointmentModel'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _databaseHelper.updateAppointmentStatus(
                appointment['id'],
                'cancelled',
              );
              _loadDashboardData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('AppointmentModel cancelled successfully')),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('AppointmentModel Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DoctorModel: ${appointment['doctor_name']}'),
              Text('Specialization: ${appointment['specialization']}'),
              Text('HospitalModel: ${appointment['hospital_name']}'),
              Text('Date: ${appointment['appointment_date']}'),
              Text('Time: ${appointment['appointment_time']}'),
              Text('Status: ${appointment['status'].toUpperCase()}'),
              Text('Token: ${appointment['token']}'),
              if (appointment['reason'] != null)
                Text('Reason: ${appointment['reason']}'),
              if (appointment['doctor_notes'] != null)
                Text('DoctorModel Notes: ${appointment['doctor_notes']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _navigateToBookAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookAppointmentScreen(patientId: widget.user['id']),
      ),
    ).then((value) => _loadDashboardData()); // Refresh data when returning
  }

  void _navigateToMyAppointments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyAppointmentsScreen(patientId: widget.user['id']),
      ),
    );
  }

  void _navigateToFindDoctors() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookAppointmentScreen(patientId: widget.user['id']),
      ),
    );
  }

  void _navigateToAllAppointments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyAppointmentsScreen(patientId: widget.user['id']),
      ),
    );
  }

  void _navigateToLocationVerification() async {
    // Get today's approved appointments
    final today = DateTime.now();
    final todayAppointments = _appointments.where((appt) {
      final appointmentDate = DateTime.parse(appt['appointment_date']);
      return appt['status'] == 'approved' &&
             appointmentDate.year == today.year &&
             appointmentDate.month == today.month &&
             appointmentDate.day == today.day;
    }).toList();

    if (todayAppointments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No approved appointments for today requiring location verification'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (todayAppointments.length == 1) {
      // Single appointment - navigate directly
      final appointmentData = todayAppointments.first;
      final appointment = apt.AppointmentModel(
        id: appointmentData['id'],
        patientId: appointmentData['patient_id'],
        doctorId: appointmentData['doctor_id'],
        hospitalId: appointmentData['hospital_id'],
        appointmentDate: DateTime.parse(appointmentData['appointment_date']),
        timeSlot: appointmentData['appointment_time'],
        reason: appointmentData['reason'] ?? '',
        notes: appointmentData['notes'] ?? '',
        status: appointmentData['status'],
        token: appointmentData['token'],
        createdAt: DateTime.parse(appointmentData['created_at']),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentVerificationScreen(appointment: appointment),
        ),
      ).then((verified) {
        if (verified == true) {
          _loadDashboardData(); // Refresh data
        }
      });
    } else {
      // Multiple appointments - show selection dialog
      _showAppointmentSelectionDialog(todayAppointments);
    }
  }

  void _showAppointmentSelectionDialog(List<Map<String, dynamic>> appointments) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select AppointmentModel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: appointments.map((appt) {
            return ListTile(
              title: Text('${appt['appointment_time']} - Token: ${appt['token']}'),
              subtitle: Text('DoctorModel: ${appt['doctor_name'] ?? 'Unknown'}'),
              onTap: () {
                Navigator.of(context).pop();
                final appointment = apt.AppointmentModel(
                  id: appt['id'],
                  patientId: appt['patient_id'],
                  doctorId: appt['doctor_id'],
                  hospitalId: appt['hospital_id'],
                  appointmentDate: DateTime.parse(appt['appointment_date']),
                  timeSlot: appt['appointment_time'],
                  reason: appt['reason'] ?? '',
                  notes: appt['notes'] ?? '',
                  status: appt['status'],
                  token: appt['token'],
                  createdAt: DateTime.parse(appt['created_at']),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentVerificationScreen(appointment: appointment),
                  ),
                ).then((verified) {
                  if (verified == true) {
                    _loadDashboardData();
                  }
                });
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
