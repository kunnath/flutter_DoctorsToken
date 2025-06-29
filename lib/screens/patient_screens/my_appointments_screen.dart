import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../database_helper.dart';
import '../../models/appointment_model.dart';
import '../../models/doctor_model.dart';
import '../../models/hospital_model.dart';

class MyAppointmentsScreen extends StatefulWidget {
  final int patientId;

  const MyAppointmentsScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  _MyAppointmentsScreenState createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late TabController _tabController;
  
  List<AppointmentModel> _allAppointments = [];
  List<AppointmentModel> _upcomingAppointments = [];
  List<AppointmentModel> _pastAppointments = [];
  Map<int, DoctorModel> _doctors = {};
  Map<int, HospitalModel> _hospitals = {};
  
  bool _isLoading = true;
  String _searchQuery = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _loadAppointments();
    }
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadAppointments();
    });
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      final appointments = await _databaseHelper.getPatientAppointments(widget.patientId);
      
      // Load related data
      final Set<int> doctorIds = appointments.map((a) => a.doctorId).toSet();
      final Set<int> hospitalIds = appointments.map((a) => a.hospitalId).toSet();
      
      final doctors = <int, DoctorModel>{};
      final hospitals = <int, HospitalModel>{};
      
      for (int doctorId in doctorIds) {
        final doctor = await _databaseHelper.getDoctorById(doctorId);
        if (doctor != null) doctors[doctorId] = doctor;
      }
      
      for (int hospitalId in hospitalIds) {
        final hospital = await _databaseHelper.getHospitalById(hospitalId);
        if (hospital != null) hospitals[hospitalId] = hospital;
      }
      
      final now = DateTime.now();
      final upcoming = appointments.where((a) => 
        a.appointmentDate.isAfter(now) || 
        (a.appointmentDate.day == now.day && 
         a.appointmentDate.month == now.month && 
         a.appointmentDate.year == now.year)
      ).toList();
      
      final past = appointments.where((a) => 
        a.appointmentDate.isBefore(now) && 
        !(a.appointmentDate.day == now.day && 
          a.appointmentDate.month == now.month && 
          a.appointmentDate.year == now.year)
      ).toList();
      
      setState(() {
        _allAppointments = appointments;
        _upcomingAppointments = upcoming;
        _pastAppointments = past;
        _doctors = doctors;
        _hospitals = hospitals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load appointments: $e');
    }
  }

  Future<void> _cancelAppointment(AppointmentModel appointment) async {
    final confirmed = await _showConfirmationDialog(
      'Cancel AppointmentModel',
      'Are you sure you want to cancel this appointment? This action cannot be undone.',
    );
    
    if (confirmed) {
      try {
        await _databaseHelper.updateAppointmentStatus(appointment.id!, 'cancelled');
        
        // Create notification for doctor
        await _databaseHelper.createNotification(
          _doctors[appointment.doctorId]?.userId ?? 0,
          'AppointmentModel Cancelled',
          'Patient has cancelled appointment for ${_formatDate(appointment.appointmentDate)} at ${appointment.timeSlot}',
          'appointment_cancelled',
          appointment.id,
        );
        
        _loadAppointments();
        _showSuccessSnackBar('AppointmentModel cancelled successfully');
      } catch (e) {
        _showErrorSnackBar('Failed to cancel appointment: $e');
      }
    }
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'All (${_allAppointments.length})'),
            Tab(text: 'Upcoming (${_upcomingAppointments.length})'),
            Tab(text: 'Past (${_pastAppointments.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search appointments...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase());
                    },
                  ),
                ),
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAppointmentsList(_getFilteredAppointments(_allAppointments)),
                      _buildAppointmentsList(_getFilteredAppointments(_upcomingAppointments)),
                      _buildAppointmentsList(_getFilteredAppointments(_pastAppointments)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  List<AppointmentModel> _getFilteredAppointments(List<AppointmentModel> appointments) {
    if (_searchQuery.isEmpty) return appointments;
    
    return appointments.where((appointment) {
      final doctor = _doctors[appointment.doctorId];
      final hospital = _hospitals[appointment.hospitalId];
      
      return doctor?.fullName.toLowerCase().contains(_searchQuery) == true ||
             doctor?.specialization.toLowerCase().contains(_searchQuery) == true ||
             hospital?.name.toLowerCase().contains(_searchQuery) == true ||
             appointment.reason.toLowerCase().contains(_searchQuery) ||
             appointment.status.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search criteria',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) => _buildAppointmentCard(appointments[index]),
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    final doctor = _doctors[appointment.doctorId];
    final hospital = _hospitals[appointment.hospitalId];
    final isUpcoming = appointment.appointmentDate.isAfter(DateTime.now()) ||
        (appointment.appointmentDate.day == DateTime.now().day &&
         appointment.appointmentDate.month == DateTime.now().month &&
         appointment.appointmentDate.year == DateTime.now().year);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Token: ${appointment.token}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                _buildStatusChip(appointment.status),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // DoctorModel and HospitalModel Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    doctor?.fullName.substring(0, 1).toUpperCase() ?? 'D',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${doctor?.fullName ?? 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '🩺 ${doctor?.specialization ?? 'General'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '🏥 ${hospital?.name ?? 'Unknown HospitalModel'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // AppointmentModel Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetailRow('📅 Date', _formatDate(appointment.appointmentDate)),
                  _buildDetailRow('⏰ Time', appointment.timeSlot),
                  _buildDetailRow('🩺 Reason', appointment.reason),
                  if (appointment.notes?.isNotEmpty == true)
                    _buildDetailRow('📝 Notes', appointment.notes!),
                  if (appointment.prescription?.isNotEmpty == true)
                    _buildDetailRow('💊 Prescription', appointment.prescription!),
                  if (appointment.followUpNotes?.isNotEmpty == true)
                    _buildDetailRow('📋 Follow-up', appointment.followUpNotes!),
                ],
              ),
            ),
            
            // Action Buttons
            if (isUpcoming && appointment.status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelAppointment(appointment),
                      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                      label: const Text('Cancel', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAppointmentDetails(appointment),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (appointment.status == 'approved' && isUpcoming) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAppointmentDetails(appointment),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
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
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'completed':
        color = Colors.blue;
        icon = Icons.done_all;
        break;
      case 'cancelled':
        color = Colors.grey;
        icon = Icons.block;
        break;
      default:
        color = Colors.grey;
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
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(AppointmentModel appointment) {
    final doctor = _doctors[appointment.doctorId];
    final hospital = _hospitals[appointment.hospitalId];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AppointmentModel Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Token', appointment.token ?? 'N/A'),
              _buildDetailRow('DoctorModel', 'Dr. ${doctor?.fullName ?? 'Unknown'}'),
              _buildDetailRow('Specialization', doctor?.specialization ?? 'General'),
              _buildDetailRow('HospitalModel', hospital?.name ?? 'Unknown'),
              _buildDetailRow('Date', _formatDate(appointment.appointmentDate)),
              _buildDetailRow('Time', appointment.timeSlot),
              _buildDetailRow('Status', appointment.status.toUpperCase()),
              _buildDetailRow('Reason', appointment.reason),
              if (appointment.notes?.isNotEmpty == true)
                _buildDetailRow('Notes', appointment.notes!),
              if (appointment.prescription?.isNotEmpty == true)
                _buildDetailRow('Prescription', appointment.prescription!),
              if (appointment.followUpNotes?.isNotEmpty == true)
                _buildDetailRow('Follow-up Notes', appointment.followUpNotes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
