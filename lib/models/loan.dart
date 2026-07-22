import 'package:facility_borrowing/models/facility.dart';
import 'package:facility_borrowing/models/profile.dart';

class Loan {
  final String id;
  final String userId;
  final String facilityId;
  final DateTime startDate;
  final DateTime endDate;
  final String purpose;
  final String status;
  final DateTime createdAt;

  // Optional relations
  final Profile? profile;
  final Facility? facility;

  Loan({
    required this.id,
    required this.userId,
    required this.facilityId,
    required this.startDate,
    required this.endDate,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.profile,
    this.facility,
  });

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      facilityId: map['facility_id'] as String,
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      purpose: map['purpose'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at']),
      profile: map['profiles'] != null ? Profile.fromMap(map['profiles']) : null,
      facility: map['facilities'] != null ? Facility.fromMap(map['facilities']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'facility_id': facilityId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'purpose': purpose,
      'status': status,
    };
  }
}
