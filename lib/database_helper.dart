import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'models/appointment_model.dart';
import 'models/doctor_model.dart';
import 'models/hospital_model.dart';
import 'services/email_service.dart';
import 'services/location_service.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'healthcare_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table (patients, doctors, admins)
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        full_name TEXT NOT NULL,
        phone TEXT,
        role TEXT NOT NULL CHECK(role IN ('patient', 'doctor', 'admin')),
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Doctors table (additional doctor information)
    await db.execute('''
      CREATE TABLE doctors(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        full_name TEXT NOT NULL,
        license_number TEXT UNIQUE NOT NULL,
        specialization TEXT NOT NULL,
        hospital_id INTEGER,
        experience_years INTEGER DEFAULT 0,
        consultation_fee REAL DEFAULT 0,
        qualifications TEXT,
        biography TEXT,
        available_days TEXT,
        available_hours TEXT,
        rating REAL DEFAULT 0,
        total_ratings INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        is_verified INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (hospital_id) REFERENCES hospitals (id)
      )
    ''');

    // Hospitals table
    await db.execute('''
      CREATE TABLE hospitals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        city TEXT NOT NULL,
        state TEXT NOT NULL,
        postal_code TEXT,
        phone TEXT,
        email TEXT,
        latitude REAL,
        longitude REAL,
        facilities TEXT,
        operating_hours TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Appointments table
    await db.execute('''
      CREATE TABLE appointments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        doctor_id INTEGER NOT NULL,
        hospital_id INTEGER NOT NULL,
        appointment_date TEXT NOT NULL,
        time_slot TEXT NOT NULL,
        status TEXT NOT NULL CHECK(status IN ('pending', 'approved', 'scheduled', 'confirmed', 'completed', 'cancelled', 'no_show')),
        reason TEXT NOT NULL,
        notes TEXT,
        token TEXT UNIQUE,
        rating REAL,
        feedback TEXT,
        prescription TEXT,
        follow_up_notes TEXT,
        is_location_verified INTEGER DEFAULT 0,
        patient_latitude REAL,
        patient_longitude REAL,
        verification_time TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES users (id),
        FOREIGN KEY (doctor_id) REFERENCES doctors (id),
        FOREIGN KEY (hospital_id) REFERENCES hospitals (id)
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        related_id INTEGER,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Patients table (additional patient information)
    await db.execute('''
      CREATE TABLE patients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        emergency_contact TEXT,
        blood_group TEXT,
        allergies TEXT,
        medical_history TEXT,
        insurance_details TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Ratings table
    await db.execute('''
      CREATE TABLE ratings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appointment_id INTEGER NOT NULL,
        patient_id INTEGER NOT NULL,
        doctor_id INTEGER NOT NULL,
        rating INTEGER NOT NULL CHECK(rating >= 1 AND rating <= 5),
        review TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (appointment_id) REFERENCES appointments (id),
        FOREIGN KEY (patient_id) REFERENCES users (id),
        FOREIGN KEY (doctor_id) REFERENCES doctors (id)
      )
    ''');

    // Insert default data
    await _insertDefaultData(db);
  }

  Future<void> _insertDefaultData(Database db) async {
    // Insert default hospitals
    await db.insert('hospitals', {
      'name': 'City General Hospital',
      'address': '123 Main Street',
      'city': 'New York',
      'state': 'NY',
      'postal_code': '10001',
      'phone': '+1-555-0123',
      'email': 'info@citygeneral.com',
      'latitude': 40.7128,
      'longitude': -74.0060,
      'facilities': 'Emergency Care, Surgery, Cardiology',
      'operating_hours': '24/7 Emergency, Regular: 8:00 AM - 6:00 PM',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('hospitals', {
      'name': 'Metropolitan Medical Center',
      'address': '456 Oak Avenue',
      'city': 'Los Angeles',
      'state': 'CA',
      'postal_code': '90001',
      'phone': '+1-555-0456',
      'email': 'contact@metromedical.com',
      'latitude': 34.0522,
      'longitude': -118.2437,
      'facilities': 'General Practice, Orthopedics, Pediatrics',
      'operating_hours': 'Mon-Fri: 7:00 AM - 9:00 PM, Sat: 8:00 AM - 5:00 PM',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert default admin user
    await db.insert('users', {
      'email': 'admin@healthcare.com',
      'password': _hashPassword('admin123'),
      'full_name': 'System Administrator',
      'phone': '+1-555-0001',
      'role': 'admin',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert default doctor user
    int doctorUserId = await db.insert('users', {
      'email': 'dr.smith@healthcare.com',
      'password': _hashPassword('doctor123'),
      'full_name': 'Dr. John Smith',
      'phone': '+1-555-0002',
      'role': 'doctor',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert doctor profile
    await db.insert('doctors', {
      'user_id': doctorUserId,
      'full_name': 'Dr. John Smith',
      'license_number': 'MD123456',
      'specialization': 'Cardiology',
      'hospital_id': 1,
      'experience_years': 10,
      'consultation_fee': 150.0,
      'biography': 'Experienced cardiologist with 10 years of practice.',
      'available_days': 'Monday,Tuesday,Wednesday,Thursday,Friday',
      'available_hours': '09:00-17:00',
      'is_verified': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert default patient user
    await db.insert('users', {
      'email': 'patient@test.com',
      'password': _hashPassword('patient123'),
      'full_name': 'John Doe',
      'phone': '+1-555-0003',
      'role': 'patient',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Authentication methods
  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    final db = await database;
    String hashedPassword = _hashPassword(password);
    
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND password = ? AND is_active = 1',
      whereArgs: [email, hashedPassword],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<bool> registerUser(String email, String password, String fullName, String phone, String role) async {
    try {
      final db = await database;
      String hashedPassword = _hashPassword(password);
      
      await db.insert('users', {
        'email': email,
        'password': hashedPassword,
        'full_name': fullName,
        'phone': phone,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Create user from User object (for demo data)
  Future<int> createUser(Map<String, dynamic> userMap) async {
    try {
      final db = await database;
      
      // Hash the password if it's not already hashed
      if (userMap['password'] != null && !userMap['password'].startsWith('\$2b\$')) {
        userMap['password'] = _hashPassword(userMap['password']);
      }
      
      // Ensure created_at is set
      if (userMap['created_at'] == null) {
        userMap['created_at'] = DateTime.now().toIso8601String();
      }
      
      return await db.insert('users', userMap);
    } catch (e) {
      print('Error creating user: $e');
      return -1;
    }
  }

  // DoctorModel methods
  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT d.*, u.full_name, u.email, u.phone, h.name as hospital_name, h.address, h.city
      FROM doctors d
      JOIN users u ON d.user_id = u.id
      LEFT JOIN hospitals h ON d.hospital_id = h.id
      WHERE u.is_active = 1 AND d.is_verified = 1
      ORDER BY d.rating DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> searchDoctors(String query) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT d.*, u.full_name, u.email, u.phone, h.name as hospital_name, h.address, h.city
      FROM doctors d
      JOIN users u ON d.user_id = u.id
      LEFT JOIN hospitals h ON d.hospital_id = h.id
      WHERE u.is_active = 1 AND d.is_verified = 1
      AND (u.full_name LIKE ? OR d.specialization LIKE ? OR h.name LIKE ?)
      ORDER BY d.rating DESC
    ''', ['%$query%', '%$query%', '%$query%']);
  }

  // AppointmentModel methods
  Future<String> bookAppointment(Map<String, dynamic> appointmentData) async {
    final db = await database;
    String token = _generateToken();
    
    appointmentData['token'] = token;
    appointmentData['created_at'] = DateTime.now().toIso8601String();
    
    await db.insert('appointments', appointmentData);
    return token;
  }

  Future<List<Map<String, dynamic>>> getAppointmentsByPatient(int patientId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT a.*, u.full_name as doctor_name, d.specialization, h.name as hospital_name, h.address
      FROM appointments a
      JOIN doctors d ON a.doctor_id = d.id
      JOIN users u ON d.user_id = u.id
      JOIN hospitals h ON a.hospital_id = h.id
      WHERE a.patient_id = ?
      ORDER BY a.appointment_date DESC, a.appointment_time DESC
    ''', [patientId]);
  }

  Future<List<Map<String, dynamic>>> getAppointmentsByDoctor(int doctorId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT a.*, u.full_name as patient_name, u.phone as patient_phone
      FROM appointments a
      JOIN users u ON a.patient_id = u.id
      WHERE a.doctor_id = ? AND a.status != 'cancelled'
      ORDER BY a.appointment_date ASC, a.appointment_time ASC
    ''', [doctorId]);
  }

  Future<void> updateAppointmentStatus(int appointmentId, String status, {String? doctorNotes}) async {
    final db = await database;
    Map<String, dynamic> updateData = {
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    if (doctorNotes != null) {
      updateData['doctor_notes'] = doctorNotes;
    }
    
    await db.update(
      'appointments',
      updateData,
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }

  Future<void> verifyLocationForAppointment(int appointmentId, double latitude, double longitude) async {
    final db = await database;
    await db.update(
      'appointments',
      {
        'location_verified': 1,
        'patient_latitude': latitude,
        'patient_longitude': longitude,
        'verification_time': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }

  // HospitalModel methods
  Future<List<Map<String, dynamic>>> getAllHospitals() async {
    final db = await database;
    return await db.query('hospitals', orderBy: 'name ASC');
  }

  // Analytics methods
  Future<Map<String, dynamic>> getSystemAnalytics() async {
    final db = await database;
    
    // Get user counts by role
    List<Map<String, dynamic>> userCounts = await db.rawQuery('''
      SELECT role, COUNT(*) as count
      FROM users
      WHERE is_active = 1
      GROUP BY role
    ''');
    
    // Get appointment statistics
    List<Map<String, dynamic>> appointmentStats = await db.rawQuery('''
      SELECT status, COUNT(*) as count
      FROM appointments
      GROUP BY status
    ''');
    
    // Get total appointments today
    String today = DateTime.now().toIso8601String().split('T')[0];
    List<Map<String, dynamic>> todayAppointments = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM appointments
      WHERE appointment_date = ?
    ''', [today]);
    
    return {
      'user_counts': userCounts,
      'appointment_stats': appointmentStats,
      'today_appointments': todayAppointments.first['count'],
    };
  }

  // Utility methods
  String _generateToken() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (DateTime.now().microsecond % 1000).toString().padLeft(3, '0');
  }

  Future<bool> userExists(String email) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'created_at DESC');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }

  // Enhanced Patient Experience Methods
  
  // Smart DoctorModel Search with advanced filtering
  Future<List<DoctorModel>> searchDoctorsAdvanced({
    String? name,
    String? specialization,
    String? hospital,
    double? minRating,
    double? maxFee,
    String? city,
    List<String>? availableDays,
  }) async {
    final db = await database;
    String whereClause = 'doctors.is_active = 1';
    List<dynamic> whereArgs = [];

    if (name != null && name.isNotEmpty) {
      whereClause += ' AND users.full_name LIKE ?';
      whereArgs.add('%$name%');
    }

    if (specialization != null && specialization.isNotEmpty) {
      whereClause += ' AND doctors.specialization LIKE ?';
      whereArgs.add('%$specialization%');
    }

    if (hospital != null && hospital.isNotEmpty) {
      whereClause += ' AND hospitals.name LIKE ?';
      whereArgs.add('%$hospital%');
    }

    if (minRating != null) {
      whereClause += ' AND doctors.rating >= ?';
      whereArgs.add(minRating);
    }

    if (maxFee != null) {
      whereClause += ' AND doctors.consultation_fee <= ?';
      whereArgs.add(maxFee);
    }

    if (city != null && city.isNotEmpty) {
      whereClause += ' AND hospitals.city LIKE ?';
      whereArgs.add('%$city%');
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT doctors.*, users.full_name, users.email, users.phone, hospitals.name as hospital_name
      FROM doctors
      JOIN users ON doctors.user_id = users.id
      LEFT JOIN hospitals ON doctors.hospital_id = hospitals.id
      WHERE $whereClause
      ORDER BY doctors.rating DESC, doctors.total_ratings DESC
    ''', whereArgs);

    return List.generate(maps.length, (i) {
      return DoctorModel.fromMap(maps[i]);
    });
  }

  // Real-time availability check
  Future<Map<String, List<String>>> getDoctorAvailability(int doctorId, DateTime startDate, DateTime endDate) async {
    final db = await database;
    
    // Get doctor's available days and hours
    final doctor = await getDoctorById(doctorId);
    if (doctor == null) return {};
    
    // Get existing appointments for the date range
    final appointments = await db.query(
      'appointments',
      where: 'doctor_id = ? AND appointment_date BETWEEN ? AND ? AND status != ?',
      whereArgs: [doctorId, startDate.toIso8601String(), endDate.toIso8601String(), 'cancelled'],
    );

    // Parse available slots (simplified logic)
    Map<String, List<String>> availability = {};
    
    for (int i = 0; i < endDate.difference(startDate).inDays; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      String dateKey = currentDate.toIso8601String().split('T')[0];
      
      // Skip Sundays
      if (currentDate.weekday == DateTime.sunday) continue;
      
      // Default time slots
      List<String> availableSlots = [
        '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
        '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
        '05:00 PM', '05:30 PM'
      ];
      
      // Remove booked slots
      for (var appointment in appointments) {
        String? appointmentDateStr = appointment['appointment_date']?.toString();
        if (appointmentDateStr != null) {
          DateTime appointmentDate = DateTime.parse(appointmentDateStr);
          if (appointmentDate.day == currentDate.day && 
              appointmentDate.month == currentDate.month && 
              appointmentDate.year == currentDate.year) {
            availableSlots.remove(appointment['time_slot']);
          }
        }
      }
      
      availability[dateKey] = availableSlots;
    }
    
    return availability;
  }

  // Enhanced appointment booking with real-time checks
  Future<int> bookAppointmentEnhanced(AppointmentModel appointment) async {
    final db = await database;
    
    // Check slot availability
    final existingAppointment = await db.query(
      'appointments',
      where: 'doctor_id = ? AND appointment_date = ? AND time_slot = ? AND status != ?',
      whereArgs: [appointment.doctorId, appointment.appointmentDate.toIso8601String(), 
                  appointment.timeSlot, 'cancelled'],
    );
    
    if (existingAppointment.isNotEmpty) {
      throw Exception('Time slot is no longer available');
    }
    
    // Create appointment
    final appointmentId = await db.insert('appointments', appointment.toMap());
    
    // Create notification for doctor
    await createNotification(
      appointment.doctorId,
      'New AppointmentModel Request',
      'New appointment request from patient for ${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year} at ${appointment.timeSlot}',
      'appointment_request',
      appointmentId,
    );
    
    // Send email notification to doctor
    try {
      final doctor = await getDoctorById(appointment.doctorId);
      if (doctor != null) {
        await EmailService.sendAppointmentRequest(doctor.userId, appointment);
      }
    } catch (e) {
      print('Failed to send email notification: $e');
    }
    
    return appointmentId;
  }

  // GPS Location Verification
  Future<bool> verifyPatientLocation(int appointmentId, double patientLat, double patientLng) async {
    final db = await database;
    
    // Get appointment details
    final appointment = await getAppointmentById(appointmentId);
    if (appointment == null) return false;
    
    // Get hospital location
    final hospital = await getHospitalById(appointment.hospitalId);
    if (hospital == null) return false;
    
    // Calculate distance
    final distance = LocationService.calculateDistance(
      patientLat, patientLng, 
      hospital.latitude, hospital.longitude
    );
    
    // Check if within 500 meters
    const maxDistance = 0.5; // 500 meters
    bool isWithinRange = distance <= maxDistance;
    
    if (!isWithinRange) {
      // Auto-cancel appointment if too far
      await updateAppointmentStatus(appointmentId, 'cancelled');
      
      // Create notification
      await createNotification(
        appointment.patientId,
        'AppointmentModel Cancelled',
        'Your appointment has been automatically cancelled due to location verification failure. You were ${distance.toStringAsFixed(2)}km away from the hospital.',
        'appointment_cancelled',
        appointmentId,
      );
      
      // Send email notification
      try {
        await EmailService.sendLocationVerificationFailed(appointment.patientId, appointment, distance);
      } catch (e) {
        print('Failed to send email notification: $e');
      }
    } else {
      // Update appointment with location verification
      await db.update(
        'appointments',
        {'location_verified': 1, 'location_verified_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [appointmentId],
      );
    }
    
    return isWithinRange;
  }

  // Enhanced appointment status updates with notifications
  Future<void> updateAppointmentStatusEnhanced(int appointmentId, String newStatus, {String? notes}) async {
    final db = await database;
    
    final appointment = await getAppointmentById(appointmentId);
    if (appointment == null) return;
    
    // Update appointment
    Map<String, dynamic> updateData = {
      'status': newStatus,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    if (notes != null) updateData['doctor_notes'] = notes;
    
    if (newStatus == 'approved') {
      updateData['approved_at'] = DateTime.now().toIso8601String();
    } else if (newStatus == 'completed') {
      updateData['completed_at'] = DateTime.now().toIso8601String();
    }
    
    await db.update(
      'appointments',
      updateData,
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
    
    // Create notification for patient
    String notificationTitle = 'AppointmentModel ${newStatus.toUpperCase()}';
    String notificationMessage = _getStatusChangeMessage(newStatus, appointment.token ?? 'N/A');
    
    await createNotification(
      appointment.patientId,
      notificationTitle,
      notificationMessage,
      'appointment_status_change',
      appointmentId,
    );
    
    // Send email notification
    try {
      await EmailService.sendAppointmentStatusUpdate(appointment.patientId, appointment, newStatus, notes);
    } catch (e) {
      print('Failed to send email notification: $e');
    }
  }

  String _getStatusChangeMessage(String status, String token) {
    switch (status) {
      case 'approved':
        return 'Your appointment (Token: $token) has been approved by the doctor. Please arrive 15 minutes before your scheduled time.';
      case 'rejected':
        return 'Your appointment (Token: $token) has been rejected by the doctor. Please book a new appointment or contact the hospital.';
      case 'completed':
        return 'Your appointment (Token: $token) has been completed. Thank you for visiting us!';
      case 'cancelled':
        return 'Your appointment (Token: $token) has been cancelled.';
      default:
        return 'Your appointment (Token: $token) status has been updated to $status.';
    }
  }

  // Patient appointment history with enhanced filtering
  Future<List<AppointmentModel>> getPatientAppointmentsEnhanced(int patientId, {
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? doctorName,
    String? specialization,
  }) async {
    final db = await database;
    
    String whereClause = 'appointments.patient_id = ?';
    List<dynamic> whereArgs = [patientId];
    
    if (status != null) {
      whereClause += ' AND appointments.status = ?';
      whereArgs.add(status);
    }
    
    if (startDate != null) {
      whereClause += ' AND appointments.appointment_date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClause += ' AND appointments.appointment_date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    if (doctorName != null && doctorName.isNotEmpty) {
      whereClause += ' AND users.full_name LIKE ?';
      whereArgs.add('%$doctorName%');
    }
    
    if (specialization != null && specialization.isNotEmpty) {
      whereClause += ' AND doctors.specialization LIKE ?';
      whereArgs.add('%$specialization%');
    }
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT appointments.*, users.full_name as doctor_name, doctors.specialization
      FROM appointments
      JOIN doctors ON appointments.doctor_id = doctors.id
      JOIN users ON doctors.user_id = users.id
      WHERE $whereClause
      ORDER BY appointments.appointment_date DESC, appointments.time_slot DESC
    ''', whereArgs);
    
    return List.generate(maps.length, (i) {
      return AppointmentModel.fromMap(maps[i]);
    });
  }

  // Token-based appointment retrieval
  Future<AppointmentModel?> getAppointmentByTokenEnhanced(String token) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT appointments.*, 
             users.full_name as doctor_name, 
             users.email as doctor_email,
             doctors.specialization,
             hospitals.name as hospital_name,
             hospitals.address as hospital_address,
             hospitals.latitude as hospital_latitude,
             hospitals.longitude as hospital_longitude
      FROM appointments
      JOIN doctors ON appointments.doctor_id = doctors.id
      JOIN users ON doctors.user_id = users.id
      JOIN hospitals ON appointments.hospital_id = hospitals.id
      WHERE appointments.token = ?
    ''', [token]);
    
    if (maps.isNotEmpty) {
      return AppointmentModel.fromMap(maps.first);
    }
    return null;
  }

  // AppointmentModel reminder system
  Future<List<AppointmentModel>> getAppointmentsForReminders() async {
    final db = await database;
    final DateTime now = DateTime.now();
    final DateTime oneHourLater = now.add(Duration(hours: 1));
    final DateTime fifteenMinutesLater = now.add(Duration(minutes: 15));
    
    // Get appointments that need reminders (1 hour and 15 minutes before)
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT appointments.*, users.email as patient_email, users.full_name as patient_name
      FROM appointments
      JOIN users ON appointments.patient_id = users.id
      WHERE appointments.status = 'approved' 
      AND appointments.appointment_date BETWEEN ? AND ?
      AND (appointments.reminder_1h_sent = 0 OR appointments.reminder_15m_sent = 0)
    ''', [now.toIso8601String(), oneHourLater.toIso8601String()]);
    
    return List.generate(maps.length, (i) {
      return AppointmentModel.fromMap(maps[i]);
    });
  }

  // Mark reminder as sent
  Future<void> markReminderSent(int appointmentId, String reminderType) async {
    final db = await database;
    String column = reminderType == '1h' ? 'reminder_1h_sent' : 'reminder_15m_sent';
    
    await db.update(
      'appointments',
      {column: 1},
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }

  // Get appointment statistics for patient
  Future<Map<String, int>> getPatientAppointmentStats(int patientId) async {
    final db = await database;
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
        SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled
      FROM appointments
      WHERE patient_id = ?
    ''', [patientId]);
    
    if (result.isNotEmpty) {
      return {
        'total': result.first['total'] as int,
        'pending': result.first['pending'] as int,
        'approved': result.first['approved'] as int,
        'completed': result.first['completed'] as int,
        'cancelled': result.first['cancelled'] as int,
      };
    }
    
    return {'total': 0, 'pending': 0, 'approved': 0, 'completed': 0, 'cancelled': 0};
  }

  // Helper methods that were missing
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<DoctorModel?> getDoctorById(int doctorId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT doctors.*, users.full_name, users.email, users.phone
      FROM doctors
      JOIN users ON doctors.user_id = users.id
      WHERE doctors.id = ?
    ''', [doctorId]);
    
    if (maps.isNotEmpty) {
      return DoctorModel.fromMap(maps.first);
    }
    return null;
  }

  Future<HospitalModel?> getHospitalById(int hospitalId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'hospitals',
      where: 'id = ?',
      whereArgs: [hospitalId],
    );
    
    if (maps.isNotEmpty) {
      return HospitalModel.fromMap(maps.first);
    }
    return null;
  }

  Future<AppointmentModel?> getAppointmentById(int appointmentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
    
    if (maps.isNotEmpty) {
      return AppointmentModel.fromMap(maps.first);
    }
    return null;
  }

  Future<AppointmentModel?> getAppointmentByToken(String token) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'token = ?',
      whereArgs: [token],
    );
    
    if (maps.isNotEmpty) {
      return AppointmentModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> createNotification(int userId, String title, String message, String type, int? relatedId) async {
    final db = await database;
    return await db.insert('notifications', {
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'related_id': relatedId,
      'is_read': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> createAppointment(AppointmentModel appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment.toMap());
  }

  Future<List<DoctorModel>> searchDoctorsByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT doctors.*, users.full_name, users.email, users.phone
      FROM doctors
      JOIN users ON doctors.user_id = users.id
      WHERE users.full_name LIKE ? AND doctors.is_active = 1
    ''', ['%$name%']);
    
    return List.generate(maps.length, (i) {
      return DoctorModel.fromMap(maps[i]);
    });
  }

  Future<List<DoctorModel>> searchDoctorsByHospital(String hospitalName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT doctors.*, users.full_name, users.email, users.phone
      FROM doctors
      JOIN users ON doctors.user_id = users.id
      JOIN hospitals ON doctors.hospital_id = hospitals.id
      WHERE hospitals.name LIKE ? AND doctors.is_active = 1
    ''', ['%$hospitalName%']);
    
    return List.generate(maps.length, (i) {
      return DoctorModel.fromMap(maps[i]);
    });
  }

  Future<List<DoctorModel>> searchDoctorsBySpecialization(String specialization) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT doctors.*, users.full_name, users.email, users.phone
      FROM doctors
      JOIN users ON doctors.user_id = users.id
      WHERE doctors.specialization LIKE ? AND doctors.is_active = 1
    ''', ['%$specialization%']);
    
    return List.generate(maps.length, (i) {
      return DoctorModel.fromMap(maps[i]);
    });
  }

  Future<List<AppointmentModel>> getPatientAppointments(int patientId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'appointment_date DESC, time_slot DESC',
    );
    
    return List.generate(maps.length, (i) {
      return AppointmentModel.fromMap(maps[i]);
    });
  }

  Future<List<AppointmentModel>> getOverdueAppointments() async {
    final db = await database;
    final now = DateTime.now();
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'status = ? AND appointment_date < ?',
      whereArgs: ['approved', now.toIso8601String()],
    );
    
    return List.generate(maps.length, (i) {
      return AppointmentModel.fromMap(maps[i]);
    });
  }

  Future<List<AppointmentModel>> getTodaysApprovedAppointments() async {
    final db = await database;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'status = ? AND appointment_date >= ? AND appointment_date < ?',
      whereArgs: ['approved', todayStart.toIso8601String(), todayEnd.toIso8601String()],
    );
    
    return List.generate(maps.length, (i) {
      return AppointmentModel.fromMap(maps[i]);
    });
  }
}
