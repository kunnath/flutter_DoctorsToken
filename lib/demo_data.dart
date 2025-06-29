import 'database_helper.dart';
import 'models/doctor_model.dart' as doctor_models;
import 'models/hospital_model.dart' as hospital_models;
import 'user_model.dart';

class DemoData {
  static final DatabaseHelper _db = DatabaseHelper();

  static Future<void> populateDemoData() async {
    print('Starting to populate demo data...');
    
    try {
      // Clear existing data first
      await _clearExistingData();
      
      // Insert demo data in proper order
      await _insertDemoHospitals();
      await _insertDemoUsers();
      await _insertDemoDoctors();
      await _insertDemoPatients();
      
      print('Demo data populated successfully!');
    } catch (e) {
      print('Error populating demo data: $e');
      rethrow;
    }
  }

  static Future<void> _clearExistingData() async {
    final db = await _db.database;
    await db.delete('appointments');
    await db.delete('notifications');
    await db.delete('doctors');
    await db.delete('users');
    await db.delete('hospitals');
    print('Existing data cleared');
  }

  static Future<void> _insertDemoHospitals() async {
    final hospitals = [
      hospital_models.HospitalModel(
        id: 1,
        name: 'City General Hospital',
        address: '123 Main Street',
        city: 'San Francisco',
        state: 'California',
        pinCode: '94102',
        phoneNumber: '+1-415-555-0001',
        email: 'info@citygeneralhospital.com',
        latitude: 37.7749,
        longitude: -122.4194,
        facilities: 'Emergency Care, Surgery, Cardiology, Pediatrics, ICU, Laboratory',
        operatingHours: '24/7 Emergency, Regular: 6:00 AM - 10:00 PM',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      hospital_models.HospitalModel(
        id: 2,
        name: 'St. Mary Medical Center',
        address: '456 Oak Avenue',
        city: 'Los Angeles',
        state: 'California',
        pinCode: '90210',
        phoneNumber: '+1-213-555-0002',
        email: 'contact@stmarymedical.com',
        latitude: 34.0522,
        longitude: -118.2437,
        facilities: 'Oncology, Neurology, Orthopedics, Radiology, Pharmacy',
        operatingHours: '24/7 Emergency, Regular: 7:00 AM - 9:00 PM',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      hospital_models.HospitalModel(
        id: 3,
        name: 'Metro Health Clinic',
        address: '789 Pine Road',
        city: 'San Diego',
        state: 'California',
        pinCode: '92101',
        phoneNumber: '+1-619-555-0003',
        email: 'admin@metrohealthclinic.com',
        latitude: 32.7157,
        longitude: -117.1611,
        facilities: 'General Practice, Dermatology, Gynecology, Dental, Eye Care',
        operatingHours: 'Mon-Fri: 8:00 AM - 6:00 PM, Sat: 9:00 AM - 2:00 PM',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      hospital_models.HospitalModel(
        id: 4,
        name: 'Riverside Specialty Hospital',
        address: '321 River Drive',
        city: 'Sacramento',
        state: 'California',
        pinCode: '95814',
        phoneNumber: '+1-916-555-0004',
        email: 'info@riversidespecialty.com',
        latitude: 38.5816,
        longitude: -121.4944,
        facilities: 'Gastroenterology, Pulmonology, Endocrinology, Rheumatology, Psychiatry',
        operatingHours: 'Mon-Fri: 7:00 AM - 8:00 PM, Sat: 8:00 AM - 4:00 PM',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      hospital_models.HospitalModel(
        id: 5,
        name: 'Coastal Medical Center',
        address: '555 Ocean View Boulevard',
        city: 'Monterey',
        state: 'California',
        pinCode: '93940',
        phoneNumber: '+1-831-555-0005',
        email: 'contact@coastalmedical.com',
        latitude: 36.6002,
        longitude: -121.8947,
        facilities: 'Oncology, Hematology, Nephrology, Urology, Plastic Surgery',
        operatingHours: '24/7 Emergency, Regular: 6:00 AM - 10:00 PM',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    for (var hospital in hospitals) {
      await _db.database.then((db) => db.insert('hospitals', hospital.toMap()));
    }
    print('Demo hospitals inserted: ${hospitals.length}');
  }

  static Future<void> _insertDemoUsers() async {
    final users = [
      // Admin user
      User(
        id: 1,
        fullName: 'System Administrator',
        email: 'admin@healthcare.com',
        phone: '+1-555-ADMIN',
        password: 'admin123', // This will be hashed
        role: 'admin',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      
      // Doctor users
      User(
        id: 2,
        fullName: 'Dr. Sarah Johnson',
        email: 'sarah.johnson@citygeneralhospital.com',
        phone: '+1-415-555-1001',
        password: 'doctor123',
        role: 'doctor',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      User(
        id: 3,
        fullName: 'Dr. Michael Chen',
        email: 'michael.chen@citygeneralhospital.com',
        phone: '+1-415-555-1002',
        password: 'doctor123',
        role: 'doctor',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      User(
        id: 4,
        fullName: 'Dr. Emily Rodriguez',
        email: 'emily.rodriguez@stmarymedical.com',
        phone: '+1-213-555-1003',
        password: 'doctor123',
        role: 'doctor',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      User(
        id: 5,
        fullName: 'Dr. James Wilson',
        email: 'james.wilson@stmarymedical.com',
        phone: '+1-213-555-1004',
        password: 'doctor123',
        role: 'doctor',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      User(
        id: 6,
        fullName: 'Dr. Lisa Anderson',
        email: 'lisa.anderson@metrohealthclinic.com',
        phone: '+1-619-555-1005',
        password: 'doctor123',
        role: 'doctor',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      User(
        id: 7,
        fullName: 'Dr. David Thompson',
        email: 'david.thompson@metrohealthclinic.com',
        phone: '+1-619-555-1006',
        password: 'doctor123',
        role: 'doctor',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      User(
        id: 8,
        fullName: 'Dr. Rachel Kim',
        email: 'rachel.kim@riversidespecialty.com',
        phone: '+1-916-555-1007',
        password: 'doctor123',
        role: 'doctor',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      User(
        id: 9,
        fullName: 'Dr. Mark Davis',
        email: 'mark.davis@riversidespecialty.com',
        phone: '+1-916-555-1008',
        password: 'doctor123',
        role: 'doctor',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      User(
        id: 10,
        fullName: 'Dr. Jennifer Lee',
        email: 'jennifer.lee@coastalmedical.com',
        phone: '+1-831-555-1009',
        password: 'doctor123',
        role: 'doctor',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      User(
        id: 11,
        fullName: 'Dr. Robert Garcia',
        email: 'robert.garcia@coastalmedical.com',
        phone: '+1-831-555-1010',
        password: 'doctor123',
        role: 'doctor',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      
      // Patient users
      User(
        id: 12,
        fullName: 'John Smith',
        email: 'john.smith@email.com',
        phone: '+1-555-2001',
        password: 'patient123',
        role: 'patient',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      User(
        id: 13,
        fullName: 'Alice Brown',
        email: 'alice.brown@email.com',
        phone: '+1-555-2002',
        password: 'patient123',
        role: 'patient',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      User(
        id: 14,
        fullName: 'Robert Davis',
        email: 'robert.davis@email.com',
        phone: '+1-555-2003',
        password: 'patient123',
        role: 'patient',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      User(
        id: 15,
        fullName: 'Maria Martinez',
        email: 'maria.martinez@email.com',
        phone: '+1-555-2004',
        password: 'patient123',
        role: 'patient',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      User(
        id: 16,
        fullName: 'William Johnson',
        email: 'william.johnson@email.com',
        phone: '+1-555-2005',
        password: 'patient123',
        role: 'patient',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    for (var user in users) {
      await _db.createUser(user.toMap());
    }
    print('Demo users inserted: ${users.length}');
  }

  static Future<void> _insertDemoDoctors() async {
    final doctors = [
      // City General Hospital Doctors
      doctor_models.DoctorModel(
        id: 1,
        userId: 2,
        fullName: 'Dr. Sarah Johnson',
        specialization: 'Cardiology',
        licenseNumber: 'CA-CARD-001',
        hospitalId: 1,
        availableHours: 'Mon-Fri: 9:00 AM - 5:00 PM',
        consultationFee: 250.0,
        qualifications: 'MD, FACC, Fellowship in Interventional Cardiology',
        experienceYears: 12,
        rating: 4.8,
        totalRatings: 156,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      doctor_models.DoctorModel(
        id: 2,
        userId: 3,
        fullName: 'Dr. Michael Chen',
        specialization: 'Neurology',
        licenseNumber: 'CA-NEURO-002',
        hospitalId: 1,
        availableHours: 'Tue-Sat: 8:00 AM - 4:00 PM',
        consultationFee: 300.0,
        qualifications: 'MD, PhD in Neuroscience, Board Certified Neurologist',
        experienceYears: 15,
        rating: 4.9,
        totalRatings: 203,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      
      // St. Mary Medical Center Doctors
      doctor_models.DoctorModel(
        id: 3,
        userId: 4,
        fullName: 'Dr. Emily Rodriguez',
        specialization: 'Pediatrics',
        licenseNumber: 'CA-PED-003',
        hospitalId: 2,
        availableHours: 'Mon-Fri: 8:00 AM - 6:00 PM, Sat: 9:00 AM - 1:00 PM',
        consultationFee: 200.0,
        qualifications: 'MD, Board Certified Pediatrician, Subspecialty in Pediatric Cardiology',
        experienceYears: 8,
        rating: 4.7,
        totalRatings: 124,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      doctor_models.DoctorModel(
        id: 4,
        userId: 5,
        fullName: 'Dr. James Wilson',
        specialization: 'Orthopedics',
        licenseNumber: 'CA-ORTHO-004',
        hospitalId: 2,
        availableHours: 'Mon-Thu: 7:00 AM - 3:00 PM',
        consultationFee: 275.0,
        qualifications: 'MD, Fellowship in Sports Medicine, Board Certified Orthopedic Surgeon',
        experienceYears: 18,
        rating: 4.6,
        totalRatings: 189,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      
      // Metro Health Clinic Doctors
      doctor_models.DoctorModel(
        id: 5,
        userId: 6,
        fullName: 'Dr. Lisa Anderson',
        specialization: 'Dermatology',
        licenseNumber: 'CA-DERM-005',
        hospitalId: 3,
        availableHours: 'Wed-Sun: 10:00 AM - 6:00 PM',
        consultationFee: 180.0,
        qualifications: 'MD, Board Certified Dermatologist, Mohs Surgery Certified',
        experienceYears: 10,
        rating: 4.5,
        totalRatings: 98,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      doctor_models.DoctorModel(
        id: 6,
        userId: 7,
        fullName: 'Dr. David Thompson',
        specialization: 'General Practice',
        licenseNumber: 'CA-GP-006',
        hospitalId: 3,
        availableHours: 'Mon-Fri: 8:00 AM - 5:00 PM',
        consultationFee: 150.0,
        qualifications: 'MD, Board Certified Family Medicine, Preventive Care Specialist',
        experienceYears: 12,
        rating: 4.4,
        totalRatings: 87,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      
      // Riverside Specialty Hospital Doctors
      doctor_models.DoctorModel(
        id: 7,
        userId: 8,
        fullName: 'Dr. Rachel Kim',
        specialization: 'Gastroenterology',
        licenseNumber: 'CA-GI-007',
        hospitalId: 4,
        availableHours: 'Mon-Wed-Fri: 9:00 AM - 4:00 PM',
        consultationFee: 280.0,
        qualifications: 'MD, Fellowship in Advanced Endoscopy, Board Certified Gastroenterologist',
        experienceYears: 9,
        rating: 4.7,
        totalRatings: 67,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      doctor_models.DoctorModel(
        id: 8,
        userId: 9,
        fullName: 'Dr. Mark Davis',
        specialization: 'Psychiatry',
        licenseNumber: 'CA-PSY-008',
        hospitalId: 4,
        availableHours: 'Tue-Thu: 10:00 AM - 7:00 PM, Sat: 9:00 AM - 3:00 PM',
        consultationFee: 220.0,
        qualifications: 'MD, Board Certified Psychiatrist, Addiction Medicine Subspecialty',
        experienceYears: 14,
        rating: 4.6,
        totalRatings: 112,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      
      // Coastal Medical Center Doctors
      doctor_models.DoctorModel(
        id: 9,
        userId: 10,
        fullName: 'Dr. Jennifer Lee',
        specialization: 'Oncology',
        licenseNumber: 'CA-ONC-009',
        hospitalId: 5,
        availableHours: 'Mon-Fri: 8:00 AM - 5:00 PM',
        consultationFee: 350.0,
        qualifications: 'MD, Board Certified Medical Oncologist, Hematology Fellowship',
        experienceYears: 11,
        rating: 4.9,
        totalRatings: 234,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      doctor_models.DoctorModel(
        id: 10,
        userId: 11,
        fullName: 'Dr. Robert Garcia',
        specialization: 'Urology',
        licenseNumber: 'CA-URO-010',
        hospitalId: 5,
        availableHours: 'Mon-Thu: 7:00 AM - 4:00 PM, Fri: 8:00 AM - 2:00 PM',
        consultationFee: 265.0,
        qualifications: 'MD, Board Certified Urologist, Robotic Surgery Certified',
        experienceYears: 16,
        rating: 4.5,
        totalRatings: 143,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    for (var doctor in doctors) {
      await _db.database.then((db) => db.insert('doctors', doctor.toMap()));
    }
    print('Demo doctors inserted: ${doctors.length}');
  }

  static Future<void> _insertDemoPatients() async {
    // Create patient records with medical history
    final patients = [
      {
        'user_id': 12, // John Smith
        'emergency_contact': 'Jane Smith - +1-555-2011',
        'blood_group': 'O+',
        'allergies': 'Penicillin, Nuts',
        'medical_history': 'Hypertension, Diabetes Type 2',
        'insurance_details': 'Blue Cross Blue Shield - Policy: BC123456',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'user_id': 13, // Alice Brown
        'emergency_contact': 'Tom Brown - +1-555-2012',
        'blood_group': 'A-',
        'allergies': 'Shellfish',
        'medical_history': 'Asthma, Migraines',
        'insurance_details': 'Aetna Health - Policy: AE789012',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'user_id': 14, // Robert Davis
        'emergency_contact': 'Mary Davis - +1-555-2013',
        'blood_group': 'B+',
        'allergies': 'None',
        'medical_history': 'No significant medical history',
        'insurance_details': 'Kaiser Permanente - Policy: KP345678',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'user_id': 15, // Maria Martinez
        'emergency_contact': 'Carlos Martinez - +1-555-2014',
        'blood_group': 'AB+',
        'allergies': 'Latex, Codeine',
        'medical_history': 'Thyroid disorder, Anxiety',
        'insurance_details': 'Cigna Health - Policy: CG456789',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'user_id': 16, // William Johnson
        'emergency_contact': 'Linda Johnson - +1-555-2015',
        'blood_group': 'O-',
        'allergies': 'Sulfa drugs',
        'medical_history': 'High cholesterol, Arthritis',
        'insurance_details': 'United Healthcare - Policy: UH567890',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    final db = await _db.database;
    for (var patient in patients) {
      await db.insert('patients', patient);
    }
    print('Demo patients inserted: ${patients.length}');
  }

  static Future<void> createSampleAppointments() async {
    print('Creating sample appointments...');
    
    final sampleAppointments = [
      {
        'patient_id': 12, // John Smith
        'doctor_id': 1, // Dr. Sarah Johnson (Cardiology)
        'hospital_id': 1,
        'appointment_date': DateTime.now().add(Duration(days: 2)).toIso8601String(),
        'time_slot': '10:00 AM',
        'reason': 'Chest pain and shortness of breath',
        'status': 'scheduled',
        'token': 'TOK001',
        'notes': 'Patient reports intermittent chest pain for the past week',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'patient_id': 13, // Alice Brown
        'doctor_id': 3, // Dr. Emily Rodriguez (Pediatrics)
        'hospital_id': 2,
        'appointment_date': DateTime.now().add(Duration(days: 5)).toIso8601String(),
        'time_slot': '2:00 PM',
        'reason': 'Child wellness checkup',
        'status': 'scheduled',
        'token': 'TOK002',
        'notes': 'Annual checkup for 8-year-old daughter',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'patient_id': 14, // Robert Davis
        'doctor_id': 5, // Dr. Lisa Anderson (Dermatology)
        'hospital_id': 3,
        'appointment_date': DateTime.now().add(Duration(days: 1)).toIso8601String(),
        'time_slot': '11:30 AM',
        'reason': 'Skin rash examination',
        'status': 'confirmed',
        'token': 'TOK003',
        'notes': 'Persistent rash on arms and legs',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'patient_id': 15, // Maria Martinez
        'doctor_id': 8, // Dr. Mark Davis (Psychiatry)
        'hospital_id': 4,
        'appointment_date': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        'time_slot': '3:00 PM',
        'reason': 'Anxiety management consultation',
        'status': 'scheduled',
        'token': 'TOK004',
        'notes': 'Follow-up for anxiety treatment and medication review',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'patient_id': 16, // William Johnson
        'doctor_id': 4, // Dr. James Wilson (Orthopedics)
        'hospital_id': 2,
        'appointment_date': DateTime.now().add(Duration(days: 3)).toIso8601String(),
        'time_slot': '9:00 AM',
        'reason': 'Knee pain and mobility issues',
        'status': 'confirmed',
        'token': 'TOK005',
        'notes': 'Patient reports chronic knee pain affecting daily activities',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'patient_id': 12, // John Smith (second appointment)
        'doctor_id': 6, // Dr. David Thompson (General Practice)
        'hospital_id': 3,
        'appointment_date': DateTime.now().add(Duration(days: 10)).toIso8601String(),
        'time_slot': '11:00 AM',
        'reason': 'Annual physical examination',
        'status': 'scheduled',
        'token': 'TOK006',
        'notes': 'Routine annual checkup and health screening',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    final db = await _db.database;
    for (var appointment in sampleAppointments) {
      await db.insert('appointments', appointment);
    }
    print('Sample appointments created: ${sampleAppointments.length}');
  }

  static Future<void> createSampleNotifications() async {
    print('Creating sample notifications...');
    
    final sampleNotifications = [
      {
        'user_id': 12, // John Smith
        'title': 'Appointment Confirmed',
        'message': 'Your appointment with Dr. Sarah Johnson on ${DateTime.now().add(Duration(days: 2)).toString().split(' ')[0]} at 10:00 AM has been confirmed.',
        'type': 'appointment',
        'related_id': 1,
        'is_read': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'user_id': 13, // Alice Brown
        'title': 'Appointment Reminder',
        'message': 'Reminder: You have an appointment with Dr. Emily Rodriguez tomorrow at 2:00 PM.',
        'type': 'reminder',
        'related_id': 2,
        'is_read': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'user_id': 14, // Robert Davis
        'title': 'Test Results Available',
        'message': 'Your test results from Dr. Lisa Anderson are now available. Please log in to view them.',
        'type': 'results',
        'related_id': 3,
        'is_read': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    final db = await _db.database;
    for (var notification in sampleNotifications) {
      await db.insert('notifications', notification);
    }
    print('Sample notifications created: ${sampleNotifications.length}');
  }

  // Helper method to get demo credentials for quick testing
  static Map<String, List<Map<String, String>>> getDemoCredentials() {
    return {
      'admin': [
        {'email': 'admin@healthcare.com', 'password': 'admin123'},
      ],
      'doctors': [
        {'email': 'sarah.johnson@citygeneralhospital.com', 'password': 'doctor123', 'name': 'Dr. Sarah Johnson'},
        {'email': 'michael.chen@citygeneralhospital.com', 'password': 'doctor123', 'name': 'Dr. Michael Chen'},
        {'email': 'emily.rodriguez@stmarymedical.com', 'password': 'doctor123', 'name': 'Dr. Emily Rodriguez'},
        {'email': 'james.wilson@stmarymedical.com', 'password': 'doctor123', 'name': 'Dr. James Wilson'},
        {'email': 'lisa.anderson@metrohealthclinic.com', 'password': 'doctor123', 'name': 'Dr. Lisa Anderson'},
      ],
      'patients': [
        {'email': 'john.smith@email.com', 'password': 'patient123', 'name': 'John Smith'},
        {'email': 'alice.brown@email.com', 'password': 'patient123', 'name': 'Alice Brown'},
        {'email': 'robert.davis@email.com', 'password': 'patient123', 'name': 'Robert Davis'},
        {'email': 'maria.martinez@email.com', 'password': 'patient123', 'name': 'Maria Martinez'},
        {'email': 'william.johnson@email.com', 'password': 'patient123', 'name': 'William Johnson'},
      ],
    };
  }

  static Future<void> printDatabaseStats() async {
    final db = await _db.database;
    
    final hospitalCount = await db.query('hospitals').then((list) => list.length);
    final userCount = await db.query('users').then((list) => list.length);
    final doctorCount = await db.query('doctors').then((list) => list.length);
    final patientCount = await db.query('patients').then((list) => list.length);
    final appointmentCount = await db.query('appointments').then((list) => list.length);
    
    print('\n=== DATABASE STATISTICS ===');
    print('Hospitals: $hospitalCount');
    print('Users: $userCount');
    print('Doctors: $doctorCount');
    print('Patients: $patientCount');
    print('Appointments: $appointmentCount');
    print('===========================\n');
    
    // Print available specializations for testing
    final specializations = await db.rawQuery('''
      SELECT DISTINCT specialization, COUNT(*) as count 
      FROM doctors 
      WHERE is_active = 1 
      GROUP BY specialization 
      ORDER BY specialization
    ''');
    
    print('=== AVAILABLE SPECIALIZATIONS ===');
    for (var spec in specializations) {
      print('${spec['specialization']}: ${spec['count']} doctor(s)');
    }
    print('==================================\n');
  }
}
