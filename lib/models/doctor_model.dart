class DoctorModel {
  final int id;
  final int userId;
  final String fullName;
  final String specialization;
  final String licenseNumber;
  final int hospitalId;
  final String availableHours;
  final double consultationFee;
  final String qualifications;
  final int experienceYears;
  final double rating;
  final int totalRatings;
  final bool isActive;
  final DateTime createdAt;

  DoctorModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.specialization,
    required this.licenseNumber,
    required this.hospitalId,
    required this.availableHours,
    required this.consultationFee,
    required this.qualifications,
    required this.experienceYears,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'specialization': specialization,
      'license_number': licenseNumber,
      'hospital_id': hospitalId,
      'available_hours': availableHours,
      'consultation_fee': consultationFee,
      'qualifications': qualifications,
      'experience_years': experienceYears,
      'rating': rating,
      'total_ratings': totalRatings,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map['id'],
      userId: map['user_id'],
      fullName: map['full_name'] ?? map['name'] ?? 'Unknown Doctor',
      specialization: map['specialization'],
      licenseNumber: map['license_number'],
      hospitalId: map['hospital_id'],
      availableHours: map['available_hours'] ?? 'Not specified',
      consultationFee: (map['consultation_fee'] ?? 0.0).toDouble(),
      qualifications: map['qualifications'] ?? 'Not specified',
      experienceYears: map['experience_years'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRatings: map['total_ratings'] ?? 0,
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
