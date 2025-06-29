class AppointmentModel {
  final int? id;
  final int patientId;
  final int doctorId;
  final int hospitalId;
  final DateTime appointmentDate;
  final String timeSlot;
  final String reason;
  final String status;
  final String? token;
  final String? notes;
  final double? rating;
  final String? feedback;
  final String? prescription;
  final String? followUpNotes;
  final bool isLocationVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.hospitalId,
    required this.appointmentDate,
    required this.timeSlot,
    required this.reason,
    this.status = 'scheduled',
    this.token,
    this.notes,
    this.rating,
    this.feedback,
    this.prescription,
    this.followUpNotes,
    this.isLocationVerified = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'hospital_id': hospitalId,
      'appointment_date': appointmentDate.toIso8601String(),
      'time_slot': timeSlot,
      'reason': reason,
      'status': status,
      'token': token,
      'notes': notes,
      'rating': rating,
      'feedback': feedback,
      'prescription': prescription,
      'follow_up_notes': followUpNotes,
      'is_location_verified': isLocationVerified ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'],
      patientId: map['patient_id'],
      doctorId: map['doctor_id'],
      hospitalId: map['hospital_id'],
      appointmentDate: DateTime.parse(map['appointment_date']),
      timeSlot: map['time_slot'],
      reason: map['reason'],
      status: map['status'] ?? 'scheduled',
      token: map['token'],
      notes: map['notes'],
      rating: map['rating']?.toDouble(),
      feedback: map['feedback'],
      prescription: map['prescription'],
      followUpNotes: map['follow_up_notes'],
      isLocationVerified: (map['is_location_verified'] ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  AppointmentModel copyWith({
    int? id,
    int? patientId,
    int? doctorId,
    int? hospitalId,
    DateTime? appointmentDate,
    String? timeSlot,
    String? reason,
    String? status,
    String? token,
    String? notes,
    double? rating,
    String? feedback,
    String? prescription,
    String? followUpNotes,
    bool? isLocationVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      hospitalId: hospitalId ?? this.hospitalId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeSlot: timeSlot ?? this.timeSlot,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      token: token ?? this.token,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      prescription: prescription ?? this.prescription,
      followUpNotes: followUpNotes ?? this.followUpNotes,
      isLocationVerified: isLocationVerified ?? this.isLocationVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AppointmentModel(id: $id, patientId: $patientId, doctorId: $doctorId, hospitalId: $hospitalId, appointmentDate: $appointmentDate, timeSlot: $timeSlot, reason: $reason, status: $status, token: $token, notes: $notes, rating: $rating, feedback: $feedback, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppointmentModel &&
        other.id == id &&
        other.patientId == patientId &&
        other.doctorId == doctorId &&
        other.hospitalId == hospitalId &&
        other.appointmentDate == appointmentDate &&
        other.timeSlot == timeSlot &&
        other.reason == reason &&
        other.status == status &&
        other.token == token &&
        other.notes == notes &&
        other.rating == rating &&
        other.feedback == feedback &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        patientId.hashCode ^
        doctorId.hashCode ^
        hospitalId.hashCode ^
        appointmentDate.hashCode ^
        timeSlot.hashCode ^
        reason.hashCode ^
        status.hashCode ^
        token.hashCode ^
        notes.hashCode ^
        rating.hashCode ^
        feedback.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
