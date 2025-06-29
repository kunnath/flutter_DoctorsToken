class HospitalModel {
  final int id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String phoneNumber;
  final String email;
  final double latitude;
  final double longitude;
  final String facilities;
  final String operatingHours;
  final bool isActive;
  final DateTime createdAt;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.phoneNumber,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.facilities,
    required this.operatingHours,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'postal_code': pinCode,
      'phone': phoneNumber,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'facilities': facilities,
      'operating_hours': operatingHours,
      'is_active': isActive ? 1 : 0,
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
      pinCode: map['postal_code'],
      phoneNumber: map['phone'],
      email: map['email'],
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      facilities: map['facilities'] ?? '',
      operatingHours: map['operating_hours'] ?? '',
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
