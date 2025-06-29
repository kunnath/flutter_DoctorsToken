import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../database_helper.dart';
import '../../models/doctor_model.dart';
import '../../models/hospital_model.dart';
import '../../models/appointment_model.dart';
import 'appointment_confirmation_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  final int patientId;

  const BookAppointmentScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  List<DoctorModel> _doctors = [];
  List<HospitalModel> _hospitals = [];
  String _searchType = 'doctor'; // doctor, hospital, specialization
  String _selectedSpecialization = '';
  DoctorModel? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isLoading = false;

  final List<String> _specializations = [
    'Cardiology',
    'Dermatology',
    'Gastroenterology',
    'General Medicine',
    'Gynecology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Radiology',
    'Surgery',
    'Urology'
  ];

  final List<String> _timeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
    '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
    '05:00 PM', '05:30 PM'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final doctorMaps = await _databaseHelper.getAllDoctors();
      final hospitalMaps = await _databaseHelper.getAllHospitals();
      setState(() {
        _doctors = doctorMaps.map((map) => DoctorModel.fromMap(map)).toList();
        _hospitals = hospitalMaps.map((map) => HospitalModel.fromMap(map)).toList();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchDoctors() async {
    if (_searchController.text.trim().isEmpty && _selectedSpecialization.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      List<DoctorModel> results = [];
      
      if (_searchType == 'doctor') {
        results = await _databaseHelper.searchDoctorsByName(_searchController.text.trim());
      } else if (_searchType == 'hospital') {
        results = await _databaseHelper.searchDoctorsByHospital(_searchController.text.trim());
      } else if (_searchType == 'specialization') {
        results = await _databaseHelper.searchDoctorsBySpecialization(_selectedSpecialization);
      }
      
      setState(() => _doctors = results);
    } catch (e) {
      _showErrorSnackBar('Search failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _bookAppointmentModel() async {
    if (_selectedDoctor == null || _selectedDate == null || _selectedTimeSlot == null) {
      _showErrorSnackBar('Please fill all required fields');
      return;
    }

    if (_reasonController.text.trim().length < 10) {
      _showErrorSnackBar('Reason for visit must be at least 10 characters');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Generate unique appointment token
      final token = 'APT-${DateTime.now().millisecondsSinceEpoch}';
      
      final appointment = AppointmentModel(
        patientId: widget.patientId,
        doctorId: _selectedDoctor!.id,
        hospitalId: _selectedDoctor!.hospitalId,
        appointmentDate: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        reason: _reasonController.text.trim(),
        notes: _notesController.text.trim(),
        status: 'pending',
        token: token,
        createdAt: DateTime.now(),
      );

      final appointmentId = await _databaseHelper.createAppointment(appointment);
      
      // Create notification for doctor
      await _databaseHelper.createNotification(
        _selectedDoctor!.userId,
        'New AppointmentModel Request',
        'New appointment request from patient. Token: $token',
        'appointment_request',
        appointmentId,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentConfirmationScreen(
            appointmentToken: token,
            patientId: widget.patientId,
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to book appointment: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book AppointmentModel'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchSection(),
                  const SizedBox(height: 20),
                  _buildDoctorsList(),
                  if (_selectedDoctor != null) ...[
                    const SizedBox(height: 20),
                    _buildAppointmentDetailsSection(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find Your DoctorModel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _searchType,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'doctor', child: Text('🔍 DoctorModel Name')),
                      DropdownMenuItem(value: 'hospital', child: Text('🏥 HospitalModel')),
                      DropdownMenuItem(value: 'specialization', child: Text('🩺 Specialization')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _searchType = value!;
                        _searchController.clear();
                        _selectedSpecialization = '';
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_searchType == 'specialization')
              DropdownButton<String>(
                value: _selectedSpecialization.isEmpty ? null : _selectedSpecialization,
                isExpanded: true,
                hint: const Text('Select Specialization'),
                items: _specializations.map((spec) {
                  return DropdownMenuItem(value: spec, child: Text(spec));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSpecialization = value!);
                  _searchDoctors();
                },
              )
            else
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: _searchType == 'doctor' 
                      ? 'Enter doctor name' 
                      : 'Enter hospital name',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchDoctors,
                  ),
                ),
                onSubmitted: (_) => _searchDoctors(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorsList() {
    if (_doctors.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No doctors found. Try a different search.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Doctors (${_doctors.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _doctors.length,
          itemBuilder: (context, index) {
            final doctor = _doctors[index];
            final isSelected = _selectedDoctor?.id == doctor.id;
            
            return Card(
              color: isSelected ? Colors.blue[50] : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(doctor.fullName.substring(0, 1).toUpperCase()),
                ),
                title: Text(
                  doctor.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🩺 ${doctor.specialization}'),
                    Text('🏥 HospitalModel ID: ${doctor.hospitalId}'),
                    Text('💰 Fee: \$${doctor.consultationFee}'),
                    Text('⏰ Available: ${doctor.availableHours}'),
                  ],
                ),
                trailing: isSelected 
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.radio_button_unchecked),
                onTap: () {
                  setState(() {
                    _selectedDoctor = doctor;
                    _selectedDate = null;
                    _selectedTimeSlot = null;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppointmentDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AppointmentModel Details for Dr. ${_selectedDoctor!.fullName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Date Selection
            const Text('Select Date:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(_selectedDate == null 
                        ? 'Choose appointment date' 
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                  ],
                ),
              ),
            ),
            
            if (_selectedDate != null) ...[
              const SizedBox(height: 16),
              const Text('Select Time Slot:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return ChoiceChip(
                    label: Text(slot),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedTimeSlot = selected ? slot : null);
                    },
                  );
                }).toList(),
              ),
            ],
            
            if (_selectedTimeSlot != null) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason for Visit *',
                  hintText: 'Describe your symptoms or reason for consultation (min 10 characters)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  hintText: 'Any additional information for the doctor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _bookAppointmentModel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Book AppointmentModel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now.add(const Duration(days: 1));
    final DateTime lastDate = now.add(const Duration(days: 30));
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (DateTime day) {
        // Don't allow Sundays
        return day.weekday != DateTime.sunday;
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null; // Reset time selection
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
