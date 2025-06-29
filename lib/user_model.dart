class User {
  final int? id;
  final String email;
  final String password;
  final String fullName;
  final String? phone;
  final String role; // 'patient', 'doctor', 'admin'
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      fullName: map['full_name'],
      phone: map['phone'],
      role: map['role'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, fullName: $fullName, role: $role}';
  }
}

class DoctorModel {
  final int? id;
  final int userId;
  final String licenseNumber;
  final String specialization;
  final int? hospitalId;
  final int experienceYears;
  final double consultationFee;
  final String? biography;
  final String? availableDays;
  final String? availableHours;
  final double rating;
  final int totalRatings;
  final bool isVerified;
  final DateTime createdAt;

  // Additional fields from joins
  final String? fullName;
  final String? email;
  final String? phone;
  final String? hospitalName;
  final String? hospitalAddress;
  final String? hospitalCity;

  DoctorModel({
    this.id,
    required this.userId,
    required this.licenseNumber,
    required this.specialization,
    this.hospitalId,
    this.experienceYears = 0,
    this.consultationFee = 0.0,
    this.biography,
    this.availableDays,
    this.availableHours,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.isVerified = false,
    required this.createdAt,
    this.fullName,
    this.email,
    this.phone,
    this.hospitalName,
    this.hospitalAddress,
    this.hospitalCity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'license_number': licenseNumber,
      'specialization': specialization,
      'hospital_id': hospitalId,
      'experience_years': experienceYears,
      'consultation_fee': consultationFee,
      'biography': biography,
      'available_days': availableDays,
      'available_hours': availableHours,
      'rating': rating,
      'total_ratings': totalRatings,
      'is_verified': isVerified ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map['id'],
      userId: map['user_id'],
      licenseNumber: map['license_number'],
      specialization: map['specialization'],
      hospitalId: map['hospital_id'],
      experienceYears: map['experience_years'] ?? 0,
      consultationFee: (map['consultation_fee'] ?? 0.0).toDouble(),
      biography: map['biography'],
      availableDays: map['available_days'],
      availableHours: map['available_hours'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRatings: map['total_ratings'] ?? 0,
      isVerified: map['is_verified'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      fullName: map['full_name'],
      email: map['email'],
      phone: map['phone'],
      hospitalName: map['hospital_name'],
      hospitalAddress: map['address'],
      hospitalCity: map['city'],
    );
  }
}

class HospitalModel {
  final int? id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String? postalCode;
  final String? phone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  HospitalModel({
    this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    this.postalCode,
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory HospitalModel.fromMap(Map<String, dynamic> map) {
    return HospitalModel(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      city: map['city'],
      state: map['state'],
      postalCode: map['postal_code'],
      phone: map['phone'],
      email: map['email'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class AppointmentModel {
  final int? id;
  final int patientId;
  final int doctorId;
  final int hospitalId;
  final String appointmentDate;
  final String appointmentTime;
  final String status; // 'pending', 'approved', 'completed', 'cancelled', 'no_show'
  final String reason;
  final String? notes;
  final String? doctorNotes;
  final String token;
  final bool locationVerified;
  final double? patientLatitude;
  final double? patientLongitude;
  final DateTime? verificationTime;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Additional fields from joins
  final String? doctorName;
  final String? patientName;
  final String? patientPhone;
  final String? specialization;
  final String? hospitalName;
  final String? hospitalAddress;

  AppointmentModel({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.hospitalId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.reason,
    this.notes,
    this.doctorNotes,
    required this.token,
    this.locationVerified = false,
    this.patientLatitude,
    this.patientLongitude,
    this.verificationTime,
    required this.createdAt,
    this.updatedAt,
    this.doctorName,
    this.patientName,
    this.patientPhone,
    this.specialization,
    this.hospitalName,
    this.hospitalAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'hospital_id': hospitalId,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'status': status,
      'reason': reason,
      'notes': notes,
      'doctor_notes': doctorNotes,
      'token': token,
      'location_verified': locationVerified ? 1 : 0,
      'patient_latitude': patientLatitude,
      'patient_longitude': patientLongitude,
      'verification_time': verificationTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'],
      patientId: map['patient_id'],
      doctorId: map['doctor_id'],
      hospitalId: map['hospital_id'],
      appointmentDate: map['appointment_date'],
      appointmentTime: map['appointment_time'],
      status: map['status'],
      reason: map['reason'],
      notes: map['notes'],
      doctorNotes: map['doctor_notes'],
      token: map['token'],
      locationVerified: map['location_verified'] == 1,
      patientLatitude: map['patient_latitude']?.toDouble(),
      patientLongitude: map['patient_longitude']?.toDouble(),
      verificationTime: map['verification_time'] != null 
          ? DateTime.parse(map['verification_time']) 
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : null,
      doctorName: map['doctor_name'],
      patientName: map['patient_name'],
      patientPhone: map['patient_phone'],
      specialization: map['specialization'],
      hospitalName: map['hospital_name'],
      hospitalAddress: map['address'],
    );
  }
}

class AppointmentNotification {
  final int? id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  AppointmentNotification({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AppointmentNotification.fromMap(Map<String, dynamic> map) {
    return AppointmentNotification(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      message: map['message'],
      type: map['type'],
      isRead: map['is_read'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class Rating {
  final int? id;
  final int appointmentId;
  final int patientId;
  final int doctorId;
  final int rating; // 1-5 stars
  final String? review;
  final DateTime createdAt;

  Rating({
    this.id,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.rating,
    this.review,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'rating': rating,
      'review': review,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'],
      appointmentId: map['appointment_id'],
      patientId: map['patient_id'],
      doctorId: map['doctor_id'],
      rating: map['rating'],
      review: map['review'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
