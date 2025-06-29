import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'login_screen.dart';
import 'user_model.dart';

class DoctorDashboard extends StatefulWidget {
  final Map<String, dynamic> user;

  const DoctorDashboard({super.key, required this.user});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  int _pendingCount = 0;
  int _todayCount = 0;
  int _totalPatients = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Get doctor ID from user data
      final doctorData = await _getDoctorData();
      if (doctorData != null) {
        final appointments = await _databaseHelper.getAppointmentsByDoctor(doctorData['id']);
        
        String today = DateTime.now().toIso8601String().split('T')[0];
        
        setState(() {
          _appointments = appointments;
          _pendingCount = appointments.where((a) => a['status'] == 'pending').length;
          _todayCount = appointments.where((a) => a['appointment_date'] == today).length;
          _totalPatients = appointments.map((a) => a['patient_id']).toSet().length;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
      );
    }
  }

  Future<Map<String, dynamic>?> _getDoctorData() async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'doctors',
      where: 'user_id = ?',
      whereArgs: [widget.user['id']],
    );
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. ${widget.user['full_name']}'),
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
              if (value == 'profile') {
                _navigateToProfile();
              } else if (value == 'logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
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
                  // Quick Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatsCard(
                          'Pending Requests',
                          _pendingCount.toString(),
                          Icons.pending_actions,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatsCard(
                          'Today\'s Appointments',
                          _todayCount.toString(),
                          Icons.today,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatsCard(
                          'Total Patients',
                          _totalPatients.toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatsCard(
                          'Total Appointments',
                          _appointments.length.toString(),
                          Icons.calendar_month,
                          Colors.purple,
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'Review Requests',
                          'Approve/reject appointments',
                          Icons.rate_review,
                          Colors.orange,
                          () => _showPendingAppointments(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          'Today\'s Schedule',
                          'View today\'s appointments',
                          Icons.schedule,
                          Colors.green,
                          () => _showTodaySchedule(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Pending Appointments
                  if (_pendingCount > 0) ...[
                    Text(
                      'Pending AppointmentModel Requests ($_pendingCount)',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _appointments.where((a) => a['status'] == 'pending').take(3).length,
                      itemBuilder: (context, index) {
                        final pendingAppointments = _appointments.where((a) => a['status'] == 'pending').toList();
                        return _buildPendingAppointmentCard(pendingAppointments[index]);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  
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
                                  'Patients will be able to book appointments with you',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                  ),
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

  Widget _buildPendingAppointmentCard(Map<String, dynamic> appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['patient_name'] ?? 'Unknown Patient',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${appointment['appointment_date']} at ${appointment['appointment_time']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PENDING',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Reason: ${appointment['reason']}',
              style: const TextStyle(fontSize: 14),
            ),
            if (appointment['notes'] != null && appointment['notes'].isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Notes: ${appointment['notes']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveAppointment(appointment),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectAppointment(appointment),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
          appointment['patient_name'] ?? 'Unknown Patient',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${appointment['appointment_date']} at ${appointment['appointment_time']}'),
            Text('Status: ${appointment['status'].toUpperCase()}'),
            Text('Reason: ${appointment['reason']}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleAppointmentAction(appointment, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'details',
              child: Text('View Details'),
            ),
            if (appointment['status'] == 'approved')
              const PopupMenuItem(
                value: 'complete',
                child: Text('Mark Complete'),
              ),
          ],
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

  void _approveAppointment(Map<String, dynamic> appointment) async {
    await _databaseHelper.updateAppointmentStatus(
      appointment['id'],
      'approved',
      doctorNotes: 'AppointmentModel approved by doctor',
    );
    _loadDashboardData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AppointmentModel approved successfully')),
    );
  }

  void _rejectAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) {
        final noteController = TextEditingController();
        return AlertDialog(
          title: const Text('Reject AppointmentModel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for rejection:'),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  hintText: 'Reason for rejection...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _databaseHelper.updateAppointmentStatus(
                  appointment['id'],
                  'cancelled',
                  doctorNotes: noteController.text.isNotEmpty 
                      ? noteController.text 
                      : 'AppointmentModel rejected by doctor',
                );
                _loadDashboardData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AppointmentModel rejected')),
                );
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  void _handleAppointmentAction(Map<String, dynamic> appointment, String action) {
    switch (action) {
      case 'details':
        _showAppointmentDetails(appointment);
        break;
      case 'complete':
        _markAppointmentComplete(appointment);
        break;
    }
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AppointmentModel Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient: ${appointment['patient_name']}'),
              Text('Phone: ${appointment['patient_phone']}'),
              Text('Date: ${appointment['appointment_date']}'),
              Text('Time: ${appointment['appointment_time']}'),
              Text('Status: ${appointment['status'].toUpperCase()}'),
              Text('Token: ${appointment['token']}'),
              Text('Reason: ${appointment['reason']}'),
              if (appointment['notes'] != null)
                Text('Patient Notes: ${appointment['notes']}'),
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

  void _markAppointmentComplete(Map<String, dynamic> appointment) async {
    await _databaseHelper.updateAppointmentStatus(
      appointment['id'],
      'completed',
      doctorNotes: 'AppointmentModel completed successfully',
    );
    _loadDashboardData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AppointmentModel marked as completed')),
    );
  }

  void _showPendingAppointments() {
    final pendingAppointments = _appointments.where((a) => a['status'] == 'pending').toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pending Requests (${pendingAppointments.length})'),
        content: SizedBox(
          width: double.maxFinite,
          child: pendingAppointments.isEmpty
              ? const Text('No pending requests')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: pendingAppointments.length,
                  itemBuilder: (context, index) {
                    return _buildPendingAppointmentCard(pendingAppointments[index]);
                  },
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

  void _showTodaySchedule() {
    String today = DateTime.now().toIso8601String().split('T')[0];
    final todayAppointments = _appointments.where((a) => a['appointment_date'] == today).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Today\'s Schedule (${todayAppointments.length})'),
        content: SizedBox(
          width: double.maxFinite,
          child: todayAppointments.isEmpty
              ? const Text('No appointments today')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: todayAppointments.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(todayAppointments[index]);
                  },
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

  void _navigateToProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile management coming soon!')),
    );
  }
}
