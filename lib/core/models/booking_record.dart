import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRecord {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String serviceType;
  final DateTime bookingDate;
  final String bookingTime;
  final String status; // e.g. pending, approved, declined
  final DateTime createdAt;

  BookingRecord({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.serviceType,
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'serviceType': serviceType,
        'bookingDate': bookingDate.toIso8601String(),
        'bookingTime': bookingTime,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
